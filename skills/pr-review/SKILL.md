---
name: pr-review
description: Review a GitHub PR, explain and rank findings, and post only user-selected comments.
argument-hint: "[PR URL or number]"
disable-model-invocation: true
---

# PR review

Review one GitHub PR in four steps. Do steps 1–3 in one pass, without stopping for the user. Stop after step 3 and wait for the user to select IDs for step 4.

## Skill references

Resolve `skill://<name>` through the harness's skill loader. If the harness does not support these URLs, read that skill's `SKILL.md` from its reported installation path, or from `~/.agents/skills/<name>/SKILL.md` or `~/.claude/skills/<name>/SKILL.md`. The required skills are `show-me`, `ponytail-review`, and `code-review`.

## 1. Gather

- Read the PR body, the diff, the head SHA, and all existing reviews and comments (human and bot).
- Look for stacked PRs: branches that contain this PR's head, and open PRs from the same author. Write down the order of the stack.

Done when you know the head SHA, every existing finding, and the position of this PR in the stack.

## 2. Explain and find

- Before you look for issues, explain in simple terms what the PR does: read `skill://show-me` and use the smallest view that makes the change clear. On Linux, open an HTML view with `xdg-open`. Put this explanation before the findings.
- Find issues in correctness, spec fit, and simplicity. Check how the change interacts with the system around it: callers, runtime and boot paths, and later steps in the pipeline.
- Do a ponytail pass on the diff: read `skill://ponytail-review` and apply its tags (`delete`, `stdlib`, `native`, `yagni`, `shrink`). Each tag finding becomes a fix in step 3.
- Do a Standards pass and a Spec pass: read `skill://code-review` and use its two axes, including the Fowler smell list. The spec is the PR body and the issues it links. Use only its find logic. Report its findings in this skill's ID format, with priorities, and skip its sub-agents, its headings, and its issue-tracker file.
- For each existing comment, check whether it is still open at the head SHA.
- Reproduce each P1 claim with a throwaway test in a temporary worktree, then delete the test and the worktree. Mark claims you did not reproduce as [INFERENCE].
- For stacked PRs: check whether a later PR fixes each finding. Assign each finding to the PR that introduces the problem.

Done when the explanation shows what the PR changes, each finding has evidence, a status (open, fixed later in the stack, or already in main), and an owning PR, and the ponytail, Standards, and Spec passes are complete.

## 3. Report

Give each potential fix its own header:

```
## <PREFIX>-NN: <title>
**Priority:** P1 | P2 | P3 | P4
**Location:** `file:line` (or the PR number, if the finding is on a different PR)
**Context:** what is wrong, the evidence, and the fix
**Suggested PR comment:**
> <comment text>
```

- Priorities: P1 = bug that blocks approval. P2 = behavior risk or open question. P3 = improvement. P4 = nit.
- For a ponytail finding, start the title with its tag (for example `yagni: hand-rolled libconfig parser`). In the context, say what replaces the code and how many lines the change removes. A ponytail finding is P3 or P4, unless the complexity hides a bug.
- Choose `<PREFIX>` from the PR topic. Keep IDs stable for the whole session. Give new findings the next free number.
- After the fixes, list the findings that need no action, with the reason (fixed later in the stack, not a regression).
- Then write `net: -<N> lines possible.` from the ponytail pass, or `Lean already.` if it found nothing.
- End with the approval recommendation:
  - The findings that must be fixed before approval, with the reason, and the findings that can wait.
  - Whether it is safe to merge this PR without the rest of the stack.
  - A review type (Comment, Approve, or Request changes). Take existing approvals into account.

Done when every finding has an ID, the report ends with the approval recommendation, and you have sent no comments.

## 4. Post (only the IDs the user selects)

- Start every comment with `🤖`. Start nits with `🤖 nit:`.
- Post each comment separately, never as a review:
  - Line comment: `gh api -X POST repos/O/R/pulls/N/comments` with `commit_id` (head SHA), `path`, `line`, and `side: RIGHT`.
  - If an existing comment already reports the finding: reply with a +1 and the new evidence: `POST .../pulls/N/comments/<id>/replies`.
  - If the file is not in that PR's diff: `gh pr comment N`.
- Before you post, make sure the head SHA did not change.
- Use the user's edits exactly (for example, remove the pleasantries). Write comments as direct questions with a concrete fix.
- Reply with a table (ID, location, link), then the approval recommendation again, changed if the new comments change it.
