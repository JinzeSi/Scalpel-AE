import contextlib
from decimal import Decimal
import io
import json
from pathlib import Path
import tarfile
import unittest
from unittest.mock import MagicMock, patch

import confirm_perf_reports as confirm
import mysql_validation as validation
import test_generate_perf_report as screening_tests


class ConfirmationTests(unittest.TestCase):
    def setUp(self):
        self.fixture = screening_tests.ReportTests()
        self.fixture.setUp()
        self.addCleanup(self.fixture.doCleanups)
        self.root = self.fixture.root.resolve()
        self.commit, self.parent = self.fixture.commit, self.fixture.parent
        self.identity = self.commit + '-1'
        self.mapping = self.root / 'sql-times.txt'
        self.sql = (self.fixture.case / 'testcase.txt').read_text().strip()
        self.mapping.write_text(self.sql + '\t23000\n')
        self.args = confirm.parser().parse_args(['--root', str(self.root),
            '--report-dir', str(self.root / 'report'), '--final-dir', str(self.root / 'report-final'),
            '--mapping', str(self.mapping), '--source-repo', str(self.root / 'mysql-server'),
            '--boost-dir', str(self.root / 'boost'), '--data-file', str(self.root / 'tables.tar.gz'),
            '--mysqlslap', str(self.root / 'mysqlslap'), '--output-dir', str(self.root / 'confirmation')])
        self.args.source_repo.mkdir()
        self.args.boost_dir.mkdir()
        self.args.data_file.write_bytes(b'data snapshot fixture')
        self.args.mysqlslap.write_text('fixture')
        self.args.mysqlslap.chmod(0o755)
        self.generate()

    def generate(self):
        with contextlib.redirect_stdout(io.StringIO()):
            self.fixture.run_cli()

    def cases(self):
        return confirm.load_cases(self.args)

    def benchmark_fixture(self):
        (self.fixture.case / 'symbolic_testcase.txt').write_text('')
        return self.cases()

    def test_redis_retention_and_mapping_times_two(self):
        self.assertEqual(self.cases()[0]['action'], 'direct_report')
        for text in ('', '  \n'):
            (self.fixture.case / 'symbolic_testcase.txt').write_text(text)
            case = self.cases()[0]
            self.assertEqual(case['action'], 'benchmark')
            self.assertEqual(case['query_count'], 46000)
        (self.fixture.case / 'symbolic_testcase.txt').unlink()
        self.assertEqual(self.cases()[0]['symbolic_state'], 'missing')
        self.fixture.fixture(symbolic='101', default='103')
        (self.fixture.case / 'symbolic_testcase.txt').write_text('nonempty symbols')
        self.generate()
        self.assertEqual(self.cases()[0]['action'], 'benchmark')
        self.args.threshold_percent = Decimal('5')
        self.assertEqual(self.cases()[0]['action'], 'below_threshold')

    def test_failed_symbols_and_missing_results_do_not_confirm(self):
        self.fixture.fixture(default='104')
        self.generate()
        (self.fixture.case / 'compile.txt').write_text(confirm.reporting.FAILURES[confirm.reporting.SYMBOLIC][0])
        self.assertEqual(self.cases()[0]['action'], 'benchmark')
        (self.fixture.case / 'final-res.txt').unlink()
        self.assertEqual(self.cases()[0]['action'], 'manual_review')

    def test_mapping_errors_and_parent_mismatch(self):
        self.benchmark_fixture()
        self.mapping.write_text('different SQL\t10000\n')
        self.assertEqual(self.cases()[0]['action'], 'manual_review')
        self.args.expected_parent = 'c' * 40
        self.assertIn('parent', self.cases()[0]['error'])
        self.args.case = ['d' * 40 + '-1']
        with self.assertRaises(ValueError):
            self.cases()

    def test_clean_build_commands_and_cache(self):
        builds = self.root / 'builds'
        builds.mkdir()
        with patch.object(confirm, 'run_logged') as run, patch.object(confirm.os, 'access', return_value=True):
            destination = confirm.build_version(self.args.source_repo, self.commit, builds, self.args)
            commands = [call.args[0] for call in run.call_args_list]
            self.assertEqual(commands[0][:4], ['git', 'clone', '--no-hardlinks', '--no-checkout'])
            self.assertEqual(commands[1][-2:], ['--detach', self.commit])
            self.assertIn('-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=-O2 -g -DNDEBUG', commands[2])
            self.assertIn('-DWITH_BOOST=' + str(self.args.boost_dir), commands[2])
            self.assertEqual(commands[3][4:6], ['mysqld', 'mysql'])
            self.assertEqual(destination, builds / self.commit / 'build')
            run.reset_mock()
            self.assertEqual(confirm.build_version(self.args.source_repo, self.commit, builds, self.args), destination)
            run.assert_not_called()

    def test_plan_never_executes_or_writes(self):
        self.benchmark_fixture()
        before = sorted(str(path) for path in self.root.rglob('*'))
        with patch.object(confirm, 'execute') as execute, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(confirm.main(['--root', str(self.root)]), 0)
        execute.assert_not_called()
        self.assertEqual(before, sorted(str(path) for path in self.root.rglob('*')))

    def test_direct_retention_does_not_build_and_preserves_originals(self):
        case = self.cases()[0]
        original = Path(case['report']).read_bytes()
        with patch.object(confirm, 'build_version') as build, patch.object(validation, 'measure') as measure, \
                contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(confirm.execute([case], self.args), 0)
        build.assert_not_called()
        measure.assert_not_called()
        final = self.args.final_dir / self.commit / (self.identity + '.md')
        self.assertIn('No additional benchmark was run', final.read_text())
        self.assertEqual(Path(case['report']).read_bytes(), original)

    def test_benchmark_pipeline_uses_same_snapshot_and_count(self):
        cases = self.benchmark_fixture()
        samples = [dict(seconds='100', query_count=46000), dict(seconds='102', query_count=46000)]
        with patch.object(confirm.shutil, 'which', return_value='/bin/true'), \
                patch.object(confirm, 'resolve_pair', return_value={'old': self.parent, 'new': self.commit}), \
                patch.object(confirm, 'build_version', side_effect=[Path('/old-build'), Path('/new-build')]), \
                patch.object(validation, 'extract_data', side_effect=lambda archive, dest: dest / 'data') as extract, \
                patch.object(validation, 'measure', side_effect=samples) as measure, \
                contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(confirm.execute(cases, self.args), 0)
        calls = measure.call_args_list
        self.assertEqual(len(calls), 2)
        self.assertEqual(calls[0].args[1], self.sql)
        self.assertEqual(calls[0].args[4], calls[1].args[4])
        self.assertEqual(calls[0].args[5], calls[1].args[5])
        self.assertEqual(calls[0].kwargs['client'], calls[1].kwargs['client'])
        self.assertEqual(extract.call_args_list[0].args[0], extract.call_args_list[1].args[0])
        results = json.loads((self.args.output_dir / 'summary.json').read_text())
        self.assertEqual(results[0]['status'], 'benchmark_confirmed')
        self.assertEqual(Decimal(results[0]['slowdown_percent']), Decimal('2'))
        self.assertEqual((self.args.output_dir / 'snapshots/sql-times.txt').read_bytes(), self.mapping.read_bytes())
        self.assertTrue((self.args.final_dir / self.commit / (self.identity + '.md')).exists())

    def test_mismatched_counts_rejected(self):
        case = self.benchmark_fixture()[0]
        output = self.args.output_dir
        (output / 'snapshots').mkdir(parents=True)
        (output / 'builds').mkdir()
        (output / 'snapshots/sql-times.txt').write_bytes(self.mapping.read_bytes())
        folder = output / 'case'
        folder.mkdir()
        with patch.object(confirm, 'resolve_pair', return_value={'old': self.parent, 'new': self.commit}), \
                patch.object(confirm, 'build_version', return_value=Path('/build')), \
                patch.object(validation, 'extract_data', return_value=Path('/data')), \
                patch.object(validation, 'measure', side_effect=[dict(seconds='100', query_count=46000),
                                                                dict(seconds='110', query_count=23000)]):
            with self.assertRaisesRegex(ValueError, 'query counts'):
                confirm.benchmark_case(case, folder, output, self.args)

    def test_error_and_interruption_preserve_data(self):
        cases = self.benchmark_fixture()
        original = Path(cases[0]['result_path']).read_bytes()
        with patch.object(confirm.shutil, 'which', return_value='/bin/true'), \
                patch.object(confirm, 'benchmark_case', side_effect=RuntimeError('compile failed')), \
                contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(confirm.execute(cases, self.args), 1)
        result = json.loads((self.args.output_dir / 'summary.json').read_text())[0]
        self.assertEqual(result['status'], 'error')
        self.assertFalse(list(self.args.final_dir.rglob('*.md')))
        self.assertEqual(Path(cases[0]['result_path']).read_bytes(), original)
        self.args.output_dir = self.root / 'interrupted'
        with patch.object(confirm.shutil, 'which', return_value='/bin/true'), \
                patch.object(confirm, 'benchmark_case', side_effect=KeyboardInterrupt), \
                patch.object(confirm, 'publish_final_reports') as publish, \
                contextlib.redirect_stdout(io.StringIO()), self.assertRaises(KeyboardInterrupt):
            confirm.execute(cases, self.args)
        publish.assert_not_called()
        self.assertEqual(json.loads((self.args.output_dir / 'summary.json').read_text())[0]['status'], 'interrupted')

    def test_final_refresh_keeps_unselected_and_unowned_files(self):
        output = self.args.output_dir
        (output / 'reports').mkdir(parents=True)
        other = self.commit + '-2'
        content = '# Report\n\n## Original Result\n\n```text\ntimings\nmodified part:\nauxiliary\n```\n'
        for identity in (self.identity, other):
            (output / 'reports' / (identity + '.md')).write_text(content)
        confirm.publish_final_reports(output, [dict(id=i, status='direct_report')
                                               for i in (self.identity, other)], self.args.final_dir)
        final = self.args.final_dir / self.commit
        self.assertNotIn('auxiliary', (final / (self.identity + '.md')).read_text())
        (final / 'notes.md').write_text('manual note')
        confirm.publish_final_reports(output, [dict(id=self.identity, status='not_reproduced')],
                                      self.args.final_dir, selected_only=True)
        self.assertFalse((final / (self.identity + '.md')).exists())
        self.assertTrue((final / (other + '.md')).exists())
        confirm.publish_final_reports(output, [], self.args.final_dir)
        self.assertFalse((final / (other + '.md')).exists())
        self.assertEqual((final / 'notes.md').read_text(), 'manual note')

    def test_measurement_argv_count_and_process_cleanup(self):
        data = self.root / 'data'
        data.mkdir()
        output = self.root / 'measurement'
        server = MagicMock()
        server.poll.return_value = None

        def benchmark(command, log, **kwargs):
            self.assertIn('--number-of-queries=46000', command)
            self.assertIn('--query=' + self.sql, command)
            self.assertIn('--iterations=1', command)
            self.assertIn('--concurrency=1', command)
            log.write_text('Average number of seconds to run all queries: 100 seconds\n'
                           'Number of clients running queries: 1\n'
                           'Average number of queries per client: 46000\n')
            kwargs['stderr'].write_text('')

        with patch.object(validation.os, 'access', return_value=True), \
                patch.object(validation.subprocess, 'Popen', return_value=server), \
                patch.object(validation, 'wait_ready'), patch.object(validation, 'run_logged', side_effect=benchmark), \
                patch.object(validation, 'stop_process') as stop:
            result = validation.measure(self.root, self.sql, output, data, self.mapping)
        self.assertEqual(result['query_count'], 46000)
        stop.assert_called_once_with(server)
        with patch.object(validation.os, 'access', return_value=True), \
                patch.object(validation.subprocess, 'Popen', return_value=server), \
                patch.object(validation, 'wait_ready', side_effect=TimeoutError('startup timeout')), \
                patch.object(validation, 'stop_process') as stop, self.assertRaises(TimeoutError):
            validation.measure(self.root, self.sql, output, data, self.mapping)
        stop.assert_called_once_with(server)

    def test_data_extracted_separately_and_not_overwritten(self):
        archive = self.root / 'data.tar.gz'
        with tarfile.open(archive, 'w:gz') as stream:
            member = tarfile.TarInfo('./data/mysql.ibd')
            member.size = 7
            stream.addfile(member, io.BytesIO(b'fixture'))
        old, new = self.root / 'old', self.root / 'new'
        old.mkdir()
        new.mkdir()
        a = validation.extract_data(archive, old)
        b = validation.extract_data(archive, new)
        (a / 'mysql.ibd').write_bytes(b'changed')
        self.assertEqual((b / 'mysql.ibd').read_bytes(), b'fixture')
        with self.assertRaises(ValueError):
            validation.extract_data(archive, old)


if __name__ == '__main__':
    unittest.main()
