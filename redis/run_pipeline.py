#!/usr/bin/env python3
"""Archive prior outputs, run both tmux workers in batch order, and publish final reports."""

import argparse
import contextlib
import csv
from datetime import datetime
import fcntl
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import time
import traceback

sys.dont_write_bytecode = True
HASH = re.compile(r'[0-9a-f]{40}')
REPORT = re.compile(r'[0-9a-f]{40}-[0-9]+\.md')
OUTPUT_NAMES = {'report', 'report-final', 'report-confirmation', 'pipeline-runs',
                'time-tall.txt', 'Makefile', 'Makefile1', 'bootstrap-1.sh', 'tmp',
                '__pycache__', 'make_symbolic-NULLEND copy 2.sh'}
PRE_ROOT = Path('/data2/sjz/Pre-knowledge')
REPLY = Path('/data/sjz/call_analyse2.txt')


def save_json(path, value):
    temporary = path.with_name(f'.{path.name}.{os.getpid()}.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')
    temporary.replace(path)


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8'))


def timestamp():
    return datetime.now().strftime('%Y%m%d-%H%M%S-%f')


@contextlib.contextmanager
def project_lock(root, wait=False):
    with (root / '.pipeline.lock').open('a') as lock:
        deadline = time.monotonic() + (60 if wait else 0)
        while True:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError as error:
                if time.monotonic() >= deadline:
                    raise RuntimeError('Another pipeline or archive operation is running') from error
                time.sleep(0.1)
        yield


def output_entries(root):
    return sorted((path for path in root.iterdir() if
                   path.name in OUTPUT_NAMES or
                   re.fullmatch(r'redis-[0-9a-f]{40}(?:-old)?', path.name) or
                   path.name.startswith(('run-commit-', 'trial-commit-'))), key=lambda path: path.name)


def archive_outputs(root, archive_root):
    entries = output_entries(root)
    if not entries:
        return None
    if archive_root == root or root in archive_root.parents:
        raise ValueError('Archive directory must be outside the project')
    archive_root.mkdir(parents=True, exist_ok=True)
    if root.stat().st_dev != archive_root.stat().st_dev:
        raise ValueError('Archive must be on the same filesystem for directory renames')
    destination = archive_root / timestamp()
    destination.mkdir()
    snapshot = destination / 'source-snapshot'
    snapshot.mkdir()
    for path in root.iterdir():
        if path.is_file() and path.suffix in {'.sh', '.py', '.md'}:
            shutil.copy2(path, snapshot / path.name)
    shutil.copytree(root / 'commit', snapshot / 'commit')
    manifest = dict(source=str(root), destination=str(destination),
                    entries=[dict(name=path.name, moved=False) for path in entries])
    save_json(destination / 'manifest.json', manifest)
    for path, record in zip(entries, manifest['entries']):
        path.rename(destination / path.name)
        record['moved'] = True
        save_json(destination / 'manifest.json', manifest)
    print(f'Archived {len(entries)} entries to {destination}', flush=True)
    return str(destination)


def require_file(path):
    if not path.is_file():
        raise ValueError(f'Missing required file: {path}')


def load_plan(root, pre_root, batches=None):
    with (batches or root / 'commit/batches.tsv').open(encoding='utf-8', newline='') as stream:
        groups = list(csv.DictReader(stream, delimiter='\t'))
    if not groups:
        raise ValueError('No batches configured')
    seen_groups, seen_commits, seen_files = set(), set(), set()
    for group in groups:
        if set(group) != {'group', 'file', 'base', 'makefile', 'socket'}:
            raise ValueError('Invalid batches.tsv columns')
        if not re.fullmatch(r'[0-9]+(?:-[0-9]+)*', group['group']) or group['group'] in seen_groups:
            raise ValueError(f'Invalid or duplicate group: {group["group"]}')
        seen_groups.add(group['group'])
        for key in ('file', 'makefile', 'socket'):
            if Path(group[key]).name != group[key] or group[key] in {'', '.', '..'}:
                raise ValueError(f'Invalid batch filename: {group[key]}')
        if not HASH.fullmatch(group['base']):
            raise ValueError(f'Invalid baseline: {group["base"]}')
        path = root / 'commit' / group['file']
        commits = [line.strip() for line in path.read_text().splitlines() if line.strip()]
        if not commits or any(not HASH.fullmatch(commit) for commit in commits):
            raise ValueError(f'Invalid or empty commit list: {path}')
        if len(commits) != len(set(commits)) or seen_commits.intersection(commits):
            raise ValueError(f'Duplicate commits in batch: {path}')
        seen_commits.update(commits)
        seen_files.add(group['file'])
        group['commits'] = commits
        for required in (root / 'commit/makefile' / group['makefile'],
                         root / 'commit/makefile' / (group['makefile'] + '-1'),
                         pre_root / 'makefile-26-02-01' / group['makefile'],
                         pre_root / 'socket-26-02-01' / group['socket'],
                         pre_root / ('init_file_' + group['base']) / 'redis-BB-res-2.txt',
                         pre_root / ('init_file_' + group['base']) / 'redis-BB-res-3.txt'):
            require_file(required)
    available = {path.name for path in (root / 'commit').iterdir()
                 if path.is_file() and path.name.startswith('commit')}
    if available != seen_files:
        raise ValueError(f'Commit lists and batches.tsv differ: {sorted(available ^ seen_files)}')
    return groups


