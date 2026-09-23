#!/usr/bin/env python3
"""Run one native MySQL validation measurement using sql-times.txt x2."""

import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tarfile
import tempfile
import time

sys.dont_write_bytecode = True
import generate_perf_report as reporting

ROOT = Path(__file__).resolve().parent
MYSQLSLAP = Path('/data/sjz/commit-analysis/mysql-8.4.4/build/bin/mysqlslap')
DATA_FILE = Path('/data/sjz/commit-analysis/mysql-8.0.41-next/testcases/tables.tar.gz')


def save_json(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def query_count(query, mapping):
    spec = importlib.util.spec_from_file_location('sql_times', ROOT / 'get-sql-times.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.query_count(query, mapping=mapping, multiplier=2)


def positive_int(value):
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError('must be positive')
    return number


def stop_process(process):
    if process.poll() is not None:
        return
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait()


def run_logged(command, log, cwd=None, timeout=14400, env=None, stderr=None):
    save_json(log.with_suffix(log.suffix + '.command.json'), command)
    with log.open('w', encoding='utf-8') as output:
        error_stream = stderr.open('w', encoding='utf-8') if stderr else None
        try:
            process = subprocess.Popen(command, cwd=cwd, stdout=output,
                                       stderr=error_stream or subprocess.STDOUT,
                                       env=env, start_new_session=True)
            try:
                code = process.wait(timeout=timeout)
            finally:
                stop_process(process)
        finally:
            if error_stream:
                error_stream.close()
    if code != 0:
        raise RuntimeError(f'Command exited with {code}; see {log}')


def extract_data(archive, destination):
    """Extract the saved data directory into a fresh measurement directory."""
    if (destination / 'data').exists():
        raise ValueError(f'Data directory already exists: {destination / "data"}')
    with tarfile.open(archive, 'r:gz') as stream:
        members = stream.getmembers()
        for member in members:
            path = Path(member.name)
            if (path.is_absolute() or '..' in path.parts or not path.parts or
                    path.parts[0] != 'data' or not (member.isdir() or member.isfile())):
                raise ValueError(f'Unsupported data archive member: {member.name}')
        options = {'filter': 'data'} if hasattr(tarfile, 'data_filter') else {}
        stream.extractall(destination, members=members, **options)
    if not (destination / 'data/mysql.ibd').is_file():
        raise ValueError('The archive does not contain data/mysql.ibd')
    return destination / 'data'


def wait_ready(process, client, socket, data, deadline):
    command = [str(client), '--no-defaults', '--protocol=SOCKET', '--user=root',
               f'--socket={socket}', '--batch', '--skip-column-names',
               '--execute=SELECT @@datadir']
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError('mysqld exited during startup; see server-error.log')
        try:
            result = subprocess.run(command, capture_output=True, text=True, timeout=2)
            if result.returncode == 0:
                if Path(result.stdout.strip()).resolve() != data.resolve():
                    raise RuntimeError('MySQL connected to a different data directory')
                return
        except subprocess.TimeoutExpired:
            pass
        time.sleep(0.2)
    raise TimeoutError('MySQL startup timed out; see server-error.log')


def measure(build, query, destination, data, mapping, mysqlslap=MYSQLSLAP,
            timeout=14400, startup_timeout=120, client=None):
    build, destination, data = build.resolve(), destination.resolve(), data.resolve()
    count = query_count(query, mapping)
    client = client or build / 'bin/mysql'
    for executable in (build / 'bin/mysqld', client, mysqlslap):
        if not os.access(executable, os.X_OK):
            raise ValueError(f'Executable unavailable: {executable}')
    if not data.is_dir():
        raise ValueError(f'Data directory missing: {data}')
    destination.mkdir(parents=True, exist_ok=True)
    # A short private socket avoids both shared-server collisions and UNIX path limits.
    with tempfile.TemporaryDirectory(prefix='mysql-confirm-') as temporary:
        socket = Path(temporary) / 'mysql.sock'
        command = [str(build / 'bin/mysqld'), '--no-defaults', f'--basedir={build}',
                   f'--datadir={data}', f'--socket={socket}',
                   f'--pid-file={destination / "mysqld.pid"}', '--thread_stack=2097152',
                   '--skip-networking', '--mysqlx=0',
                   f'--log-error={destination / "server-error.log"}']
        save_json(destination / 'server-command.json', command)
        with (destination / 'server.log').open('w') as stream:
            process = subprocess.Popen(command, cwd=build, stdout=stream,
                                       stderr=subprocess.STDOUT, start_new_session=True)
            try:
                wait_ready(process, client, socket, data, time.monotonic() + startup_timeout)
                benchmark = [str(mysqlslap), '--no-defaults', '--protocol=SOCKET',
                             '--concurrency=1', '--iterations=1', '--create-schema=test',
                             f'--query={query}', '--user=root', f'--socket={socket}',
                             f'--number-of-queries={count}']
                log, errors = destination / 'error.log', destination / 'benchmark.stderr.log'
                run_logged(benchmark, log, cwd=build, timeout=timeout, stderr=errors)
                if process.poll() is not None:
                    raise RuntimeError('mysqld exited during the benchmark')
                if re.search(r'error|failed', errors.read_text(encoding='utf-8'), re.I):
                    raise ValueError('mysqlslap reported an error; see benchmark.stderr.log')
                seconds, measured = reporting.benchmark(log)
                if measured != count:
                    raise ValueError(f'Expected {count} queries, benchmark reported {measured}')
                result = dict(seconds=str(seconds), query_count=count, multiplier=2,
                              clients=1, iterations=1, testcase=query)
                save_json(destination / 'measurement.json', result)
                return result
            finally:
                stop_process(process)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build-dir', type=Path, default=Path.cwd())
    parser.add_argument('--query-file', type=Path, default=Path('get_mysql.txt'))
    parser.add_argument('--data-dir', type=Path, default=Path('bin/data'))
    parser.add_argument('--output-dir', type=Path, default=Path.cwd())
    parser.add_argument('--mapping', type=Path, default=ROOT / 'sql-times.txt')
    parser.add_argument('--mysqlslap', type=Path, default=MYSQLSLAP)
    parser.add_argument('--timeout', type=positive_int, default=14400)
    parser.add_argument('--startup-timeout', type=positive_int, default=120)
    args = parser.parse_args(argv)
    try:
        query = args.query_file.read_text(encoding='utf-8').strip()
        result = measure(args.build_dir, query, args.output_dir, args.data_dir,
                         args.mapping, args.mysqlslap, args.timeout, args.startup_timeout)
        print(json.dumps(result, ensure_ascii=False))
        return 0
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'MySQL validation error: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(143))
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
