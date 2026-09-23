# Replay archived analysis

For the full normal workflow, use `run_all.sh` as documented in `README.md`.
It recomputes analysis and builds and runs live Pre-knowledge in tmux 4.
The shortcut below is an explicit historical replay; it reuses archived analysis
and replies and is never selected by the normal one-click workflow.

Run from the LLVM/S2E environment (the existing tmux 2 pane):

```bash
cd /data3/sjz/AE/mysql
bash run-replay.sh
```

The default selection is `cd66c5c`, `c17d86b`, `0fa789a`, and `6ba1fef`.
To run one commit, pass its full or abbreviated hash:

```bash
bash run-replay.sh cd66c5c
```

Each commit is compared with its first parent. The driver reads the archived
analysis files from `/data/sjz/commit-analysis/mysql-run/brk-5-5/<commit>/`.
Set `MYSQL_ANALYSIS_ARCHIVE` to use another archive with the same layout.
The original archive and the default 135-commit list are unchanged.

`make_symbolic-NULLEND.sh` accepts `MYSQL_ANALYSIS_DIR` as an optional input.
With this variable set, it regenerates both compilation databases and generated
headers, relocates source paths in local copies of the analysis, and resumes at
the existing instrumentation/test loop. It skips commit/call analysis, bitcode
builds, and the Pre-knowledge request. `mysql-server-2` is not checked out or
built. Without the variable, the full workflow recomputes analysis and reads
only `call_analyse2.txt` from `MYSQL_CALL_ANALYSIS_ARCHIVE`.

The archived replies select 1, 1, 8, and 1 test cases respectively. Entries
containing `testcase:no testcase` are skipped by the existing loop. The previous
`6ba1fef` run has a symbolic instrumentation compilation error in `rec.h`; this
replay does not assume that all archived cases succeeded.

The driver requires a clean `mysql-server` worktree and takes the same lock as
`run_auto.sh`. Each run creates `replay-<timestamp>.<suffix>/` containing:

- `commits.txt`: selected full hashes.
- `<commit>.log`: compilation, instrumentation and execution output.
- `<commit>.instrumentation.patch`: source changes left by that commit's run.
- `status.tsv`: actual parent, exit status and elapsed seconds for each commit.
- `results-root.txt`: points to the MySQL root, where `<commit>/` and
  `<parent>-old/` remain after replay. Older replay batches used `results/`.
- `exit-status.txt`: aggregate exit status, written when all commits finish.

As in the original script, symbolic compilation failure and S2E timeout are
recorded while later real-execution phases continue. Tool, compilation, benchmark
and result-parser failures do not add new early exits. Directory changes and
Git checkout failures still stop the run to protect the source tree.
Check logs and per-case `compile.txt`; exit status alone does not establish
that every measurement succeeded. Existing result directories are rejected to prevent
overwriting previous runs. During execution the current commit's results are
at the root and remain there after that commit finishes. Generate reports with
`python3 generate_perf_report.py`; old archived batches can be read with
`--run-dir replay-<timestamp>`. Report generation does not launch validation.

Normal real-execution query counts now come from the matching testcase in
`/data3/sjz/AE/mysql/sql-times.txt`, via `get-sql-times.py`. Both new and old
versions use that same count. Each replay saves the mapping and lookup script
alongside its other script snapshots. Keep the mapping fixed during a run.
This replaces the historical fixed 10,000-query workload at the user's request.
Each S2E invocation retains its 600-second timeout. Real-execution mysqlslap has
no timeout, matching the old script. MySQL waits 10 seconds before the benchmark
without a warm-up query. See `SEMANTICS-AUDIT.md` for the migration audit.
