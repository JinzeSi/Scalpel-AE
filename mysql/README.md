# MySQL Performance Analysis

Run the complete 135-commit list with live Pre-knowledge, screen candidates, confirm them,
and publish the retained reports to `report-final/`.

This README describes the installation at `/data3/sjz/AE/mysql`. The analysis
scripts still use the configured external LLVM, S2E and testcase paths; copying
this directory alone does not configure a new machine.

## Start a Full Run

**Let Redis finish using tmux 2 first.** Keep the prepared LLVM/S2E environment
active in that pane and the Pre-knowledge environment active in tmux `4:0.0`.
Both panes must be idle. Then check the inputs from tmux `2:0.0`:

```bash
bash /data3/sjz/AE/mysql/run_all.sh --check
```

`--check` is read-only: it does not send tmux keys, change files, build MySQL,
execute testcases or generate reports. It checks the invoking shell's environment;
from an ordinary terminal, a missing `s2e` may mean that the prepared environment
is only active in tmux 2. Run the check there before starting.

Start the complete workflow from tmux 2 or an ordinary terminal:

```bash
bash /data3/sjz/AE/mysql/run_all.sh
```

When invoked outside tmux 2, the launcher submits this command to its idle pane:

```bash
cd -- /data3/sjz/AE/mysql && bash ./run_all.sh
```

Inside tmux 2, the launcher explicitly changes to the MySQL directory. It starts
the real Pre-knowledge worker in tmux 4 after `cd /data2/sjz/Pre-knowledge-mysql`,
waits for readiness, then runs `bash run_auto.sh --confirm`. Each side uses the
environment already active in its pane. A busy pane,
including background jobs associated with its terminal, or an occupied MySQL
run lock blocks startup. The launcher does not queue an automatic run after Redis.

| Pane | Role |
| --- | --- |
| `2:0.0` | All MySQL analysis, S2E execution, measurements, screening and confirmation |
| `4:0.0` | Live Pre-knowledge updates, testcase generation and required rebuilds |

An outside-terminal return means the launch command was **submitted**, not that
preflight or the experiment succeeded. Inspect tmux 2 for startup output. Inside
tmux 2, the command remains in the foreground until the workflow ends. Detach
with `Ctrl-b`, then `d`, to leave it running. Start only one copy. Do not separately
start Pre-knowledge's `run_auto.sh`; the launcher initializes its baseline and
calls its existing `updateCommit-new-mysql.sh` with the same list as MySQL.

## Inputs and Execution Order

The one-click entry always selects the full local [commit-tmp.txt](commit-tmp.txt),
currently **135 commits**, even if `MYSQL_COMMIT_FILE` was set for an older trial.
It starts with parent `27cd03548955749bd18c30e0e96ea798937375f0`, then compares
each commit with the preceding entry. Preflight checks the first-parent chain.
The old 37-43 and 125-135 selections are not used.

1. `run_auto.sh` runs `make_symbolic-NULLEND.sh` for every commit in file order.
2. `/data2/sjz/Pre-knowledge-mysql/updateCommit-new-mysql.sh` processes the same
   commit sequence, builds current bitcode, updates the tables and performs any
   required rebuilds. MySQL sends its fresh call and symbolic analysis to it.
3. `call_analyse2.txt` is the real worker's newly generated reply. Even a commit
   with no C/C++ modification sends an empty request so both sides advance together.
   The analysis, compilation, S2E and measurement steps otherwise run normally.
4. After all first-round commits have been attempted, `run-report.sh --execute`
   screens this run's measurements and confirms its candidates.
5. Accepted reports are published to `report-final/<commit>/`.

Both workers read the same commit-list snapshot. Requests carry the commit hash;
replies are published atomically under this run and hash. The full workflow never
reads `brk-5-5` replies. `MYSQL_CALL_ANALYSIS_ARCHIVE` has no effect on this entry.
Old `full-...` and `replay-...` trial directories are not inputs to a fresh run.

## Environment Requirements

