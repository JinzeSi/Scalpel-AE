#!/usr/bin/env python3
"""Run live MySQL/Pre-knowledge in tmux 2/4, then screen and confirm reports."""

import argparse
import contextlib
from datetime import datetime
import fcntl
import json
import os
from pathlib import Path
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import traceback


ROOT = Path(__file__).resolve().parent
TARGET = '2:0.0'
PEER_TARGET = '4:0.0'
PRE_ROOT = Path('/data2/sjz/Pre-knowledge-mysql')


def pane_info(target=TARGET):
    output = subprocess.check_output([
        'tmux', 'display-message', '-p', '-t', target,
        '#{pane_id}\t#{pane_pid}\t#{pane_tty}\t#{pane_current_command}\t#{pane_dead}',
    ], text=True).strip()
    pane, pid, tty, command, dead = output.split('\t')
    return dict(pane=pane, pid=int(pid), tty=tty, command=command, dead=dead, target=target)


def terminal_processes(tty):
    output = subprocess.check_output([
        'ps', '-t', tty, '-o', 'pid=,ppid=,comm=',
    ], text=True)
    processes = {}
    for line in output.splitlines():
        pid, parent, command = line.split(None, 2)
        processes[int(pid)] = (int(parent), command)
    return processes


def require_idle_pane(pane):
    target = pane.get('target', TARGET)
    current = os.environ.get('TMUX_PANE') == pane['pane']
    if pane['dead'] != '0' or (
            not current and pane['command'] not in {'bash', 'zsh', 'fish', 'sh'}):
        raise RuntimeError(f'tmux {target} is busy ({pane["command"]}); wait for Redis to finish.')
    processes = terminal_processes(pane['tty'])
    allowed = {pane['pid']}
    if current:
        pid = os.getpid()
        ancestors = set()
        while pid != pane['pid']:
            if pid not in processes or pid in ancestors:
                raise RuntimeError('TMUX_PANE does not match this process; launch from an ordinary terminal.')
            ancestors.add(pid)
            pid = processes[pid][0]
        allowed.update(ancestors)
        # Ignore this launcher's own short-lived ps subprocess, but not other jobs.
        descendants = {os.getpid()}
        while True:
            children = {pid for pid, (parent, _) in processes.items() if parent in descendants}
            if children <= descendants:
                break
            descendants.update(children)
        allowed.update(descendants)
    busy = [(pid, command) for pid, (_, command) in processes.items() if pid not in allowed]
    if busy:
        details = ', '.join(f'{pid} ({command})' for pid, command in busy)
        raise RuntimeError(f'tmux {target} still has jobs: {details}. Finish these jobs before starting MySQL.')
    return current


def check_lock(root, name='.run_auto.lock'):
    lock = root / name
    if not lock.exists():
        return
    with lock.open('rb') as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise RuntimeError(f'Another process holds {lock}; inspect it with fuser -v {lock}.') from error


def launch_command(root):
    return f'cd -- {shlex.quote(str(root))} && bash ./run_all.sh'


