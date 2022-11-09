import unittest


class TestCase(unittest.TestCase):
    def test_simple(self):
        self.assertEqual(1, 1)
