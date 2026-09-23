#!/usr/bin/env python3
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import sys


SKIP = 10


def check_selection(commit, commit_file):
    # The log path scopes the policy to one existing batch, including child PIDs.
    log_path = Path(os.readlink('/proc/self/fd/1'))
    if not log_path.is_absolute() or log_path.name != commit + '.log':
        return 0
    plan_path = log_path.parent / 'run-selection.json'
    if not plan_path.exists():
        return 0
    plan = json.loads(plan_path.read_text())
    if (plan.get('version') != 1
            or not isinstance(plan.get('run_dir'), str)
            or Path(plan['run_dir']).resolve() != log_path.parent.resolve()):
        raise ValueError('selection policy does not match this run')
    content = Path(commit_file).read_bytes()
    if hashlib.sha256(content).hexdigest() != plan['commit_digest']:
        raise ValueError('commit list has changed since the selection was defined')
    commits = content.decode('ascii').splitlines()
    if len(set(commits)) != len(commits) or any(
        re.fullmatch('[0-9a-f]{40}', item) is None for item in commits
    ):
        raise ValueError('invalid or duplicate commit in input')
    index = commits.index(commit) + 1
    ranges = plan['ranges']
    if not isinstance(ranges, list) or not ranges:
        raise ValueError('selection must contain at least one range')
    previous_end = 0
    for item in ranges:
        if (not isinstance(item, list) or len(item) != 2
                or any(type(number) is not int for number in item)
                or not previous_end < item[0] <= item[1] <= len(commits)):
            raise ValueError('ranges must be ordered, disjoint, and within the list')
        previous_end = item[1]
    if any(start <= index <= end for start, end in ranges):
        print(f'SELECTED original index {index}/{len(commits)}: {commit}')
        return 0

    skipped_file = log_path.parent / 'skipped-by-selection.tsv'
    with skipped_file.open('a', newline='') as stream:
        writer = csv.writer(stream, delimiter='\t', lineterminator='\n')
        if stream.tell() == 0:
            writer.writerow(['original_index', 'commit', 'reason'])
        writer.writerow([index, commit, 'outside selected ranges'])
    print(f'SKIPPED_BY_SELECTION original index {index}/{len(commits)}: {commit}; '
          'no analysis, compilation, or testcase execution')
    return SKIP


def main():
    if len(sys.argv) != 3:
        print('Usage: run-selection.py COMMIT COMMIT_FILE', file=sys.stderr)
        return 1
    try:
        return check_selection(sys.argv[1], sys.argv[2])
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f'Run selection failed: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
