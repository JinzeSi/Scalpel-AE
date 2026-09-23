#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/run-common.sh"
export GIT_OPTIONAL_LOCKS=0
load_commits
check_preknowledge_inputs
for dependency in git cmake make python3 sancov; do
    command -v "$dependency" >/dev/null || { echo "Missing Pre-knowledge command: $dependency" >&2; exit 1; }
done
if [[ "${1:-}" == --check && $# == 1 ]]; then
    echo "Pre-knowledge inputs and invoking environment checked; no experiments started."
    exit 0
fi
[[ $# == 0 ]] || { echo "Usage: run-preknowledge.sh [--check]" >&2; exit 2; }
require_peer_run
exec 9> "$PREKNOWLEDGE_DIR/.mysql-ae-peer.lock"
flock -n 9 || { echo "The AE Pre-knowledge worker is already running." >&2; exit 1; }
finish_peer() {
    local status=$?
    rm -f -- "$PREKNOWLEDGE_READY"
    printf '%s\n' "$status" > "$MYSQL_PEER_RUN_DIR/preknowledge.exit-status.txt.tmp.$$"
    mv -f -- "$MYSQL_PEER_RUN_DIR/preknowledge.exit-status.txt.tmp.$$" "$MYSQL_PEER_RUN_DIR/preknowledge.exit-status.txt"
}
trap finish_peer EXIT
cd "$PREKNOWLEDGE_DIR"
for pending in demo-S2E-times-res-3-flag.txt build_KeyValue_hashTable.txt; do
    [[ ! -e "$pending" ]] || { echo "Unresolved Pre-knowledge handshake file: $pending" >&2; exit 1; }
done
seed="$PREKNOWLEDGE_DIR/mysql-BB/init_file_$INITIAL_COMMIT"
sed -n '1~2p' mysql-order-priority.txt > mysql-order.txt
cp -- "sql_parse/sql_parse-$INITIAL_COMMIT.cc" sql_parse/sql_parse.cc
cp -- "$seed/mysql-BB-res-2.txt" mysql-BB-res-2-new.txt
cp -- "$seed/mysql-BB-res-3.txt" mysql-BB-res-3-new.txt
printf '%s %s %s\n' "$$" "$COMMIT_DIGEST" "$INITIAL_COMMIT" > "$PREKNOWLEDGE_READY.tmp.$$"
mv -f -- "$PREKNOWLEDGE_READY.tmp.$$" "$PREKNOWLEDGE_READY"

# Keep the lock in this wrapper; native/background children must not inherit it.
bash -e ./updateCommit-new-mysql.sh "$COMMIT_FILE" 9>&-
