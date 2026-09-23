# Redis Performance Analysis

Run all configured Redis commits, generate candidate performance reports, and
automatically publish the selected reports to `report-final/`.

This README describes the existing installation at `/data3/sjz/AE/redis` with
Pre-knowledge at `/data2/sjz/Pre-knowledge`. The scripts contain absolute paths;
copying this directory to another machine is not sufficient to configure it.

## Start a Full Run

Use the prepared environment in **tmux 2**, or launch from an ordinary terminal
while both prepared tmux panes are idle:

```bash
cd /data3/sjz/AE/redis
bash run_all.sh --check
```

`--check` performs a read-only preflight. It does not start experiments, move
results, or generate reports. Resolve any reported errors before starting:

```bash
bash /data3/sjz/AE/redis/run_all.sh
```

The script coordinates both sides automatically:

| Pane | Role |
| --- | --- |
| `2:0.0` | Redis analysis, S2E execution, measurements, report generation and confirmation |
| `4:0.0` | Pre-knowledge updates and any required rebuilds |

When launched from an ordinary terminal, the command starts the workers in tmux
and returns. That return means **started**, not finished. When launched inside
tmux 2, the coordinator stays in that pane. Detaching with `Ctrl-b`, then `d`,
leaves the run active. Do not launch it from tmux 4 or start a second copy.

Do not separately start `run_auto-26-02-01.sh`: `run_pipeline.py` now restores
each batch's baseline and directly invokes `updateCommit-new.sh`. The archived
legacy entry scripts are not required by `run_all.sh`.

## Environment Requirements

Keep the existing Redis/S2E environment active in tmux 2 and the Pre-knowledge
environment active in tmux 4. Both panes must be free of other jobs before launch.

- The configured LLVM toolchains, S2E installation and project, `tmux`, Git,
  Python 3 with NumPy, `make`, GCC, `clang`, `clang-format`, `llvm-link`, `sancov`,
  `s2e`, and `taskset` must be available where the scripts use them.
- CPU affinity must allow the configured CPUs: 30, 45 and 57. The clean benchmark
  confirmation uses server CPU 45 and client CPU 57.
- Ports 6379 and 16379 must be free. Run only one experiment using the shared
  Redis/S2E/Pre-knowledge resources; the legacy runners use `pkill redis-server`.
- Keep `redis/` clean and retain the required commits in both `redis/` and
  `/data2/sjz/Pre-knowledge/redis-version/redis`.
- Retain `/data/sjz/commit-analysis/redis-run/dump.rdb` and
  `/home/sjz/S2E/s2e/projects/redis-server/launch-s2e.sh`.
- Shared handshake files must not be left over from a previous run. Preflight
  identifies them; establish that no job owns them before archiving leftovers.

Preflight catches missing inputs, busy panes, conflicting experiment processes,
occupied ports, stale handshake files and missing Git commits. It does not prove
that every historical commit will compile or that every testcase will succeed.

## Batch Order

[commit/batches.tsv](commit/batches.tsv) defines the execution order and the
baseline, Makefile and socket template for each batch:

| Order | Group | Commit List | Commits |
| ---: | --- | --- | ---: |
| 1 | `1` | `commit/commit-1.new` | 18 |
| 2 | `2` | `commit/commit-2.new` | 19 |
| 3 | `3` | `commit/commit-3.new` | 74 |
| 4 | `8` | `commit/commit-8.new` | 22 |
| 5 | `9-2` | `commit/commit-9-2-new.txt` | 17 |
| 6 | `9-3` | `commit/commit-9-3-new.txt` | 23 |

The current total is **173 commits**. Lists are read in file order. Both workers
must finish a batch before the next begins. Within a batch, `run.sh` compares the
first commit with the configured baseline, then each commit with its predecessor
in the list. Clean benchmark confirmation compares the reported commit with its
first Git parent.

To change the workload, update both the commit lists and `batches.tsv`, then run
`--check`. Additional commit lists without a manifest entry, duplicate commits,
or missing batch inputs fail validation.

## Logs and Progress

Startup prints `Pipeline logs: /data3/sjz/AE/redis/pipeline-runs/<run-id>`.
Use that exact directory to inspect this run:

```bash
run_dir=/data3/sjz/AE/redis/pipeline-runs/REPLACE_WITH_RUN_ID
tail -F "$run_dir/redis.worker.log" "$run_dir/preknowledge.worker.log"
```

