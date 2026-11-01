#!/usr/bin/env python3
"""Validate a Claude Code skill folder. Stdlib only.

Usage: validate_skill.py <skill-folder>
Exit 0 = no errors (warnings allowed), 1 = errors, 2 = bad usage.
"""
import re
import sys
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
REF_RE = re.compile(r"`((?:scripts|references|assets)/[^`\s]+)`")


def parse_frontmatter(text):
    """Return (dict, body) or raise ValueError. Handles flat `key: value` lines only."""
    if not text.startswith("---\n"):
        raise ValueError("missing opening '---' on line 1")
    end = text.find("\n---", 4)
    if end == -1:
        raise ValueError("missing closing '---'")
    fields = {}
    for line in text[4:end].splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(f"unparseable frontmatter line: {line!r}")
        key, _, val = line.partition(":")
        val = re.sub(r"\s+#.*$", "", val.strip())  # drop trailing comment
        fields[key.strip()] = val.strip("\"'")
    return fields, text[end + 4:]


def validate(folder):
    errors, warns = [], []
    skill_md = folder / "SKILL.md"
    if not skill_md.is_file():
        return ["SKILL.md not found"], warns
    text = skill_md.read_text(encoding="utf-8")

    try:
        fm, body = parse_frontmatter(text)
    except ValueError as e:
        return [f"frontmatter: {e}"], warns

    name, desc = fm.get("name", ""), fm.get("description", "")
    if not name:
        errors.append("frontmatter: 'name' missing")
    else:
        if not NAME_RE.match(name):
            errors.append(f"name {name!r}: use lowercase letters, digits, single hyphens")
        if len(name) > 64:
            errors.append(f"name is {len(name)} chars (max 64)")
        if name != folder.resolve().name:
            warns.append(f"name {name!r} differs from folder {folder.resolve().name!r}")
    if not desc:
        errors.append("frontmatter: 'description' missing")
    else:
        if len(desc) > 1024:
            errors.append(f"description is {len(desc)} chars (max 1024)")
        if "<" in desc or ">" in desc:
            warns.append("description contains angle brackets")
        if not re.search(r"\b(use|when)\b", desc, re.I):
            warns.append("description never says when to use the skill; triggering will suffer")
    unknown = set(fm) - {"name", "description", "license", "allowed-tools", "metadata"}
    if unknown:
        warns.append(f"unrecognized frontmatter keys: {sorted(unknown)}")

    if not body.strip():
        errors.append("SKILL.md body is empty")
    if "TODO" in text:
        warns.append("SKILL.md still contains TODO placeholders")
    lines = len(text.splitlines())
    if lines > 500:
        warns.append(f"SKILL.md is {lines} lines (aim for <500; move bulk to references/)")

    for ref in sorted(set(REF_RE.findall(body))):
        if not (folder / ref.rstrip("/.,:;")).exists():
            errors.append(f"referenced file not found: {ref}")
    return errors, warns


def main(argv):
    if len(argv) != 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    folder = Path(argv[1])
    if not folder.is_dir():
        print(f"ERROR: not a directory: {folder}", file=sys.stderr)
        return 2
    errors, warns = validate(folder)
    for w in warns:
        print(f"WARN  {w}")
    for e in errors:
        print(f"ERROR {e}")
    print("FAIL" if errors else "OK")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
