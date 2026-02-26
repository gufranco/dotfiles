#!/usr/bin/env python3
"""Claude Code statusline: context usage, git branch, cost, and duration.

Reads JSON from stdin with: model, workspace, transcript_path, cost.
Outputs a single statusline string.

Context estimation is based on transcript file size as a rough proxy
for token usage. Color thresholds:
  green  (< 50%): plenty of room
  yellow (50-70%): moderate usage
  orange (70-85%): getting tight
  red    (85-95%): consider compacting
  critical (> 95%): compaction imminent
"""

import json
import os
import subprocess
import sys
import time

# Context window estimates by model family (in tokens)
CONTEXT_LIMITS = {
    "opus": 200000,
    "sonnet": 200000,
    "haiku": 200000,
}

# Rough bytes-per-token ratio for transcript files
BYTES_PER_TOKEN = 4

# ANSI-free statusline symbols
BAR_FULL = "#"
BAR_EMPTY = "-"
BAR_WIDTH = 10


def get_context_percentage(transcript_path, model):
    """Estimate context usage from transcript file size."""
    if not transcript_path or not os.path.exists(transcript_path):
        return 0

    file_size = os.path.getsize(transcript_path)
    estimated_tokens = file_size / BYTES_PER_TOKEN

    limit = CONTEXT_LIMITS.get("sonnet", 200000)
    for key, value in CONTEXT_LIMITS.items():
        if key in model.lower():
            limit = value
            break

    return min(100, int((estimated_tokens / limit) * 100))


def get_git_info(workspace):
    """Get current branch and dirty status."""
    try:
        branch = subprocess.run(
            ["git", "-C", workspace, "branch", "--show-current"],
            capture_output=True, text=True, timeout=3,
        )
        branch_name = branch.stdout.strip() or "detached"

        status = subprocess.run(
            ["git", "-C", workspace, "status", "--porcelain"],
            capture_output=True, text=True, timeout=3,
        )
        dirty = "*" if status.stdout.strip() else ""

        return f"{branch_name}{dirty}"
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return ""


def format_cost(cost):
    """Format session cost."""
    if not cost:
        return ""
    try:
        amount = float(cost)
        if amount < 0.01:
            return ""
        return f"${amount:.2f}"
    except (ValueError, TypeError):
        return ""


def build_bar(percentage):
    """Build a text progress bar."""
    filled = int(BAR_WIDTH * percentage / 100)
    empty = BAR_WIDTH - filled
    return f"[{BAR_FULL * filled}{BAR_EMPTY * empty}]"


def get_level(percentage):
    """Get severity label for context usage."""
    if percentage >= 95:
        return "CRITICAL"
    if percentage >= 85:
        return "HIGH"
    if percentage >= 70:
        return "MED"
    if percentage >= 50:
        return "LOW"
    return ""


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        print("")
        return

    model = data.get("model", "sonnet")
    workspace = data.get("workspace", os.getcwd())
    transcript_path = data.get("transcript_path", "")
    cost = data.get("cost", 0)

    parts = []

    # Context usage
    pct = get_context_percentage(transcript_path, model)
    bar = build_bar(pct)
    level = get_level(pct)
    ctx_str = f"ctx:{bar} {pct}%"
    if level:
        ctx_str += f" {level}"
    parts.append(ctx_str)

    # Git branch
    git_info = get_git_info(workspace)
    if git_info:
        parts.append(git_info)

    # Cost
    cost_str = format_cost(cost)
    if cost_str:
        parts.append(cost_str)

    print(" | ".join(parts))


if __name__ == "__main__":
    main()
