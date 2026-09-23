#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TARGET=${1:-}
DURATION=${2:-10h}
PYTHON2=${APOLLO_PYTHON2:-/home/sjz/miniconda3/envs/apollo-py2/bin/python}
BUILD_PREFIX=${APOLLO_BUILD_PREFIX:-/home/sjz/miniconda3/envs/apollo-build}
RUN_ROOT=${APOLLO_RUN_ROOT:-"$ROOT/reproduced"}
SQLSMITH_TIMEOUT_MS=${APOLLO_SQLSMITH_TIMEOUT_MS:-18000}
FUZZ_DIR="$ROOT/src/sqlfuzz"
CONFIG="$FUZZ_DIR/configuration/mysql.yaml"

usage() {
  cat <<'EOF'
Usage: ae/run-mysql-commit.sh COMMIT [DURATION]

COMMIT must be one of: cd66c5c, 0fa789a, c17d86b, 6ba1fef.
DURATION defaults to 10h. Use 10m for a short trial.
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

[ "$#" -le 2 ] || {
  usage >&2
  exit 2
}

case "$TARGET" in
  cd66c5c|0fa789a|c17d86b|6ba1fef) ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

[[ "$DURATION" =~ ^[1-9][0-9]*[smhd]$ ]] || \
  die "invalid duration '$DURATION' (examples: 10m, 10h)"
[[ "$SQLSMITH_TIMEOUT_MS" =~ ^[1-9][0-9]*$ ]] || \
  die "APOLLO_SQLSMITH_TIMEOUT_MS must be a positive integer"

OLD_INSTALL="$ROOT/opt/$TARGET-old"
NEW_INSTALL="$ROOT/opt/$TARGET"
OLD_SOCKET=/tmp/mysql3307.sock
NEW_SOCKET=/tmp/mysql3308.sock
OLD_X_SOCKET=/tmp/mysqlx3307.sock
NEW_X_SOCKET=/tmp/mysqlx3308.sock

mkdir -p "$RUN_ROOT"
LOCK_FILE="$RUN_ROOT/.mysql-fuzz.lock"
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  die "another MySQL fuzzing run holds $LOCK_FILE"
fi

for command in flock timeout netstat awk grep sed find wc date cmp seq tail; do
  command -v "$command" >/dev/null 2>&1 || die "required command not found: $command"
done
[ -x /usr/bin/time ] || die "required executable not found: /usr/bin/time"
[ -x "$PYTHON2" ] || die "Python 2 not found: $PYTHON2 (set APOLLO_PYTHON2)"
[ -f "$CONFIG" ] || die "configuration not found: $CONFIG"
[ -f "$ROOT/init.sql" ] || die "initial schema not found: $ROOT/init.sql"
[ -f "$ROOT/insert.sql" ] || die "initial data not found: $ROOT/insert.sql"

for executable in \
  "$OLD_INSTALL/bin/mysqld" \
  "$OLD_INSTALL/bin/mysql" \
  "$OLD_INSTALL/bin/mysqladmin" \
  "$NEW_INSTALL/bin/mysqld" \
  "$NEW_INSTALL/bin/mysql" \
  "$NEW_INSTALL/bin/mysqladmin" \
  "$FUZZ_DIR/sqlsmith"; do
  [ -x "$executable" ] || die "required executable not found: $executable"
done

"$PYTHON2" - "$CONFIG" <<'PY' || \
  die "Python dependencies or configuration/mysql.yaml are invalid"
import sys
assert sys.version_info[0] == 2
import yaml, tqdm, sqlparse
with open(sys.argv[1], "r") as config_file:
    config = yaml.safe_load(config_file)
assert config["DBMS"] == "mysql"
assert config["DB"] == "test_bd"
assert config["OLD_VER_PORT"] == 3307
assert config["NEW_VER_PORT"] == 3308
assert abs(float(config["THRESHOLD"]) - 1.02) < 0.000001
assert config["PREFIX"] == "EXPLAIN ANALYZE"
assert config["USE_MINIMIZER"] is True
PY

grep -q 'APOLLO_RESULT_DIR' "$FUZZ_DIR/fuzz.py" || \
  die "fuzz.py lacks the AE output-directory patch"
grep -q 'APOLLO_MINIMIZER_DIR' "$FUZZ_DIR/conf.py" || \
  die "conf.py lacks the AE minimizer-directory patch"
