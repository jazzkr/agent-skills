---
name: pr-cycle
description: Review and fix a GitHub PR until no open P1 or P2 findings remain, then summarize the changes.
argument-hint: "[PR URL or number]"
disable-model-invocation: true
---

# PR cycle

Run a review–fix–review cycle for one GitHub PR. Continue without asking the user to select findings. Stop successfully only after a fresh full review finds no open P1 or P2 findings and the changed behavior passes verification. If progress is blocked, report the blocker instead of claiming a clean result.

## Review procedure

Read the sibling `../pr-review/SKILL.md`. If the harness cannot resolve that relative path, read the installed `pr-review` skill from its reported path, `~/.agents/skills/pr-review/SKILL.md`, or `~/.claude/skills/pr-review/SKILL.md`. Read its dependency skills as directed there.

Reuse steps 1–3 of `pr-review`: gathering the PR and stack, explaining the change, reviewing correctness and simplicity, and recording findings with evidence and stable IDs. Apply these overrides only for this cycle:

- After step 3, fix open P1/P2 findings and repeat the review instead of waiting for ID selection.
- After the initial remote review, review the full current local change against the recorded base, including fixes, untracked files, and tests. Do not keep reviewing the unchanged remote diff or only the last fix.
- Keep the finding ledger during the cycle. Give brief progress updates; present the combined summary at the end rather than repeat the full report after every pass.
- Never run step 4. Do not post comments, submit reviews, approve, or merge the PR. Keep fixes local; commit or push only if the user explicitly asks. Any commits must use Conventional Commits.

Do not change `pr-review` or its normal stop-for-selection behavior.

## 1. Prepare

- Resolve the PR repository, number, base, and head SHA. Gather existing reviews, comments, linked specs, and stack order with the `pr-review` procedure.
- Use the current checkout only if it is clean and matches the selected PR head. Otherwise, fetch the required refs and create a separate worktree at that head. Preserve the user's existing changes.
- Record the base revision and starting head SHA. Run the relevant baseline checks; distinguish existing failures from regressions introduced during the cycle.

Done when the review target and baseline are known and fixes can be made without changing unrelated work.

## 2. Review

- Run the full `pr-review` procedure, including the show-me explanation, ponytail tags, Standards and Spec axes, existing-comment checks, P1 reproductions, and stack ownership.
- Track each finding's ID, priority, owning PR, evidence, status, proposed fix, and verification. Reuse IDs across passes; give new findings the next free number. Record which pass found or closed each item.
- An unresolved P2 question remains open until code, tests, or the linked spec answers it. Do not invent product decisions or lower a priority to end the cycle.
- Fix findings owned by this PR. Keep findings fixed later in the stack or already in main in the record, with their evidence and merge implications. Do not silently modify other PRs.
- Before fixing or declaring success, check whether the remote head or base changed. If either changed, refresh the target and review again. Preserve local fixes; if they cannot be carried forward safely, report a blocker.

If open P1/P2 findings remain, go to step 3. If none remain, run the final relevant tests and a smoke check of the changed behavior. If verification reveals a new issue, record it and continue the cycle. Proceed to step 4 only when the current local tree has a clean full review and verification passes.

## 3. Fix and verify

- Fix open P1/P2 findings in priority order. Make the smallest changes that address their causes. Leave P3/P4 improvements alone unless they are needed for a P1/P2 fix.
- For each bug, add a suitable regression test, observe it fail for the expected reason, apply the fix, and observe it pass. Run the relevant existing checks and exercise the changed runtime path. If a regression test cannot cover the behavior, use a reproducible smoke check and state the limit.
- Close an item only with evidence that its behavior is fixed or its question is resolved. Passing tests do not by themselves prove all P1/P2 findings are gone.
- Remove throwaway P1 reproduction tests and their temporary worktrees as `pr-review` requires. Keep permanent regression tests and any worktree that contains the fixes.
- If the same finding survives a pass, investigate the failed fix rather than repeat it. If a required decision, permission, external dependency, or safe fix is unavailable, stop with a blocked summary. Do not use a fixed pass count as a clean-exit condition.

Return to step 2 after the fixes. A fix pass is not a final review.

## 4. Summarize

Report:

- The PR, base revision, starting head SHA, final local revision or worktree path, and number of review passes. State whether fixes are uncommitted, committed, or pushed.
- A table of resolved IDs, original priorities, fixes, and verification evidence. Include questions resolved without code changes and issues introduced and fixed during the cycle.
- The final open P1/P2 count. For a successful cycle it must be zero; name the final reviewed tree and the checks that passed. For a blocked cycle, list every remaining P1/P2 ID and the exact missing decision or prerequisite. Never label a blocked cycle clean.
- Remaining P3/P4 findings, findings fixed elsewhere in the stack, and any dependence on later PRs. Include the ponytail line estimate or `Lean already.` from the review.
- The approval recommendation, including whether this PR can merge without the rest of the stack. This is a recommendation, not a submitted GitHub review.

Leave the fixes available for the user. Remove only disposable artifacts that contain no fixes. Do not claim the remote PR is fixed while changes exist only locally. No comments or reviews are posted by this skill.