- Keep independent `mysql-server/` and `mysql-server-2/` checkouts with their Git
  history and `boost_1_77_0/`. Tracked source files must be clean at startup.
- Keep the local `tool/`, scripts and [sql-times.txt](sql-times.txt).
- The prepared environment must provide `s2e`, Git, Python 3, CMake, make,
  timeout and flock. The launcher also needs tmux and ps. Native confirmation
  uses `/usr/bin/cc` and `/usr/bin/c++`.
- Retain LLVM at `/data/sjz/llvm-18.1.8`, symbolic headers/libraries under
  `/data/sjz/commit-analysis/llvm-analysis/tools/{include,lib}`, testcase data at
  `/data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz`, and
  `/data/sjz/commit-analysis/mysql-8.4.4/build/bin/mysqlslap`.
- Retain `/home/sjz/S2E/s2e/projects/mysqld/launch-s2e.sh`. Run only one experiment
  using these source trees and this S2E project at a time.
- Pre-knowledge uses its existing `/data2/sjz/mysql/mysql-server{,-2}` sources,
  build directories and LLVM toolchains, the shared Boost directory, `sancov`
  in tmux 4, and `mysql-BB/init_file_27cd03548955749bd18c30e0e96ea798937375f0`.
  Preserve hand edits in both source trees before startup. The only accepted
  tracked change is `mysql-server/sql/sql_parse.cc` exactly matching a saved
  instrumentation template with no staged edits. Startup snapshots both source
  patches, HEADs and parser files before the worker runs. The live worker updates
  its tables in place and restores its baseline on each fresh run.

Preflight checks both panes, run locks, main and peer input files, commit history,
clean sources and main build-cache locations. The peer checks its own environment
in tmux 4 before becoming ready. It does
not prove that every historical commit compiles or every testcase succeeds.
If an older S2E process holds `.run_auto.lock`, inspect it with
`fuser -v /data3/sjz/AE/mysql/.run_auto.lock`; do not remove the lock file to bypass it.

## Query Counts and Confirmation

[sql-times.txt](sql-times.txt) maps each SQL testcase to its execution count.
Normal measurements use that count; native confirmation uses **twice that count
on each version**, with one mysqlslap client and one iteration. Matching ignores
leading/trailing whitespace only. Missing mappings or invalid counts are errors.

The default screening threshold is a slowdown **greater than or equal to 2%**
in either valid end-to-end execution mode. Invalid timings, mismatched counts,
failed commits and affected compilation failures are excluded.

Confirmation follows the Redis retention rules:

1. Nonempty saved symbolic values plus a valid symbolic-mode slowdown of at
   least 2% retain the report directly (`direct_report`), without another benchmark.
2. Other qualifying candidates use clean native builds of the commit and its
   actual first parent. SQL is executed with the doubled mapped count.
3. Native slowdown is `(new seconds / old seconds - 1) * 100`. At least 2%
   produces `benchmark_confirmed`; otherwise the result is `not_reproduced`.
4. `manual_review` and `error` entries remain in the confirmation summary and
   are not published as confirmed reports.

Clean confirmation builds use their own sources, data directories and sockets.
They do not overwrite first-round results. See
[confirm_perf_reports.md](confirm_perf_reports.md) for options and full details.

## Results and Progress

Startup prints `Pipeline logs: /data3/sjz/AE/mysql/pipeline-runs/<run-id>`.
Its `mysql.log` and `preknowledge.log` contain each side's execution output.
`mysql-run-dir.txt` identifies the new `full-...` directory with per-commit logs.
Use these exact new directories to inspect this run:

```bash
pipeline_dir=/data3/sjz/AE/mysql/pipeline-runs/REPLACE_WITH_RUN_ID
tail -F "$pipeline_dir/mysql.log" "$pipeline_dir/preknowledge.log"
run_dir=$(cat "$pipeline_dir/mysql-run-dir.txt")
tail -n 20 "$run_dir/status.tsv"
tail -F "$run_dir/COMMIT_HASH.log"
```

