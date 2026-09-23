# Redis 性能分析运行说明

本项目按配置依次运行 Redis commit，生成潜在性能问题报告，并自动将最终筛选结果写入 `report-final/`。

本说明对应当前机器上的环境：

- Redis 项目：`/data3/sjz/AE/redis`
- Pre-knowledge：`/data2/sjz/Pre-knowledge`

脚本中包含绝对路径，因此仅将项目目录复制到其他机器，并不能直接获得可运行的环境。
英文版见 [README.md](README.md)。

## 一键运行

可以在已经配置好环境的 **tmux 2** 中启动，也可以在普通终端中启动。
启动前，tmux 2 和 tmux 4 都必须处于空闲状态。

先执行预检查：

```bash
cd /data3/sjz/AE/redis
bash run_all.sh --check
```

`--check` 只检查环境和输入文件，不启动实验、不移动结果，也不生成报告。
如果检查报错，先处理报错，再正式启动：

```bash
bash /data3/sjz/AE/redis/run_all.sh
```

脚本会自动协调两个 tmux 窗格：

| 窗格 | 职责 |
| --- | --- |
| `2:0.0` | Redis 分析、S2E 执行、性能测量、报告生成和验证 |
| `4:0.0` | Pre-knowledge 更新，以及必要时的重建 |

从普通终端启动时，命令将任务交给 tmux 后返回，表示任务**已经启动**，不代表全部完成。
从 tmux 2 启动时，主控程序会一直在该窗格中运行。
按 `Ctrl-b`，再按 `d` 可以离开 tmux，后台任务会继续运行。
不要从 tmux 4 启动，也不要重复启动第二份任务。

不需要单独运行 `run_auto-26-02-01.sh`。
现在由 `run_pipeline.py` 恢复每批的基线数据，然后直接调用 `updateCommit-new.sh`。
已经归档的旧入口脚本不属于 `run_all.sh` 的运行依赖。

## 环境要求

tmux 2 应保留配置好的 Redis/S2E 环境，tmux 4 应保留配置好的 Pre-knowledge 环境。
正式启动前，两个窗格都不能有其他任务正在运行。

- 已配置的 LLVM 工具链、S2E 安装和项目，以及 `tmux`、Git、Python 3、NumPy、`make`、GCC、`clang`、`clang-format`、`llvm-link`、`sancov`、`s2e`、`taskset`，必须能在脚本使用它们的位置正常访问。
- 当前 CPU 绑定使用 30、45、57 号 CPU，运行环境必须允许访问。干净版本的 benchmark 验证使用服务端 CPU 45、客户端 CPU 57。
- 6379 和 16379 端口必须空闲。同一时间只能有一个实验使用这套共享 Redis/S2E/Pre-knowledge 资源；旧测量脚本中包含 `pkill redis-server`。
- 保持 `redis/` 源码仓库干净，并确保它和 `/data2/sjz/Pre-knowledge/redis-version/redis` 都包含所需 commit。
- 保留 `/data/sjz/commit-analysis/redis-run/dump.rdb` 和 `/home/sjz/S2E/s2e/projects/redis-server/launch-s2e.sh`。
- 不应存在上一次运行遗留的通信标志文件。预检查会指出这些文件；确认没有运行中的任务使用它们后，再归档遗留文件。

预检查可以发现输入缺失、窗格忙碌、冲突实验进程、端口占用、通信标志残留和 Git commit 缺失。
检查通过不代表每个历史 commit 都一定能编译，也不代表每个用例都一定能成功。

## 执行顺序

[commit/batches.tsv](commit/batches.tsv) 定义每批的执行顺序、基线 commit、Makefile 和 socket 模板：

| 顺序 | 批次 | Commit 列表 | Commit 数量 |
| ---: | --- | --- | ---: |
| 1 | `1` | `commit/commit-1.new` | 18 |
| 2 | `2` | `commit/commit-2.new` | 19 |
| 3 | `3` | `commit/commit-3.new` | 74 |
| 4 | `8` | `commit/commit-8.new` | 22 |
| 5 | `9-2` | `commit/commit-9-2-new.txt` | 17 |
| 6 | `9-3` | `commit/commit-9-3-new.txt` | 23 |

当前总计 **173 个 commit**，每份列表按文件中的顺序执行。
Redis 和 Pre-knowledge 两边都完成当前批次后，才进入下一批。

在同一批中，`run.sh` 将第一个 commit 与配置的基线比较，之后将每个 commit 与列表中的前一个 commit 比较。
最终使用干净源码进行 benchmark 验证时，则将报告对应 commit 与它的第一个 Git 父提交比较。

调整任务范围时，需要同步修改 commit 列表和 `batches.tsv`，然后重新执行 `--check`。
如果有未登记的 commit 列表、重复 commit 或缺失的批次输入，检查会失败。

## 日志和进度

启动时会打印：`Pipeline logs: /data3/sjz/AE/redis/pipeline-runs/<run-id>`。
查看日志时，将下面的 `REPLACE_WITH_RUN_ID` 替换为本次实际运行目录名：

```bash
run_dir=/data3/sjz/AE/redis/pipeline-runs/REPLACE_WITH_RUN_ID
tail -F "$run_dir/redis.worker.log" "$run_dir/preknowledge.worker.log"
```

