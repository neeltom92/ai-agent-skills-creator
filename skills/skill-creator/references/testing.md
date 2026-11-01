# Testing a skill

Read this when you reach the test, iterate, or description-tuning steps in `SKILL.md`.

## Test prompts

Write 2-3 prompts a real user would type: specific, with file names or context, a little messy. Keep them in `evals.json` next to the work, not inside the skill folder:

```json
{
  "skill": "my-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "the realistic user request",
      "expected": "one sentence: what a good result looks like",
      "assertions": ["only objectively checkable statements, e.g. 'output is valid JSON'"]
    }
  ]
}
```

Leave `assertions` empty for subjective output (tone, design). Judge those by reading.

## Running

For each prompt, run it in a fresh session (or subagent) with the skill installed. Save the output. When comparing, also run the same prompt on a baseline: no skill for a new skill, the previous version for an edit. Use a fresh session each time so earlier context does not leak in.

## Grading

For each run, record per assertion: pass or fail, with a quote or file path as evidence. Then read the output yourself and note anything the assertions missed. Flag:

- An assertion that passes with and without the skill. It tests nothing; drop it.
- An assertion that flips between runs of the same prompt. The prompt or the skill is ambiguous.
- Output that passes every assertion but reads wrong. The assertions are incomplete.

## Comparing versions

Keep a small table per iteration:

| prompt | baseline | v1 | v2 | notes |
|---|---|---|---|---|
| 1 | 2/4 | 3/4 | 4/4 | v2 fixed the format step |

Also note time and token cost if they changed a lot. A skill that doubles cost for a small gain may not be worth it.

## Trigger tests (description tuning)

Write about 10 prompts in a table:

| prompt | should trigger? | triggered? |
|---|---|---|
| a clear match | yes | |
| same keywords, different intent | no | |

Include near-misses: they share words with the skill but need something else. Run each in a fresh session and fill the last column. For each miss, change the description (add the missing phrase, or narrow an over-broad claim) and rerun the whole table, because a fix for one prompt can break another. Stop when the table is clean or edits stop helping.

If the `claude` CLI is available, you can script the runs with `claude -p "<prompt>"` and read which skill it used. Check `claude --help` for the output options in your version before relying on a flag.

## When to stop

- The user is happy with the results.
- Two iterations in a row show no improvement.
- Remaining failures are not caused by the skill.
