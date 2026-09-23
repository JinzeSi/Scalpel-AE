# MySQL script semantics audit

Date: 2026-09-22

Reference: `/data/sjz/commit-analysis/mysql-run`
Target: `/data3/sjz/AE/mysql`

## Restored behavior

- Symbolic compilation failure records the error and continues to the independent
  real-execution phases, for both new and old versions.
- Removed added pipeline failure propagation and experimental-command early exits.
  S2E exit handling again uses the original timeout status check (124).
- Restored the original analysis block parsing and symbolic testcase lifetime.
  In particular, there is no added per-case deletion of `symbolic_testcase.txt`.
- Native mysqlslap has no timeout. Each measurement uses one client, one iteration,
  and 10,000 queries, with the same mysqlslap binary as the reference.
- Restored the ten-second startup delay without an extra readiness query, and
  removed added `--skip-networking` and `--mysqlx=OFF` server arguments.
- The batch driver continues after a child failure and advances the previous
  commit as before. Pre-knowledge waits indefinitely by default; a positive
  `PREKNOWLEDGE_WAIT_SECONDS` can still opt into a timeout.

## Checked unchanged

- All 13 files in the local `tool` bundle are byte-identical to the reference.
- `bootstrap.sh`, all four `run-getres` scripts, `draw.py`, `transform.py`, and
  `run-mysql-val.sh` are byte-identical to the reference.
- `run_auto-1.sh`, `run_auto-no-exe.sh`, and `summary.py` match after path relocation.
- The no-execution and validation scripts retain their experimental flow; their
  differences are common setup, relocated paths, fresh build directories, and
  the explicit Boost path needed by a fresh validation build.
- The default commit list still contains all 135 commits.
- Symbolic `-O0` and native `-O2` settings are unchanged. Explicit
  `RelWithDebInfo` matches the copied historical CMake caches.

## Retained migration and execution differences

- Source/tool paths point into the target directory. Fresh `build-ae-*`
  directories avoid absolute paths retained in copied CMake caches.
- Input checks, run locking, directory-change guards and Git-operation guards
  remain. Failures in these prerequisites stop execution.
- The live Pre-knowledge wrapper retains its commit-list handshake and complete
  request/reply checks. Archived replay bypasses this worker entirely.
- Archived replay checks out the actual first parent, relocates paths in copied
  analysis files, saves script snapshots, and archives each run separately.
- Process cleanup targets only the launched mysqld or S2E process group, instead
  of the reference's broad process-name kills. S2E still has a 600-second limit;
  `timeout --kill-after=10s` additionally bounds cleanup. Forced cleanup can return
  137, which the original status-124-only branch does not classify as a timeout.
- Server stdout/stderr redirection is corrected. Benchmark output is still
  appended to `error.log` as in the reference.
- The old-version source backup uses `${command}-old` in place of the reference's
  undefined `$command_old`. This affects artifact location, not instrumentation.

After normalizing paths, build-directory names, explicit cached build type and
directory/Git guards, the downstream analysis/test loop differs only in S2E
cleanup and the old-version source backup destination.

## Historical limitations retained

`6ba1fef` has a new-version symbolic compilation error in `rec.h` caused by
passing a const pointer to the generated symbolic helper. The reference run
recorded that error and nevertheless completed the native measurements. This
repair restores that continuation; it does not change the instrumenter.

The original instruction-count extractor can emit an empty result for a trace
without a matching symbolic testcase, even when the raw JSON has an instruction
count. The statistics scripts can also leave a partial `final-res.txt`. Their
formulas, extraction rules, and historical modified-part timing behavior are
unchanged. Exit status zero alone is not evidence that every metric is valid.

The reference scripts, `brk-5-5` archive, previous replay archive, and original
Pre-knowledge files are preserved. Installed scripts receive numbered backups.

## Subsequent user-requested query-count change

The user subsequently replaced fixed query counts with the per-testcase mapping
in `/data3/sjz/AE/mysql/sql-times.txt`: normal/replay execution uses the mapped
count and validation uses twice that count. This intentionally supersedes the
fixed 10,000-query workload described in the migration audit above. New and old
versions of a testcase use the same count within each workflow. Lookup failures
stop the individual runner before MySQL starts; outer pipeline failure handling
is unchanged. New replay archives include the mapping and lookup script.

## Full 135-commit run using archived replies

The normal workflow now recomputes all analysis and builds. Only the request
for `call_analyse2.txt` is replaced by a read from `brk-5-5/<commit>/`.
The no-code-change branch still exits before result archival and allows the
expected absent reply; other commits require the file but allow it to be empty.
The old full-analysis shortcut remains exclusive to `run-replay.sh`.

The downstream test loop was compared again with the reference after normalizing
paths, build directory names, explicit cached build type, and directory/Git
guards. Its remaining differences are scoped S2E process cleanup, recognition
of both timeout exit codes (124 and forced-cleanup 137), and the previously
documented old-version source-backup path correction. In particular, symbolic
compilation failure still records diagnostics and continues to real execution.
Both timeout statuses now follow the same timeout branch; neither adds an exit.

`run_auto.sh` preserves previous root-level results and saves per-commit logs,
source diffs, results, and actual exit statuses in a unique full-run directory.
It retains the commit order, first-parent pairing, and continuation after a
commit failure. These archival changes do not alter individual experiments.
