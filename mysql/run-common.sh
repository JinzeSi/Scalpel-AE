#!/bin/bash

MYSQL_RUN_ROOT=/data3/sjz/AE/mysql
PREKNOWLEDGE_DIR=/data2/sjz/Pre-knowledge-mysql
COMMIT_FILE=${MYSQL_COMMIT_FILE:-"$MYSQL_RUN_ROOT/commit-tmp.txt"}
INITIAL_COMMIT=27cd03548955749bd18c30e0e96ea798937375f0
PREKNOWLEDGE_READY="${MYSQL_PEER_RUN_DIR:-$MYSQL_RUN_ROOT}/preknowledge.ready"
PREKNOWLEDGE_WAIT_SECONDS=${PREKNOWLEDGE_WAIT_SECONDS:-0}

prepare_build_dirs() {
    # Copied build directories retain absolute paths to the previous checkout.
    mkdir -p "$MYSQL_RUN_ROOT"/mysql-server/{build-ae-new-tmp,build-ae-old-tmp,build-ae-new,build-ae-old} \
        "$MYSQL_RUN_ROOT"/mysql-server-2/{build-ae-tmp,build-ae-bc-new,build-ae-bc-old}
}

relocate_analysis_paths() {
    # Validation inputs can contain absolute source paths from an earlier run.
    sed -i -E "s@/(data|nvme)/sjz/commit-analysis/mysql-run/@$MYSQL_RUN_ROOT/@g" "$1"
}

