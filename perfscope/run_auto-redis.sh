#!/bin/bash

PROJECT=redis
TIME_LOG="time-tall.txt"

TASKS=(
    "commit-26-02-01/commit-9-3-new.txt"
    "commit-26-02-01/commit-9-2-new.txt"
    "commit-26-02-01/commit-8-new.txt"
    "commit-26-02-01/commit-3-new.txt"
    "commit-26-02-01/commit-2-new.txt"
    "commit-26-02-01/commit-1-new.txt"
)

STOP_REQUESTED=false
trap 'STOP_REQUESTED=true' SIGINT SIGTERM

run_commit() {
    local commit_id=$1
    local start_time
    local end_time
    local total_time
    local exit_code

    if [ "$STOP_REQUESTED" = "true" ]; then
        echo "[Master] Stop requested, skipping remaining commits."
        return 130
    fi

    start_time=$(date +%s)

    echo "--------------------------------------------------"
    echo "Processing Commit: $commit_id"
    echo "$commit_id script start: $(date)" >> "$TIME_LOG"

    bash "./run-$PROJECT.sh" "$commit_id"
    exit_code=$?

    if [ $exit_code -eq 130 ] || [ "$STOP_REQUESTED" = "true" ]; then
        echo "[Master] Received interrupt signal."
        echo "$commit_id interrupted by user: $(date)" >> "$TIME_LOG"
        echo "USER INTERRUPT - STOPPING ALL" >> "$TIME_LOG"
        return 130
    fi

    if [ $exit_code -ne 0 ]; then
        echo "[Master] Commit $commit_id failed (Code: $exit_code), continuing."
        echo "$commit_id failed (Code $exit_code): $(date)" >> "$TIME_LOG"
        echo "FAILED - CONTINUING" >> "$TIME_LOG"
        return 0
    fi

    end_time=$(date +%s)
    total_time=$((end_time - start_time))

    echo "$commit_id script end: $(date)" >> "$TIME_LOG"
    echo "$commit_id total time: ${total_time} seconds" >> "$TIME_LOG"
    echo "" >> "$TIME_LOG"

    return 0
}

for filename in "${TASKS[@]}"; do
    if [ "$STOP_REQUESTED" = "true" ]; then
        echo "[Master] Stop requested, skipping remaining files."
        break
    fi

    if [ ! -f "$filename" ]; then
        echo "[Master] Commit file not found: $filename"
        echo "MISSING FILE $filename: $(date)" >> "$TIME_LOG"
        continue
    fi

    echo "=================================================="
    echo "Task file: $filename"
    echo "=================================================="
    echo "TASK START $filename: $(date)" >> "$TIME_LOG"

    while IFS= read -r commit_id || [ -n "$commit_id" ]; do
        commit_id=${commit_id%%#*}
        commit_id=${commit_id//[[:space:]]/}

        if [ -z "$commit_id" ]; then
            continue
        fi

        run_commit "$commit_id"
        exit_code=$?

        if [ $exit_code -eq 130 ]; then
            break 2
        fi
    done < "$filename"

    echo "TASK END $filename: $(date)" >> "$TIME_LOG"
done
