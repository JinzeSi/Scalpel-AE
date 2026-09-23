# Full Redis Pipeline

Start from tmux 2 or an ordinary terminal. tmux 2 and tmux 4 must have the prepared
Redis/S2E and Pre-knowledge environments and must be idle:

```bash
bash /data3/sjz/AE/redis/run_all.sh
```

An ordinary terminal launches the job in tmux 2 and returns. Running inside tmux 2
keeps the coordinator in that pane. The coordinator starts its peer in tmux 4.
Both keep running when a tmux client detaches.

Read-only preflight, without starting an experiment or moving files:

```bash
bash /data3/sjz/AE/redis/run_all.sh --check
```

Archive current generated files without running anything:

```bash
bash /data3/sjz/AE/redis/run_all.sh --archive-only
```

## Order and Dependencies

`commit/batches.tsv` is the shared batch definition used by `run.sh` and the
Pre-knowledge worker. The current order is `1, 2, 3, 8, 9-2, 9-3`, with 173 commits.
Each commit list is read in file order. Extra commit lists, duplicate commits,
missing templates, missing baselines, and missing Git objects fail preflight.
When adding a batch, add its baseline, Makefile, and socket mapping to this file.

For each batch, the pipeline restores its existing `init_file_<base>` tables,
copies the matching Pre-knowledge Makefile and socket, and executes the existing
`updateCommit-new.sh` with a snapshot of the same commit list consumed by `run.sh`.
Both workers must finish a batch before the next one starts. A rebuild requested
by `updateCommit-new.sh` still uses the existing `demo-1.sh` / `demo-2.sh` workflow.
It does not run the old `run_auto-26-02-01.sh` startup waits.

Dependencies outside the Redis project remain in place: `/data2/sjz/Pre-knowledge`,
the S2E installation/projects, the LLVM toolchains, `/data/sjz/call_analyse2.txt`
handshake location, and `/data/sjz/commit-analysis/redis-run/dump.rdb`.
Only one experiment may use these shared resources at a time. Existing legacy
instrumentation scripts still control their Redis/S2E processes and timeouts.

`run.sh` also accepts an optional group (`bash run.sh 9-3`) for manual paired runs;
it requires a matching Pre-knowledge task. Use `run_all.sh` for automatic coordination.
It refuses to overwrite an existing per-commit result directory. Missing backup
files at the end of `make_symbolic-NULLEND.sh` no longer cause a false failure.

## Reports

After both workers finish all groups:

1. `generate_perf_report.py` creates `report/`, applying `redis-order-null.txt` and 2% screening.
2. `confirm_perf_reports.py --execute --requests 1000000 --pipeline 10` builds clean
   versions and verifies candidates, with 50 clients and one round per version.
3. The confirmation script automatically publishes `report-final/<commit>/<commit>-<case>.md`,
   grouping all retained cases for a commit in its own directory. Direct retention
   requires nonempty symbolic values and symbolic-mode slowdown of at least 2%.
   Otherwise qualifying cases go through benchmark; unsupported cases require review.
4. If there are no candidates, the final report directory is created empty.

Final reports omit `modified part` and `icount diff`. Original results remain intact.
Errors stop the batch pipeline and are recorded; an incomplete pipeline is never
reported as successfully completed. Legacy analyzer logs remain necessary to diagnose
individual skipped or invalid test cases.

## Archives and Logs

Before each new full run, recognized generated directories and files are moved into
`/data3/sjz/AE/redis-brk/<timestamp>/` with a `manifest.json` and source snapshot.
This includes `redis-<hash>`, `redis-<hash>-old`, reports, confirmation builds, old
trial logs, temporary Makefiles/bootstrap, and the unused backup script/tools copy.
Moves use same-filesystem renames; nothing is deleted. Source `redis/`, `commit/`,
`tools/`, required scripts, command lists, and `panda.so` stay in the project.
Archived reports retain historical source paths; their data moved with the archive.

Each execution writes `pipeline-runs/<timestamp>/`:

- `plan.json`, `batches.tsv`, `source-snapshot/`: exact inputs.
- `<group>/commits.txt`: shared commit list snapshot.
- `<group>/redis.log`, `<group>/commits/<hash>.log`, `<group>/preknowledge.log`: full logs.
- `<group>/redis.completed.txt`, `<group>/done.json`: completed commits and batch status.
- `redis.worker.log`, `preknowledge.worker.log`, `*.status.json`, `*.finished.json`: worker progress/exit.
- `generate-report.log`, `confirm-report.log`: report-generation and confirmation logs.
- `cancel.json`: failure or interruption details, when applicable.

Worker exit code 0 and all batch `done.json` files mean the pipeline finished.
To stop an active run, send Ctrl-C in tmux 2; the peer observes cancellation and
stops its owned command group. Wait for both workers to exit before starting again.
After an interruption, check shared handshake files before restarting; preflight
reports any leftovers instead of consuming stale data. A new launch starts from
the first batch and archives previous partial outputs.