grep -q 'for port in SERVER_PORTS' "$FUZZ_DIR/fuzz.py" || \
  die "fuzz.py lacks deterministic old/new execution order"

export PATH="$(dirname "$PYTHON2"):$OLD_INSTALL/bin:$PATH"
if [ -d "$BUILD_PREFIX/lib" ]; then
  export LD_LIBRARY_PATH="$BUILD_PREFIX/lib:${LD_LIBRARY_PATH:-}"
fi

SQLSMITH_HELP=$("$FUZZ_DIR/sqlsmith" --help 2>&1) || \
  die "SQLSmith could not start; check its runtime libraries"
case "$SQLSMITH_HELP" in
  *--mysql=*) ;;
  *) die "SQLSmith was not built with MySQL support" ;;
esac

shutdown_socket() {
  local socket=$1
  local admin

  for admin in \
    "$ROOT/opt/old/bin/mysqladmin" \
    "$ROOT/opt/new/bin/mysqladmin" \
    "$OLD_INSTALL/bin/mysqladmin" \
    "$NEW_INSTALL/bin/mysqladmin"; do
    [ -x "$admin" ] || continue
    if "$admin" --no-defaults -uroot -S "$socket" ping >/dev/null 2>&1; then
      echo "Stopping MySQL at $socket"
      timeout 60s "$admin" --no-defaults -uroot \
        -S "$socket" shutdown >/dev/null || \
        die "MySQL at $socket did not accept a clean shutdown within 60 seconds"
      break
    fi
  done

  for unused in $(seq 1 60); do
    if ! "$OLD_INSTALL/bin/mysqladmin" --no-defaults -uroot \
      -S "$socket" ping >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  die "MySQL at $socket did not stop within 60 seconds"
}

port_is_busy() {
  local port=$1
  netstat -lnt 2>/dev/null | awk -v port="$port" '
    $4 ~ (":" port "$") { found=1 }
    END { exit !found }
  '
}

shutdown_socket "$OLD_SOCKET"
shutdown_socket "$NEW_SOCKET"

for port in 3307 3308 33007 33008; do
  if port_is_busy "$port"; then
    die "TCP port $port is still in use; refusing to stop an unknown process"
  fi
done

switch_link() {
  local link=$1
  local destination=$2

  if [ -e "$link" ] && [ ! -L "$link" ]; then
    die "$link exists but is not a symbolic link"
  fi
  ln -sfn "$destination" "$link"
}

switch_link "$ROOT/opt/old" "$OLD_INSTALL"
switch_link "$ROOT/opt/new" "$NEW_INSTALL"

STAMP=$(date +%Y%m%d-%H%M%S)
RUN_DIR="$RUN_ROOT/$TARGET/run-$STAMP"
mkdir -p "$RUN_ROOT/$TARGET"
if ! mkdir "$RUN_DIR"; then
  die "could not create unique run directory: $RUN_DIR"
fi
mkdir -p "$RUN_DIR/mysql-old" "$RUN_DIR/mysql-new" \
  "$RUN_DIR/work/sqlfuzz" "$RUN_DIR/work/sqlmin" \
  "$RUN_DIR/candidates"

OLD_DATA="$RUN_DIR/mysql-old"
NEW_DATA="$RUN_DIR/mysql-new"
OLD_PID="$RUN_DIR/mysql-old.pid"
NEW_PID="$RUN_DIR/mysql-new.pid"
OLD_LOG="$RUN_DIR/mysql-old.log"
NEW_LOG="$RUN_DIR/mysql-new.log"

cat > "$RUN_DIR/metadata.txt" <<EOF
target=$TARGET
duration=$DURATION
started=$(date --iso-8601=seconds)
root=$ROOT
old_install=$OLD_INSTALL
new_install=$NEW_INSTALL
python2=$PYTHON2
sqlsmith=$FUZZ_DIR/sqlsmith
threshold=1.02
sqlsmith_server_timeout_ms=$SQLSMITH_TIMEOUT_MS
fuzz_query_timeout_ms=299000
old_port=3307
new_port=3308
EOF
"$OLD_INSTALL/bin/mysqld" --version >> "$RUN_DIR/metadata.txt"
"$NEW_INSTALL/bin/mysqld" --version >> "$RUN_DIR/metadata.txt"
if [ -f "$OLD_INSTALL/BUILD_COMMIT" ]; then
  sed 's/^/old_commit=/' "$OLD_INSTALL/BUILD_COMMIT" >> "$RUN_DIR/metadata.txt"
