# MySQL and Pre-knowledge paths

The MySQL analysis and Pre-knowledge scripts accept machine-specific paths after their existing arguments. Positional paths take precedence over the listed environment variables.

| Script | Position | Environment variable | Default | Purpose |
| --- | --- | --- | --- | --- |
| `mysql/make_symbolic-NULLEND.sh` | 3 | `AE_MYSQL_DIR` | Directory containing the script | MySQL AE files, sources, and tools |
| | 4 | `MYSQL_PREKNOWLEDGE_DIR` | Sibling `Pre-knowledge-mysql/` directory | Pre-knowledge `link.py` |
| | 5 | `MYSQL_LLVM_BIN_DIR` | Directory containing `clang` on `PATH` | LLVM compiler and linker |
| | 6 | `MYSQL_SYMBOLIC_TOOLS_DIR` | Required | Directory containing `include/` and `lib/` for symbolic instrumentation |
| | 7 | `MYSQL_TEST_DATA_FILE` | `Pre-knowledge-mysql/mysql-data/tables.tar.gz` | MySQL test database archive |
| | 8 | `S2E_ROOT` | `$HOME/S2E/s2e` | S2E installation and `projects/mysqld` |
| `Pre-knowledge-mysql/updateCommit-new-mysql.sh` | 2 | `MYSQL_PREKNOWLEDGE_DIR` | Directory containing the script | Pre-knowledge files |
| | 3 | `MYSQL_PREKNOWLEDGE_SOURCE_ROOT` | Sibling `mysql/` directory | MySQL source checkout containing `mysql-server-2` |
| | 4 | `MYSQL_PREKNOWLEDGE_LLVM_BIN_DIR` | Directory containing `llvm-dis` on `PATH` | LLVM compiler, linker, and disassembler |
| | 5 | `MYSQL_PREKNOWLEDGE_BOOST_DIR` | `mysql-server-2/boost_1_77_0` under the source root | Boost headers for the Pre-knowledge build |
| | 6 | `MYSQL_HANDOFF_FILE` | `call_analyse2.txt` in the repository root | Pre-knowledge result file |

The existing arguments remain first: the MySQL analysis script takes old and new commit IDs, and the Pre-knowledge script takes a commit-list filename. Supply positional paths in table order. If the scripts run from separate checkouts or machines, point `MYSQL_HANDOFF_FILE` to a location accessible to the intended consumer.

S2E is the symbolic-execution framework that runs the instrumented MySQL program. `S2E_ROOT` is the `s2e` directory containing `projects/mysqld`.

LLVM compiles MySQL to bitcode for analysis. The two LLVM path parameters identify directories containing the required `clang`, `clang++`, and `llvm-link` executables; the Pre-knowledge build also uses `llvm-dis` to produce readable LLVM IR.

The separate MySQL launcher and shared `run-common.sh` still contain other path-dependent setup and preflight checks. These script arguments cover the paths in the two scripts listed above; the full pipeline needs its remaining path configuration migrated separately.
