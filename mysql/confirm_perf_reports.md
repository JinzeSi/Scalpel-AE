# MySQL Screening and Confirmation

All scripts belong in `/data3/sjz/AE/mysql`. First-round results remain in
`<commit>/<case>/` and `<parent>-old/<case>/`. Existing archived results do not
need to be moved. Neither reporting nor confirmation modifies first-round results.

## Commands

The tmux-aware entry is `bash /data3/sjz/AE/mysql/run_all.sh`. It uses the full
local commit list, runs MySQL in tmux 2 and live Pre-knowledge from
`/data2/sjz/Pre-knowledge-mysql` in tmux 4, first changing both working directories.
Let Redis finish using both panes before launch. See
[README.md](README.md) for read-only preflight and progress instructions.

Run all 135 commits from the beginning, generate fresh screening reports and
confirm their candidates in one command:

```bash
bash /data3/sjz/AE/mysql/run_all.sh
```

This snapshots the complete `commit-tmp.txt` for both live workers. It does not
read `brk-5-5` replies or use a previous `MYSQL_COMMIT_FILE` selection. Both the
first-round list and real Pre-knowledge must finish before confirmation begins. The
driver passes its newly created run directory to screening, so it uses exactly
this run's root-level results and overwrites generated old candidate reports.
No previous trial directory, archived report or old selection policy is needed.
Normal executions use `sql-times.txt` counts; native confirmation uses twice
the mapped count. First-round and confirmation failures remain visible in the
overall exit status. This is an execution command, not a preview.

After a separately completed first round, generate screening reports and preview
confirmation in one command:

```bash
bash /data3/sjz/AE/mysql/run-report.sh
```

When ready to actually confirm all screened candidates:

```bash
bash /data3/sjz/AE/mysql/run-report.sh --execute
```

Historical archives are supported only when explicitly selected:

```bash
bash /data3/sjz/AE/mysql/run-report.sh \
  --run-dir /path/to/completed-run
```

The last command generates reports and a plan only. Add `--execute` later to
perform confirmation. It is not required for a new run.

To confirm an already generated report without regenerating it:

```bash
bash /data3/sjz/AE/mysql/validate_auto.sh          # read-only plan
bash /data3/sjz/AE/mysql/validate_auto.sh --execute
```

`python3 confirm_perf_reports.py` is equivalent to `validate_auto.sh`.
Select cases with `--case FULL_COMMIT-CASE`, repeatable. The existing single-case
entry point is also available as `bash validate.sh PARENT COMMIT CASE [--execute]`;
it checks the supplied parent. `validate.txt` is no longer needed. Only cases in
`report/candidates.json` are selected automatically.

## Rules

1. Screening uses a slowdown of at least 2% in either valid execution mode.
   Raw timings, ratios, equal query counts and compilation status are checked.
2. As in Redis, nonempty saved symbolic values plus a valid symbolic-mode
   slowdown reaching the threshold retain the report directly (`direct_report`).
   This status does not claim that an additional benchmark was run.
3. Other qualifying candidates are benchmarked on clean native builds of the
   reported commit and its actual first parent. Nonempty symbols alone are not
   enough for direct retention. A failed symbolic compilation cannot qualify.
4. Each version executes the testcase **twice its count in `sql-times.txt`**,
   with one mysqlslap client and one iteration. There is no fixed 100,000 count,
   additional benchmark round or workload warmup. Startup readiness uses a
   metadata query, not the testcase.
5. Slowdown is `(new batch seconds / old batch seconds - 1) * 100`. A result
   reaching the threshold is `benchmark_confirmed`; otherwise `not_reproduced`.
   Invalid/missing inputs are `manual_review`; build/startup/SQL/timeout errors
   are `error`. These statuses are never treated as confirmations.

Both threshold stages accept `--threshold-percent`; the pipeline passes the same
value to both. Known regressions below the screening threshold are not forced
into the candidate set. All decisions use the newly screened measurements;
previously known issues do not become confirmed merely from their commit names.

## Execution and Outputs

`report/` contains screening Markdown, `candidates.json`, `cases.csv` and
`commits.csv`. Confirmation rechecks original measurements before deciding what
to execute. Missing or changed measurements require regenerating the report.

Confirmation acquires the same `.run_auto.lock` as the main MySQL workflow.
The driver now closes its lock descriptor in worker children, preventing an
orphaned S2E process from retaining it. A process from an older driver may still
hold the lock; `fuser -v /data3/sjz/AE/mysql/.run_auto.lock` identifies it.
Finish or stop that process before actual execution; do not delete the lock file
or bypass the lock while a run is active. Read-only planning needs no lock.
It saves a snapshot of `sql-times.txt` and the initial `tables.tar.gz` for that
execution. Each side receives a separate extracted data directory and uses the
same mysqlslap binary and SQL. Actual query counts in the logs must match the
planned doubled count. Missing mapping entries fail before starting MySQL.

Clean local Git copies are built inside `report-confirmation/<timestamp>/builds/`,
once per version per confirmation run. Source checkouts and instrumented build
directories are not reused or modified. Native options match the current MySQL
workflow: `/usr/bin/cc`, `/usr/bin/c++`, `RelWithDebInfo`, `-O2 -g -DNDEBUG` and
the local `mysql-server/boost_1_77_0`. No LLVM analysis, S2E or Pre-knowledge runs.
These clean builds take time and disk space when confirmation is actually run.

`run-mysql-val.sh` and confirm use the same `mysql_validation.py` execution
implementation and `get-sql-times.py` lookup. The standalone shell entry point
still reads `get_mysql.txt` and `bin/data` in its build working directory and
writes the mysqlslap output to `error.log`. Server output is stored separately.
Private UNIX sockets and disabled TCP listeners avoid other MySQL instances;
only child processes owned by the validator are stopped.

Each confirmation run saves:

- `summary.csv` and `summary.json`: all processed candidates and outcomes.
- `cases/<commit>-<case>/`: original inputs, separate old/new logs, command
  arguments, measured query counts, batch times and `result.json`.
- `snapshots/`: the mapping and data archive with SHA-256 checksums.
- `builds/`: clean sources, compiler logs and build settings.
- `reports/`: retained reports for that execution.
- `plan.json`, `settings.json`, `completed.json`: provenance and completion.

After a full confirmation pass, accepted reports are automatically published to
`report-final/<commit>/<commit>-<case>.md`, as in Redis. Generated final reports
that no longer qualify are removed; unrelated files are preserved. With `--case`,
only selected reports are refreshed. Interruptions preserve the previous final
selection and leave partial diagnostics in the run archive. Final reports omit
the original `modified part` and `icount diff` blocks, while input reports retain them.

Options include `--report-dir`, `--output-dir` (must not exist), `--final-dir`,
`--source-repo`, `--boost-dir`, `--mapping`, `--data-file`, `--mysqlslap`,
`--cc`, `--cxx`, `--jobs` (24), `--build-timeout` (14400 seconds), `--timeout`
(14400 seconds per workload) and `--startup-timeout` (120 seconds). Counts are
always derived from the mapping times two. The pipeline's `--output-dir` refers
to the confirmation archive, not the screening directory.

Tests use synthetic results and mocked build/server operations:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v test_generate_perf_report test_confirm_perf_reports test_full_workflow
```
