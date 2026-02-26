#!/usr/bin/env python3
"""Scan staged files for secrets before git commit.

Intercepts Bash tool calls that run git commit. Scans all staged files
for 40+ secret patterns. Blocks the commit if any secrets are found.

Receives Bash tool input as JSON on stdin.
Exit 0 = allow, exit 2 = block.
"""

import json
import re
import subprocess
import sys

# Only activate for git commit commands
COMMIT_PATTERN = re.compile(r"\bgit\s+commit\b")

# Files to skip
SKIP_EXTENSIONS = {
    ".lock", ".lockb", ".sum", ".mod",
    ".png", ".jpg", ".jpeg", ".gif", ".ico", ".svg", ".webp",
    ".woff", ".woff2", ".ttf", ".eot",
    ".zip", ".tar", ".gz", ".bz2",
    ".pdf", ".doc", ".docx",
}
SKIP_FILES = {
    ".env.example", ".env.template", ".env.sample",
    "package-lock.json", "yarn.lock", "pnpm-lock.yaml",
    "bun.lock", "bun.lockb", "Cargo.lock", "go.sum",
    "Gemfile.lock", "poetry.lock", "composer.lock",
}
SKIP_PATHS = {"node_modules/", "vendor/", ".git/", "dist/", "build/"}

# Secret patterns: (name, regex)
SECRET_PATTERNS = [
    ("AWS Access Key", r"AKIA[0-9A-Z]{16}"),
    ("AWS Secret Key", r"(?i)aws_secret_access_key\s*[=:]\s*[A-Za-z0-9/+=]{40}"),
    ("Anthropic API Key", r"sk-ant-[a-zA-Z0-9_-]{20,}"),
    ("OpenAI API Key", r"sk-[a-zA-Z0-9]{20,}"),
    ("Google API Key", r"AIza[0-9A-Za-z_-]{35}"),
    ("Stripe Live Key", r"sk_live_[0-9a-zA-Z]{24,}"),
    ("Stripe Publishable", r"pk_live_[0-9a-zA-Z]{24,}"),
    ("GitHub Token", r"gh[pousr]_[A-Za-z0-9_]{36,}"),
    ("GitHub Fine-Grained", r"github_pat_[A-Za-z0-9_]{22,}"),
    ("GitLab Token", r"glpat-[A-Za-z0-9_-]{20,}"),
    ("Slack Token", r"xox[baprs]-[0-9a-zA-Z-]{10,}"),
    ("Slack Webhook", r"https://hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[a-zA-Z0-9]+"),
    ("Discord Webhook", r"https://discord(?:app)?\.com/api/webhooks/\d+/[\w-]+"),
    ("Telegram Bot Token", r"\b\d{8,10}:[A-Za-z0-9_-]{35}\b"),
    ("Vercel Token", r"vercel_[A-Za-z0-9_-]{24,}"),
    ("Supabase Key", r"sbp_[a-f0-9]{40}"),
    ("Hugging Face Token", r"hf_[A-Za-z0-9]{34,}"),
    ("Replicate Token", r"r8_[A-Za-z0-9]{20,}"),
    ("Groq API Key", r"gsk_[A-Za-z0-9]{20,}"),
    ("npm Token", r"npm_[A-Za-z0-9]{36}"),
    ("PyPI Token", r"pypi-[A-Za-z0-9_-]{16,}"),
    ("Databricks Token", r"dapi[a-f0-9]{32}"),
    ("SendGrid Key", r"SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}"),
    ("Twilio Key", r"SK[a-f0-9]{32}"),
    ("Mailgun Key", r"key-[a-zA-Z0-9]{32}"),
    ("Heroku API Key", r"(?i)heroku.*[=:]\s*[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"),
    ("Private Key Header", r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"),
    ("JWT Token", r"eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+"),
    ("Generic Password", r"(?i)(?:password|passwd|pwd)\s*[=:]\s*['\"][^'\"]{8,}['\"]"),
    ("Generic Secret", r"(?i)(?:secret|token|api_key|apikey)\s*[=:]\s*['\"][^'\"]{8,}['\"]"),
    ("Database URL", r"(?:postgres|mysql|mongodb|redis)://[^\s'\"]+:[^\s'\"]+@"),
    ("Connection String", r"(?i)(?:server|data source)=[^;]+;.*(?:password|pwd)=[^;]+"),
]


def should_skip(filepath):
    """Check if a file should be skipped."""
    if any(filepath.startswith(p) or f"/{p}" in filepath for p in SKIP_PATHS):
        return True
    basename = filepath.rsplit("/", 1)[-1] if "/" in filepath else filepath
    if basename in SKIP_FILES:
        return True
    ext = ""
    if "." in basename:
        ext = "." + basename.rsplit(".", 1)[-1]
    if ext.lower() in SKIP_EXTENSIONS:
        return True
    return False


def scan_staged_files():
    """Scan all staged files for secret patterns."""
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True, text=True, timeout=10,
        )
        if result.returncode != 0:
            return []
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return []

    files = [f.strip() for f in result.stdout.splitlines() if f.strip()]
    findings = []

    for filepath in files:
        if should_skip(filepath):
            continue

        try:
            result = subprocess.run(
                ["git", "diff", "--cached", "--", filepath],
                capture_output=True, text=True, timeout=10,
            )
            if result.returncode != 0:
                continue
        except (subprocess.TimeoutExpired, FileNotFoundError):
            continue

        # Only scan added lines
        for line_num, line in enumerate(result.stdout.splitlines(), 1):
            if not line.startswith("+") or line.startswith("+++"):
                continue

            added_content = line[1:]
            for name, pattern in SECRET_PATTERNS:
                if re.search(pattern, added_content):
                    findings.append((filepath, name, added_content.strip()[:80]))
                    break  # One finding per line is enough

    return findings


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    command = data.get("input", {}).get("command", "")
    if not command or not COMMIT_PATTERN.search(command):
        sys.exit(0)

    findings = scan_staged_files()
    if not findings:
        sys.exit(0)

    report = ["BLOCKED: Potential secrets detected in staged files.\n"]
    for filepath, secret_type, snippet in findings:
        report.append(f"  {filepath}: {secret_type}")
        report.append(f"    {snippet}...")

    report.append("\nRemove the secrets and try again.")
    report.append("If these are false positives, commit manually outside Claude Code.")
    print("\n".join(report))
    sys.exit(2)


if __name__ == "__main__":
    main()
