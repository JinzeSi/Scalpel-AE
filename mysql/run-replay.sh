#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/run-common.sh"

archive=${MYSQL_ANALYSIS_ARCHIVE:-/data/sjz/commit-analysis/mysql-run/brk-5-5}
selected=(
    cd66c5cd5ed4d0974a63cbf3e7ab6e8953613777
    c17d86b8f14b1a79fc1b95f0e3084c17a3aa62ad
    0fa789a93f69a4e503095fe6ab29dac0d11bbacb
    6ba1fef58b043ac5e9657ded777d20619b9b2f4e
)
if (( $# )); then
    selected=("$@")
fi
repo="$MYSQL_RUN_ROOT/mysql-server"
exec 9>"$MYSQL_RUN_ROOT/.run_auto.lock"
flock -n 9 || { echo "Another MySQL run is active." >&2; exit 1; }
[[ -z "$(git -C "$repo" status --porcelain --untracked-files=no)" ]] || {
    echo "mysql-server has local source edits; preserve them before replay." >&2; exit 1;
}
for dependency in cmake make clang-format python3 s2e timeout; do
    command -v "$dependency" >/dev/null || { echo "Missing command: $dependency" >&2; exit 1; }
done
for index in "${!selected[@]}"; do
    commit=$(git -C "$repo" rev-parse --verify "${selected[$index]}^{commit}")
    selected[$index]=$commit
    parent=$(git -C "$repo" rev-parse "$commit^1")
    for analysis_file in getFuncName-ini.txt new_function.txt getFuncName.txt call_analyse.txt symbolic_analyse.txt call_analyse2.txt; do
        [[ -r "$archive/$commit/$analysis_file" ]] || {
            echo "Missing archived analysis: $archive/$commit/$analysis_file" >&2; exit 1;
        }
    done
    [[ -s "$archive/$commit/call_analyse2.txt" ]] || exit 1
    for result_dir in "$MYSQL_RUN_ROOT/$commit" "$MYSQL_RUN_ROOT/$parent-old"; do
        [[ ! -e "$result_dir" ]] || { echo "Existing result: $result_dir" >&2; exit 1; }
    done
done

run_dir=$(mktemp -d "$MYSQL_RUN_ROOT/replay-$(date +%Y%m%d-%H%M%S).XXXXXX")
printf '%s\n' "$MYSQL_RUN_ROOT" > "$run_dir/results-root.txt"
printf '%s\n' "${selected[@]}" > "$run_dir/commits.txt"
cp "$MYSQL_RUN_ROOT/make_symbolic-NULLEND.sh" "$MYSQL_RUN_ROOT/run-common.sh" \
    "$MYSQL_RUN_ROOT/run-mysql.sh" "$MYSQL_RUN_ROOT/bootstrap.sh" \
    "$MYSQL_RUN_ROOT/get-sql-times.py" "$MYSQL_RUN_ROOT/sql-times.txt" \
    "$MYSQL_RUN_ROOT/generate_perf_report.py" "$0" "$run_dir/"
printf 'commit\tparent\texit_status\telapsed_seconds\n' > "$run_dir/status.tsv"
echo "Replay logs: $run_dir; results remain under $MYSQL_RUN_ROOT"
overall=0
for commit in "${selected[@]}"; do
    parent=$(git -C "$repo" rev-parse "$commit^1")
    started=$SECONDS
    printf '%s START %s (parent %s)\n' "$(date -Is)" "$commit" "$parent"
    status=0
    MYSQL_ANALYSIS_DIR="$archive/$commit" bash "$MYSQL_RUN_ROOT/make_symbolic-NULLEND.sh" "$parent" "$commit" \
        9>&- > "$run_dir/$commit.log" 2>&1 || status=$?
    # The worktree was clean on entry; retain this run's instrumentation before restoring it.
    git -C "$repo" diff > "$run_dir/$commit.instrumentation.patch"
    git -C "$repo" restore .
    elapsed=$((SECONDS - started))
    if [[ -d "$MYSQL_RUN_ROOT/$commit" ]]; then
        printf 'commit\tparent\texit_status\telapsed_seconds\trun_dir\n%s\t%s\t%s\t%s\t%s\n' \
            "$commit" "$parent" "$status" "$elapsed" "$run_dir" > "$MYSQL_RUN_ROOT/$commit/run-status.tsv"
    fi
    printf '%s\t%s\t%s\t%s\n' "$commit" "$parent" "$status" "$elapsed" >> "$run_dir/status.tsv"
    printf '%s END %s exit=%s\n' "$(date -Is)" "$commit" "$status"
    (( status == 0 )) || overall=1
done
printf '%s\n' "$overall" > "$run_dir/exit-status.txt"
echo "Replay finished: $run_dir/status.tsv"
printf 'Generate reports: python3 %s/generate_perf_report.py\n' "$MYSQL_RUN_ROOT"
exit "$overall"