def save_json(path, value):
    temporary = path.with_name(f'.{path.name}.{os.getpid()}.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def read_json(path):
    return json.loads(path.read_text())


@contextlib.contextmanager
def project_lock():
    with (ROOT / '.pipeline.lock').open('a') as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise RuntimeError('Another MySQL pipeline is running.') from error
        yield


def peer_command(run_dir):
    arguments = ['python3', '-B', '-u', str(ROOT / 'run_pipeline.py'),
                 '--worker', 'preknowledge', '--run-dir', str(run_dir)]
    return f'cd -- {shlex.quote(str(PRE_ROOT))} && {shlex.join(arguments)}'


def send_command(pane, command):
    subprocess.run(['tmux', 'send-keys', '-t', pane['pane'], '-l', command], check=True)
    subprocess.run(['tmux', 'send-keys', '-t', pane['pane'], 'Enter'], check=True)


def run_environment(run_dir):
    environment = os.environ.copy()
    environment['MYSQL_COMMIT_FILE'] = str(run_dir / 'commits.txt')
    environment['MYSQL_PEER_RUN_DIR'] = str(run_dir)
    environment.pop('MYSQL_ANALYSIS_DIR', None)
    return environment


def prepare_run():
    parent = ROOT / 'pipeline-runs'
    parent.mkdir(exist_ok=True)
    run_dir = Path(tempfile.mkdtemp(prefix=datetime.now().strftime('%Y%m%d-%H%M%S.'), dir=parent))
    shutil.copy2(ROOT / 'commit-tmp.txt', run_dir / 'commits.txt')
    for folder in ('replies', 'ack'):
        (run_dir / folder).mkdir()
    for name, source, files in (
            ('mysql', ROOT, ('run_all.sh', 'run_pipeline.py', 'run_auto.sh', 'run-common.sh',
                             'run-preknowledge.sh', 'make_symbolic-NULLEND.sh', 'sql-times.txt')),
            ('preknowledge', PRE_ROOT, ('run_auto.sh', 'updateCommit-new-mysql.sh',
                                        'demo-1-mysql.sh', 'demo-2-mysql.sh', 'mysql-order-priority.txt'))):
        destination = run_dir / 'source-snapshot' / name
        destination.mkdir(parents=True)
        for filename in files:
            shutil.copy2(source / filename, destination / filename)
    destination = run_dir / 'source-snapshot/preknowledge'
    for name in ('mysql-server', 'mysql-server-2'):
        repo = Path('/data2/sjz/mysql') / name
        (destination / f'{name}.patch').write_bytes(subprocess.check_output(['git', '-C', str(repo), 'diff', '--binary', 'HEAD']))
        (destination / f'{name}.head').write_bytes(subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'HEAD']))
        shutil.copy2(repo / 'sql/sql_parse.cc', destination / f'{name}.sql_parse.cc')
    save_json(run_dir / 'plan.json', dict(root=str(ROOT), preknowledge_root=str(PRE_ROOT),
              mysql_pane=TARGET, preknowledge_pane=PEER_TARGET, mode='live',
              commits=(run_dir / 'commits.txt').read_text().splitlines()))
    print(f'Pipeline logs: {run_dir}', flush=True)
    return run_dir


def check_cancel(run_dir, peer):
    if (run_dir / 'cancel.json').exists():
        raise RuntimeError('Paired run cancelled; inspect cancel.json.')
    path = run_dir / f'{peer}.status.json'
    if path.exists():
        status = read_json(path)
        if status['exit_code'] not in (None, 0):
            raise RuntimeError(f'{peer} failed: {status.get("error", "see worker log")}')
        if status['exit_code'] is None:
            try:
                os.kill(status['pid'], 0)
            except ProcessLookupError as error:
                raise RuntimeError(f'{peer} exited without a completion status.') from error


def wait_file(path, run_dir, peer, timeout=180):
    started = time.monotonic()
    while not path.is_file():
        check_cancel(run_dir, peer)
        if time.monotonic() - started >= timeout:
            raise TimeoutError(f'Timed out waiting for {path}')
        time.sleep(1)
    check_cancel(run_dir, peer)


def stop_owned(process):
    # Each worker command owns a separate process group, including native children.
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        process.wait()
        return
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait()
    # A shell may exit before its background children; stop survivors in its group.
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass


