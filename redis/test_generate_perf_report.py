import subprocess
import sys
import tempfile
import unittest
from decimal import Decimal
from pathlib import Path

import generate_perf_report as reporting


LEGACY_RESULT = (
    '\u65b0\u7248\u672c\u6cbf\u7b26\u53f7\u6267\u884c\n11\n'
    '\u65b0\u7248\u672c\u9ed8\u8ba4\u6267\u884c\n9\n'
    '\u65e7\u7248\u672c\n10\n'
    '\u65b0\u65e7\u7248\u672c\u6bd4\u8f83\uff08\u6cbf\u7b26\u53f7\u6267\u884c\uff09\n0.1\n'
    '\u65b0\u65e7\u7248\u672c\u6bd4\u8f83\uff08\u9ed8\u8ba4\u6267\u884c\uff09\n-0.1\n'
)


class ResultLabelTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.result = self.root / 'final-res.txt'

    def test_english_measurement_output_generates_report(self):
        for filename, timing in (
                ('real-execute-res-1.txt', 11),
                ('real-execute-res-old-1.txt', 10),
                ('real-execute-res-pure-1.txt', 9)):
            (self.root / filename).write_text(f'end to end took {timing} us\n' * 40)
        script = Path(__file__).resolve().with_name('run-getres.py')
        output = subprocess.check_output([sys.executable, '-B', str(script)],
                                         cwd=self.root, text=True)
        self.assertTrue(output.isascii())
        self.assertIn('New version (symbolic path)\n11.0\n', output)
        self.assertIn('New version (default execution)\n9.0\n', output)
        self.assertIn('Old version\n10.0\n', output)
        self.result.write_text(output)
        values, content = reporting.parse_result(self.result)
        self.assertEqual(values[reporting.SYMBOLIC_CHANGE], Decimal('0.1'))
        self.assertEqual(values[reporting.DEFAULT_CHANGE], Decimal('-0.1'))
        report = reporting.render_report('a' * 40, '1', self.result, values, content,
                                         Decimal('0.02'), 'GET key')
        self.assertIn('| New version (symbolic path) | 11.000000 | 10.000000 | +10.0000% | YES |', report)
        self.assertIn('| New version (default execution) | 9.000000 | 10.000000 | -10.0000% | no |', report)
        self.assertTrue(report.isascii())

    def test_legacy_chinese_results_remain_readable(self):
        self.result.write_text(LEGACY_RESULT, encoding='utf-8')
        values, content = reporting.parse_result(self.result)
        self.assertEqual(values, {
            'New version (symbolic path)': Decimal('11'),
            'New version (default execution)': Decimal('9'),
            'Old version': Decimal('10'),
            'New vs. old (symbolic path)': Decimal('0.1'),
            'New vs. old (default execution)': Decimal('-0.1'),
        })
        self.assertEqual(content, LEGACY_RESULT)

    def test_same_field_in_two_languages_is_rejected(self):
        self.result.write_text(LEGACY_RESULT + 'New version (symbolic path)\n11\n',
                               encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'duplicate field'):
            reporting.parse_result(self.result)


if __name__ == '__main__':
    unittest.main()
