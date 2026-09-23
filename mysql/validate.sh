#!/bin/bash
set -euo pipefail
if (( $# < 3 )); then
    printf 'Usage: bash validate.sh PARENT COMMIT CASE [--execute] [confirm options]\n' >&2
    exit 2
fi
parent=$1
commit=$2
testcase=$3
shift 3
[[ "$parent" =~ ^[0-9a-f]{40}$ && "$commit" =~ ^[0-9a-f]{40}$ && "$testcase" =~ ^[1-9][0-9]*$ ]] || {
    printf 'Expected full commit hashes and a positive testcase number.\n' >&2
    exit 2
}
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec python3 "$script_dir/confirm_perf_reports.py" --case "$commit-$testcase" --expected-parent "$parent" "$@"
