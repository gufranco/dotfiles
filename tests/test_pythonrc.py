import importlib.machinery
import runpy
import sys
import types
import unittest
from pathlib import Path
from unittest import mock

_PYTHONRC = Path(__file__).resolve().parents[1] / "python" / "pythonrc"


def _fake_readline(backend=None, doc=None):
    module = types.ModuleType("readline")
    module.__doc__ = doc
    module.__spec__ = importlib.machinery.ModuleSpec("readline", None)
    module.bindings = []
    module.parse_and_bind = module.bindings.append
    module.read_history_file = lambda path: None
    module.write_history_file = lambda path: None
    module.set_history_length = lambda length: None
    module.set_completer = lambda completer=None: None
    if backend is not None:
        module.backend = backend
    return module


def _run_pythonrc(readline):
    replaced = {"readline": readline}
    with (
        mock.patch.dict(sys.modules, replaced),
        mock.patch("atexit.register"),
        mock.patch.object(sys, "displayhook", sys.displayhook),
    ):
        sys.modules.pop("rlcompleter", None)
        return runpy.run_path(str(_PYTHONRC))


class TabCompletionBindingTest(unittest.TestCase):
    def test_binds_tab_with_editline_syntax_when_backend_is_editline(self):
        readline = _fake_readline(backend="editline")

        _run_pythonrc(readline)

        self.assertEqual(readline.bindings, ["bind ^I rl_complete"])

    def test_binds_tab_with_gnu_syntax_when_backend_is_readline(self):
        readline = _fake_readline(backend="readline")

        _run_pythonrc(readline)

        self.assertEqual(readline.bindings, ["tab: complete"])

    def test_detects_libedit_from_docstring_when_backend_attribute_is_missing(self):
        readline = _fake_readline(
            doc="Importing this module enables command line editing using libedit readline."
        )

        _run_pythonrc(readline)

        self.assertEqual(readline.bindings, ["bind ^I rl_complete"])

    def test_falls_back_to_gnu_syntax_when_nothing_identifies_the_backend(self):
        readline = _fake_readline()

        _run_pythonrc(readline)

        self.assertEqual(readline.bindings, ["tab: complete"])

    def test_leaves_no_helper_names_in_the_repl_namespace(self):
        namespace = _run_pythonrc(_fake_readline(backend="editline"))

        self.assertFalse(
            [
                name
                for name in namespace
                if name.startswith("_setup") or name == "_readline_available"
            ]
        )


if __name__ == "__main__":
    unittest.main()