| File Within the Run Directory | Contents |
| --- | --- |
| `plan.json`, `batches.tsv`, `source-snapshot/` | Configuration and input snapshots |
| `<group>/redis.log` | Batch progress, commit start/end records and log paths |
| `<group>/commits/<hash>.log` | Full Redis analysis and measurement output for a commit |
| `<group>/preknowledge.log` | Pre-knowledge output for the batch |
| `<group>/redis.completed.txt` | Commit loop entries that returned successfully |
| `<group>/done.json` | Batch completion marker |
| `redis.status.json`, `preknowledge.status.json` | Worker PID, exit code and any error |
| `generate-report.log`, `confirm-report.log` | Report generation and confirmation output |
| `cancel.json` | Failure or interruption details, when present |

The run is complete when both worker status files have `exit_code: 0` and every
batch has `done.json`. The Redis worker also prints `All batches completed` with
the final report count. A completed commit loop does not imply that every testcase
produced a valid measurement; report-generation logs identify skipped or invalid
results.

## Reports

All report directories are created automatically, after all batches finish:

| Directory | Purpose |
| --- | --- |
| `report/` | Candidate reports generated from valid `final-res.txt` files |
| `report-confirmation/<run-id>/` | Confirmation summaries, clean builds, server/benchmark logs and accepted report copies |
| `report-final/<commit>/` | Final selection for that commit, named `<commit>-<case>.md` |

Final reports are grouped by the full commit hash. Multiple cases for the same
commit share its directory; even a single report is placed in a commit directory:

```text
report-final/
  <commit-a>/
    <commit-a>-3.md
    <commit-a>-6.md
  <commit-b>/
    <commit-b>-1.md
```

The default threshold is a slowdown **greater than or equal to 2%**. Commands
listed in `redis-order-null.txt` are filtered when generating reports; the list
does not skip their execution during the analysis stage.

1. A case is retained directly only if `symbolic_testcase.txt` is nonempty and
   its symbolic-path slowdown meets the threshold.
2. Other qualifying cases need a benchmark, including cases with empty or
   missing symbolic values, and cases qualifying only through default execution.
3. Confirmation builds clean old/new Redis sources and runs each version once
   with **1,000,000 requests, pipeline depth 10, and 50 clients**. This corresponds
   to `redis-benchmark -n 1000000 -P 10`; the script also supplies the testcase,
   connection options and `--csv` for parsing the results.
4. Benchmark slowdown is `(old_rps / new_rps - 1) * 100`. A value of at least 2%
   retains the report. Unsupported cases and errors remain in the confirmation
   summary and are not automatically accepted.

If there are no candidates, `report-final/` is created empty and confirmation is
skipped. Final reports omit `modified part` and `icount diff`; raw result files
remain complete. New timing labels are English; the report parser also accepts
historical Chinese labels.

## Stop, Restart and Archive

To stop, attach to tmux 2 and press `Ctrl-C`. The coordinator records cancellation
and the peer stops its owned task. Wait for both workers to exit and inspect their
logs and any remaining Redis/S2E processes before restarting.

**Restarting is a new full run, not a resume.** A fresh `run_all.sh` starts from
the first batch and first archives recognized previous outputs under
`/data3/sjz/AE/redis-brk/<timestamp>/`. The archive includes the old reports,
per-commit results, run logs, a source snapshot and `manifest.json`.

To archive current Redis outputs without starting a run:

```bash
bash /data3/sjz/AE/redis/run_all.sh --archive-only
```

This automatic archive applies to the Redis project. The legacy Pre-knowledge
files moved during cleanup are separately retained in
`/data2/sjz/Pre-knowledge-redis-brk-9-21/`.

Keep these active inputs in place:

- Redis: `redis/`, `commit/` including `commit/makefile/`, `tools/`, the current
  scripts, command lists and `panda.so`.
- Pre-knowledge: `updateCommit-new.sh`, `demo-1.sh`, `demo-2.sh`, their analysis
  tools and command lists, `redis/`, `redis-version/redis/`, `makefile-26-02-01/`,
  `socket-26-02-01/`, and the baseline `init_file_<commit>/` and `re-build-<commit>/`
  directories. The unnumbered `Makefile` is used during execution.

## Regenerate Reports from Existing Results

These commands are separate from a full experiment. Use them when raw results
already exist and no other report-generation or confirmation job is active:

```bash
cd /data3/sjz/AE/redis
python3 generate_perf_report.py --dry-run
python3 generate_perf_report.py
python3 confirm_perf_reports.py
```

The first command previews candidates; the second refreshes `report/`. The third
only previews the confirmation plan. If candidates exist, run confirmation with:

```bash
python3 confirm_perf_reports.py --execute --requests 1000000 --pipeline 10
```

This automatically refreshes `report-final/`. For single-report selection and
other confirmation options, see [confirm_perf_reports.md](confirm_perf_reports.md).
For pipeline details, see [run_all.md](run_all.md). `run.sh` alone only runs the
Redis side and requires a matching Pre-knowledge worker; use `run_all.sh` for the
complete workflow.