fi
if [ -f "$NEW_INSTALL/BUILD_COMMIT" ]; then
  sed 's/^/new_commit=/' "$NEW_INSTALL/BUILD_COMMIT" >> "$RUN_DIR/metadata.txt"
fi

echo "Initializing fresh old/new databases in $RUN_DIR"
"$OLD_INSTALL/bin/mysqld" --no-defaults \
  --initialize-insecure \
  --basedir="$OLD_INSTALL" \
  --datadir="$OLD_DATA" \
  --log-error="$RUN_DIR/mysql-old-initialize.log" \
  9>&-
"$NEW_INSTALL/bin/mysqld" --no-defaults \
  --initialize-insecure \
  --basedir="$NEW_INSTALL" \
  --datadir="$NEW_DATA" \
  --log-error="$RUN_DIR/mysql-new-initialize.log" \
  9>&-

SETUP_COMPLETE=0
cleanup_failed_setup() {
  local status=$?
  trap - EXIT
  if [ "$status" -ne 0 ] && [ "$SETUP_COMPLETE" -eq 0 ]; then
    echo "Setup failed; stopping only the servers started for this run" >&2
    timeout 30s "$OLD_INSTALL/bin/mysqladmin" --no-defaults -uroot \
      -S "$OLD_SOCKET" shutdown >/dev/null 2>&1 || true
    timeout 30s "$NEW_INSTALL/bin/mysqladmin" --no-defaults -uroot \
      -S "$NEW_SOCKET" shutdown >/dev/null 2>&1 || true
  fi
  exit "$status"
}
trap cleanup_failed_setup EXIT

start_server() {
  local prefix=$1
  local datadir=$2
  local port=$3
  local socket=$4
  local xport=$5
  local xsocket=$6
  local pidfile=$7
  local logfile=$8

  "$prefix/bin/mysqld" --no-defaults \
    --basedir="$prefix" \
    --datadir="$datadir" \
    --port="$port" \
    --socket="$socket" \
    --pid-file="$pidfile" \
    --log-error="$logfile" \
    --bind-address=127.0.0.1 \
    --mysqlx-port="$xport" \
    --mysqlx-socket="$xsocket" \
    --mysqlx-bind-address=127.0.0.1 \
    --max-execution-time="$SQLSMITH_TIMEOUT_MS" \
    --daemonize \
    9>&-
}

wait_for_server() {
  local admin=$1
  local socket=$2
  local logfile=$3

  for unused in $(seq 1 60); do
    if "$admin" --no-defaults -uroot -S "$socket" ping >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "MySQL did not become ready at $socket; last log lines:" >&2
  tail -n 40 "$logfile" >&2 || true
  return 1
}

echo "Starting old on 3307 and new on 3308"
start_server "$OLD_INSTALL" "$OLD_DATA" 3307 "$OLD_SOCKET" \
  33007 "$OLD_X_SOCKET" "$OLD_PID" "$OLD_LOG"
start_server "$NEW_INSTALL" "$NEW_DATA" 3308 "$NEW_SOCKET" \
  33008 "$NEW_X_SOCKET" "$NEW_PID" "$NEW_LOG"
wait_for_server "$OLD_INSTALL/bin/mysqladmin" "$OLD_SOCKET" "$OLD_LOG"
wait_for_server "$NEW_INSTALL/bin/mysqladmin" "$NEW_SOCKET" "$NEW_LOG"

load_database() {
  local client=$1
  local socket=$2

  "$client" --no-defaults -uroot -S "$socket" \
    -e 'CREATE DATABASE test_bd;'
  "$client" --no-defaults -uroot -S "$socket" \
    test_bd < "$ROOT/init.sql"
  "$client" --no-defaults -uroot -S "$socket" \
    test_bd < "$ROOT/insert.sql"
}

echo "Loading the same schema and rows into both servers"
load_database "$OLD_INSTALL/bin/mysql" "$OLD_SOCKET"
load_database "$NEW_INSTALL/bin/mysql" "$NEW_SOCKET"

EXPECTED_COUNTS=$'users\t2500\nposts\t5000\ncomments\t10000\nuser_profiles\t2000\nlocations\t5000\nproducts\t10000\nemployee\t5000\neids\t3000'
COUNT_SQL="SELECT 'users', COUNT(*) FROM users UNION ALL SELECT 'posts', COUNT(*) FROM posts UNION ALL SELECT 'comments', COUNT(*) FROM comments UNION ALL SELECT 'user_profiles', COUNT(*) FROM user_profiles UNION ALL SELECT 'locations', COUNT(*) FROM locations UNION ALL SELECT 'products', COUNT(*) FROM products UNION ALL SELECT 'employee', COUNT(*) FROM employee UNION ALL SELECT 'eids', COUNT(*) FROM eids;"

