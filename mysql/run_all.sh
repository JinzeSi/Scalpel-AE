#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec python3 -B -u "$root/run_pipeline.py" "$@"