def ensure_idle_processes(root, pre_root=PRE_ROOT):
    output = subprocess.check_output(['ps', '-u', str(os.getuid()), '-o', 'pid=,comm=,args='], text=True)
    active = []
    roots = (root.resolve(), pre_root.resolve(), Path('/home/sjz/S2E/s2e/projects/redis-server').resolve())
    scripts = {'run.sh', 'make_symbolic-NULLEND.sh', 'updateCommit-new.sh',
               'run_auto-26-02-01.sh', 'confirm_perf_reports.py'}
    for line in output.splitlines():
        fields = line.strip().split(None, 2)
        if len(fields) != 3 or int(fields[0]) == os.getpid():
            continue
        args = fields[2].split()
        if fields[1] in {'redis-server', 'redis-benchmar', 'redis-benchmark'}:
            active.append(line.strip())
            continue
        if fields[1].startswith('qemu-system') or any(Path(arg).name in scripts for arg in args[:3]):
            try:
                cwd = Path(os.readlink(f'/proc/{fields[0]}/cwd')).resolve()
            except OSError:
                cwd = Path('/')
            paths = [(cwd / arg).resolve() for arg in args[:3] if Path(arg).name in scripts]
            if fields[1].startswith('qemu-system'):
                paths.append(cwd)
            if any(path == directory or directory in path.parents for path in paths for directory in roots):
                active.append(line.strip())
    if active:
        raise RuntimeError('Active experiment processes:\n' + '\n'.join(active))


def pane_info(target):
    output = subprocess.check_output(
        ['tmux', 'display-message', '-p', '-t', target,
         '#{pane_id}\t#{pane_current_command}\t#{pane_dead}'], text=True).strip()
    pane, command, dead = output.split('\t')
    return dict(pane=pane, command=command, dead=dead)


def require_idle_pane(target, allow_current=False):
    pane = pane_info(target)
    if pane['dead'] != '0' or (pane['command'] not in {'bash', 'zsh', 'fish'} and
                             not (allow_current and os.environ.get('TMUX_PANE') == pane['pane'])):
        raise RuntimeError(f'tmux pane is busy: {target} ({pane["command"]})')
    return pane['pane']