load_commits() {
    [[ -r "$COMMIT_FILE" ]] || { echo "Missing commit list: $COMMIT_FILE" >&2; return 1; }
    mapfile -t commits < "$COMMIT_FILE"
    [[ ${#commits[@]} -gt 0 ]] || return 1
    local commit
    for commit in "${commits[@]}"; do
        [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || {
            echo "Invalid commit in $COMMIT_FILE: $commit" >&2
            return 1
        }
    done
    [[ "$PREKNOWLEDGE_WAIT_SECONDS" =~ ^(0|[1-9][0-9]*)$ ]] || return 1
    COMMIT_DIGEST=$(sha256sum "$COMMIT_FILE") || return 1
    COMMIT_DIGEST=${COMMIT_DIGEST%% *}
}

check_main_inputs() {
    local missing=0 item repo previous parents build source_dir cached_source cached_build
    for item in mysql-server/.git mysql-server-2/.git mysql-server/boost_1_77_0 mysql-server-2/boost_1_77_0 tool; do
        if [[ ! -d "$MYSQL_RUN_ROOT/$item" ]]; then
            echo "Missing directory: $MYSQL_RUN_ROOT/$item" >&2
            missing=1
        fi
    done
    for item in .clang-format new_function_analyzer.sh new_function_combiner.py commit_analyzer++ call_analyzer++ symbolic_analyzer++ make_symbolizer++ real_executor++ jsonAnalyze jsonAnalyze-icount get_redis_1 get_redis_2 redis-order.txt; do
        if [[ ! -r "$MYSQL_RUN_ROOT/tool/$item" ]]; then
            echo "Missing tool: $MYSQL_RUN_ROOT/tool/$item" >&2
            missing=1
        fi
    done
    for item in new_function_analyzer.sh commit_analyzer++ call_analyzer++ symbolic_analyzer++ make_symbolizer++ real_executor++ jsonAnalyze jsonAnalyze-icount; do
        if [[ -r "$MYSQL_RUN_ROOT/tool/$item" && ! -x "$MYSQL_RUN_ROOT/tool/$item" ]]; then
            echo "Tool is not executable: $MYSQL_RUN_ROOT/tool/$item" >&2
            missing=1
        fi
    done
    for item in git cmake make python3 timeout flock s2e; do
        if ! command -v "$item" >/dev/null; then
            echo "Command unavailable (activate the required environment): $item" >&2
            missing=1
        fi
    done
    for item in "$PREKNOWLEDGE_DIR/mysql-link/link.py" \
        "$MYSQL_RUN_ROOT/run-selection.py" \
        "$MYSQL_RUN_ROOT/get-sql-times.py" \
        "$MYSQL_RUN_ROOT/sql-times.txt" \
        /data/sjz/llvm-18.1.8/bin/clang \
        /data/sjz/llvm-18.1.8/bin/clang++ \
        /data/sjz/llvm-18.1.8/bin/llvm-link \
        /data/sjz/commit-analysis/llvm-analysis/tools/include/symbolic.h \
        /data/sjz/commit-analysis/llvm-analysis/tools/lib/libsymbolic.so \
        /data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz \
        /data/sjz/commit-analysis/mysql-8.4.4/build/bin/mysqlslap \
        /home/sjz/S2E/s2e/projects/mysqld/launch-s2e.sh; do
        if [[ ! -r "$item" ]]; then
            echo "Missing dependency: $item" >&2
            missing=1
        fi
    done
    [[ "$missing" -eq 0 ]] || return 1
    for repo in mysql-server mysql-server-2; do
        source_dir="$MYSQL_RUN_ROOT/$repo"
        [[ "$(realpath "$source_dir")" == "$source_dir" ]] || {
            echo "Use an independent checkout, not a link to the old directory: $source_dir" >&2
            return 1
        }
        previous=$INITIAL_COMMIT
        for item in "${commits[@]}"; do
            parents=$(git -C "$source_dir" show -s --format=%P "$item") || return 1
            [[ "${parents%% *}" == "$previous" ]] || {
                echo "Non-contiguous first-parent chain: $previous -> $item" >&2
                return 1
            }
            previous=$item
        done
        for build in "$source_dir"/build-ae-*; do
            [[ -f "$build/CMakeCache.txt" ]] || continue
            cached_source=$(sed -n 's/^CMAKE_HOME_DIRECTORY:INTERNAL=//p' "$build/CMakeCache.txt")
            cached_build=$(sed -n 's/^CMAKE_CACHEFILE_DIR:INTERNAL=//p' "$build/CMakeCache.txt")
            [[ "$cached_source" == "$source_dir" && "$cached_build" == "$build" ]] || {
                echo "CMake cache belongs to another source tree: $build. Use a fresh build directory." >&2
                return 1
            }
        done
    done
}

check_preknowledge_source() {
    local repo=$1 allow_template=${2:-0} status changed template
    status=$(git -C "$repo" status --porcelain --untracked-files=no) || return 1
    [[ -n "$status" ]] || return 0
    changed=$(git -C "$repo" diff --name-only HEAD) || return 1
    if [[ "$allow_template" == 1 && "$changed" == sql/sql_parse.cc ]] && git -C "$repo" diff --cached --quiet; then
        for template in "$PREKNOWLEDGE_DIR/sql_parse/sql_parse-$INITIAL_COMMIT.cc" \
            "$PREKNOWLEDGE_DIR/sql_parse/sql_parse-e3c9955d236ac19bae4674fea46576aeb41e0d90.cc"; do
            if cmp -s "$repo/sql/sql_parse.cc" "$template"; then
                echo "Pre-knowledge source contains its saved instrumentation template: $repo"
                return 0
            fi
        done
    fi
    echo "Preserve existing source edits before running Pre-knowledge: $repo" >&2
    return 1
}

check_preknowledge_inputs() {
    local seed="$PREKNOWLEDGE_DIR/mysql-BB/init_file_$INITIAL_COMMIT" input repo objects
    for input in "$seed/mysql-BB-res-2.txt" "$seed/mysql-BB-res-3.txt" \
        "$PREKNOWLEDGE_DIR/sql_parse/sql_parse-$INITIAL_COMMIT.cc" \
        "$PREKNOWLEDGE_DIR/sql_parse/sql_parse-e3c9955d236ac19bae4674fea46576aeb41e0d90.cc" \
        "$PREKNOWLEDGE_DIR/mysql-order-priority.txt" "$PREKNOWLEDGE_DIR/updateCommit-new-mysql.sh" \
        "$PREKNOWLEDGE_DIR/demo-1-mysql.sh" "$PREKNOWLEDGE_DIR/demo-2-mysql.sh" \
        "$PREKNOWLEDGE_DIR/mysql-data/tables.tar.gz" "$PREKNOWLEDGE_DIR/mysql-link/link.py" \
        "$PREKNOWLEDGE_DIR/dup_S2E_case.py" "$PREKNOWLEDGE_DIR/dup_S2E_case-1.py"; do
        [[ -r "$input" ]] || { echo "Missing Pre-knowledge input: $input" >&2; return 1; }
    done
    for input in gitshow-mysql getBB-mysql update_KeyValue_hashTable-mysql2 \
        generate_S2E_case-mysql2 generate_S2E_case-2 get_BB_hashTable-mysql \
        build_BB_hashTable-mysql build_KeyValue_hashTable-mysql; do
        [[ -x "$PREKNOWLEDGE_DIR/$input" ]] || { echo "Missing Pre-knowledge tool: $input" >&2; return 1; }
    done
    for input in /data/sjz/llvm-project/build2/bin/{clang,clang++,llvm-link,llvm-dis,llvm-symbolizer} \
        /data2/sjz/llvm-sjz/llvm-project/build/bin/llvm-dis; do
        [[ -x "$input" ]] || { echo "Missing Pre-knowledge compiler: $input" >&2; return 1; }
    done
    [[ -d /data/sjz/commit-analysis/mysql-run/mysql-server/boost_1_77_0 ]] || return 1
    for repo in /data2/sjz/mysql/mysql-server /data2/sjz/mysql/mysql-server-2; do
        [[ -d "$repo/.git" ]] || { echo "Missing Pre-knowledge source: $repo" >&2; return 1; }
        if [[ "$repo" == /data2/sjz/mysql/mysql-server ]]; then
            check_preknowledge_source "$repo" 1 || return 1
        else
            check_preknowledge_source "$repo" || return 1
        fi
        objects=$(printf '%s\n' "$INITIAL_COMMIT" "${commits[@]}" | git -C "$repo" cat-file --batch-check='%(objecttype)') || return 1
        [[ "${objects//commit/}" != *[!$'\n']* ]] || {
            echo "Missing Git commits in Pre-knowledge source: $repo" >&2; return 1;
        }
    done
    for input in /data2/sjz/mysql/mysql-server/build1 /data2/sjz/mysql/mysql-server/build4 \
        /data2/sjz/mysql/mysql-server-2/build; do
        [[ -d "$input" ]] || { echo "Missing Pre-knowledge build directory: $input" >&2; return 1; }
    done
}

require_peer_run() {
    [[ -n "${MYSQL_PEER_RUN_DIR:-}" && -d "$MYSQL_PEER_RUN_DIR/replies" && -d "$MYSQL_PEER_RUN_DIR/ack" ]] || {
        echo "Use run_all.sh to start MySQL and live Pre-knowledge together." >&2; return 1;
    }
    [[ ! -f "$MYSQL_PEER_RUN_DIR/cancel.json" ]] || { echo "The paired run was cancelled." >&2; return 1; }
}

peer_is_ready() {
    local peer_pid peer_digest peer_base
    [[ -r "$PREKNOWLEDGE_READY" ]] || return 1
    read -r peer_pid peer_digest peer_base < "$PREKNOWLEDGE_READY" || return 1
    [[ "$peer_pid" =~ ^[1-9][0-9]*$ ]] || return 1
    [[ "$peer_digest" == "$COMMIT_DIGEST" && "$peer_base" == "$INITIAL_COMMIT" ]] || return 1
    kill -0 "$peer_pid" 2>/dev/null
}

wait_for_preknowledge() {
    require_peer_run || return 1
    local started=$SECONDS
    echo "Waiting for run-preknowledge.sh with the same commit list..."
    until peer_is_ready; do
        [[ ! -e "$MYSQL_PEER_RUN_DIR/preknowledge.exit-status.txt" && ! -e "$MYSQL_PEER_RUN_DIR/cancel.json" ]] || {
            echo "Pre-knowledge exited before becoming ready." >&2; return 1;
        }
        if (( PREKNOWLEDGE_WAIT_SECONDS > 0 && SECONDS - started >= PREKNOWLEDGE_WAIT_SECONDS )); then
            echo "Pre-knowledge did not become ready before the timeout." >&2
            return 1
        fi
        sleep 3
    done
}

request_preknowledge() {
    require_peer_run || return 1
    local started=$SECONDS
    local request="$PREKNOWLEDGE_DIR/demo-S2E-times-res-2.txt"
    local flag="$PREKNOWLEDGE_DIR/demo-S2E-times-res-3-flag.txt"
    local reply="$MYSQL_PEER_RUN_DIR/replies/$command_now.txt"
    peer_is_ready || { echo "Pre-knowledge stopped or its commit list differs." >&2; return 1; }
    [[ ! -e "$reply" && ! -e "$flag" ]] || { echo "Duplicate or pending Pre-knowledge request." >&2; return 1; }
    rm -f -- call_analyse2.txt || return 1
    # Publish complete inputs before the peer sees the flag.
    cp call_analyse.txt "$request.tmp.$$" || return 1
    mv -f -- "$request.tmp.$$" "$request" || return 1
    printf '%s\n' "$command_now" > "$MYSQL_PEER_RUN_DIR/request-commit.txt.tmp.$$" || return 1
    mv -f -- "$MYSQL_PEER_RUN_DIR/request-commit.txt.tmp.$$" "$MYSQL_PEER_RUN_DIR/request-commit.txt" || return 1
    cp symbolic_analyse.txt "$flag.tmp.$$" || return 1
    mv -f -- "$flag.tmp.$$" "$flag" || return 1
    # The peer publishes a complete reply atomically under this run and commit.
    until [[ -f "$reply" ]]; do
        if (( PREKNOWLEDGE_WAIT_SECONDS > 0 && SECONDS - started >= PREKNOWLEDGE_WAIT_SECONDS )); then
            echo "Timed out waiting for Pre-knowledge for $command_now." >&2
            return 1
        fi
        # The last reply can be published just as the peer removes its ready file.
        peer_is_ready || [[ -f "$reply" ]] || {
            echo "Pre-knowledge exited without a complete reply." >&2; return 1;
        }
        [[ ! -e "$MYSQL_PEER_RUN_DIR/cancel.json" ]] || return 1
        sleep 3
    done
    cp -- "$reply" call_analyse2.txt || return 1
    touch "$MYSQL_PEER_RUN_DIR/ack/$command_now" || return 1
    echo "$command_now: Received live Pre-knowledge reply: $reply"
}

wait_for_preknowledge_completion() {
    local status_file="$MYSQL_PEER_RUN_DIR/preknowledge.exit-status.txt"
    until [[ -f "$status_file" ]]; do
        [[ ! -e "$MYSQL_PEER_RUN_DIR/cancel.json" ]] || return 1
        sleep 1
    done
    [[ "$(cat "$status_file")" == 0 ]] || { echo "Pre-knowledge failed; confirmation will not start." >&2; return 1; }
}
