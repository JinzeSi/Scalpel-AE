# Running the AE MySQL Scripts

For the complete one-click workflow in tmux 2, use
`bash /data3/sjz/AE/mysql/run_all.sh` after Redis finishes. It explicitly changes
to the MySQL directory before starting. See [README.md](README.md) for preflight,
progress and completion checks. The commands below are the lower-level entries.

These scripts use independent `mysql-server/`, `mysql-server-2/`, and `tool/`
directories under `/data3/sjz/AE/mysql`. Prepare those directories before running.
Both MySQL checkouts need their Git history and `boost_1_77_0/`. Scripts create
fresh `build-ae-*` directories on startup because copied CMake caches contain
absolute paths to the previous checkout. Existing `build-*` directories are
preserved and are not used by these scripts.

All analysis tools are copied from the local `tool/` directory. Symbolic headers
and libraries remain external dependencies under
`/data/sjz/commit-analysis/llvm-analysis/tools/include` and `lib`.

The shared list is `commit-tmp.txt` (135 commits). Its initial parent is
`27cd03548955749bd18c30e0e96ea798937375f0`.

Activate the existing LLVM/S2E environment (tmux 2). The main script
checks for `s2e` in PATH. The existing compiler, symbolic headers/libraries,
testcase archive, mysqlslap, and S2E MySQL project remain external dependencies.

Start a fresh first round over all 135 commits, then automatically screen and
confirm that run's candidates:

```bash
cd /data3/sjz/AE/mysql
bash run_all.sh
```

This command is the complete workflow. It reads the current `commit-tmp.txt`,
runs every entry, leaves results under `<commit>/<case>/`, regenerates `report/`
from this run and publishes accepted confirmation reports under `report-final/`.
It also starts the live worker in `/data2/sjz/Pre-knowledge-mysql` in tmux 4.
It does not reuse an old `full-...` run or its selected commit ranges. Existing
root-level results are backed up before each commit is rerun. The paired launcher
always snapshots the full local list; `MYSQL_COMMIT_FILE` from a previous trial
does not override it. The internal `run_auto.sh --confirm` receives this snapshot
and the paired-run directory from the coordinator.

`--confirm` waits for the first-round list and the live peer to finish. Failures
after a completed exchange can continue to later commits; a failed/missing
exchange stops the pair to prevent commit misalignment. Failed commits are
excluded from screening. The workflow returns a failure status if either stage
failed. An interrupted first round or failed peer does not start confirmation.

The normal workflow uses real `updateCommit-new-mysql.sh` execution in
`/data2/sjz/Pre-knowledge-mysql`; no archived reply is read. Both workers use the
same list and initial baseline. MySQL sends current call/symbolic analysis, and
the peer publishes a fresh reply under `pipeline-runs/<run-id>/replies/<commit>.txt`.
Requests are checked against the peer's current commit. The existing
`mysql-link/link.py` remains a build helper.
Commit analysis, compilation databases, both mysqld binaries, new-function
comparison, both bitcode builds, call analysis, and symbolic analysis still run.
The ordinary no-code-change branch sends empty analysis, waits for the live
reply, then exits early. Empty replies are accepted. This exchange keeps both
workers aligned even for comment-only or non-C/C++ commits.

`run_auto.sh` requires clean tracked source trees and creates `full-<timestamp>/`.
It saves the selected list, scripts, mapping, per-commit logs and `status.tsv`.
New results stay at `<commit>/<case>/` and `<parent>-old/<case>/` under the
MySQL root, just like the Redis workflow. `results-root.txt` in the run directory
records that location. Each commit directory gets `run-status.tsv` with its actual
parent, exit status and run directory. Existing root-level results are moved to
`previous-results/` before reuse. Each completed commit's source diff is saved before its generated edits
are restored. Commit failures are recorded; continuation requires a completed peer exchange.
`exit-status.txt` is written after the full list finishes. Historical compilation
and result-parser errors can coexist with a zero child exit status; inspect
per-case logs and `compile.txt` when evaluating measurement success.
With `--confirm`, `confirmation.log`, `confirmation-exit-status.txt` and
`workflow-exit-status.txt` record the subsequent stages. The first-round
`exit-status.txt` keeps its original meaning.

