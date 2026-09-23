#/bin/bash
if [ $# -lt 1 ]; then
    echo "Usage: $0 <redis/mysql/httpd/rocksdb/mariadb>"
    exit 1
fi
PROJECT=$1

case "${PROJECT}" in
redis)
    rm -f redis/redis.res
    ;;
mysql)
    rm -f mysql-server/mysql.res
    ;;
httpd)
    rm -f httpd/httpd.res
    ;;
rocksdb)
    rm -f rocksdb/rocksdb.res
    ;;
mariadb)
    rm -f mariadb-server/mariadb.res
    ;;
*)
;;
esac

# ================= Signal Control =================
STOP_REQUESTED=false
trap 'STOP_REQUESTED=true' SIGINT SIGTERM
FILENAME="commit-$PROJECT.txt"
if [ ! -f "$FILENAME" ]; then
    echo "ERROR: File $FILENAME not found!"
    exit 1
fi

last_commit="27cd03548955749bd18c30e0e96ea798937375f0"
while IFS= read -r commitId; do
    if [ "$STOP_REQUESTED" = "true" ]; then
        echo "🛑 [Master] Interrupt signal detected, stop processing subsequent tasks."
        break
    fi
    
    start_time=$(date +%s)
    echo "--------------------------------------------------"
    echo "Processing Commit: $commitId"
    echo "$commitId script start: $(date)" >> time-tall.txt
    bash ./run-$PROJECT.sh $commitId
    EXIT_CODE=$?
    # 1. Check for Ctrl-C (Exit Code 130)
    if [ $EXIT_CODE -eq 130 ] || [ "$STOP_REQUESTED" = "true" ]; then
        echo "🛑 [Master] Termination command received (Ctrl-C)."
        echo "$commitId manually interrupted by user: $(date)" >> time-tall.txt
        echo "USER INTERRUPT - STOPPING ALL" >> time-tall.txt
        break
    fi
    # 2. Check for general errors (build failure / patch failure, etc.)
    if [ $EXIT_CODE -ne 0 ]; then
        echo "⚠️ [Master] Commit $commitId execution failed (Code: $EXIT_CODE), continue to next."
        echo "$commitId execution error (Code $EXIT_CODE): $(date)" >> time-tall.txt
        echo "FAILED - CONTINUING" >> time-tall.txt
        
        continue
    fi
    # Save commit hash of last successful version
    last_commit=$commitId
    # Get end timestamp
    end_time=$(date +%s)
    echo "$commitId script end: $(date)" >> time-tall.txt
    # Calculate and print total execution time
    total_time=$((end_time - start_time))
    echo "$commitId total execution time: ${total_time} seconds" >> time-tall.txt
    echo -e "\n\n" >> time-tall.txt
    
done < "$FILENAME"
