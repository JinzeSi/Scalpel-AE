# Scalpel AE

This document describes the experiment order, launch commands, and final result
locations for the artifact at `/data3/sjz/AE`.
These instructions assume the existing AE machine has LLVM, S2E, Docker, and the
required dependencies configured. The Redis and MySQL scripts still reference
external absolute paths; copying the project directories alone does not configure
a new machine.

## Experiment Order

Run the experiments in the following order:

```text
perfscope -> apollo -> redis -> mysql
```

**Do not run experiments concurrently: competing workloads can interfere with
performance measurements.** Wait for all analysis, measurements, and report
confirmation in one experiment to finish before starting the next.
Run each tool's target projects sequentially as well, and avoid other heavy
workloads during measurements.

## 1. PerfScope

See the [PerfScope README](perfscope/README) for environment setup, Docker launch
instructions, and commands for each target project. Run the targets one at a time
and finish all PerfScope runs before proceeding to the next experiment.

## 2. Apollo

See the [Apollo README](apollo/README.md) for the Python 2 environment, target
commits, fuzzing commands, and result inspection. Run the four targets one at a
time, using the documented 10-hour duration for the full evaluation.

For example, start a full run for `0fa789a` with:

```bash
cd /data3/sjz/AE/apollo
conda activate apollo-py2
./ae/run-0fa789a.sh 10h
```

The other targets are `cd66c5c`, `c17d86b`, and `6ba1fef`; use their corresponding
`ae/run-<commitId>.sh` scripts after the preceding run has finished.

The commands use the prepared MySQL installations under `apollo/opt/` and the
built SQLSmith executable. These generated dependencies are excluded from Git;
the source checkout alone does not provide a ready-to-run environment.

## 3. Redis

The single-command entry point is `redis/run_all.sh`. It runs all configured
batches, performance analysis, report generation, and confirmation.
Before starting, ensure that tmux panes `2:0.0` and `4:0.0` are both idle:
the former runs the Redis workflow, and the latter runs Pre-knowledge updates.

Run the preflight check, preferably in the prepared environment in tmux `2:0.0`:

```bash
cd /data3/sjz/AE/redis
bash run_all.sh --check
```

After the check passes, start the complete workflow:

```bash
bash /data3/sjz/AE/redis/run_all.sh
```

`--check` checks the environment and inputs without starting experiments.
The full workflow can also be launched from an ordinary terminal; the launcher
starts the workers in the prepared tmux panes.
**Returning to the ordinary terminal's prompt does not mean the experiment has
finished.** Do not launch from tmux `4:0.0` or start a second copy.
Wait for `All batches completed` and confirm that the related tasks in both
panes have finished before starting MySQL.

See the [Redis README](redis/README.md) for details.

## 4. MySQL

The corresponding entry point is `mysql/run_all.sh`. It processes every commit
in `commit-tmp.txt` with live Pre-knowledge, then automatically screens
candidates, confirms them, and publishes the final reports.
**Wait for the complete Redis workflow to finish first. Both tmux panes
`2:0.0` and `4:0.0` must be idle.** Keep the prepared LLVM/S2E environment active
in tmux `2:0.0` and the Pre-knowledge environment active in tmux `4:0.0`.

The launcher runs the MySQL workflow in tmux 2 and automatically starts the
Pre-knowledge worker from `/data2/sjz/Pre-knowledge-mysql` in tmux 4. Both workers
use the same commit list and exchange fresh analysis results for each commit.
Do not start the Pre-knowledge worker separately.

Run the preflight check in tmux `2:0.0`:

```bash
cd /data3/sjz/AE/mysql
bash run_all.sh --check
```

After the check passes, start the complete workflow:

```bash
bash /data3/sjz/AE/mysql/run_all.sh
```

`--check` does not run experiments. It checks the invoking shell's environment,
so run it in the prepared tmux 2 environment.
The full workflow can also be launched from an ordinary terminal; the launcher
submits it to the idle tmux `2:0.0` pane. Returning to that terminal's prompt
only means the command was submitted.
Do not launch from tmux `4:0.0` or start a second copy.
Wait for MySQL analysis, live Pre-knowledge, and report confirmation to finish.
Both workers must exit with code `0` for the paired run to count as successful;
the first-round completion message does not mark the end of the workflow.

See the [MySQL README](mysql/README.md) for details.

## Final Results

All paths below are relative to `/data3/sjz/AE`. Only final results are listed.

| Experiment | Final Result Location |
| --- | --- |
| PerfScope / Redis | `perfscope/redis/redis.res` |
| PerfScope / MySQL | `perfscope/mysql-server/mysql.res` |
| PerfScope / httpd | `perfscope/httpd/httpd.res` |
| PerfScope / RocksDB | `perfscope/rocksdb/rocksdb.res` |
| PerfScope / MariaDB | `perfscope/mariadb-server/mariadb.res` |
| Apollo | `apollo/reproduced/<commitId>/run-YYYYmmdd-HHMMSS/summary.txt` and `candidates/` in the same run directory |
| Redis | `redis/report-final/` |
| MySQL | `mysql/report-final/` |

PerfScope's `.res` files contain scores and regression judgments for each commit;
`TRUE` indicates a detected performance regression. With the Docker volume mount
described in its README, these files are available at the host paths above.

Both Redis and MySQL organize final reports as
`report-final/<commit>/<commit>-<case>.md`.
The final directory may be empty when no reports meet the retention criteria.
The presence of a result directory or older reports does not establish that the
current run has completed.

## Replication Package

The [replication package](replication%20package/) contains the analysis spreadsheet
in `(1)analysis_results/` and evaluation PDFs in `(2)evaluation_results/`:

| Dataset | Directory Within `(2)evaluation_results/` |
| --- | --- |
| RocksDB | `(1) Rocksdb dataset/` |
| MySQL | `(2) MySQL dataset/` |
| httpd | `(3) Httpd dataset/` |
| MariaDB | `(4) MariaDB dataset/` |

## License

This artifact includes multiple projects with separate licenses. Existing
copyright notices, license files, and source-file notices apply to their
respective components. Key license references include:

| Component | License Reference |
| --- | --- |
| PerfScope | [Apache License 2.0](perfscope/COPYING) |
| S2E | [MIT License and component-specific licenses](S2E/s2e/source/s2e/LICENSE) |
| Redis source | [Redis license terms](redis/redis/LICENSE.txt); licensing depends on the version under evaluation |
| MySQL source | [GPLv2 with additional permissions and dependency notices](perfscope/mysql-server/LICENSE) |

Bundled dependencies and other source trees retain their own license terms.
For experiments that check out historical commits, consult the license files
and notices at the exact revision being used.

A separate license for the AE-specific scripts and documentation has not yet
been specified. The component licenses above do not constitute a single license
for the entire repository.