## Generate performance reports

After the experiment finishes, one command screens root-level results:

```bash
python3 /data3/sjz/AE/mysql/generate_perf_report.py
```

The script reads `commit-tmp.txt` and writes `report/README.md`, one
`report/<commit>-<case>.md` per candidate, `report/cases.csv` (including rejected
measurements), `report/commits.csv` and `report/candidates.json` for later
validation. It does not build, execute SQL, change checkouts or start validation.
The default threshold is an inclusive 2% slowdown in either valid end-to-end
execution mode, as in Redis. Change it with `--threshold-percent 5`, or inspect
without writing with `--dry-run`. Reports are refreshed on reruns; unrelated or
manually edited files are not overwritten. `--output-dir` selects another location.

To explicitly inspect a historical run, supply its directory. This is optional
and is not part of starting a fresh 135-commit workflow:

```bash
python3 /data3/sjz/AE/mysql/generate_perf_report.py \
  --run-dir /path/to/completed-run
```

For `--run-dir`, `selected-commits.txt` takes precedence over `commits.txt`.
Cancelled/failed commits and selection skips are excluded. `--commit-file` can
override the selection. New runs keep their results at the root; an older run
whose root results have since been replaced is identified instead of being
reported using another run's data.

Screening checks finite positive final timings, ratio consistency, compilation
diagnostics, mysqlslap batch times and equal query counts between versions.
Symbolic-mode compilation failures exclude that mode only. Missing instruction
counts and invalid modified-part metrics do not become end-to-end slowdowns.
Batch times in reports use seconds from mysqlslap; the legacy parser divides
times by 10, which does not affect ratios. Candidate JSON records the actual
parent, SQL, paths, measured query count and a planned 2x validation count.
Confirmation reads the current mapping and saves a snapshot before execution.

## Confirm screened reports

`bash run-report.sh` generates screening reports and previews the confirmation
plan. `bash run-report.sh --execute` performs both stages. Add `--run-dir` for
an old archived batch. To confirm existing reports only, use
`bash validate_auto.sh --execute`; without `--execute`, it only prints a plan.
The workflow uses the Redis retention rules and publishes accepted reports to
`report-final/<commit>/<commit>-<case>.md`. Native confirmation executes each
SQL `sql-times.txt` times two on both versions. See `confirm_perf_reports.md`
for commands, status definitions and complete input/output details.

Only one run may use these source trees and the shared S2E project at a time.
The original experiment's checkout and result replacement behavior applies to
the first round. Confirmation uses clean local Git copies and its own data and
output directories. It does not replace first-round results or rerun analysis.

See `README-replay.md` for archived-analysis replay and `SEMANTICS-AUDIT.md`
for the review of behavior changes made during migration.

## Historical selections

The September 22 trial used ranges 37-43 and 125-135. Its selection policy lives
only inside that old run directory. New runs create a new log directory without
such a policy and traverse the entire input list. Old trial directories can be
archived independently of future runs. Reports already generated from an old
archive still need that archive until they are regenerated from new results.

## Query counts

`run-mysql.sh` uses the testcase's count from `/data3/sjz/AE/mysql/sql-times.txt`.
`run-mysql-val.sh` uses twice that count. Both scripts call `get-sql-times.py`
before starting MySQL, including when copied into a build directory.
The mapping has one `SQL<TAB>execution_count` entry per testcase; blank lines
and `#` comments are ignored. Only leading/trailing whitespace is ignored when
matching SQL. Counts must be positive integers; missing matches, duplicate SQL,
or malformed entries make the runner return an error before launching MySQL.
The first-round analysis retains its historical error-continuation behavior.
Confirmation records failures explicitly and excludes them from final reports.
Keep the mapping fixed across a comparison; confirm saves and uses a snapshot.
mysqlslap records the actual count in each measurement's `error.log`.