`status.tsv` gains a row when a commit finishes; `mysql.log`'s latest `START` line
identifies the currently running commit. Failures after a completed reply can
continue to later commits. A failure before the exchange stops the pair to avoid
misaligning the lists. Peer failures also cancel the MySQL worker.

| Location Relative to the MySQL Directory | Contents |
| --- | --- |
| `pipeline-runs/<run-id>/plan.json`, `commits.txt`, `source-snapshot/` | Shared list, configuration and both sides' scripts |
| `pipeline-runs/<run-id>/{mysql,preknowledge}.status.json` | Worker PID, exit code and any error |
| `pipeline-runs/<run-id>/replies/<commit>.txt`, `ack/<commit>` | Fresh reply and completed exchange per commit |
| `pipeline-runs/<run-id>/cancel.json` | Paired-run failure or interruption |
| `<commit>/<case>/`, `<parent>-old/<case>/` | First-round raw results, retained at the root |
| `<commit>/run-status.tsv` | Parent, exit status and owning run directory |
| `full-.../commits.txt`, `run-input.txt`, script snapshots | This run's inputs |
| `full-.../<commit>.log`, `status.tsv` | Per-commit logs and completed entries |
| `full-.../<commit>.<repo>.patch` | Generated tracked source edits before restoration |
| `full-.../confirmation.log` | Screening and confirmation output |
| `report/` | Candidate Markdown, `candidates.json`, `cases.csv`, `commits.csv` |
| `report-confirmation/<run-id>/` | Confirmation plan, builds, measurements, summaries and retained copies |
| `report-final/<commit>/<commit>-<case>.md` | Final selected reports |

`full-.../exit-status.txt` covers only the first round.
`confirmation-exit-status.txt` covers screening/confirmation, and
`workflow-exit-status.txt` covers analysis, screening and confirmation: `0` means
those stages returned successfully; nonzero means at least one failed.
**The paired run is complete only when both `mysql.status.json` and
`preknowledge.status.json` have `exit_code: 0`.** If a completion
marker is absent, do not assume the workflow completed. A successful driver
status does not imply every testcase produced a valid measurement; inspect the
screening CSV and confirmation summary for exclusions and errors.

Final reports omit `modified part` and `icount diff`; raw results remain complete.
With no candidates, confirmation publishes an empty generated final selection
without native builds. Generated reports are refreshed; manually edited or
unrelated report files are protected.

## Restart and Existing Results

Starting `run_all.sh` again is a **new full run**, not a resume. Before each commit,
the driver moves conflicting old root-level result directories into the new
`full-.../previous-results/`. New raw results stay at the MySQL root and are not
automatically placed in `full-.../results/`.

Historical run directories are retained. The launcher does not archive or delete
them. The directory for manual backups and cleanup remains `/data3/sjz/AE/mysql-brk`.
Previous reports are replaced by fresh generated reports only when their stages
complete; consult the new run's completion marker rather than old report presence.

If interrupted with `Ctrl-C` in tmux 2, the coordinator records cancellation and
stops its owned task; the peer detects cancellation and stops its owned task too.
Inspect remaining MySQL/S2E processes and tracked source edits before restarting.
The first-round worker can leave partial results
or generated source edits; preserve anything needed before restoring clean trees.
The launcher never kills another job or discards source edits to force a restart.

## Reports from Existing Results

These commands are separate from a new experiment and should be run when no
other reporting or confirmation job is active:

```bash
cd /data3/sjz/AE/mysql
python3 generate_perf_report.py --dry-run
bash run-report.sh
bash run-report.sh --execute
```

The first command previews screening; the second writes screening reports and
previews confirmation; the third also executes confirmation. These use the
root-level results. An explicit `--run-dir /path/to/completed-run` is supported
for historical inspection but is not required for future 135-commit runs.

`run_auto.sh` and `run-preknowledge.sh` are internal paired-run entries; use
`run_all.sh` to initialize and coordinate them. For confirmation of existing
candidates alone, use `bash validate_auto.sh --execute`.
See [README-run.md](README-run.md) for lower-level execution details and
[README-replay.md](README-replay.md) for archived-analysis replay.
