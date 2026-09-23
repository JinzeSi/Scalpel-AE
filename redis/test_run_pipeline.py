import argparse
import contextlib
import io
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import threading
import unittest
from unittest.mock import patch

import run_pipeline as pipeline


class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / 'redis'
        self.pre = self.base / 'pre'
        self.root.mkdir()
        self.pre.mkdir()
        (self.root / 'commit/makefile').mkdir(parents=True)
        (self.root / 'redis').mkdir()
        (self.root / 'tools').mkdir()
        for directory in ('makefile-26-02-01', 'socket-26-02-01'):
            (self.pre / directory).mkdir()
        self.rows = []
        self.add_group('1', 'a' * 40, ['b' * 40])
        self.add_group('2', 'c' * 40, ['d' * 40])

    def add_group(self, group, base, commits):
        name = f'commit-{group}.new'
        makefile, socket = f'Makefile-{group}', f'socket-{base}.c'
        (self.root / 'commit' / name).write_text('\n'.join(commits))
        for path in (self.root / 'commit/makefile' / makefile,
                     self.root / 'commit/makefile' / (makefile + '-1'),
                     self.pre / 'makefile-26-02-01' / makefile,
                     self.pre / 'socket-26-02-01' / socket):
            path.write_text('fixture')
        baseline = self.pre / ('init_file_' + base)
        baseline.mkdir()
        for number in (2, 3):
            (baseline / f'redis-BB-res-{number}.txt').write_text(base)
        self.rows.append('\t'.join((group, name, base, makefile, socket)))
        (self.root / 'commit/batches.tsv').write_text(
            'group\tfile\tbase\tmakefile\tsocket\n' + '\n'.join(self.rows) + '\n')

    def test_plan_order_and_reject_unconfigured_or_duplicate_commits(self):
        groups = pipeline.load_plan(self.root, self.pre)
        self.assertEqual([group['group'] for group in groups], ['1', '2'])
        extra = self.root / 'commit/commit-extra.txt'
        extra.write_text('e' * 40)
        with self.assertRaises(ValueError):
            pipeline.load_plan(self.root, self.pre)
        extra.unlink()
        (self.root / 'commit/commit-2.new').write_text('b' * 40)
        with self.assertRaises(ValueError):
            pipeline.load_plan(self.root, self.pre)

    def test_archive_preserves_inputs_and_moves_outputs_with_manifest(self):
        names = ['redis-' + 'b' * 40, 'report-final', 'report-confirmation', 'pipeline-runs']
        for name in names:
            folder = self.root / name
            folder.mkdir()
            (folder / 'result').write_text(name)
        (self.root / 'run.sh').write_text('original script')
        (self.root / 'redis-not-a-commit').mkdir()
        archive = Path(pipeline.archive_outputs(self.root, self.base / 'redis-brk'))
        manifest = pipeline.read_json(archive / 'manifest.json')
        self.assertTrue(all(entry['moved'] for entry in manifest['entries']))
        for name in names:
            self.assertFalse((self.root / name).exists())
            self.assertEqual((archive / name / 'result').read_text(), name)
        for name in ('redis', 'tools', 'commit', 'run.sh', 'redis-not-a-commit'):
            self.assertTrue((self.root / name).exists())
        self.assertEqual((archive / 'source-snapshot/run.sh').read_text(), 'original script')

    def test_archive_rejects_destination_inside_project(self):
        (self.root / 'report').mkdir()
        with self.assertRaises(ValueError):
            pipeline.archive_outputs(self.root, self.root / 'backup')
        self.assertTrue((self.root / 'report').exists())

    def test_lock_prevents_overlapping_runs(self):
        with pipeline.project_lock(self.root):
            with self.assertRaises(RuntimeError):
                with pipeline.project_lock(self.root):
                    pass

    def test_process_check_ignores_other_projects_with_same_script_name(self):
        other = self.base / 'mysql/make_symbolic-NULLEND.sh'
        with patch.object(pipeline.subprocess, 'check_output', return_value=f'123 bash bash {other}\n'):
            pipeline.ensure_idle_processes(self.root, self.pre)
        own = self.root / 'make_symbolic-NULLEND.sh'
        with patch.object(pipeline.subprocess, 'check_output', return_value=f'123 bash bash {own}\n'):
            with self.assertRaisesRegex(RuntimeError, 'Active experiment processes'):
                pipeline.ensure_idle_processes(self.root, self.pre)

    def test_failed_peer_interrupts_wait(self):
        pipeline.save_json(self.root / 'preknowledge.status.json', dict(exit_code=1, error='failed'))
        with self.assertRaisesRegex(RuntimeError, 'preknowledge worker failed'):
            pipeline.wait_file(self.root / 'missing', self.root, 'preknowledge', timeout=1)

    def test_unexpected_peer_exit_interrupts_wait(self):
        pipeline.save_json(self.root / 'preknowledge.status.json', dict(exit_code=None, pid=123))
        with patch.object(pipeline.os, 'kill', side_effect=ProcessLookupError):
            with self.assertRaisesRegex(RuntimeError, 'exited without a completion status'):
                pipeline.wait_file(self.root / 'missing', self.root, 'preknowledge', timeout=1)

    def prepare(self):
        args = argparse.Namespace(root=self.root, preknowledge_root=self.pre, batches=None,
                                  redis_pane='2:0.0', preknowledge_pane='4:0.0')
        return pipeline.prepare_run(args, pipeline.load_plan(self.root, self.pre), None)

    def run_fake_pipeline(self, candidates):
        run_dir = self.prepare()
        plan = pipeline.read_json(run_dir / 'plan.json')
        calls = []
        threads = []

        def fake_command(command, log, cwd, current_run, peer=None, env=None):
            calls.append(Path(command[1] if command[1] != '-u' else command[2]).name)
            if command[1].endswith('updateCommit-new.sh'):
                group = Path(command[2]).parent.name
                baseline = plan['groups'][int(group) - 1]['base']
                self.assertEqual((self.pre / 'redis-BB-res-2-new.txt').read_text(), baseline)
                self.assertEqual(Path(command[2]).read_text(), (run_dir / group / 'commits.txt').read_text())
            elif command[1].endswith('run.sh'):
                if command[-1] == '2':
                    self.assertTrue((run_dir / '1/done.json').is_file())
                Path(env['REDIS_PROGRESS_FILE']).write_text(Path(env['REDIS_COMMIT_FILE']).read_text())
            elif command[1].endswith('generate_perf_report.py'):
                self.assertTrue(all((run_dir / group / 'done.json').is_file() for group in ('1', '2')))
                (self.root / 'report').mkdir()
                if candidates:
                    for case in (1, 2):
                        (self.root / 'report' / ('b' * 40 + f'-{case}.md')).write_text('candidate')
            else:
                self.assertEqual(command[command.index('--requests') + 1], '1000000')
                self.assertEqual(command[command.index('--pipeline') + 1], '10')
                final = self.root / 'report-final' / ('b' * 40)
                final.mkdir(parents=True)
                for case in (1, 2):
                    (final / ('b' * 40 + f'-{case}.md')).write_text('confirmed')

        def start_peer(*_):
            def target():
                pipeline.save_json(run_dir / 'preknowledge.status.json', dict(exit_code=None))
                try:
                    pipeline.preknowledge_worker(plan, run_dir)
                except BaseException as error:
                    pipeline.save_json(run_dir / 'preknowledge.status.json', dict(exit_code=1, error=str(error)))
                    return
                pipeline.save_json(run_dir / 'preknowledge.finished.json', dict(exit_code=0))
            thread = threading.Thread(target=target, daemon=True)
            threads.append(thread)
            thread.start()

        with patch.object(pipeline, 'require_commands'), patch.object(pipeline, 'require_idle_pane'), \
                patch.object(pipeline, 'launch_in_pane', side_effect=start_peer), \
                patch.object(pipeline, 'run_logged', side_effect=fake_command), \
                contextlib.redirect_stdout(io.StringIO()) as output:
            pipeline.redis_worker(plan, run_dir)
            threads[0].join(timeout=5)
        self.assertFalse(threads[0].is_alive())
        self.assertEqual(calls.count('run.sh'), 2)
        self.assertEqual(calls.count('updateCommit-new.sh'), 2)
        self.assertEqual(calls.count('confirm_perf_reports.py'), int(candidates))
        self.assertTrue((self.root / 'report-final').is_dir())
        self.assertIn(f'Final reports: {2 if candidates else 0};', output.getvalue())

    def test_two_workers_finish_each_batch_before_reports(self):
        self.run_fake_pipeline(candidates=True)

    def test_no_candidates_creates_empty_final_without_benchmark(self):
        self.run_fake_pipeline(candidates=False)
        self.assertEqual(list((self.root / 'report-final').iterdir()), [])

    def test_real_command_failure_is_logged(self):
        with self.assertRaisesRegex(RuntimeError, 'Exit 7'):
            pipeline.run_logged(['bash', '-c', 'echo expected-error; exit 7'],
                                self.root / 'failure.log', self.root, self.root)
        self.assertIn('expected-error', (self.root / 'failure.log').read_text())

    def test_run_sh_handles_last_line_and_preserves_existing_results(self):
        shutil.copy2(Path(pipeline.__file__).parent / 'run.sh', self.root / 'run.sh')
        (self.root / 'make_symbolic-NULLEND.sh').write_text('exit 0\n')
        binary = self.base / 'bin'
        binary.mkdir()
        git = binary / 'git'
        git.write_text('#!/bin/sh\nexit 0\n')
        git.chmod(0o755)
        env = dict(os.environ, PATH=str(binary) + os.pathsep + os.environ['PATH'],
                   REDIS_PROGRESS_FILE=str(self.root / 'completed'))
        result = subprocess.run(['bash', str(self.root / 'run.sh'), '1'], env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / 'completed').read_text().splitlines(), ['b' * 40])
        repeat = subprocess.run(['bash', str(self.root / 'run.sh'), '1'], env=env, capture_output=True, text=True)
        self.assertNotEqual(repeat.returncode, 0)
        self.assertIn('Existing result directory', repeat.stderr)


if __name__ == '__main__':
    unittest.main()
