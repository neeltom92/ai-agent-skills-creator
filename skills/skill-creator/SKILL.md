---
name: skill-creator
description: Create, edit, test, and validate Claude Code skills. Use when the user wants to make a new skill, turn a workflow into a skill, improve an existing SKILL.md, fix a skill that does not trigger, or check a skill folder before sharing it.
---

# Skill Creator

Build a skill, test it on real prompts, and iterate until it behaves. Skip steps the user does not need. If they say "just draft it", draft it.

## 1. Capture intent

Pull answers from the conversation first (tools used, steps, corrections the user made). Ask only for the gaps:

1. What should the skill make Claude do?
2. What phrases or situations should trigger it?
3. What is the expected output?
4. Does it have checkable output (file transforms, fixed workflows)? If yes, write test prompts. If it is subjective (tone, style), skip tests.

## 2. Write the skill

Scaffold the folder first, then replace all placeholder text in the generated `SKILL.md`:

```bash
python3 scripts/init_skill.py <skill-name> --path ~/.claude/skills --dirs references
```

A skill is a folder. Only `SKILL.md` is required:

```
<skill-name>/
├── SKILL.md        required: frontmatter + instructions
├── scripts/        optional: code for repeated, deterministic work
├── references/     optional: docs loaded only when needed
└── assets/         optional: templates, fonts, icons used in output
```

Frontmatter:

```yaml
---
name: my-skill            # lowercase letters, digits, hyphens; matches the folder name; max 64 chars
description: What it does and when to use it.   # max 1024 chars
---
```

Rules for a good skill:

- **Description decides triggering.** It is the only text Claude sees before loading the skill. State what the skill does AND the situations that should trigger it, using the words a user would actually type. Lean slightly pushy ("use whenever X, even if the user doesn't say Y") because skills under-trigger.
- **Keep the body under ~500 lines.** Move bulk into `references/` and say in `SKILL.md` when to read each file.
- **Explain why, not just what.** A reason lets Claude handle cases the instructions did not anticipate. Prefer it to stacked MUST/NEVER rules.
- **Imperative voice, one idea per line.** Show an example of the output format when format matters.
- **Bundle repeated work.** If every test run ends up writing the same helper script, put it in `scripts/` and tell the skill to use it.
- **No surprises.** A skill must not hide behavior from the user. Its contents should be predictable from its description.

## 3. Test it

Write 2-3 realistic prompts, the kind a real user would type, with file names, context, and some mess. Run each one with the skill and read the results with the user. For the `evals.json` format, grading rules, and the version-comparison table, read `references/testing.md`.

- Compare against a baseline when it matters: same prompt without the skill, or with the old version.
- Judge output, not just success: wrong format, missed step, wasted work, ignored instructions.
- Add assertions only where output is objectively checkable. Do not force numbers onto subjective work.

## 4. Iterate

For each problem, find the cause before editing:

- Skill did not trigger: fix the description.
- Triggered but instructions ignored: make the instruction clearer or put it earlier. Add the reason.
- Instructions followed but output poor: improve the example or the process.
- Same helper written every run: bundle it.

Generalize from the failures. Do not patch the single test prompt. Rerun all prompts after each change and stop when the user is satisfied or nothing improves.

## 5. Tune the description

Write about 10 prompts: some that should trigger the skill, some near-misses that should not (shared keywords, different intent). Run each in a fresh session and note which ones misfire. Adjust the description and repeat. Near-misses matter more than obvious cases. The table format and stop rules are in `references/testing.md`.

## 6. Validate before sharing

```bash
python3 scripts/validate_skill.py <path/to/skill-folder>
```

It checks frontmatter, name format and folder match, description length, body size, and that files referenced from `SKILL.md` exist. Fix every `ERROR`. Review each `WARN`.

To install a skill, copy its folder to `~/.claude/skills/` (all projects) or `<repo>/.claude/skills/` (one project), then start a new session.
