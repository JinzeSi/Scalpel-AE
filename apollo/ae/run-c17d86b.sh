#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[ "$#" -le 1 ] || { echo "Usage: $0 [DURATION]" >&2; exit 2; }
exec "$SCRIPT_DIR/run-mysql-commit.sh" c17d86b "${1:-10h}"
