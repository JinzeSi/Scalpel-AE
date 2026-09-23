#!/bin/bash
set -euo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
generate=(python3 "$script_dir/generate_perf_report.py")
confirm=(python3 "$script_dir/confirm_perf_reports.py")
while (( $# )); do
    case "$1" in
        --run-dir|--commit-file)
            (( $# >= 2 )) || { echo "Missing value for $1" >&2; exit 2; }
            generate+=("$1" "$2"); shift 2 ;;
        --threshold-percent)
            (( $# >= 2 )) || { echo "Missing value for $1" >&2; exit 2; }
            generate+=("$1" "$2"); confirm+=("$1" "$2"); shift 2 ;;
        --execute|--dry-run)
            confirm+=("$1"); shift ;;
        --case|--source-repo|--mapping|--data-file|--mysqlslap|--boost-dir|--jobs|--cc|--cxx|--timeout|--build-timeout|--startup-timeout|--output-dir|--final-dir)
            (( $# >= 2 )) || { echo "Missing value for $1" >&2; exit 2; }
            confirm+=("$1" "$2"); shift 2 ;;
        -h|--help)
            printf '%s\n' 'Usage: bash run-report.sh [--run-dir COMPLETED_RUN] [--execute] [confirm options]' \
                'Generate screening reports, then preview confirmation (or run it with --execute).' \
                'For a fresh full experiment and confirmation: bash run_auto.sh --confirm' \
                '--dry-run still writes screening reports; confirmation remains a read-only plan.' \
                'Use generate_perf_report.py --dry-run for a completely read-only screening.'
            exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done
"${generate[@]}"
exec "${confirm[@]}"