def preflight(root, pre_root, groups, redis_pane, pre_pane):
    ensure_idle_processes(root, pre_root)
    redis_id = require_idle_pane(redis_pane, allow_current=True)
    pre_id = require_idle_pane(pre_pane)
    if redis_id == pre_id:
        raise ValueError('Redis and Pre-knowledge need distinct panes')
    for name in ('run.sh', 'make_symbolic-NULLEND.sh', 'bootstrap.sh', 'panda.so',
                 'run-redis.sh', 'run-redis-2.sh', 'run-getres.sh', 'run-getres.py',
                 'run-getres-modify.py', 'run-getres-icount.py', 'redis-order-null.txt',
                 'generate_perf_report.py', 'confirm_perf_reports.py'):
        require_file(root / name)
    for name in ('.clang-format', 'new_function_analyzer.sh', 'commit_analyzer', 'call_analyzer',
                 'symbolic_analyzer', 'make_symbolizer-new', 'real_executor-new', 'jsonAnalyze',
                 'jsonAnalyze-icount', 'get_redis_1', 'get_redis_2', 'redis-order.txt'):
        require_file(root / 'tools' / name)
    for name in ('updateCommit-new.sh', 'demo-1.sh', 'demo-2.sh', 'gitshow', 'getBB',
                 'update_KeyValue_hashTable', 'generate_S2E_case', 'generate_S2E_case-2',
                 'dup_S2E_case.py', 'dup_S2E_case-1.py'):
        require_file(pre_root / name)
    for flag in (REPLY, pre_root / 'demo-S2E-times-res-3-flag.txt', pre_root / 'build_KeyValue_hashTable.txt'):
        if flag.exists():
            raise RuntimeError(f'Stale or active handshake file: {flag}')
    require_file(Path('/data/sjz/commit-analysis/redis-run/dump.rdb'))
    require_file(Path('/home/sjz/S2E/s2e/projects/redis-server/launch-s2e.sh'))
    for port in (6379, 16379):
        with socket.socket() as probe:
            probe.bind(('127.0.0.1', port))
    dirty = subprocess.check_output(['git', '-C', str(root / 'redis'), 'status', '--porcelain'], text=True)
    if dirty.strip():
        raise RuntimeError('The source redis repository must be clean')
    commits = sorted({commit for group in groups for commit in [group['base'], *group['commits']]})
    for repo in (root / 'redis', pre_root / 'redis-version/redis'):
        checked = subprocess.check_output(['git', '-C', str(repo), 'cat-file', '--batch-check=%(objecttype)'],
                                          input='\n'.join(commits) + '\n', text=True)
        if any(line != 'commit' for line in checked.splitlines()):
            raise RuntimeError(f'Missing commits in {repo}')


def launch_in_pane(target, script, role, run_dir):
    command = shlex.join(['python3', '-u', str(script), '--worker', role, '--run-dir', str(run_dir)])
    subprocess.run(['tmux', 'send-keys', '-t', target, '-l', command], check=True)
    subprocess.run(['tmux', 'send-keys', '-t', target, 'Enter'], check=True)


def check_cancel(run_dir, peer=None):
    if (run_dir / 'cancel.json').exists():
        raise RuntimeError('Pipeline cancelled; inspect cancel.json')
    if peer and (run_dir / f'{peer}.status.json').exists():
        status = read_json(run_dir / f'{peer}.status.json')
        if status.get('exit_code') not in (None, 0):
            raise RuntimeError(f'{peer} worker failed: {status.get("error", "see its log")}')
        if status.get('exit_code') is None and status.get('pid'):
            try:
                os.kill(status['pid'], 0)
            except ProcessLookupError as error:
                raise RuntimeError(f'{peer} worker exited without a completion status') from error


def stop_owned(process):
    if process.poll() is None:
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            return
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()


def run_logged(command, log, cwd, run_dir, peer=None, env=None):
    save_json(log.with_suffix('.command.json'), command)
    print(f'Running: {shlex.join(command)}\nLog: {log}', flush=True)
    with log.open('w') as stream:
        process = subprocess.Popen(command, cwd=cwd, env=env, stdout=stream,
                                   stderr=subprocess.STDOUT, start_new_session=True)
        try:
            while process.poll() is None:
                check_cancel(run_dir, peer)
                time.sleep(1)
            if process.returncode != 0:
                raise RuntimeError(f'Exit {process.returncode}: {shlex.join(command)}; see {log}')
        finally:
            stop_owned(process)


def wait_file(path, run_dir, peer=None, timeout=None):
    start = time.monotonic()
    while not path.is_file():
        check_cancel(run_dir, peer)
        if timeout is not None and time.monotonic() - start > timeout:
            raise TimeoutError(f'Timed out waiting for {path}')
        time.sleep(1)
    check_cancel(run_dir, peer)


def require_commands(names):
    for name in names:
        if shutil.which(name) is None:
            raise RuntimeError(f'Missing command in this tmux environment: {name}')


def preknowledge_worker(plan, run_dir):
    pre_root = Path(plan['preknowledge_root'])
    require_commands(('bash', 'make', 'sancov', 'python3'))
    for group in plan['groups']:
        folder = run_dir / group['group']
        wait_file(folder / 'start.json', run_dir, 'redis')
        baseline = pre_root / ('init_file_' + group['base'])
        shutil.copy2(pre_root / 'makefile-26-02-01' / group['makefile'], pre_root / 'Makefile')
        shutil.copy2(pre_root / 'socket-26-02-01' / group['socket'], pre_root / 'socket-26-02-01/socket.c')
        for number in (2, 3):
            shutil.copy2(baseline / f'redis-BB-res-{number}.txt', pre_root / f'redis-BB-res-{number}-new.txt')
        save_json(folder / 'ready.json', dict(baseline=str(baseline)))
        run_logged(['bash', str(pre_root / 'updateCommit-new.sh'), str(folder / 'commits.txt')],
                   folder / 'preknowledge.log', pre_root, run_dir, 'redis')
        save_json(folder / 'preknowledge.done.json', dict(exit_code=0))


