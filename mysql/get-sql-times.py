#!/usr/bin/env python3
"""Look up a testcase's mysqlslap query count in the shared TSV mapping."""

import argparse
import csv
from pathlib import Path
import re


MAPPING = Path("/data3/sjz/AE/mysql/sql-times.txt")


def query_count(query, mapping=MAPPING, multiplier=1):
    if multiplier not in (1, 2):
        raise ValueError("multiplier must be 1 or 2")
    counts = {}
    with mapping.open(encoding="utf-8", newline="") as stream:
        reader = csv.reader(stream, delimiter="\t", quoting=csv.QUOTE_NONE)
        for row in reader:
            if not row or (len(row) == 1 and not row[0].strip()) or row[0].lstrip().startswith("#"):
                continue
            location = f"{mapping}:{reader.line_num}"
            if len(row) != 2 or not row[0].strip():
                raise ValueError(f"{location}: expected SQL<TAB>execution_count")
            sql, count = (field.strip() for field in row)
            if not re.fullmatch(r"[0-9]+", count) or int(count) <= 0:
                raise ValueError(f"{location}: execution_count must be a positive integer")
            if sql in counts:
                raise ValueError(f"{location}: duplicate testcase: {sql}")
            counts[sql] = int(count)
    sql = query.strip()
    if not sql:
        raise ValueError("testcase is empty")
    if sql not in counts:
        raise ValueError(f"testcase not found in {mapping}: {sql}")
    return counts[sql] * multiplier


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--multiplier", type=int, choices=(1, 2), default=1)
    parser.add_argument("--mapping", type=Path, default=MAPPING)
    parser.add_argument("query")
    args = parser.parse_args()
    try:
        count = query_count(args.query, args.mapping, args.multiplier)
    except (OSError, UnicodeError, csv.Error, ValueError) as error:
        parser.exit(1, f"get-sql-times: {error}\n")
    print(count)


if __name__ == "__main__":
    main()
