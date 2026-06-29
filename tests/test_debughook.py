"""Tests for the breakpoint fallback hook in python/debughook.py.

Pure-logic module with no real I/O, so a stdlib unittest suite is enough.
Run with: python3 -m unittest discover -s tests -p "test_*.py"
"""

import io
import sys
import types
import unittest
from contextlib import redirect_stdout
from pathlib import Path

# debughook.py lives in the repo's python/ config dir, not on the default path.
_PYTHON_DIR = Path(__file__).resolve().parents[1] / "python"
sys.path.insert(0, str(_PYTHON_DIR))

import debughook  # noqa: E402


class _Recorder:
    """Stands in for a debugger backend and records how it was entered."""

    def __init__(self):
        self.frame = "unset"
        self.entered = False

    def set_trace(self, frame=None):
        self.frame = frame
        self.entered = True


def _fake_pdb_module():
    """A module whose Pdb() returns a fresh recorder, mimicking pdb/pdbp."""
    module = types.ModuleType("fake_pdb")
    recorder = _Recorder()
    module.Pdb = lambda: recorder
    module._recorder = recorder
    return module


class DebughookDispatchTests(unittest.TestCase):
    def setUp(self):
        self._saved = {
            name: sys.modules.get(name) for name in ("pdbp", "ipdb", "pdb")
        }

    def tearDown(self):
        for name, mod in self._saved.items():
            if mod is None:
                sys.modules.pop(name, None)
            else:
                sys.modules[name] = mod

    def _block(self, *names):
        # Setting a module to None forces ``import name`` to raise ImportError.
        for name in names:
            sys.modules[name] = None

    def test_falls_back_to_pdb_when_others_missing(self):
        # Arrange
        self._block("pdbp", "ipdb")
        fake_pdb = _fake_pdb_module()
        sys.modules["pdb"] = fake_pdb
        here = sys._getframe()

        # Act
        debughook.set_trace()

        # Assert
        self.assertTrue(fake_pdb._recorder.entered)
        self.assertIs(fake_pdb._recorder.frame, here)

    def test_prefers_pdbp_over_everything(self):
        # Arrange
        fake_pdbp = _fake_pdb_module()
        sys.modules["pdbp"] = fake_pdbp
        sys.modules["ipdb"] = _fake_pdb_module()
        sys.modules["pdb"] = _fake_pdb_module()

        # Act
        debughook.set_trace()

        # Assert
        self.assertTrue(fake_pdbp._recorder.entered)

    def test_prefers_ipdb_over_pdb(self):
        # Arrange
        self._block("pdbp")
        fake_ipdb = types.ModuleType("fake_ipdb")
        recorder = _Recorder()
        fake_ipdb.set_trace = recorder.set_trace
        sys.modules["ipdb"] = fake_ipdb
        sys.modules["pdb"] = _fake_pdb_module()
        here = sys._getframe()

        # Act
        debughook.set_trace()

        # Assert
        self.assertTrue(recorder.entered)
        self.assertIs(recorder.frame, here)

    def test_header_is_printed(self):
        # Arrange
        self._block("pdbp", "ipdb")
        sys.modules["pdb"] = _fake_pdb_module()
        buffer = io.StringIO()

        # Act
        with redirect_stdout(buffer):
            debughook.set_trace(header="paused here")

        # Assert
        self.assertEqual(buffer.getvalue().strip(), "paused here")


if __name__ == "__main__":
    unittest.main()