verify_database() {
  local label=$1
  local client=$2
  local socket=$3
  local actual

  actual=$("$client" --no-defaults -uroot -S "$socket" \
    --batch --skip-column-names test_bd -e "$COUNT_SQL")
  printf '%s\n' "$actual" > "$RUN_DIR/table-counts-$label.txt"
  if [ "$actual" != "$EXPECTED_COUNTS" ]; then
    echo "Unexpected table counts on $label:" >&2
    printf '%s\n' "$actual" >&2
    return 1
  fi
  "$client" --no-defaults -uroot -S "$socket" \
    --batch --skip-column-names test_bd \
    -e 'SELECT COUNT(*) FROM user_post_comments;' \
    > "$RUN_DIR/view-count-$label.txt"
}

verify_database old "$OLD_INSTALL/bin/mysql" "$OLD_SOCKET"
verify_database new "$NEW_INSTALL/bin/mysql" "$NEW_SOCKET"
cmp "$RUN_DIR/view-count-old.txt" "$RUN_DIR/view-count-new.txt" >/dev/null || \
  die "user_post_comments differs between old and new"

SETUP_COMPLETE=1

export APOLLO_RESULT_DIR="$RUN_DIR/candidates"
export APOLLO_TMP_DIR="$RUN_DIR/work/sqlfuzz"
export APOLLO_MINIMIZER_DIR="$RUN_DIR/work/sqlmin"
export APOLLO_FUZZ_LOG="$RUN_DIR/fuzz.log"
export APOLLO_MYSQL_QUERY_TIMEOUT_MS=299000

echo "Running Apollo for $DURATION (2% threshold)"
echo "Live log: $RUN_DIR/fuzz.txt"
cd "$FUZZ_DIR"
set +e
/usr/bin/time -p -o "$RUN_DIR/fuzz.time" \
  timeout --signal=TERM --kill-after=30s "$DURATION" \
  "$PYTHON2" fuzz.py -c configuration/mysql.yaml \
  > "$RUN_DIR/fuzz.txt" 2>&1
STATUS=$?
set -e

printf '%s\n' "$STATUS" > "$RUN_DIR/exit-status.txt"
"$OLD_INSTALL/bin/mysql" --no-defaults -uroot -S "$OLD_SOCKET" \
  -e 'SHOW FULL PROCESSLIST;' > "$RUN_DIR/processlist-old.txt" 2>&1 || true
"$NEW_INSTALL/bin/mysql" --no-defaults -uroot -S "$NEW_SOCKET" \
  -e 'SHOW FULL PROCESSLIST;' > "$RUN_DIR/processlist-new.txt" 2>&1 || true

ROUNDS=$(grep -c '^\[\*\] Running .* Round' "$RUN_DIR/fuzz.txt" || true)
CANDIDATES=$(find "$APOLLO_RESULT_DIR" -maxdepth 1 -type f \
  -name '*.txt' | wc -l)
CANDIDATES_10=0
if [ "$CANDIDATES" -gt 0 ]; then
  CANDIDATES_10=$(awk -F'[(), ]+' '
    FNR == 1 && ($2 > 1.10) && ($5 > 1.10) { count++ }
    END { print count + 0 }
  ' "$APOLLO_RESULT_DIR"/*.txt)
fi

cat > "$RUN_DIR/summary.txt" <<EOF
target=$TARGET
exit=$STATUS
rounds=$ROUNDS
candidates_2pct=$CANDIDATES
candidates_10pct=$CANDIDATES_10
run_dir=$RUN_DIR
servers_left_running=yes
EOF

cat "$RUN_DIR/summary.txt"
echo "The two MySQL servers were left running for inspection."
echo "The next run script will shut them down through mysqladmin."

if [ "$ROUNDS" -eq 0 ]; then
  die "Apollo did not begin a fuzzing round; inspect $RUN_DIR/fuzz.txt"
fi
if [ "$STATUS" -ne 0 ] && [ "$STATUS" -ne 124 ]; then
  die "Apollo exited with status $STATUS; inspect $RUN_DIR/fuzz.txt"
fi
