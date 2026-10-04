# MySQL tool sources

The MySQL-specific files are copies from `commitanalysis/llvm-analysis/tools++/`. The shared `get_redis_*` and `jsonAnalyze*` sources are copies from `commitanalysis/llvm-analysis/tools/`. The executables remain in `../tool/`.

| Executable in `../tool/` | Source file |
| --- | --- |
| `commit_analyzer++` | `commit_analyzer++.cpp` |
| `call_analyzer++` | `call_analyzer++.cpp` |
| `symbolic_analyzer++` | `symbolic_analyzer++.cpp` |
| `make_symbolizer++` | `make_symbolizer++.cpp` |
| `real_executor++` | `real_executor++.cpp` |
| `get_redis_1` | `get_redis_1.cc` |
| `get_redis_2` | `get_redis_2.cc` |
| `jsonAnalyze` | `jsonAnalyze.cc` |
| `jsonAnalyze-icount` | `jsonAnalyze-icount-new.cc` |

`jsonAnalyze-icount.cc` is retained as an earlier variant. The existing `jsonAnalyze-icount` binary contains the source filename `jsonAnalyze-icount-new.cc`.
