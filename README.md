# ai-agent-skills-creator

A minimal, self-contained `skill-creator` skill for Claude Code. It walks Claude through creating, testing, tuning, and validating other skills.

No dependencies beyond bash and standard Unix tools (works on macOS bash 3.2), and no network access needed. Written from scratch; it contains no third-party skill text.

## What's in it

```
skills/skill-creator/
├── SKILL.md                  the skill: capture intent, write, test, iterate, tune, validate
├── references/
│   ├── context-gathering.md  parallel research subagents (repo, GitHub/GitLab, Jira/Confluence MCPs)
│   └── testing.md            evals.json format, grading, version comparison, trigger tests
└── scripts/
    ├── init_skill.sh         scaffold a new skill folder from a template
    └── validate_skill.sh     checks a skill folder (frontmatter, name, length, TODOs, referenced files)
```

## Requirements

`bash`, `sed`, `awk`, `grep`. Tested on macOS (bash 3.2) and Linux (GNU and busybox). On Windows use WSL or Git Bash. The skill itself works without the scripts; they are helpers.

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

Scaffold and validate directly:

```bash
bash skills/skill-creator/scripts/init_skill.sh my-skill --dirs references   # creates ./my-skill
bash skills/skill-creator/scripts/validate_skill.sh path/to/my-skill
```

Exit code is `0` when there are no errors (warnings allowed), `1` on errors.

## Context gathering

When you ask Claude to create a skill, it fans out read-only subagents in parallel to collect context: your conversation, the local repo and existing skills, and whichever of GitHub, GitLab, Jira or Confluence MCP servers you have connected. Sources that aren't connected are skipped; none are required. See `references/context-gathering.md`.

## Scope

Deliberately small. It does not include an automated eval runner, benchmark harness, or description-optimization loop. `SKILL.md` covers those steps as a manual process. Add tooling when manual testing becomes the bottleneck.

## License

Not set yet. Add a `LICENSE` file before sharing outside your org.
