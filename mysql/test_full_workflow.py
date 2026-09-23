import csv
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

import generate_perf_report as reporting


class FullWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.scripts = Path(__file__).resolve().parent

    def prepare(self, count=135, failed_commit=False, confirmation_failure=False):
        commits = [f'{number:040x}' for number in range(1, count + 1)]
        (self.root / 'commit-tmp.txt').write_text('\n'.join(commits) + '\n')
        for name in ('run_auto.sh', 'run-report.sh', 'generate_perf_report.py',
                     'confirm_perf_reports.py', 'mysql_validation.py', 'get-sql-times.py',
                     'run-selection.py'):
            shutil.copy2(self.scripts / name, self.root / name)
        for name in ('run-mysql.sh', 'bootstrap.sh', 'run-getres.sh', 'run-getres.py',
                     'run-getres-modify.py', 'run-getres-icount.py'):
            (self.root / name).write_text('exit 97\n')
        # Only the worker, Git and first-round preflight are mocked. The real
        # screening/confirmation code processes its saved synthetic measurements.
        (self.root / 'run-common.sh').write_text(r'''
export MYSQL_RUN_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMMIT_FILE="$MYSQL_RUN_ROOT/commit-tmp.txt"
INITIAL_COMMIT=0000000000000000000000000000000000000000
PREKNOWLEDGE_DIR="$MYSQL_RUN_ROOT/peer"
export MYSQL_PEER_RUN_DIR="$MYSQL_RUN_ROOT/paired-run"
load_commits() {
    mapfile -t commits < "$COMMIT_FILE"
    COMMIT_DIGEST=$(sha256sum "$COMMIT_FILE")
    COMMIT_DIGEST=${COMMIT_DIGEST%% *}
}
check_main_inputs() { :; }
check_preknowledge_inputs() { :; }
require_peer_run() { :; }
wait_for_preknowledge() { :; }
wait_for_preknowledge_completion() { :; }
prepare_build_dirs() { :; }
git() {
    case "$3" in
        status|diff|restore) return 0 ;;
        *) echo 'Unexpected Git operation in test' >&2; return 98 ;;
    esac
}
''')
        (self.root / 'make_symbolic-NULLEND.sh').write_text(r'''
set -euo pipefail
[[ ! -e /proc/$$/fd/9 ]] || exit 98
python3 "$MYSQL_RUN_ROOT/run-selection.py" "$2" "$MYSQL_RUN_ROOT/commit-tmp.txt"
printf '%s\n' "$2" >> "$MYSQL_RUN_ROOT/attempted.txt"
if [[ "$2" == "${FIXTURE_BEFORE_EXCHANGE:-}" ]]; then
    exit 7
fi
touch "$MYSQL_PEER_RUN_DIR/ack/$2"
mkdir -p "$MYSQL_RUN_ROOT/$2" "$MYSQL_RUN_ROOT/$1-old"
if [[ "$2" == "$FIXTURE_CANDIDATE" ]]; then
    mkdir -p "$MYSQL_RUN_ROOT/$2/1"
    cp -a "$MYSQL_RUN_ROOT/template/." "$MYSQL_RUN_ROOT/$2/1/"
fi
if [[ "$2" == "${FIXTURE_FAIL_COMMIT:-}" ]]; then
    exit 7
fi
''')
        template = self.root / 'template'
        (self.root / 'paired-run/ack').mkdir(parents=True)
        template.mkdir()
        (template / 'testcase.txt').write_text('SELECT 1;\n')
        (template / 'symbolic_testcase.txt').write_text('value = 1\n')
        (self.root / 'sql-times.txt').write_text('SELECT 1;\t10000\n')
        values = {reporting.SYMBOLIC: '10.2', reporting.DEFAULT: '10.1', reporting.OLD: '10',
                  reporting.SYMBOLIC_CHANGE: '.02', reporting.DEFAULT_CHANGE: '.01'}
        (template / 'final-res.txt').write_text(''.join(f'{label}\n{value}\n'
                                                      for label, value in values.items()))
        for mode, seconds in ((reporting.SYMBOLIC, '102'), (reporting.DEFAULT, '101'), (reporting.OLD, '100')):
            (template / reporting.BENCHMARKS[mode]).write_text(
                f'Average number of seconds to run all queries: {seconds} seconds\n'
                'Number of clients running queries: 1\nAverage number of queries per client: 10000\n')
        old_run = self.root / 'full-old-trial'
        old_run.mkdir()
        digest = hashlib.sha256((self.root / 'commit-tmp.txt').read_bytes()).hexdigest()
        (old_run / 'run-selection.json').write_text(json.dumps(dict(
            version=1, run_dir=str(old_run), commit_digest=digest, ranges=[[37, 43], [125, 135]])))
        reporting.write_reports(self.root / 'report', {
            'README.md': 'Old trial report\n',
            'obsolete.md': 'Obsolete generated report\n',
            'candidates.json': json.dumps(dict(schema_version=1, source=str(old_run / 'results'), candidates=[]))})
        if confirmation_failure:
            (self.root / 'confirm_perf_reports.py').write_text('raise SystemExit(17)\n')
        environment = os.environ.copy()
        environment.pop('MYSQL_ANALYSIS_DIR', None)
        environment.pop('MYSQL_COMMIT_FILE', None)
        environment.update(FIXTURE_CANDIDATE=commits[0],
                           FIXTURE_FAIL_COMMIT=commits[1] if failed_commit else '')
        return commits, environment

    def run_workflow(self, environment):
        process = subprocess.run(['bash', str(self.root / 'run_auto.sh'), '--confirm'],
            cwd=self.root, env=environment, capture_output=True, text=True, timeout=60)
        runs = [path for path in self.root.glob('full-*') if path.name != 'full-old-trial']
        self.assertEqual(len(runs), 1, process.stdout + process.stderr)
        return process, runs[0]

    def test_all_135_commits_then_fresh_confirmation(self):
        commits, environment = self.prepare()
        process, run = self.run_workflow(environment)
        self.assertEqual(process.returncode, 0, process.stdout + process.stderr)
        self.assertEqual((self.root / 'attempted.txt').read_text().splitlines(), commits)
        self.assertEqual((run / 'commits.txt').read_text().splitlines(), commits)
        statuses = reporting.load_status(run / 'status.tsv')
        self.assertEqual(list(statuses), commits)
        self.assertEqual(statuses[commits[-1]]['parent'], commits[-2])
        self.assertFalse((run / 'results').exists())
        self.assertFalse((run / 'run-selection.json').exists())
        with (self.root / 'report/commits.csv').open(newline='') as stream:
            coverage = list(csv.DictReader(stream))
        self.assertEqual(len(coverage), 135)
        self.assertTrue(all(item['status'] in {'scanned', 'no_cases'} for item in coverage))
        metadata = json.loads((self.root / 'report/candidates.json').read_text())
        self.assertEqual(metadata['source'], str(self.root))
        self.assertEqual([item['commit'] for item in metadata['candidates']], [commits[0]])
        self.assertFalse((self.root / 'report/obsolete.md').exists())
        final = self.root / 'report-final' / commits[0] / (commits[0] + '-1.md')
        self.assertTrue(final.is_file())
        confirmation, = (self.root / 'report-confirmation').iterdir()
        summary = json.loads((confirmation / 'summary.json').read_text())
        self.assertEqual(summary[0]['status'], 'direct_report')
        self.assertFalse(any((confirmation / 'builds').iterdir()))
        self.assertEqual((run / 'confirmation-exit-status.txt').read_text().strip(), '0')
        self.assertEqual((run / 'workflow-exit-status.txt').read_text().strip(), '0')

    def test_first_round_failure_still_records_remaining_commits(self):
        commits, environment = self.prepare(count=3, failed_commit=True)
        process, run = self.run_workflow(environment)
        self.assertEqual(process.returncode, 1, process.stdout + process.stderr)
        self.assertEqual((self.root / 'attempted.txt').read_text().splitlines(), commits)
        self.assertEqual((run / 'exit-status.txt').read_text().strip(), '1')
        self.assertEqual((run / 'confirmation-exit-status.txt').read_text().strip(), '0')
        self.assertEqual((run / 'workflow-exit-status.txt').read_text().strip(), '1')
        with (self.root / 'report/commits.csv').open(newline='') as stream:
            coverage = {row['commit']: row for row in csv.DictReader(stream)}
        self.assertEqual(coverage[commits[1]]['status'], 'failed')

    def test_confirmation_failure_does_not_hide_first_round_success(self):
        _, environment = self.prepare(count=3, confirmation_failure=True)
        process, run = self.run_workflow(environment)
        self.assertEqual(process.returncode, 1, process.stdout + process.stderr)
        self.assertEqual((run / 'exit-status.txt').read_text().strip(), '0')
        self.assertEqual((run / 'confirmation-exit-status.txt').read_text().strip(), '17')
        self.assertEqual((run / 'workflow-exit-status.txt').read_text().strip(), '1')

    def test_preflight_does_not_write_or_run_workers(self):
        _, environment = self.prepare(count=3)
        before = {str(path.relative_to(self.root)): path.read_bytes()
                  for path in self.root.rglob('*') if path.is_file()}
        process = subprocess.run(['bash', str(self.root / 'run_auto.sh'), '--confirm', '--check'],
            cwd=self.root, env=environment, capture_output=True, text=True, timeout=20)
        self.assertEqual(process.returncode, 0, process.stdout + process.stderr)
        self.assertIn('Preflight passed for 3 commits', process.stdout)
        after = {str(path.relative_to(self.root)): path.read_bytes()
                 for path in self.root.rglob('*') if path.is_file()}
        self.assertEqual(before, after)
        self.assertFalse((self.root / '.run_auto.lock').exists())
        self.assertFalse((self.root / 'attempted.txt').exists())
        self.assertEqual([path.name for path in self.root.glob('full-*')], ['full-old-trial'])

    def test_preflight_rejects_existing_lock_without_running(self):
        _, environment = self.prepare(count=3)
        with (self.root / '.run_auto.lock').open('wb') as stream:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
            process = subprocess.run(['bash', str(self.root / 'run_auto.sh'), '--confirm', '--check'],
                cwd=self.root, env=environment, capture_output=True, text=True, timeout=20)
        self.assertNotEqual(process.returncode, 0)
        self.assertIn('Another process holds', process.stderr)
        self.assertFalse((self.root / 'attempted.txt').exists())

    def test_failure_before_exchange_stops_without_advancing_peer(self):
        commits, environment = self.prepare(count=3)
        environment['FIXTURE_BEFORE_EXCHANGE'] = commits[0]
        process, run = self.run_workflow(environment)
        self.assertEqual(process.returncode, 1)
        self.assertIn('prevent commit misalignment', process.stderr)
        self.assertEqual((self.root / 'attempted.txt').read_text().splitlines(), commits[:1])
        self.assertFalse((run / 'confirmation.log').exists())


if __name__ == '__main__':
    unittest.main()
