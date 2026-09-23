import contextlib
import io
import json
import os
from decimal import Decimal
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

import generate_perf_report as report


class ReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.commit, self.parent = 'a' * 40, 'b' * 40
        self.directory = self.root / self.commit
        self.case = self.directory / '1'
        self.case.mkdir(parents=True)
        (self.root / 'commit-tmp.txt').write_text(self.commit + '\n')
        (self.directory / 'run-status.tsv').write_text(
            'commit\tparent\texit_status\telapsed_seconds\n'
            f'{self.commit}\t{self.parent}\t0\t15\n')
        (self.case / 'testcase.txt').write_text("SELECT 'hello, report';\n")
        (self.case / 'symbolic_testcase.txt').write_text('value = 1\n')
        self.fixture()

    def fixture(self, symbolic='102', default='101', symbolic_count=10000):
        times = {report.SYMBOLIC: Decimal(symbolic), report.DEFAULT: Decimal(default), report.OLD: Decimal(100)}
        values = {label: value / 10 for label, value in times.items()}
        for mode, change in report.MODES:
            values[change] = (times[mode] - times[report.OLD]) / times[report.OLD]
        reverse = {label: legacy for legacy, label in report.LEGACY_LABELS.items()}
        text = '\n'.join(f'{reverse[label]}\n{values[label]}' for label in report.LABELS)
        (self.case / 'final-res.txt').write_text(text + '\n', encoding='utf-8')
        for mode, filename in report.BENCHMARKS.items():
            count = symbolic_count if mode == report.SYMBOLIC else 10000
            (self.case / filename).write_text(
                f'Benchmark\nAverage number of seconds to run all queries: {times[mode]} seconds\n'
                f'Number of clients running queries: 1\nAverage number of queries per client: {count}\n')

    def collect(self):
        return report.collect_reports(self.root, self.root, [self.commit], Decimal('.02'))

    def run_cli(self, *args):
        with contextlib.redirect_stdout(io.StringIO()):
            return report.main(['--root', str(self.root), *args])

    def test_inclusive_threshold_and_real_units(self):
        reports, records, _ = self.collect()
        self.assertEqual(len(reports), 1)
        self.assertEqual(records[0]['modes'][report.SYMBOLIC]['status'], 'candidate')
        self.assertEqual(records[0]['modes'][report.DEFAULT]['status'], 'below_threshold')
        self.assertEqual(records[0]['old_seconds'], '100')
        self.assertEqual(records[0]['parent'], self.parent)
        self.assertIn('102', next(iter(reports.values())))

    def test_symbolic_failure_keeps_valid_default_candidate(self):
        self.fixture(default='105')
        (self.case / 'compile.txt').write_text(report.FAILURES[report.SYMBOLIC][0], encoding='utf-8')
        _, records, _ = self.collect()
        self.assertEqual(records[0]['status'], 'candidate')
        self.assertEqual(records[0]['modes'][report.SYMBOLIC]['status'], 'invalid')
        self.assertEqual(records[0]['modes'][report.DEFAULT]['status'], 'candidate')

    def test_query_count_mismatch_excludes_only_affected_mode(self):
        self.fixture(default='106', symbolic_count=20000)
        _, records, _ = self.collect()
        self.assertEqual(records[0]['modes'][report.SYMBOLIC]['status'], 'invalid')
        self.assertIn('counts differ', records[0]['modes'][report.SYMBOLIC]['reason'])
        self.assertEqual(records[0]['modes'][report.DEFAULT]['status'], 'candidate')

    def test_missing_and_nonfinite_results(self):
        path = self.case / 'final-res.txt'
        original = path.read_text(encoding='utf-8')
        for bad in ('', original.replace('10.2\n', 'NaN\n'), original.replace('10.2\n', '0\n')):
            with self.subTest(content=bad):
                path.write_text(bad, encoding='utf-8')
                reports, records, _ = self.collect()
                self.assertFalse(reports)
                self.assertEqual(records[0]['status'], 'invalid')

    def test_raw_ratio_mismatch_and_duplicate_benchmark(self):
        path = self.case / report.BENCHMARKS[report.SYMBOLIC]
        path.write_text(path.read_text().replace('102 seconds', '109 seconds'))
        _, records, _ = self.collect()
        self.assertEqual(records[0]['modes'][report.SYMBOLIC]['status'], 'invalid')
        path.write_text(path.read_text() * 2)
        with self.assertRaises(ValueError):
            report.benchmark(path)

    def test_old_native_failure_rejects_both_modes(self):
        old = self.root / f'{self.parent}-old' / '1'
        old.mkdir(parents=True)
        (old / 'compile.txt').write_text(report.FAILURES[report.OLD][0], encoding='utf-8')
        reports, records, _ = self.collect()
        self.assertFalse(reports)
        self.assertEqual(records[0]['status'], 'invalid')

    def test_null_order_and_missing_case_are_audited(self):
        (self.directory / 'call_analyse2.txt').write_text(
            'testcase:SELECT 2;\n\nBegin NULL\n\ntestcase:SELECT 1;\n\n'
            'testcase:no testcase\n\nEnd NULL\n')
        self.assertEqual(report.load_case_commands(self.directory), {'1': 'SELECT 1;', '2': 'SELECT 2;'})
        _, records, _ = self.collect()
        self.assertEqual(len(records), 2)
        self.assertEqual(records[1]['status'], 'invalid')
        self.assertEqual(records[1]['testcase'], 'SELECT 2;')

    def test_dry_run_root_report_refresh_and_user_files(self):
        self.run_cli('--dry-run')
        output = self.root / 'report'
        self.assertFalse(output.exists())
        self.run_cli()
        metadata = json.loads((output / 'candidates.json').read_text())
        self.assertEqual(metadata['candidates'][0]['validation_query_count'], 20000)
        self.assertEqual(metadata['candidates'][0]['validation_status'], 'not_run')
        (output / 'notes.md').write_text('keep me')
        self.run_cli('--threshold-percent', '5')
        self.assertFalse((output / f'{self.commit}-1.md').exists())
        self.assertEqual((output / 'notes.md').read_text(), 'keep me')
        (output / 'README.md').write_text('manual changes')
        with self.assertRaises(ValueError):
            report.write_reports(output, {'README.md': 'replacement'})

    def test_archived_selection_ignores_cancelled_and_unselected(self):
        run = self.root / 'full-test'
        source = run / 'results'
        source.mkdir(parents=True)
        self.directory.rename(source / self.commit)
        (run / 'commits.txt').write_text(self.parent + '\n' + self.commit + '\n')
        (run / 'selected-commits.txt').write_text(self.commit + '\n')
        (run / 'exit-status.txt').write_text('1\n')
        (run / 'status.tsv').write_text(
            'commit\tparent\texit_status\telapsed_seconds\n'
            f'{self.parent}\t{"c" * 40}\t137\t15\n{self.commit}\t{self.parent}\t0\t15\n')
        self.run_cli('--run-dir', str(run))
        records = json.loads((self.root / 'report/candidates.json').read_text())['candidates']
        self.assertEqual([r['commit'] for r in records], [self.commit])
        self.assertEqual(records[0]['parent'], self.parent)
        reports, records, coverage = report.collect_reports(self.root, source, [self.commit], Decimal('.02'),
            report.load_status(run / 'status.tsv'), {self.commit})
        self.assertFalse(reports)
        self.assertFalse(records)
        self.assertEqual(coverage[0]['status'], 'skipped')

    def test_failed_root_run_is_not_a_candidate(self):
        status = self.directory / 'run-status.tsv'
        status.write_text(status.read_text().replace('\t0\t15', '\t137\t15'))
        reports, records, coverage = self.collect()
        self.assertFalse(reports)
        self.assertFalse(records)
        self.assertEqual(coverage[0]['status'], 'failed')

    def test_run_pointer_rejects_replaced_results(self):
        run = self.root / 'full-test'
        run.mkdir()
        (run / 'results-root.txt').write_text(str(self.root) + '\n')
        (run / 'commits.txt').write_text(self.commit + '\n')
        (run / 'exit-status.txt').write_text('0\n')
        status = self.directory / 'run-status.tsv'
        (run / 'status.tsv').write_text(status.read_text())
        status.write_text('commit\tparent\texit_status\telapsed_seconds\trun_dir\n'
                          f'{self.commit}\t{self.parent}\t0\t15\t{run}\n')
        self.run_cli('--run-dir', str(run))
        output = self.root / 'report/candidates.json'
        self.assertEqual(len(json.loads(output.read_text())['candidates']), 1)
        status.write_text(status.read_text().replace(str(run), str(run) + '-newer'))
        self.run_cli('--run-dir', str(run))
        self.assertEqual(json.loads(output.read_text())['candidates'], [])
        self.assertIn('replaced', (self.root / 'report/commits.csv').read_text())