def redis_worker(plan, run_dir):
    root = Path(plan['root'])
    require_commands(('bash', 'clang', 'clang-format', 'llvm-link', 'make', 's2e', 'taskset', 'gcc'))
    require_idle_pane(plan['preknowledge_pane'])
    launch_in_pane(plan['preknowledge_pane'], root / 'run_pipeline.py', 'preknowledge', run_dir)
    wait_file(run_dir / 'preknowledge.status.json', run_dir, 'preknowledge', timeout=60)
    for group in plan['groups']:
        folder = run_dir / group['group']
        print(f'Group {group["group"]}: {len(group["commits"])} commits', flush=True)
        save_json(folder / 'start.json', dict(started_at=datetime.now().isoformat()))
        wait_file(folder / 'ready.json', run_dir, 'preknowledge', timeout=120)
        env = dict(os.environ, REDIS_BATCH_FILE=str(run_dir / 'batches.tsv'),
                   REDIS_COMMIT_FILE=str(folder / 'commits.txt'), REDIS_LOG_DIR=str(folder / 'commits'),
                   REDIS_PROGRESS_FILE=str(folder / 'redis.completed.txt'))
        run_logged(['bash', str(root / 'run.sh'), group['group']], folder / 'redis.log',
                   root, run_dir, 'preknowledge', env)
        completed = (folder / 'redis.completed.txt').read_text().splitlines()
        if completed != group['commits']:
            raise RuntimeError(f'Incomplete Redis batch: {group["group"]}')
        wait_file(folder / 'preknowledge.done.json', run_dir, 'preknowledge')
        save_json(folder / 'done.json', dict(exit_code=0, commits=len(completed)))
    wait_file(run_dir / 'preknowledge.finished.json', run_dir, 'preknowledge', timeout=60)
    run_logged([sys.executable, str(root / 'generate_perf_report.py'), '--root', str(root)],
               run_dir / 'generate-report.log', root, run_dir)
    candidates = [path for path in (root / 'report').glob('*.md') if REPORT.fullmatch(path.name)]
    if candidates:
        run_logged([sys.executable, '-u', str(root / 'confirm_perf_reports.py'), '--root', str(root),
                    '--execute', '--requests', '1000000', '--pipeline', '10',
                    '--output-dir', str(root / 'report-confirmation' / run_dir.name)],
                   run_dir / 'confirm-report.log', root, run_dir)
    else:
        (root / 'report-final').mkdir(exist_ok=True)
        (run_dir / 'confirm-report.log').write_text('No candidates; report-final is empty.\n')
    final_count = sum(1 for path in (root / 'report-final').glob('*/*.md')
                      if path.is_file() and REPORT.fullmatch(path.name)
                      and path.parent.name == path.stem.rsplit('-', 1)[0])
    print(f'All batches completed. Final reports: {final_count}; {root / "report-final"}', flush=True)


def worker(role, run_dir):
    plan = read_json(run_dir / 'plan.json')
    status = dict(pid=os.getpid(), started_at=datetime.now().isoformat(), exit_code=None)
    save_json(run_dir / f'{role}.status.json', status)
    print(f'{role} worker log: {run_dir / (role + ".worker.log")}', flush=True)
    code = 0
    with (run_dir / f'{role}.worker.log').open('w', buffering=1) as log:
        with contextlib.redirect_stdout(log), contextlib.redirect_stderr(log):
            try:
                (redis_worker if role == 'redis' else preknowledge_worker)(plan, run_dir)
            except BaseException as error:
                code = 130 if isinstance(error, KeyboardInterrupt) else 1
                status['error'] = str(error) or type(error).__name__
                save_json(run_dir / 'cancel.json', dict(worker=role, error=status['error']))
                traceback.print_exc()
            finally:
                status.update(exit_code=code, finished_at=datetime.now().isoformat())
                save_json(run_dir / f'{role}.status.json', status)
                save_json(run_dir / f'{role}.finished.json', status)
    print(f'{role} finished with exit code {code}. Logs: {run_dir}', flush=True)
    return code


