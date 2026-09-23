#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
batch_file=${REDIS_BATCH_FILE:-"$root/commit/batches.tsv"}
selected_group=${1:-}
if [[ "$selected_group" == --help || $# -gt 1 ]]; then
    printf 'Usage: bash run.sh [GROUP]\nGroups follow commit/batches.tsv. Pre-knowledge must run alongside.\n'
    exit 0
fi

found=0
while IFS=$'\t' read -r group commit_file last_commit makefile socket; do
    [[ "$group" == group || -z "$group" ]] && continue
    [[ -n "$selected_group" && "$group" != "$selected_group" ]] && continue
    found=1
    filename=${REDIS_COMMIT_FILE:-"$root/commit/$commit_file"}
    [[ -f "$filename" && "$last_commit" =~ ^[0-9a-f]{40}$ ]] || exit 1
    cp -- "$root/commit/makefile/$makefile" "$root/Makefile"
    cp -- "$root/commit/makefile/$makefile-1" "$root/Makefile1"
    while IFS= read -r line || [[ -n "$line" ]]; do
        line=${line%$'\r'}
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[0-9a-f]{40}$ ]] || { printf 'Invalid commit: %s\n' "$line" >&2; exit 1; }
        work="$root/redis-$line"
        old_work="$root/redis-$last_commit-old"
        for directory in "$work" "$old_work"; do
            if [[ -e "$directory" || -L "$directory" ]]; then
                printf 'Existing result directory: %s. Archive it before rerunning.\n' "$directory" >&2
                exit 1
            fi
        done
        start_time=$(date +%s)
        printf '%s START group=%s old=%s new=%s\n' "$(date -Is)" "$group" "$last_commit" "$line" |
            tee -a "$root/time-tall.txt"
        cp -a -- "$root/redis" "$work"
        cp -a -- "$root/redis" "$old_work"
        git -C "$old_work" checkout --detach "$last_commit"
        git -C "$work" checkout --detach "$line"
        if [[ -n "${REDIS_LOG_DIR:-}" ]]; then
            mkdir -p -- "$REDIS_LOG_DIR"
            log="$REDIS_LOG_DIR/$line.log"
            printf 'Commit log: %s\n' "$log"
            if (cd "$work" && bash "$root/make_symbolic-NULLEND.sh" "$last_commit" "$line") > "$log" 2>&1; then
                :
            else
                code=$?
                printf 'Commit %s failed with status %s; see %s\n' "$line" "$code" "$log" >&2
                exit "$code"
            fi
        else
            (cd "$work" && bash "$root/make_symbolic-NULLEND.sh" "$last_commit" "$line")
        fi
        printf '%s END group=%s commit=%s seconds=%s\n' "$(date -Is)" "$group" "$line" "$(( $(date +%s) - start_time ))" |
            tee -a "$root/time-tall.txt"
        if [[ -n "${REDIS_PROGRESS_FILE:-}" ]]; then
            printf '%s\n' "$line" >> "$REDIS_PROGRESS_FILE"
        fi
        last_commit=$line
    done < "$filename"
done < "$batch_file"
[[ "$found" == 1 ]] || { printf 'Unknown group: %s\n' "$selected_group" >&2; exit 1; }
