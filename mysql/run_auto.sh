#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/run-common.sh"

confirm_after_run=0
check_only=0
while (( $# )); do
    case "$1" in
        --confirm) confirm_after_run=1 ;;
        --check) check_only=1 ;;
        -h|--help)
            printf '%s\n' 'Usage: bash run_auto.sh [--confirm] [--check]' \
                'Run every commit in commit-tmp.txt (135 by default).' \
                '--confirm: regenerate reports from this run, then confirm its candidates.' \
                '--check: read-only input, environment, source and lock checks; do not run.'
            exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done
if (( check_only )); then
    export GIT_OPTIONAL_LOCKS=0
fi
confirm_scripts=(run-report.sh confirm_perf_reports.py mysql_validation.py)
if (( confirm_after_run )); then
    for script in "${confirm_scripts[@]}"; do
        [[ -r "$MYSQL_RUN_ROOT/$script" ]] || { echo "Missing confirmation script: $script" >&2; exit 1; }
    done
fi

[[ -z "${MYSQL_ANALYSIS_DIR:-}" ]] || {
    echo "run_auto.sh recomputes analysis; use run-replay.sh for full archived-analysis replay." >&2
    exit 1
}
load_commits
printf 'Input: %s (%s commits)\n' "$COMMIT_FILE" "${#commits[@]}"
check_main_inputs
check_preknowledge_inputs
cd "$MYSQL_RUN_ROOT"
if (( check_only )); then
    if [[ -e "$MYSQL_RUN_ROOT/.run_auto.lock" ]]; then
        exec 9< "$MYSQL_RUN_ROOT/.run_auto.lock"
        flock -n 9 || { echo "Another process holds .run_auto.lock." >&2; exit 1; }
    fi
else
    exec 9> "$MYSQL_RUN_ROOT/.run_auto.lock"
    flock -n 9 || { echo "This run_auto.sh is already running." >&2; exit 1; }
fi
for repo in mysql-server mysql-server-2; do
    [[ -z "$(git -C "$MYSQL_RUN_ROOT/$repo" status --porcelain --untracked-files=no)" ]] || {
        echo "Preserve existing source edits before running: $MYSQL_RUN_ROOT/$repo" >&2
        exit 1
    }
done
if (( check_only )); then
    printf 'Preflight passed for %s commits. No experiments started or files changed.\n' "${#commits[@]}"
    exit 0
fi
require_peer_run
wait_for_preknowledge
prepare_build_dirs

run_dir=$(mktemp -d "$MYSQL_RUN_ROOT/full-$(date +%Y%m%d-%H%M%S).XXXXXX")
mkdir "$run_dir/previous-results"
printf '%s\n' "$MYSQL_RUN_ROOT" > "$run_dir/results-root.txt"
cp "$COMMIT_FILE" "$run_dir/commits.txt"
cp "$MYSQL_RUN_ROOT/"{run_auto.sh,run-common.sh,make_symbolic-NULLEND.sh,run-mysql.sh,get-sql-times.py,sql-times.txt,bootstrap.sh,run-getres.sh,run-getres.py,run-getres-modify.py,run-getres-icount.py,generate_perf_report.py} "$run_dir/"
if (( confirm_after_run )); then
    for script in "${confirm_scripts[@]}"; do
        cp -- "$MYSQL_RUN_ROOT/$script" "$run_dir/"
    done
fi
printf 'preknowledge=%s\npaired_run=%s\ninitial_commit=%s\ncommit_digest=%s\n' "$PREKNOWLEDGE_DIR" "$MYSQL_PEER_RUN_DIR" "$INITIAL_COMMIT" "$COMMIT_DIGEST" > "$run_dir/run-input.txt"
printf '%s\n' "$run_dir" > "$MYSQL_PEER_RUN_DIR/mysql-run-dir.txt"
printf 'commit\tparent\texit_status\telapsed_seconds\n' > "$run_dir/status.tsv"
printf 'Full run logs: %s\nResults remain under: %s\n' "$run_dir" "$MYSQL_RUN_ROOT"
overall=0
last_commit=$INITIAL_COMMIT
for commit in "${commits[@]}"; do
    for result_dir in "$MYSQL_RUN_ROOT/$commit" "$MYSQL_RUN_ROOT/$last_commit-old"; do
        if [[ -e "$result_dir" || -L "$result_dir" ]]; then
            mv -- "$result_dir" "$run_dir/previous-results/"
        fi
    done
    start_time=$(date +%s)
    printf '%s start: %s\n' "$commit" "$(date)" >> time-tall.txt
    printf '%s START %s (parent %s)\n' "$(date -Is)" "$commit" "$last_commit"
    status=0
    # Keep the lock in this driver; background S2E children must not inherit it.
    bash "$MYSQL_RUN_ROOT/make_symbolic-NULLEND.sh" "$last_commit" "$commit" 9>&- > "$run_dir/$commit.log" 2>&1 || status=$?
    elapsed=$(( $(date +%s) - start_time ))
    if (( status != 0 )); then
        printf '%s failed (exit %s); continuing with the next commit.\n' "$commit" "$status" | tee -a time-tall.txt >&2
        overall=1
    else
        printf '%s completed in %s seconds\n' "$commit" "$elapsed" >> time-tall.txt
    fi
    # Both worktrees were clean at startup; retain and clear this run's source edits.
    for repo in mysql-server mysql-server-2; do
        git -C "$MYSQL_RUN_ROOT/$repo" diff --binary > "$run_dir/$commit.$repo.patch"
        git -C "$MYSQL_RUN_ROOT/$repo" restore .
    done
    if [[ -d "$MYSQL_RUN_ROOT/$commit" ]]; then
        printf 'commit\tparent\texit_status\telapsed_seconds\trun_dir\n%s\t%s\t%s\t%s\t%s\n' \
            "$commit" "$last_commit" "$status" "$elapsed" "$run_dir" > "$MYSQL_RUN_ROOT/$commit/run-status.tsv"
    fi
    printf '%s\t%s\t%s\t%s\n' "$commit" "$last_commit" "$status" "$elapsed" >> "$run_dir/status.tsv"
    printf '%s END %s exit=%s\n' "$(date -Is)" "$commit" "$status"
    if [[ ! -f "$MYSQL_PEER_RUN_DIR/ack/$commit" ]]; then
        echo "No completed Pre-knowledge exchange for $commit; stopping to prevent commit misalignment." >&2
        printf '1\n' > "$run_dir/exit-status.txt"
        exit 1
    fi
    last_commit=$commit
done
wait_for_preknowledge_completion
printf '%s\n' "$overall" > "$run_dir/exit-status.txt"
printf 'Full run finished: %s/status.tsv\n' "$run_dir"
printf 'Generate reports: python3 %s/generate_perf_report.py\n' "$MYSQL_RUN_ROOT"
if (( confirm_after_run )); then
    # Confirmation acquires the same lock itself after the first round finishes.
    exec 9>&-
    confirm_status=0
    printf 'Screening and confirming this run; log: %s/confirmation.log\n' "$run_dir"
    bash "$MYSQL_RUN_ROOT/run-report.sh" --run-dir "$run_dir" --execute \
        2>&1 | tee "$run_dir/confirmation.log" || confirm_status=$?
    printf '%s\n' "$confirm_status" > "$run_dir/confirmation-exit-status.txt"
    (( confirm_status == 0 )) || overall=1
    printf '%s\n' "$overall" > "$run_dir/workflow-exit-status.txt"
fi
exit "$overall"