def prepare_run(args, groups, archive):
    run_dir = args.root / 'pipeline-runs' / timestamp()
    run_dir.mkdir(parents=True)
    shutil.copy2(args.batches or args.root / 'commit/batches.tsv', run_dir / 'batches.tsv')
    snapshot = run_dir / 'source-snapshot'
    snapshot.mkdir()
    for path in args.root.iterdir():
        if path.is_file() and path.suffix in {'.sh', '.py', '.md', '.txt'}:
            shutil.copy2(path, snapshot / path.name)
    shutil.copytree(args.root / 'commit', snapshot / 'commit')
    pre_snapshot = snapshot / 'preknowledge'
    pre_snapshot.mkdir()
    for name in ('updateCommit-new.sh', 'demo-1.sh', 'demo-2.sh', 'dup_S2E_case.py', 'dup_S2E_case-1.py'):
        source = args.preknowledge_root / name
        if source.is_file():
            shutil.copy2(source, pre_snapshot / name)
    plan = dict(root=str(args.root), preknowledge_root=str(args.preknowledge_root),
                redis_pane=args.redis_pane, preknowledge_pane=args.preknowledge_pane,
                archive=archive, groups=groups)
    save_json(run_dir / 'plan.json', plan)
    for group in groups:
        folder = run_dir / group['group']
        folder.mkdir()
        (folder / 'commits.txt').write_text('\n'.join(group['commits']) + '\n')
    return run_dir


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument('--preknowledge-root', type=Path, default=PRE_ROOT)
    parser.add_argument('--archive-root', type=Path)
    parser.add_argument('--batches', type=Path)
    parser.add_argument('--redis-pane', default='2:0.0')
    parser.add_argument('--preknowledge-pane', default='4:0.0')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--check', action='store_true', help='read-only preflight; do not launch experiments')
    mode.add_argument('--archive-only', action='store_true', help='archive generated outputs without running')
    mode.add_argument('--worker', choices=('redis', 'preknowledge'), help=argparse.SUPPRESS)
    parser.add_argument('--run-dir', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    args.root = args.root.resolve()
    args.preknowledge_root = args.preknowledge_root.resolve()
    archive_root = (args.archive_root or args.root.parent / 'redis-brk').resolve()
    try:
        if args.worker:
            if not args.run_dir:
                raise ValueError('--worker requires --run-dir')
            if args.worker == 'redis':
                with project_lock(args.root, wait=True):
                    return worker('redis', args.run_dir)
            return worker('preknowledge', args.run_dir)
        if args.archive_only:
            with project_lock(args.root):
                ensure_idle_processes(args.root, args.preknowledge_root)
                archive_outputs(args.root, archive_root)
            return 0
        groups = load_plan(args.root, args.preknowledge_root, args.batches)
        preflight(args.root, args.preknowledge_root, groups, args.redis_pane, args.preknowledge_pane)
        print('Order: ' + ' -> '.join(group['group'] for group in groups))
        print(f'Total commits: {sum(len(group["commits"]) for group in groups)}')
        if args.check:
            print(f'Preflight passed. Would archive {len(output_entries(args.root))} entries. No experiments started.')
            return 0
        with project_lock(args.root):
            require_idle_pane(args.redis_pane, allow_current=True)
            require_idle_pane(args.preknowledge_pane)
            ensure_idle_processes(args.root, args.preknowledge_root)
            archive = archive_outputs(args.root, archive_root)
            run_dir = prepare_run(args, groups, archive)
            print(f'Pipeline logs: {run_dir}', flush=True)
            if os.environ.get('TMUX_PANE') == pane_info(args.redis_pane)['pane']:
                return worker('redis', run_dir)
            launch_in_pane(args.redis_pane, args.root / 'run_pipeline.py', 'redis', run_dir)
        wait_file(run_dir / 'redis.status.json', run_dir, 'redis', timeout=60)
        print(f'Started in tmux {args.redis_pane} and {args.preknowledge_pane}. Final output: {args.root / "report-final"}')
        return 0
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        return 1


def interrupted(*_):
    raise KeyboardInterrupt


if __name__ == '__main__':
    signal.signal(signal.SIGTERM, interrupted)
    sys.exit(main())
