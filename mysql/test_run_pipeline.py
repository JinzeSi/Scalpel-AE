import contextlib
import fcntl
import io
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import run_pipeline as pipeline


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.pane = dict(pane='%2', pid=100, tty='/dev/pts/21', command='bash', dead='0')
        self.root = Path('/tmp/mysql path with spaces and \'quotes')
        peer_patch = patch.object(pipeline, 'PRE_ROOT', self.root / 'preknowledge')
        peer_patch.start()
        self.addCleanup(peer_patch.stop)

    def test_command_changes_directory_and_quotes_path(self):
        self.assertEqual(shlex.split(pipeline.launch_command(self.root)),
                         ['cd', '--', str(self.root), '&&', 'bash', './run_all.sh'])

    def test_outside_launch_submits_cd_then_entry(self):
        with patch.object(pipeline, 'ROOT', self.root), \
             patch.object(pipeline, 'pane_info', return_value=self.pane), \
             patch.object(pipeline, 'require_idle_pane', return_value=False), \
             patch.object(pipeline, 'check_lock'), \
             patch.object(pipeline.subprocess, 'run') as run, \
             contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(pipeline.main([]), 0)
        self.assertEqual([call.args[0] for call in run.call_args_list], [
            ['tmux', 'send-keys', '-t', '%2', '-l', pipeline.launch_command(self.root)],
            ['tmux', 'send-keys', '-t', '%2', 'Enter'],
        ])

    def test_check_never_sends_keys_and_propagates_failure(self):
        with patch.object(pipeline, 'ROOT', self.root), \
             patch.object(pipeline, 'pane_info', return_value=self.pane), \
             patch.object(pipeline, 'require_idle_pane', return_value=False), \
             patch.object(pipeline, 'check_lock'), \
             patch.object(pipeline.subprocess, 'run', return_value=subprocess.CompletedProcess([], 7)) as run, \
             contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(pipeline.main(['--check']), 7)
        run.assert_called_once()
        self.assertEqual(run.call_args.args[0],
                         ['bash', str(self.root / 'run_auto.sh'), '--confirm', '--check'])
        self.assertEqual(run.call_args.kwargs['cwd'], self.root)
        self.assertEqual(run.call_args.kwargs['env']['MYSQL_COMMIT_FILE'], str(self.root / 'commit-tmp.txt'))

    def test_inside_pane_uses_full_list_and_preserves_prepared_environment(self):
        with patch.object(pipeline, 'ROOT', self.root), \
             patch.object(pipeline, 'pane_info', return_value=self.pane), \
             patch.object(pipeline, 'require_idle_pane', side_effect=[True, False]), \
             patch.object(pipeline, 'check_lock'), \
             patch.dict(os.environ, MYSQL_COMMIT_FILE='/old/selected.txt', S2E_TEST_ENV='prepared', MYSQL_ANALYSIS_DIR='/old/replay'), \
             patch.object(pipeline.os, 'chdir') as chdir, \
             patch.object(pipeline, 'project_lock', return_value=contextlib.nullcontext()), \
             patch.object(pipeline, 'prepare_run', return_value=self.root / 'session'), \
             patch.object(pipeline, 'worker', return_value=0) as worker, \
             patch.object(pipeline.subprocess, 'run') as run, \
             contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(pipeline.main([]), 0)
        chdir.assert_called_once_with(self.root)
        worker.assert_called_once_with('mysql', self.root / 'session')
        self.assertEqual(run.call_args.args[0], ['bash', str(self.root / 'run_auto.sh'), '--confirm', '--check'])
        environment = run.call_args.kwargs['env']
        self.assertEqual(environment['MYSQL_COMMIT_FILE'], str(self.root / 'commit-tmp.txt'))
        self.assertEqual(environment['S2E_TEST_ENV'], 'prepared')
        self.assertNotIn('MYSQL_ANALYSIS_DIR', environment)

    def test_peer_command_changes_to_real_preknowledge_directory(self):
        with patch.object(pipeline, 'ROOT', self.root):
            command = shlex.split(pipeline.peer_command(self.root / 'session'))
        self.assertEqual(command, ['cd', '--', str(pipeline.PRE_ROOT), '&&', 'python3', '-B', '-u',
                                  str(self.root / 'run_pipeline.py'), '--worker', 'preknowledge',
                                  '--run-dir', str(self.root / 'session')])

    def test_peer_busy_blocks_both_launches(self):
        with patch.object(pipeline, 'pane_info', return_value=self.pane), \
             patch.object(pipeline, 'require_idle_pane', side_effect=[False, RuntimeError('peer busy')]), \
             patch.object(pipeline.subprocess, 'run') as run, \
             contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(pipeline.main([]), 1)
        run.assert_not_called()

    def test_workers_share_snapshot_and_never_inherit_replay_mode(self):
        with patch.dict(os.environ, MYSQL_COMMIT_FILE='/old/selection', MYSQL_ANALYSIS_DIR='/archive', TEST_ENV='active'):
            env = pipeline.run_environment(self.root / 'session')
        self.assertEqual(env['MYSQL_COMMIT_FILE'], str(self.root / 'session/commits.txt'))
        self.assertEqual(env['MYSQL_PEER_RUN_DIR'], str(self.root / 'session'))
        self.assertNotIn('MYSQL_ANALYSIS_DIR', env)
        self.assertEqual(env['TEST_ENV'], 'active')

    def test_peer_failure_is_recorded_and_cancels_pair(self):
        with tempfile.TemporaryDirectory() as temporary:
            run_dir = Path(temporary)
            pipeline.save_json(run_dir / 'plan.json', dict(root=str(pipeline.ROOT),
                               preknowledge_root=str(pipeline.PRE_ROOT), mode='live'))
            with patch.object(pipeline, 'run_logged', side_effect=RuntimeError('build failed')), \
                 contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(pipeline.worker('preknowledge', run_dir), 1)
            status = json.loads((run_dir / 'preknowledge.status.json').read_text())
            self.assertEqual(status['exit_code'], 1)
            self.assertIn('build failed', status['error'])
            self.assertTrue((run_dir / 'cancel.json').is_file())
            with self.assertRaises(RuntimeError):
                pipeline.check_cancel(run_dir, 'preknowledge')

    def test_mysql_waits_for_live_peer_before_main_workflow(self):
        with tempfile.TemporaryDirectory() as temporary:
            run_dir = Path(temporary)
            commit = 'a' * 40
            (run_dir / 'commits.txt').write_text(commit + '\n')
            (run_dir / 'ack').mkdir()
            (run_dir / 'ack' / commit).touch()
            events = []
            with patch.object(pipeline, 'pane_info', return_value=self.pane), \
                 patch.object(pipeline, 'require_idle_pane', return_value=False), \
                 patch.object(pipeline, 'send_command', side_effect=lambda *a: events.append('launch peer')), \
                 patch.object(pipeline, 'wait_file', side_effect=lambda path, *a: events.append(path.name)), \
                 patch.object(pipeline, 'run_logged', side_effect=lambda *a: events.append('run main')), \
                 contextlib.redirect_stdout(io.StringIO()):
                pipeline.mysql_worker(run_dir)
            self.assertEqual(events, ['launch peer', 'preknowledge.ready', 'run main', 'preknowledge.finished.json'])

    def test_busy_redis_job_gets_no_keys(self):
        with patch.dict(os.environ, {}, clear=True), \
             patch.object(pipeline, 'pane_info', return_value=self.pane), \
             patch.object(pipeline, 'terminal_processes', return_value={100: (1, 'bash'), 101: (100, 'bash')}), \
             patch.object(pipeline.subprocess, 'run') as run, \
             contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(pipeline.main([]), 1)
        run.assert_not_called()

    def test_orphan_s2e_on_terminal_is_not_mistaken_for_idle(self):
        with patch.dict(os.environ, {}, clear=True), \
             patch.object(pipeline, 'terminal_processes', return_value={100: (1, 'bash'), 101: (1, 'qemu-system-x86')}):
            with self.assertRaisesRegex(RuntimeError, '101.*qemu'):
                pipeline.require_idle_pane(self.pane)

    def test_current_launch_ancestors_and_ps_are_allowed(self):
        processes = {100: (1, 'bash'), 200: (100, 'bash'), 300: (200, 'python3'), 400: (300, 'ps')}
        with patch.dict(os.environ, TMUX_PANE='%2'), \
             patch.object(pipeline.os, 'getpid', return_value=300), \
             patch.object(pipeline, 'terminal_processes', return_value=processes):
            self.assertTrue(pipeline.require_idle_pane(self.pane))
            processes[500] = (100, 'make')
            with self.assertRaisesRegex(RuntimeError, '500.*make'):
                pipeline.require_idle_pane(self.pane)

    def test_foreground_application_is_busy(self):
        with patch.dict(os.environ, {}, clear=True):
            for command in ('python3', 'vim', 'make'):
                with self.subTest(command=command), self.assertRaises(RuntimeError):
                    pipeline.require_idle_pane(dict(self.pane, command=command))

    def test_missing_tmux_pane_does_not_launch(self):
        with patch.object(pipeline.subprocess, 'check_output', side_effect=subprocess.CalledProcessError(1, ['tmux'])), \
             patch.object(pipeline.subprocess, 'run') as run, \
             contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(pipeline.main([]), 1)
        run.assert_not_called()

    def test_lock_check_does_not_create_file_and_rejects_held_lock(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            pipeline.check_lock(root)
            self.assertEqual(list(root.iterdir()), [])
            lock = root / '.run_auto.lock'
            with lock.open('wb') as stream:
                fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
                with self.assertRaisesRegex(RuntimeError, 'Another process holds'):
                    pipeline.check_lock(root)
            pipeline.check_lock(root)


if __name__ == '__main__':
    unittest.main()
