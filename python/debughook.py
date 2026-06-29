"""Breakpoint hook that prefers a rich debugger but always yields one.

Wired in through ``PYTHONBREAKPOINT=debughook.set_trace``. The module sits on
``PYTHONPATH`` via ``~/.config/python``, so ``import debughook`` succeeds in
every interpreter, including project virtualenvs. It tries pdbp, then ipdb,
then the standard library pdb. A missing optional debugger downgrades to the
next one instead of leaving ``breakpoint()`` dead, which is what a bare
``PYTHONBREAKPOINT=pdbp.set_trace`` would do in any venv without pdbp.
"""

from __future__ import annotations

import sys


def _enter(frame, header):
    """Open the best available debugger stopped at ``frame``."""
    if header is not None:
        print(header)

    # pdbp: maintained pdb++ fork. Drop-in pdb with sticky mode, syntax
    # highlighting and tab completion.
    try:
        import pdbp
    except ImportError:
        pass
    else:
        pdbp.Pdb().set_trace(frame)
        return

    # ipdb: IPython-powered prompt with completion and richer tracebacks.
    try:
        import ipdb
    except ImportError:
        pass
    else:
        ipdb.set_trace(frame)
        return

    # Standard library fallback. Always present.
    import pdb

    pdb.Pdb().set_trace(frame)


def set_trace(*args, **kwargs):
    """``sys.breakpointhook`` entry point. Stops in the caller's frame.

    ``breakpoint()`` forwards its arguments here. Only ``header`` is meaningful
    across backends, so it is honored and the rest are ignored.
    """
    header = kwargs.pop("header", None)
    _enter(sys._getframe(1), header)


def post_mortem(traceback=None):
    """Post-mortem debugging with the same backend preference as set_trace."""
    try:
        import pdbp as backend
    except ImportError:
        try:
            import ipdb as backend
        except ImportError:
            import pdb as backend
    backend.post_mortem(traceback)
