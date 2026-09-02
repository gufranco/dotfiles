#!/usr/bin/env python3
"""Reject `local` declarations that collide with zsh special parameters.

zsh ties several lowercase names to shell state. Declaring one with `local`
either fails at runtime ("read-only variable: status") or silently replaces the
tied value for that scope, which is how `local path=...` makes every external
command in a function unresolvable. Neither failure is visible to `zsh -n`,
which only parses, or to shellcheck, which reads the file as bash.
"""

import pathlib
import re
import sys

SPECIAL = set(
    """
    argv status path cdpath fpath manpath mailpath module_path fignore psvar
    watch prompt prompt2 prompt3 prompt4 options commands functions aliases
    galiases saliases builtins dis_builtins dis_functions dis_aliases
    dis_galiases dis_saliases reswords dis_reswords patchars dis_patchars
    parameters modules nameddirs userdirs historywords history jobdirs jobtexts
    jobstates funcstack funcfiletrace funcsourcetrace zsh_eval_context
    pipestatus signals termcap terminfo usergroups sysparams keymaps widgets
    epochtime
    """.split()
)

DECLARATION = re.compile(r"^\s*(?:local|typeset|declare)\s+(?:-[A-Za-z]+\s+)*(.*)$")


def findings(paths):
    for path in paths:
        with open(path, encoding="utf-8", errors="replace") as handle:
            for number, line in enumerate(handle, 1):
                match = DECLARATION.match(line)
                if not match:
                    continue
                for token in match.group(1).split():
                    name = token.split("=")[0].strip("\"'")
                    if name in SPECIAL:
                        yield path, number, name


def main():
    paths = sorted(p for p in pathlib.Path("zsh").rglob("*") if p.is_file())
    found = list(findings(paths))

    for path, number, name in found:
        print(
            "%s:%d: `local %s` shadows a zsh special parameter; rename it"
            % (path, number, name)
        )

    if found:
        print("")
        print("%d declaration(s) must be renamed." % len(found))
        return 1

    print("No zsh special parameters shadowed by local declarations.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
