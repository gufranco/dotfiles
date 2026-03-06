#!/usr/bin/env python3
"""Block catastrophic and dangerous bash commands at runtime.

Three severity levels:
  Level 1 BLOCK: Catastrophic, irreversible system damage
  Level 2 BLOCK: Critical path protection (.git, .env, lockfiles)
  Level 3 WARN:  Suspicious patterns that might be intentional

Receives Bash tool input as JSON on stdin.
Exit 0 = allow, exit 2 = block.
"""

import json
import re
import subprocess
import sys

# Level 1: Catastrophic commands. Always block.
CATASTROPHIC = [
    r"\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?/\s*$",  # rm -rf /
    r"\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?/\s+",  # rm -rf / <anything>
    r"\bdd\s+.*\bof=/dev/[sh]d",  # dd to disk device
    r"\bmkfs\b",  # format filesystem
    r":\(\)\s*\{\s*:\|:\s*&\s*\}\s*;",  # fork bomb
    r"\bchmod\s+(-[a-zA-Z]*\s+)?777\s+/\s*$",  # chmod 777 /
    r"\bchmod\s+(-[a-zA-Z]*\s+)?777\s+/[a-z]",  # chmod 777 /etc, /usr...
    r">\s*/dev/[sh]d",  # write to raw disk
    r"\bwget\b.*\|\s*(ba)?sh",  # pipe remote script to shell
    r"\bcurl\b.*\|\s*(ba)?sh",  # pipe remote script to shell
]

# Level 2: Critical path protection. Block with explanation.
CRITICAL_PATHS = [
    (r"\brm\s+(-[a-zA-Z]*\s+)?.*\.git\b", "Deleting .git/ destroys repository history"),
    (r"\brm\s+(-[a-zA-Z]*\s+)?.*\.env\b", "Deleting .env removes environment configuration"),
    (r"\brm\s+(-[a-zA-Z]*\s+)?.*\.claude\b", "Deleting .claude/ removes Claude configuration"),
    (r"\bgit\s+push\s+.*--force\s", "Use --force-with-lease instead of --force"),
    (r"\bgit\s+push\s+.*-f\s", "Use --force-with-lease instead of -f"),
    (r"\bgit\s+reset\s+--hard\b", "git reset --hard discards uncommitted work"),
    (r"\bgit\s+clean\s+.*-f", "git clean -f permanently deletes untracked files"),
    (r"\bgit\s+checkout\s+\.\s*$", "git checkout . discards all unstaged changes"),
]

# Level 3: Suspicious patterns. Warn but allow.
SUSPICIOUS = [
    (r"\brm\s+(-[a-zA-Z]*\s+)?.*\*", "rm with wildcard, double-check the path"),
    (r"\bfind\b.*-delete\b", "find -delete permanently removes matched files"),
    (r"\bxargs\s+rm\b", "xargs rm can delete unexpected files"),
    (r">\s*/etc/", "Writing to /etc/ modifies system configuration"),
    (r"\bkillall\b", "killall terminates all processes with that name"),
]


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    command = data.get("input", {}).get("command", "")
    if not command:
        sys.exit(0)

    # Level 1: Catastrophic
    for pattern in CATASTROPHIC:
        if re.search(pattern, command):
            print(f"BLOCKED: Catastrophic command detected.\nCommand: {command}")
            sys.exit(2)

    # Level 2: Critical paths
    for pattern, reason in CRITICAL_PATHS:
        if re.search(pattern, command):
            print(f"BLOCKED: {reason}\nCommand: {command}")
            sys.exit(2)

    # Level 2.5: Protected branch push detection
    if re.search(r"\bgit\s+push\b", command) and not re.search(r"--force", command):
        try:
            branch = subprocess.check_output(
                ["git", "branch", "--show-current"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        except Exception:
            branch = ""

        targets_protected = (
            "origin main" in command
            or "origin master" in command
            or "origin develop" in command
            or (branch in ("main", "master", "develop") and "origin " not in command)
        )
        if targets_protected:
            print(
                f"BLOCKED: Direct push to protected branch ({branch or 'main/develop'}).\n"
                "Use a feature branch and create a PR instead.\n"
                f"Command: {command}"
            )
            sys.exit(2)

    # Level 3: Suspicious (warn via stderr, allow)
    for pattern, reason in SUSPICIOUS:
        if re.search(pattern, command):
            print(f"WARNING: {reason}\nCommand: {command}", file=sys.stderr)
            break

    sys.exit(0)


if __name__ == "__main__":
    main()
