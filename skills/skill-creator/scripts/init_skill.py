#!/usr/bin/env python3
"""Scaffold a new skill folder. Stdlib only.

Usage: init_skill.py <skill-name> [--path DIR] [--dirs scripts references assets]
Creates DIR/<skill-name>/SKILL.md from a template. Refuses to overwrite.
"""
import argparse
import re
import sys
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")

TEMPLATE = """---
name: {name}
description: TODO what the skill does. Use when TODO the situations and phrases that should trigger it.
---

# {title}

TODO one or two lines on the purpose.

## Steps

1. TODO first step
2. TODO next step

## Output

TODO describe the expected output, with a short example if format matters.
"""


def main():
    ap = argparse.ArgumentParser(description="Scaffold a new skill folder.")
    ap.add_argument("name", help="lowercase letters, digits, hyphens; max 64 chars")
    ap.add_argument("--path", default=".", help="parent directory (default: current)")
    ap.add_argument("--dirs", nargs="*", default=[], choices=["scripts", "references", "assets"],
                    help="optional subfolders to create")
    a = ap.parse_args()

    if not NAME_RE.match(a.name) or len(a.name) > 64:
        sys.exit(f"ERROR: invalid name {a.name!r}: use lowercase letters, digits, single hyphens, max 64 chars")
    root = Path(a.path).expanduser() / a.name
    if root.exists():
        sys.exit(f"ERROR: {root} already exists; not overwriting")

    root.mkdir(parents=True)
    (root / "SKILL.md").write_text(TEMPLATE.format(name=a.name, title=a.name.replace("-", " ").title()))
    for d in a.dirs:
        (root / d).mkdir()
    print(f"Created {root}/SKILL.md. Fill in every TODO, then run validate_skill.py on the folder.")


if __name__ == "__main__":
    main()
