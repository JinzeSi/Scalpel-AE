# Redis and Pre-knowledge paths

The Redis analysis and Pre-knowledge update scripts accept machine-specific paths after their existing arguments. A positional path takes precedence over the corresponding environment variable; otherwise, the scripts use the default shown below.

| Script | Position | Environment variable | Default | Purpose |
| --- | --- | --- | --- | --- |
| `redis/make_symbolic-NULLEND.sh` | 3 | `AE_REDIS_DIR` | Directory containing the script | Redis AE files and tools |
| | 4 | `PREKNOWLEDGE_DIR` | Sibling `Pre-knowledge/` directory | Pre-knowledge files and inputs |
| | 5 | `REDIS_HANDOFF_FILE` | `call_analyse2.txt` in the repository root | Result passed from Pre-knowledge to Redis |
| | 6 | `S2E_ROOT` | `$HOME/S2E/s2e` | S2E installation and Redis S2E project |
| | 7 | `REDIS_LOG_FILE` | `/tmp/redis.log` | Redis log during symbolic execution |
| `Pre-knowledge/updateCommit-new.sh` | 2 | `PREKNOWLEDGE_DIR` | Directory containing the script | Pre-knowledge files and Redis source checkout |
| | 3 | `LLVM_BIN_DIR` | Directory containing `llvm-dis` on `PATH` | LLVM executables |
| | 4 | `REDIS_HANDOFF_FILE` | `call_analyse2.txt` in the repository root | Result passed to Redis |

The existing arguments remain first: Redis takes the old and new commit IDs; Pre-knowledge takes the commit-list filename. When supplying positional paths, pass them in table order. The default handoff file only matches when both scripts are in the same repository tree. For separate checkouts or machines, pass the same shared file as argument 5 to Redis and argument 4 to Pre-knowledge, or set `REDIS_HANDOFF_FILE` for both processes.

S2E is the symbolic-execution framework used to run the instrumented Redis program. `S2E_ROOT` points to its `s2e` directory, which contains `projects/redis-server` and `install/bin/qemu-system-x86_64`.

LLVM is used to compile Redis into bitcode for analysis. `LLVM_BIN_DIR` points to the directory containing both `clang` and `llvm-dis`; the update script uses them to build `final_obj.bc` and generate `final_obj.ll`.

## Full pipeline

`run_all.sh` passes options to `run_pipeline.py`. Supply machine-specific locations when running the complete pipeline:

```bash
bash redis/run_all.sh --preknowledge-root /path/to/Pre-knowledge \
  --handoff-file /shared/path/call_analyse2.txt \
  --s2e-root /path/to/S2E/s2e \
  --redis-data-file /path/to/dump.rdb \
  --llvm-bin-dir /path/to/llvm/bin
```

`--preknowledge-root` defaults to the sibling `Pre-knowledge/` directory, `--handoff-file` to `call_analyse2.txt` in the repository root, and `--s2e-root` to `$HOME/S2E/s2e`. `--redis-data-file` defaults to `redis/dump.rdb`; pass the actual location when it is stored elsewhere. `--llvm-bin-dir` is optional when the Pre-knowledge worker has `llvm-dis` on `PATH`. The pipeline records these paths in `plan.json` and passes the shared settings to both workers. Use the same options with `--check` for preflight.
