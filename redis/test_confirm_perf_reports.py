import contextlib
from decimal import Decimal
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import MagicMock, patch

import confirm_perf_reports as confirm


CSV = ('"test","rps","avg_latency_ms","min_latency_ms","p50_latency_ms",'
       '"p95_latency_ms","p99_latency_ms","max_latency_ms"\n'
       '"GET key","100000.00","0.010","0.005","0.010","0.015","0.020","0.030"\n')


class ConfirmationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'report').mkdir()
        self.data = self.root / 'initial data.rdb'
        self.data.write_bytes(b'initial-fixture')
        self.commit = 'a' * 40
        self.args = confirm.parser().parse_args(['--root', str(self.root)])
        self.args.output_dir = self.root / 'confirmation'

    def fixture(self, case, symbolic='', command='GET key', symbolic_percent='3', default_percent='3'):
        directory = self.root / f'redis-{self.commit}'
        case_dir = directory / str(case)
        case_dir.mkdir(parents=True)
        if symbolic is not None:
            (case_dir / 'symbolic_testcase.txt').write_text(symbolic)
        symbolic_percent = Decimal(symbolic_percent)
        default_percent = Decimal(default_percent)
        result = {
            confirm.reporting.SYMBOLIC: 100 + symbolic_percent,
            confirm.reporting.DEFAULT: 100 + default_percent,
            confirm.reporting.OLD: Decimal('100'),
            confirm.reporting.SYMBOLIC_CHANGE: symbolic_percent / 100,
            confirm.reporting.DEFAULT_CHANGE: default_percent / 100,
        }
        (case_dir / 'final-res.txt').write_text(
            ''.join(f'{label}\n{value}\n' for label, value in result.items()), encoding='utf-8')
        binary_dir = directory / 'src' / f'{case}-2' / 'bin'
        binary_dir.mkdir(parents=True)
        (binary_dir / 'get_redis_3.txt').write_text(command + '\n')
        (binary_dir / 'get_redis_2.txt').write_text(
            f'./redis-server --dir "{self.root}" --dbfilename "initial data.rdb" --save "" --pidfile redis.pid\n')
        report = self.root / 'report' / f'{self.commit}-{case}.md'
        report.write_text('# Original report\n')
        return report

    def test_empty_missing_and_nonempty_symbols(self):
        self.fixture(1, '')
        self.fixture(2, '  \n ')
        self.fixture(3, 'v0_value 42\n')
        self.fixture(4, None)
        cases = confirm.load_cases(self.args)
        self.assertEqual([item['action'] for item in cases],
                         ['benchmark', 'benchmark', 'direct_report', 'benchmark'])
        self.assertEqual(cases[3]['symbolic_state'], 'missing')

    def test_direct_retention_requires_symbolic_threshold_and_default_falls_back(self):
        self.fixture(1, 'value 0', symbolic_percent='1.7753', default_percent='13.1050')
        self.fixture(2, 'value 0', symbolic_percent='2', default_percent='0')
        self.fixture(3, 'value 0', symbolic_percent='1.9', default_percent='2')
        self.fixture(4, 'value 0', symbolic_percent='1.9', default_percent='1')
        self.fixture(5, '', symbolic_percent='2', default_percent='1')
        self.fixture(6, '', symbolic_percent='1', default_percent='1')
        cases = confirm.load_cases(self.args)
        self.assertEqual([item['action'] for item in cases],
                         ['benchmark', 'direct_report', 'benchmark', 'below_threshold',
                          'benchmark', 'below_threshold'])
        self.assertEqual(Decimal(cases[0]['symbolic_slowdown_percent']), Decimal('1.7753'))
        self.assertEqual(Decimal(cases[0]['default_slowdown_percent']), Decimal('13.1050'))
        self.args.threshold_percent = Decimal('14')
        self.assertTrue(all(item['action'] == 'below_threshold' for item in confirm.load_cases(self.args)))

    def test_nonempty_symbols_cannot_bypass_missing_or_invalid_timings(self):
        for case in (1, 2, 3):
            self.fixture(case, 'value 0')
        root = self.root / f'redis-{self.commit}'
        (root / '1/final-res.txt').unlink()
        (root / '2/final-res.txt').write_text('incomplete\n')
        path = root / '3/final-res.txt'
        path.write_text(path.read_text().replace('0.03', 'nan'))
        cases = confirm.load_cases(self.args)
        self.assertEqual([item['action'] for item in cases], ['manual_review'] * 3)
        self.assertTrue(all(item['error'] for item in cases))

    def test_default_plan_does_not_build_measure_or_write(self):
        self.fixture(1)
        before = sorted(str(path) for path in self.root.rglob('*'))
        with patch.object(confirm, 'execute') as execute, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(confirm.main(['--root', str(self.root)]), 0)
        execute.assert_not_called()
        self.assertEqual(before, sorted(str(path) for path in self.root.rglob('*')))
        self.assertEqual(self.args.requests, 1000000)
        self.assertEqual(self.args.clients, 50)
        self.assertEqual(self.args.pipeline, 10)

    def test_pipeline_must_be_positive(self):
        for value in ('0', '-1'):
            with self.subTest(value=value), contextlib.redirect_stderr(io.StringIO()), \
                    self.assertRaises(SystemExit):
                confirm.parser().parse_args(['--pipeline', value])

    def test_symbolic_case_does_not_require_command_or_dataset(self):
        original = self.fixture(1, 'value 0')
        self.data.unlink()
        with patch.object(confirm, 'build_version') as build, patch.object(confirm, 'measure') as measure:
            self.assertEqual(confirm.execute(confirm.load_cases(self.args), self.args), 0)
        build.assert_not_called()
        measure.assert_not_called()
        retained = self.args.output_dir / 'reports' / original.name
        self.assertIn('No benchmark was run', retained.read_text())
        self.assertIn('symbolic-mode slowdown is +3.0000%', retained.read_text())
        self.assertIn('at least the 2% threshold', retained.read_text())
        final = self.root / 'report-final' / self.commit / original.name
        self.assertEqual(final.read_text(), confirm.FINAL_MARKER + '\n' + retained.read_text())
        self.assertEqual(original.read_text(), '# Original report\n')

    def test_missing_rdb_requires_explicit_empty_database(self):
        self.fixture(1)
        self.data.unlink()
        self.assertEqual(confirm.load_cases(self.args)[0]['action'], 'manual_review')
        self.args.empty_db = True
        case = confirm.load_cases(self.args)[0]
        self.assertEqual(case['action'], 'benchmark')
        self.assertIsNone(case['data_file'])

    def test_command_quoting_and_unsupported_commands(self):
        self.assertEqual(confirm.command_arguments('SET "a b" ""'), ['SET', 'a b', ''])
        for command in ('', '""', 'redis-cli --cluster check localhost:6379',
                        'DEBUG RELOAD', 'BLPOP key 0', 'XREAD BLOCK 0 STREAMS key $', 'GET x | cat'):
            with self.subTest(command=command), self.assertRaises(ValueError):
                confirm.command_arguments(command)

    def test_csv_validation(self):
        self.assertEqual(confirm.parse_benchmark(CSV)['rps'], '100000.00')
        for output in ('', CSV + CSV, CSV.replace('100000.00', 'nan'),
                       CSV.replace('100000.00', '0'), 'not,csv\n'):
            with self.subTest(output=output), self.assertRaises(ValueError):
                confirm.parse_benchmark(output)
        with self.assertRaises(ValueError):
            confirm.parse_benchmark(CSV, 'Error: WRONGTYPE')

    def test_elapsed_slowdown_formula_and_inclusive_threshold(self):
        value, verdict = confirm.benchmark_verdict({'rps': '102'}, {'rps': '100'}, Decimal('2'))
        self.assertEqual(Decimal(value), Decimal('2'))
        self.assertEqual(verdict, 'benchmark_confirmed')
        self.assertEqual(confirm.benchmark_verdict({'rps': '100'}, {'rps': '110'}, Decimal('2'))[1],
                         'not_reproduced')

    def test_snapshot_is_stable_when_original_changes(self):
        snapshots = self.root / 'snapshots'
        snapshots.mkdir()
        first = confirm.snapshot_data(str(self.data), snapshots)
        self.data.write_bytes(b'changed')
        second = confirm.snapshot_data(str(self.data), snapshots)
        self.assertEqual(first, second)
        self.assertEqual(second.read_bytes(), b'initial-fixture')

    def test_clean_local_copy_checkout_and_build_cache(self):
        builds = self.root / 'builds'
        builds.mkdir()
        calls = []

        def fake_run(command, log, **kwargs):
            calls.append(command)
            if command[0] == 'make':
                binary_dir = Path(kwargs['cwd']) / 'src'
                binary_dir.mkdir(parents=True)
                for name in ('redis-server', 'redis-cli', 'redis-benchmark'):
                    file = binary_dir / name
                    file.write_text('fixture')
                    file.chmod(0o755)

        with patch.object(confirm, 'run_logged', side_effect=fake_run):
            first = confirm.build_version(self.root / 'redis', self.commit, builds, self.args)
            second = confirm.build_version(self.root / 'redis', self.commit, builds, self.args)
        self.assertEqual(first, second)
        self.assertEqual(len(calls), 3)
        self.assertEqual(calls[0][:4], ['git', 'clone', '--no-hardlinks', '--no-checkout'])
        self.assertEqual(calls[1][-3:], ['checkout', '--detach', self.commit])
        self.assertIn('OPTIMIZATION=-O3', calls[2])

    def test_two_versions_one_round_same_client(self):
        self.fixture(1, 'value 0', symbolic_percent='1.7753', default_percent='13.1050')
        case = confirm.load_cases(self.args)[0]
        self.assertEqual(case['action'], 'benchmark')
        bins = {'b' * 40: self.root / 'old-bin', self.commit: self.root / 'new-bin'}
        (self.root / 'redis').mkdir()
        with patch.object(confirm, 'resolve_pair', return_value={'old': 'b' * 40, 'new': self.commit}), \
                patch.object(confirm, 'build_version', side_effect=lambda repo, commit, *_: bins[commit]), \
                patch.object(confirm.shutil, 'which', return_value='/tool'), \
                patch.object(confirm.os, 'sched_getaffinity', return_value={45, 57}), \
                patch.object(confirm, 'measure', side_effect=[{'rps': '103'}, {'rps': '100'}]) as measure:
            self.assertEqual(confirm.execute([case], self.args), 0)
        self.assertEqual(measure.call_count, 2)
        for call in measure.call_args_list:
            self.assertEqual(call.args[1], bins[self.commit])
        self.assertEqual(measure.call_args_list[0].args[4], measure.call_args_list[1].args[4])
        result = json.loads((self.args.output_dir / 'summary.json').read_text())[0]
        self.assertEqual(result['status'], 'benchmark_confirmed')
        self.assertEqual(result['symbolic_slowdown_percent'], '1.775300')
        self.assertTrue((self.root / 'report-final' / self.commit / f'{self.commit}-1.md').is_file())

    def test_below_threshold_removes_selected_final_without_benchmark(self):
        report = self.fixture(1, 'value 0', symbolic_percent='1', default_percent='1')
        final = self.root / 'report-final' / self.commit
        final.mkdir(parents=True)
        (final / report.name).write_text(confirm.FINAL_MARKER + '\nprevious report')
        other = final / f'{self.commit}-2.md'
        other.write_text(confirm.FINAL_MARKER + '\nother report')
        self.args.case = [report.stem]
        with patch.object(confirm, 'build_version') as build, patch.object(confirm, 'measure') as measure:
            self.assertEqual(confirm.execute(confirm.load_cases(self.args), self.args), 0)
        build.assert_not_called()
        measure.assert_not_called()
        self.assertFalse((final / report.name).exists())
        self.assertTrue(other.is_file())
        result = json.loads((self.args.output_dir / 'summary.json').read_text())[0]
        self.assertEqual(result['status'], 'below_threshold')

    def test_final_reports_refresh_only_accepted_cases(self):
        output = self.root / 'archive'
        (output / 'reports').mkdir(parents=True)
        final = self.root / 'report-final'
        final.mkdir()
        statuses = ['direct_report', 'benchmark_confirmed', 'not_reproduced', 'error', 'manual_review']
        results = []
        for index, status in enumerate(statuses, 1):
            identity = f'{self.commit}-{index}'
            results.append(dict(id=identity, status=status))
            (final / f'{identity}.md').write_text(confirm.FINAL_MARKER + '\nold content')
            if status in {'direct_report', 'benchmark_confirmed'}:
                (output / 'reports' / f'{identity}.md').write_text(f'new {identity}')
        stale = final / f'{"b" * 40}-9.md'
        stale.write_text(confirm.FINAL_MARKER + '\nstale report')
        notes = final / 'notes.md'
        notes.write_text('user notes')
        self.assertEqual(confirm.publish_final_reports(output, results, final), 2)
        self.assertEqual({path.name for path in final.iterdir()},
                         {self.commit, 'notes.md'})
        self.assertEqual({path.name for path in (final / self.commit).iterdir()},
                         {f'{self.commit}-1.md', f'{self.commit}-2.md'})
        self.assertIn('new', (final / self.commit / f'{self.commit}-1.md').read_text())
        self.assertEqual(notes.read_text(), 'user notes')

    def test_selected_run_preserves_other_final_reports(self):
        final = self.root / 'report-final'
        commit_dir = final / self.commit
        commit_dir.mkdir(parents=True)
        for index in (1, 2):
            (commit_dir / f'{self.commit}-{index}.md').write_text(confirm.FINAL_MARKER + '\nprevious')
        other_commit = final / ('b' * 40)
        other_commit.mkdir()
        other_report = other_commit / f'{other_commit.name}-1.md'
        other_report.write_text(confirm.FINAL_MARKER + '\nother commit')
        results = [dict(id=f'{self.commit}-1', status='not_reproduced')]
        confirm.publish_final_reports(self.root, results, final, selected_only=True)
        self.assertFalse((commit_dir / f'{self.commit}-1.md').exists())
        self.assertTrue((commit_dir / f'{self.commit}-2.md').exists())
        self.assertTrue(other_report.is_file())

    def test_final_publication_refuses_unowned_collision_before_writing(self):
        final = self.root / 'report-final'
        commit_dir = final / self.commit
        commit_dir.mkdir(parents=True)
        reports = self.root / 'archive/reports'
        reports.mkdir(parents=True)
        identity = f'{self.commit}-1'
        (commit_dir / f'{identity}.md').write_text('hand-written report')
        (reports / f'{identity}.md').write_text('accepted report')
        other = f'{self.commit}-2'
        (reports / f'{other}.md').write_text('another accepted report')
        results = [dict(id=other, status='direct_report'), dict(id=identity, status='direct_report')]
        with self.assertRaises(ValueError):
            confirm.publish_final_reports(reports.parent, results, final)
        self.assertEqual((commit_dir / f'{identity}.md').read_text(), 'hand-written report')
        self.assertFalse((commit_dir / f'{other}.md').exists())

    def test_custom_final_directory_is_published_automatically(self):
        report = self.fixture(1, 'symbol 1')
        self.args.final_dir = self.root / 'custom-final'
        confirm.execute(confirm.load_cases(self.args), self.args)
        self.assertTrue((self.args.final_dir / self.commit / report.name).is_file())
        self.assertFalse((self.root / 'report-final').exists())

    def test_publication_groups_multiple_cases_and_commits(self):
        output = self.root / 'archive'
        reports = output / 'reports'
        reports.mkdir(parents=True)
        identities = [f'{self.commit}-3', f'{self.commit}-6', f'{"b" * 40}-1']
        for identity in identities:
            (reports / f'{identity}.md').write_text(identity)
        results = [dict(id=identity, status='direct_report') for identity in identities]
        final = self.root / 'report-final'
        self.assertEqual(confirm.publish_final_reports(output, results, final), 3)
        self.assertEqual({path.name for path in final.iterdir()}, {self.commit, 'b' * 40})
        for identity in identities:
            path = final / identity.split('-')[0] / f'{identity}.md'
            self.assertEqual(path.read_text(), confirm.FINAL_MARKER + '\n' + identity)

    def test_stale_grouped_reports_remove_only_empty_commit_directories(self):
        final = self.root / 'report-final'
        empty_commit, noted_commit = self.commit, 'b' * 40
        for commit in (empty_commit, noted_commit):
            directory = final / commit
            directory.mkdir(parents=True)
            (directory / f'{commit}-1.md').write_text(confirm.FINAL_MARKER + '\nstale')
        notes = final / noted_commit / 'notes.md'
        notes.write_text('user notes')
        unowned = final / noted_commit / f'{noted_commit}-2.md'
        unowned.write_text('hand-written report')
        confirm.publish_final_reports(self.root, [], final)
        self.assertFalse((final / empty_commit).exists())
        self.assertEqual({path.name for path in (final / noted_commit).iterdir()},
                         {'notes.md', unowned.name})
        self.assertEqual(notes.read_text(), 'user notes')
        self.assertEqual(unowned.read_text(), 'hand-written report')

    def test_selected_publication_migrates_only_selected_legacy_reports(self):
        final = self.root / 'report-final'
        final.mkdir()
        for index in (1, 2, 3):
            (final / f'{self.commit}-{index}.md').write_text(confirm.FINAL_MARKER + '\nlegacy')
        output = self.root / 'archive'
        (output / 'reports').mkdir(parents=True)
        name = f'{self.commit}-1.md'
        (output / 'reports' / name).write_text('refreshed')
        results = [dict(id=f'{self.commit}-1', status='direct_report'),
                   dict(id=f'{self.commit}-2', status='not_reproduced')]
        confirm.publish_final_reports(output, results, final, selected_only=True)
        self.assertEqual((final / self.commit / name).read_text(), confirm.FINAL_MARKER + '\nrefreshed')
        self.assertFalse((final / name).exists())
        self.assertFalse((final / f'{self.commit}-2.md').exists())
        self.assertEqual((final / f'{self.commit}-3.md').read_text(), confirm.FINAL_MARKER + '\nlegacy')

    def test_publication_refuses_symlinked_commit_directory(self):
        final = self.root / 'report-final'
        final.mkdir()
        external = self.root / 'external'
        external.mkdir()
        (final / self.commit).symlink_to(external, target_is_directory=True)
        output = self.root / 'archive'
        (output / 'reports').mkdir(parents=True)
        identity = f'{self.commit}-1'
        (output / 'reports' / f'{identity}.md').write_text('accepted')
        with self.assertRaisesRegex(ValueError, 'Invalid final report commit directory'):
            confirm.publish_final_reports(output, [dict(id=identity, status='direct_report')], final)
        self.assertEqual(list(external.iterdir()), [])

    def test_each_measurement_gets_fresh_data_and_cleans_up_server(self):
        self.fixture(1)
        case = confirm.load_cases(self.args)[0]
        process = MagicMock()
        process.poll.return_value = None
        seen = []

        def fake_run(command, log, **kwargs):
            seen.append(command)
            data = Path(kwargs['cwd']) / 'data/dump.rdb'
            self.assertEqual(data.read_bytes(), b'initial-fixture')
            data.write_bytes(b'modified by test workload')
            log.write_text(CSV)
            kwargs['stderr'].write_text('')

        with patch.object(confirm.subprocess, 'Popen', return_value=process), \
                patch.object(confirm.socket, 'socket'), patch.object(confirm, 'wait_ready'), \
                patch.object(confirm, 'stop_process') as stop, \
                patch.object(confirm, 'run_logged', side_effect=fake_run):
            for label in ('old', 'new'):
                result = confirm.measure(self.root, self.root, case, self.root / label, self.data, self.args)
                self.assertEqual(result['pipeline'], 10)
                self.assertEqual(result['clients'], 50)
        self.assertEqual(stop.call_count, 2)
        self.assertEqual(self.data.read_bytes(), b'initial-fixture')
        for command in seen:
            self.assertEqual(command[command.index('-n') + 1], '1000000')
            self.assertEqual(command[command.index('-c', 3) + 1], '50')
            self.assertEqual(command[command.index('-P') + 1], '10')

    def test_explicit_pipeline_and_clients_reach_benchmark(self):
        self.fixture(1)
        case = confirm.load_cases(self.args)[0]
        self.args = confirm.parser().parse_args(['--pipeline', '20', '--clients', '3'])
        process = MagicMock()
        process.poll.return_value = None

        def fake_run(command, log, **kwargs):
            self.assertEqual(command[command.index('-P') + 1], '20')
            self.assertEqual(command[command.index('-c', 3) + 1], '3')
            log.write_text(CSV)
            kwargs['stderr'].write_text('')

        with patch.object(confirm.subprocess, 'Popen', return_value=process), \
                patch.object(confirm.socket, 'socket'), patch.object(confirm, 'wait_ready'), \
                patch.object(confirm, 'stop_process'), \
                patch.object(confirm, 'run_logged', side_effect=fake_run):
            result = confirm.measure(self.root, self.root, case, self.root / 'measure', self.data, self.args)
        self.assertEqual(result['pipeline'], 20)
        self.assertEqual(result['clients'], 3)

    def test_timeout_stops_owned_command(self):
        process = MagicMock(pid=123456)
        process.wait.side_effect = subprocess.TimeoutExpired('test', 1)
        with patch.object(confirm.subprocess, 'Popen', return_value=process), \
                patch.object(confirm, 'stop_process') as stop, self.assertRaises(subprocess.TimeoutExpired):
            confirm.run_logged(['fixture'], self.root / 'command.log', timeout=1)
        stop.assert_called_once_with(process)


if __name__ == '__main__':
    unittest.main()