def run_logged(command, log, cwd, run_dir, peer):
    print(f'Running: {shlex.join(command)}\nLog: {log}', flush=True)
    with log.open('w') as stream:
        process = subprocess.Popen(command, cwd=cwd, env=run_environment(run_dir),
                                   stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            while process.poll() is None:
                check_cancel(run_dir, peer)
                time.sleep(1)
            check_cancel(run_dir, peer)
            if process.returncode:
                raise RuntimeError(f'Exit {process.returncode}: {shlex.join(command)}; see {log}')
        finally:
            stop_owned(process)


def mysql_worker(run_dir):
    peer = pane_info(PEER_TARGET)
    if require_idle_pane(peer):
        raise RuntimeError('Start the MySQL coordinator in tmux 2, not tmux 4.')
    send_command(peer, peer_command(run_dir))
    wait_file(run_dir / 'preknowledge.ready', run_dir, 'preknowledge')
    run_logged(['bash', str(ROOT / 'run_auto.sh'), '--confirm'],
               run_dir / 'mysql.log', ROOT, run_dir, 'preknowledge')
    wait_file(run_dir / 'preknowledge.finished.json', run_dir, 'preknowledge')
    commits = (run_dir / 'commits.txt').read_text().splitlines()
    if any(not (run_dir / 'ack' / commit).is_file() for commit in commits):
        raise RuntimeError('Not every commit completed a live Pre-knowledge exchange.')
    print(f'All {len(commits)} commits, live Pre-knowledge and confirmation completed.\n'
          f'Final reports: {ROOT / "report-final"}', flush=True)


def worker(role, run_dir):
    plan = read_json(run_dir / 'plan.json')
    if plan['root'] != str(ROOT) or plan['preknowledge_root'] != str(PRE_ROOT) or plan['mode'] != 'live':
        raise ValueError('The paired run belongs to a different installation or mode.')
    status = dict(pid=os.getpid(), started_at=datetime.now().isoformat(), exit_code=None)
    save_json(run_dir / f'{role}.status.json', status)
    print(f'{role} worker log: {run_dir / (role + ".worker.log")}', flush=True)
    code = 0
    with (run_dir / f'{role}.worker.log').open('w', buffering=1) as log:
        with contextlib.redirect_stdout(log), contextlib.redirect_stderr(log):
            try:
                check_cancel(run_dir, 'mysql' if role == 'preknowledge' else 'preknowledge')
                if role == 'mysql':
                    mysql_worker(run_dir)
                else:
                    run_logged(['bash', str(ROOT / 'run-preknowledge.sh')],
                               run_dir / 'preknowledge.log', PRE_ROOT, run_dir, 'mysql')
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


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true',
                        help='read-only preflight in the invoking shell; no tmux keys or experiments')
    parser.add_argument('--worker', choices=('preknowledge',), help=argparse.SUPPRESS)
    parser.add_argument('--run-dir', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    try:
        if args.worker:
            if args.check or not args.run_dir:
                raise ValueError('--worker requires --run-dir and cannot use --check.')
            return worker(args.worker, args.run_dir.resolve())
        if args.run_dir:
            raise ValueError('--run-dir is only for the internal worker.')
        pane = pane_info()
        current = require_idle_pane(pane)
        peer = pane_info(PEER_TARGET)
        if require_idle_pane(peer):
            raise RuntimeError('Launch from tmux 2 or an ordinary terminal, not tmux 4.')
        check_lock(ROOT)
        check_lock(ROOT, '.pipeline.lock')
        check_lock(PRE_ROOT, '.mysql-ae-peer.lock')
        for name in ('demo-S2E-times-res-3-flag.txt', 'build_KeyValue_hashTable.txt'):
            if (PRE_ROOT / name).exists():
                raise RuntimeError(f'Unresolved Pre-knowledge handshake file: {PRE_ROOT / name}')
        driver = ['bash', str(ROOT / 'run_auto.sh'), '--confirm']
        environment = os.environ.copy()
        environment['MYSQL_COMMIT_FILE'] = str(ROOT / 'commit-tmp.txt')
        environment.pop('MYSQL_ANALYSIS_DIR', None)
        if args.check:
            if not current:
                print('Checking the invoking shell environment. For the prepared S2E environment, '
                      'run --check inside tmux 2.', flush=True)
            return subprocess.run(driver + ['--check'], cwd=ROOT, env=environment).returncode
        if current:
            os.chdir(ROOT)
            subprocess.run(driver + ['--check'], cwd=ROOT, env=environment, check=True)
            with project_lock():
                print(f'Working directory: {ROOT}\nRunning all commits with live Pre-knowledge.', flush=True)
                return worker('mysql', prepare_run())
        # Use the pane's existing environment; its current directory may still be Redis.
        send_command(pane, launch_command(ROOT))
        print(f'Launch command sent to tmux {TARGET}; it changes directory to {ROOT} first.\n'
              'Inspect that pane for preflight/startup output. This is not a completion notice.')
        return 0
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(143))
    sys.exit(main())