| 运行目录内的文件 | 内容 |
| --- | --- |
| `plan.json`、`batches.tsv`、`source-snapshot/` | 本次配置及输入快照 |
| `<group>/redis.log` | 批次进度、commit 开始和结束记录、详细日志路径 |
| `<group>/commits/<hash>.log` | 单个 commit 的完整 Redis 分析和测量输出 |
| `<group>/preknowledge.log` | 对应批次的 Pre-knowledge 输出 |
| `<group>/redis.completed.txt` | 已正常返回的 commit 循环条目 |
| `<group>/done.json` | 批次完成标志 |
| `redis.status.json`、`preknowledge.status.json` | 两边任务的 PID、退出码及错误信息 |
| `generate-report.log`、`confirm-report.log` | 报告生成和验证日志 |
| `cancel.json` | 失败或中断原因，仅在发生相应情况时出现 |

两份任务状态文件中 `exit_code` 都为 `0`，并且每个批次都有 `done.json`，才表示完整流程结束。
Redis 主控还会打印 `All batches completed` 和最终报告数量。

commit 循环完成，不等于其中每个用例都生成了有效测量结果。
报告生成日志会记录跳过或无效的结果，需要结合这些日志判断具体用例。

## 报告生成和筛选

全部批次完成后，脚本会自动创建报告目录，无需手动创建：

| 目录 | 用途 |
| --- | --- |
| `report/` | 从有效的 `final-res.txt` 中筛选出的候选报告 |
| `report-confirmation/<run-id>/` | 验证汇总、干净源码构建、服务端及 benchmark 日志、保留报告的副本 |
| `report-final/<commit>/` | 对应 commit 的最终筛选结果，文件名为 `<commit>-<case>.md` |

最终报告按完整 commit 号建立子目录。同一 commit 的多个用例放在同一目录中；即使只有一份报告，也放在对应 commit 子目录下：

```text
report-final/
  <commit-a>/
    <commit-a>-3.md
    <commit-a>-6.md
  <commit-b>/
    <commit-b>-1.md
```

默认阈值为执行变慢**大于或等于 2%**。
`redis-order-null.txt` 中列出的命令会在生成报告时过滤，不会因为这个列表而在前面的分析阶段跳过执行。

1. 只有 `symbolic_testcase.txt` 非空，并且沿符号执行路径的变慢比例达到阈值，才直接保留报告。
2. 其他达到筛选阈值的情况需要 benchmark 验证，包括符号取值为空或缺失，以及只有默认执行结果达到阈值的情况。
3. 验证时从干净源码编译新旧 Redis，每个版本只运行一轮，使用 **100 万次请求、pipeline 深度 10、50 个客户端**。对应 `redis-benchmark -n 1000000 -P 10`，脚本还会附加测试命令、连接参数和用于解析结果的 `--csv`。
4. Benchmark 变慢比例为 `(old_rps / new_rps - 1) * 100`，达到 2% 才保留。不能自动验证或发生错误的用例会记录在验证汇总中，不会自动判定为确认成功。

如果没有候选报告，脚本仍会创建空的 `report-final/`，并跳过验证阶段。
最终报告中不包含 `modified part` 和 `icount diff`，原始结果文件仍保留完整内容。
新生成的计时标签使用英文，报告解析器也兼容历史中文标签。

## 停止、重新运行和归档

需要停止时，进入 tmux 2，按 `Ctrl-C`。
主控会记录取消状态，另一边的任务会停止自己启动的命令。
重新启动前，应等待两边任务退出，并检查日志以及是否还有 Redis/S2E 残留进程。

**重新启动会从第一批开始完整运行，不是断点续跑。**
新的 `run_all.sh` 会先把识别出的旧输出移动到 `/data3/sjz/AE/redis-brk/<timestamp>/`。
归档内容包括旧报告、各 commit 的结果、运行日志、源码快照和 `manifest.json`。

只归档当前 Redis 输出、不启动实验时，执行：

```bash
bash /data3/sjz/AE/redis/run_all.sh --archive-only
```

自动归档只针对 Redis 项目。
此前清理的 Pre-knowledge 旧文件单独保存在 `/data2/sjz/Pre-knowledge-redis-brk-9-21/`。

以下运行输入需要继续保留：

- Redis：`redis/`、`commit/` 及其中的 `commit/makefile/`、`tools/`、当前脚本、命令列表和 `panda.so`。
- Pre-knowledge：`updateCommit-new.sh`、`demo-1.sh`、`demo-2.sh`、它们使用的分析工具和命令列表、`redis/`、`redis-version/redis/`、`makefile-26-02-01/`、`socket-26-02-01/`，以及各基线对应的 `init_file_<commit>/` 和 `re-build-<commit>/`。顶层不带编号的 `Makefile` 也在运行时使用。

## 根据现有结果重新生成报告

如果原始结果已经存在，可以单独重新生成报告，不必重新执行全部 commit。
执行前应确认没有其他报告生成或验证任务正在运行：

```bash
cd /data3/sjz/AE/redis
python3 generate_perf_report.py --dry-run
python3 generate_perf_report.py
python3 confirm_perf_reports.py
```

这里按顺序完成以下操作：

1. 预览候选报告，不写文件。
2. 生成或刷新 `report/`。
3. 仅预览验证计划，不编译、不运行 benchmark。

有候选报告时，正式验证执行：

```bash
python3 confirm_perf_reports.py --execute --requests 1000000 --pipeline 10
```

验证脚本会自动刷新 `report-final/`，无需手动复制报告。
单份报告验证及其他参数见 [confirm_perf_reports.md](confirm_perf_reports.md)，完整流程细节见 [run_all.md](run_all.md)。

`run.sh` 单独运行时只负责 Redis 这一边，需要另行启动对应的 Pre-knowledge 任务。
完整自动化流程统一使用 `run_all.sh`。