class RunnerLayoutTests(unittest.TestCase):
    def test_drivers_keep_results_in_root(self):
        scripts = Path(__file__).resolve().parent
        for name, prefix in (('run_auto.sh', 'full-'), ('run-replay.sh', 'replay-')):
            with self.subTest(driver=name), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                commit, parent = 'a' * 40, 'b' * 40
                shutil.copy2(scripts / name, root / name)
                (root / 'commit-tmp.txt').write_text(commit + '\n')
                # Replace experiment and source-control operations with fixtures.
                common = f'TEST_COMMIT={commit}\nINITIAL_COMMIT={parent}\n' + r'''
export MYSQL_RUN_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMMIT_FILE="$MYSQL_RUN_ROOT/commit-tmp.txt"
COMMIT_DIGEST=fixture
PREKNOWLEDGE_DIR="$MYSQL_RUN_ROOT/peer"
export MYSQL_PEER_RUN_DIR="$MYSQL_RUN_ROOT/paired-run"
load_commits() { commits=("$TEST_COMMIT"); }
check_main_inputs() { :; }
check_preknowledge_inputs() { :; }
require_peer_run() { :; }
wait_for_preknowledge() { :; }
wait_for_preknowledge_completion() { :; }
prepare_build_dirs() { :; }
git() {
    case "$3" in
        status|diff|restore) return 0 ;;
        rev-parse)
            case "${@: -1}" in
                *^1) printf '%s\n' "$INITIAL_COMMIT" ;;
                *) printf '%s\n' "$TEST_COMMIT" ;;
            esac ;;
        *) return 97 ;;
    esac
}
cmake() { :; }
make() { :; }
clang-format() { :; }
python3() { :; }
s2e() { :; }
timeout() { :; }
'''
                (root / 'run-common.sh').write_text(common)
                (root / 'make_symbolic-NULLEND.sh').write_text(r'''
set -eu
if [[ -e /proc/$$/fd/9 ]]; then
    echo 'Driver lock leaked to worker' >&2
    exit 98
fi
mkdir -p "$MYSQL_RUN_ROOT/$2/1" "$MYSQL_RUN_ROOT/$1-old/1"
touch "$MYSQL_PEER_RUN_DIR/ack/$2"
printf '%s\n' "$2" > "$MYSQL_RUN_ROOT/$2/1/worker.txt"
printf '%s\n' "$1" > "$MYSQL_RUN_ROOT/$1-old/1/worker.txt"
''')
                for dependency in ('run-mysql.sh', 'get-sql-times.py', 'sql-times.txt',
                                   'bootstrap.sh', 'run-getres.sh', 'run-getres.py',
                                   'run-getres-modify.py', 'run-getres-icount.py',
                                   'generate_perf_report.py'):
                    (root / dependency).touch()
                archive = root / 'archive' / commit
                (root / 'paired-run/ack').mkdir(parents=True)
                archive.mkdir(parents=True)
                for dependency in ('getFuncName-ini.txt', 'new_function.txt', 'getFuncName.txt',
                                   'call_analyse.txt', 'symbolic_analyse.txt', 'call_analyse2.txt'):
                    (archive / dependency).write_text('fixture\n')
                if name == 'run_auto.sh':
                    for result in (commit, parent + '-old'):
                        (root / result).mkdir()
                        (root / result / 'previous.txt').write_text('keep previous result\n')
                environment = dict(os.environ, MYSQL_ANALYSIS_ARCHIVE=str(archive.parent))
                environment.pop('MYSQL_ANALYSIS_DIR', None)
                arguments = [commit] if name == 'run-replay.sh' else []
                process = subprocess.run(['bash', str(root / name), *arguments], cwd=root,
                                         env=environment, capture_output=True, text=True, timeout=10)
                self.assertEqual(process.returncode, 0, process.stdout + process.stderr)
                run, = root.glob(prefix + '*')
                self.assertFalse((run / 'results').exists())
                self.assertEqual((run / 'results-root.txt').read_text().strip(), str(root))
                self.assertEqual((run / 'exit-status.txt').read_text().strip(), '0')
                status = report.load_status(root / commit / 'run-status.tsv')[commit]
                self.assertEqual(status['parent'], parent)
                self.assertEqual(status['run_dir'], str(run))
                self.assertTrue((root / commit / '1/worker.txt').is_file())
                self.assertTrue((root / (parent + '-old') / '1/worker.txt').is_file())
                if name == 'run_auto.sh':
                    for result in (commit, parent + '-old'):
                        self.assertEqual((run / 'previous-results' / result / 'previous.txt').read_text(),
                                         'keep previous result\n')


if __name__ == '__main__':
    unittest.main()
