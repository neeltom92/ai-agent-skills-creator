# ai-agent-skills-creator

A minimal, self-contained `skill-creator` skill for Claude Code. It walks Claude through creating, testing, tuning, and validating other skills.

No dependencies beyond Python 3 (stdlib only) and no network access needed. Written from scratch; it contains no third-party skill text.

## What's in it

```
skills/skill-creator/
├── SKILL.md                  the skill: capture intent, write, test, iterate, tune, validate
└── scripts/
    └── validate_skill.py     checks a skill folder (frontmatter, name, length, referenced files)
```

## Install

Copy the folder; a skill is just a directory.

```bash
# all projects
cp -R skills/skill-creator ~/.claude/skills/

# or one project
cp -R skills/skill-creator <repo>/.claude/skills/
```

Start a new Claude Code session and run `/skill-creator`, or just ask Claude to make a skill and it should trigger on its own.

## Use

Ask Claude things like:

- "Turn this workflow into a skill."
- "My `deploy-check` skill never triggers. Fix it."
- "Review this SKILL.md before I share it."

Validate any skill folder directly:

```bash
python3 skills/skill-creator/scripts/validate_skill.py path/to/my-skill
```

Exit code is `0` when there are no errors (warnings allowed), `1` on errors.

## Scope

Deliberately small. It does not include an automated eval runner, benchmark harness, or description-optimization loop. `SKILL.md` covers those steps as a manual process. Add tooling when manual testing becomes the bottleneck.

## License

Not set yet. Add a `LICENSE` file before sharing outside your org.
