import hashlib
import os
from pathlib import Path
import subprocess
import tempfile
import threading
import time
import unittest


class LiveExchangeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.session = self.root / 'session'
        self.peer = self.root / 'peer'
        for folder in (self.session / 'replies', self.session / 'ack', self.peer, self.root / 'work'):
            folder.mkdir(parents=True)
        self.commits = ['a' * 40, 'b' * 40]
        self.base = '0' * 40
        self.common = Path(__file__).resolve().with_name('run-common.sh')
        self.environment = dict(os.environ, TEST_ROOT=str(self.root), REAL_COMMON=str(self.common))
        self.prefix = r'''
set -euo pipefail
source "$REAL_COMMON"
MYSQL_RUN_ROOT="$TEST_ROOT"
PREKNOWLEDGE_DIR="$TEST_ROOT/peer"
MYSQL_PEER_RUN_DIR="$TEST_ROOT/session"
PREKNOWLEDGE_READY="$MYSQL_PEER_RUN_DIR/preknowledge.ready"
COMMIT_FILE="$TEST_ROOT/commits.txt"
INITIAL_COMMIT=0000000000000000000000000000000000000000
PREKNOWLEDGE_WAIT_SECONDS=2
load_commits
sleep() { command sleep .01; }
cd "$TEST_ROOT/work"
'''

    def ready(self, commits=None, digest=None):
        (self.root / 'commits.txt').write_text('\n'.join(commits or self.commits) + '\n')
        digest = digest or hashlib.sha256((self.root / 'commits.txt').read_bytes()).hexdigest()
        (self.session / 'preknowledge.ready').write_text(f'{os.getpid()} {digest} {self.base}\n')

    def execute(self, script):
        return subprocess.run(['bash', '-c', self.prefix + script], env=self.environment,
                              capture_output=True, text=True, timeout=8)

    def test_live_empty_and_normal_requests_stay_in_order(self):
        self.ready()
        seen, errors = [], []
        stop = threading.Event()

        def peer():
            try:
                for commit in self.commits:
                    flag = self.peer / 'demo-S2E-times-res-3-flag.txt'
                    deadline = time.monotonic() + 6
                    while not flag.exists():
                        if stop.is_set() or time.monotonic() >= deadline:
                            raise TimeoutError('fake peer did not receive a request')
                        time.sleep(.005)
                    self.assertEqual((self.session / 'request-commit.txt').read_text().strip(), commit)
                    seen.append(((self.peer / 'demo-S2E-times-res-2.txt').read_text(), flag.read_text()))
                    flag.unlink()
                    temporary = self.session / 'replies/reply.tmp'
                    temporary.write_text('' if commit == self.commits[0] else 'testcase:SELECT 1;\n')
                    temporary.replace(self.session / 'replies' / (commit + '.txt'))
            except BaseException as error:
                errors.append(error)

        thread = threading.Thread(target=peer)
        thread.start()
        try:
            result = self.execute(r'''
wait_for_preknowledge
for command_now in "${commits[@]}"; do
    : > call_analyse.txt
    : > symbolic_analyse.txt
    if [[ "$command_now" == "${commits[1]}" ]]; then
        printf 'current call analysis\n' > call_analyse.txt
        printf 'current symbolic analysis\n' > symbolic_analyse.txt
    fi
    request_preknowledge
    cp call_analyse2.txt "$TEST_ROOT/$command_now.received"
done
''')
        finally:
            stop.set()
            thread.join(timeout=8)
        self.assertFalse(thread.is_alive())
        self.assertFalse(errors, errors)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(seen, [('', ''), ('current call analysis\n', 'current symbolic analysis\n')])
        self.assertEqual((self.root / (self.commits[0] + '.received')).read_text(), '')
        self.assertIn('SELECT 1;', (self.root / (self.commits[1] + '.received')).read_text())
        self.assertEqual(sorted(path.name for path in (self.session / 'ack').iterdir()), self.commits)

    def test_wrong_list_digest_is_rejected_before_publishing_request(self):
        self.ready(digest='incorrect-list')
        result = self.execute('command_now=${commits[0]}\nrequest_preknowledge\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('commit list differs', result.stderr)
        self.assertFalse((self.peer / 'demo-S2E-times-res-3-flag.txt').exists())

    def test_another_commits_reply_is_never_used(self):
        self.ready()
        (self.session / 'replies' / (self.commits[1] + '.txt')).write_text('wrong commit\n')
        result = self.execute(r'''
: > call_analyse.txt
: > symbolic_analyse.txt
command_now=${commits[0]}
request_preknowledge
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Timed out', result.stderr)
        self.assertFalse((self.session / 'ack' / self.commits[0]).exists())
        self.assertFalse((self.root / 'work/call_analyse2.txt').exists())

    def test_failed_peer_cannot_start_confirmation(self):
        self.ready()
        (self.session / 'preknowledge.exit-status.txt').write_text('1\n')
        result = self.execute('wait_for_preknowledge_completion\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('confirmation will not start', result.stderr)

    def test_final_reply_is_accepted_when_peer_exits_at_the_same_time(self):
        self.ready()
        result = self.execute(r'''
: > call_analyse.txt
: > symbolic_analyse.txt
command_now=${commits[0]}
checks=0
peer_is_ready() {
    checks=$((checks + 1))
    if (( checks == 1 )); then return 0; fi
    printf 'final live reply\n' > "$MYSQL_PEER_RUN_DIR/replies/$command_now.txt"
    return 1
}
request_preknowledge
''')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((self.root / 'work/call_analyse2.txt').read_text(), 'final live reply\n')
        self.assertTrue((self.session / 'ack' / self.commits[0]).is_file())

    def test_only_exact_unstaged_instrumentation_template_is_accepted(self):
        repo = self.root / 'source'
        (repo / 'sql').mkdir(parents=True)
        parser = repo / 'sql/sql_parse.cc'
        parser.write_text('original source\n')
        (repo / 'other.cc').write_text('other source\n')
        commands = [
            ['git', 'init', '-q', str(repo)],
            ['git', '-C', str(repo), 'add', '.'],
            ['git', '-C', str(repo), '-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
             'commit', '-qm', 'fixture'],
        ]
        for command in commands:
            subprocess.run(command, check=True, capture_output=True)
        self.ready()
        check = 'check_preknowledge_source "$TEST_ROOT/source" 1\n'
        self.assertEqual(self.execute(check).returncode, 0)
        (self.peer / 'sql_parse').mkdir()
        (self.peer / 'sql_parse' / ('sql_parse-' + self.base + '.cc')).write_text('saved instrumentation\n')
        parser.write_text('saved instrumentation\n')
        self.assertEqual(self.execute(check).returncode, 0)
        parser.write_text('unrecognized hand edit\n')
        self.assertNotEqual(self.execute(check).returncode, 0)
        parser.write_text('saved instrumentation\n')
        (repo / 'other.cc').write_text('another hand edit\n')
        self.assertNotEqual(self.execute(check).returncode, 0)
        (repo / 'other.cc').write_text('other source\n')
        subprocess.run(['git', '-C', str(repo), 'add', 'sql/sql_parse.cc'], check=True)
        self.assertNotEqual(self.execute(check).returncode, 0)


if __name__ == '__main__':
    unittest.main()
