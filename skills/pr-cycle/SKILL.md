---
name: pr-cycle
description: Review and fix a GitHub PR until no open P1 or P2 findings remain, then summarize the changes.
argument-hint: "[PR URL or number]"
disable-model-invocation: true
---

# PR cycle

Run a review–fix–review cycle for one GitHub PR with a fixer, a normal reviewer, and an additional adversarial reviewer. Continue without asking the user to select findings. Stop successfully only after both reviewers find no open P1 or P2 findings on the same final local tree and the changed behavior passes verification. If progress is blocked, report the blocker instead of claiming a clean result.

## Review procedure

Read the sibling `../pr-review/SKILL.md`. If the harness cannot resolve that relative path, read the installed `pr-review` skill from its reported path, `~/.agents/skills/pr-review/SKILL.md`, or `~/.claude/skills/pr-review/SKILL.md`. Read its dependency skills as directed there.

Reuse steps 1–3 of `pr-review`: gathering the PR and stack, explaining the change, reviewing correctness and simplicity, and recording findings with evidence and stable IDs. Apply these overrides only for this cycle:

- After step 3, fix open P1/P2 findings and repeat the review instead of waiting for ID selection.
- After the initial remote review, review the full current local change against the recorded base, including fixes, untracked files, and tests. Do not keep reviewing the unchanged remote diff or only the last fix.
- Keep the finding ledger during the cycle. Give brief progress updates; present the combined summary at the end rather than repeat the full report after every pass.
- Never run step 4. Do not post comments, submit reviews, approve, or merge the PR. Keep fixes local; commit or push only if the user explicitly asks. Any commits must use Conventional Commits.

Do not change `pr-review` or its normal stop-for-selection behavior.

## Agent roles

| Role | Responsibility |
|---|---|
| Fixer/coordinator | Gather context, maintain the finding ledger, edit production code, run verification, and report the result. |
| Normal reviewer | A separate agent in a fresh context runs the full `pr-review` procedure. It may use the fixer's model. |
| Adversarial reviewer | An additional agent in a fresh context tries to break the change. It must use a different model from both the fixer and the normal reviewer. |

- Discover supported agents and models through the harness's tools, configuration, or CLI help. Prefer the fixer's model for the normal reviewer, so only two distinct models are needed. Select the additional adversarial model with the table below, based on the model driving the normal review:

  | Driving main-review model | Required adversarial model |
  |---|---|
  | OpenAI/GPT, including GPT-6.1 | Claude Opus 5.5 |
  | Anthropic/Claude, including Opus 5.5 | GPT-6.1 |

  Resolve the named version to an exact provider/model ID from the current catalog or configuration. Use GPT-6.1, not GPT-6 or an older GPT; use Opus 5.5, not another Opus version or Sonnet. If the required version is unavailable, or the driving model is outside these two families, report a model-selection blocker. Do not invent an ID or choose a substitute.
- Record the actual provider/model IDs used and confirm that the chosen adversarial model differs from both primary roles. A different agent name, alias, or reasoning level is not a different model. Do not accept a silent model fallback.
- The adversarial reviewer supplements the normal reviewer; it never replaces it. Neither reviewer edits production files or fixes findings. Reviewers may reproduce claims in disposable worktrees and remove those artifacts afterward.
- Give each reviewer the PR spec, stack context, base/head revisions, full current local change, and the review instructions. Initially omit the fixer's rationale and the other reviewer's conclusions so each inspects the code independently. After that inspection, have each verify the existing finding ledger and the claimed fixes.
- Hold the local tree unchanged while both reviews run. Record the exact reviewed state, including local diffs and untracked file contents, not just the remote head SHA. A later edit invalidates both clean results; run both reviewers again after fixing.
- If separate reviewer agents or a distinct adversarial model cannot be used, report a blocked cycle and the missing capability. Do not substitute self-review or describe normal-review-only results as a completed cycle.

## 1. Prepare

- Resolve the PR repository, number, base, and head SHA. Gather existing reviews, comments, linked specs, and stack order with the `pr-review` procedure.
- Use the current checkout only if it is clean and matches the selected PR head. Otherwise, fetch the required refs and create a separate worktree at that head. Preserve the user's existing changes.
- Record the base revision and starting head SHA. Run the relevant baseline checks; distinguish existing failures from regressions introduced during the cycle.
- Select and verify the three agent roles and model identities before starting the review passes.

Done when the review target and baseline are known, both reviewers are available with the required model separation, and fixes can be made without changing unrelated work.

## 2. Review

- Have the normal reviewer run the full `pr-review` procedure, including the show-me explanation, ponytail tags, Standards and Spec axes, existing-comment checks, P1 reproductions, and stack ownership.
- Have the additional, different-model adversarial reviewer independently challenge spec assumptions, callers and boot paths, state transitions, boundaries, malformed inputs, failure paths, permissions, races, and stack/pipeline interactions where relevant. Ask for concrete counterexamples and evidence, not a quota of findings or agreement with the fixer. Apply the same priority, reproduction, and ownership rules as `pr-review`.
- Collect both reports before fixing. Merge duplicate findings into one stable ID and record which reviewer found or confirmed each issue. Resolve disagreements with the spec, code, and reproductions, not majority vote; an unresolved P1/P2 disagreement stays open.
- Track each finding's ID, priority, owning PR, evidence, status, proposed fix, and verification. Reuse IDs across passes; give new findings the next free number. Record which pass found or closed each item.
- An unresolved P2 question remains open until code, tests, or the linked spec answers it. Do not invent product decisions or lower a priority to end the cycle.
- Fix findings owned by this PR. Keep findings fixed later in the stack or already in main in the record, with their evidence and merge implications. Do not silently modify other PRs.
- Before fixing or declaring success, check whether the remote head or base changed. If either changed, refresh the target and review again. Preserve local fixes; if they cannot be carried forward safely, report a blocker.

If either reviewer reports an open P1/P2 finding, go to step 3. If neither does, run the final relevant tests and a smoke check of the changed behavior. If verification reveals a new issue or changes the reviewed files, record it and repeat both reviews. Proceed to step 4 only when both reviewer reports cover the same current local tree, the merged ledger has no open P1/P2 findings, and verification passes.

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
- The role and actual provider/model ID of each agent. Confirm that the adversarial reviewer was an additional agent on a different model from the fixer and the normal reviewer; report any unavailable or failed reviewer as a blocker.
- A table of resolved IDs, original priorities, fixes, and verification evidence. Include questions resolved without code changes and issues introduced and fixed during the cycle.
- The final open P1/P2 count and each reviewer's final result. For a successful cycle the count must be zero; name the exact local state both reviewers inspected and the checks that passed. For a blocked cycle, list every remaining P1/P2 ID and the exact missing decision, model, reviewer, or prerequisite. Never label a blocked cycle clean.
- Remaining P3/P4 findings, findings fixed elsewhere in the stack, and any dependence on later PRs. Include the ponytail line estimate or `Lean already.` from the review.
- The approval recommendation, including whether this PR can merge without the rest of the stack. This is a recommendation, not a submitted GitHub review.

Leave the fixes available for the user. Remove only disposable artifacts that contain no fixes. Do not claim the remote PR is fixed while changes exist only locally. No comments or reviews are posted by this skill.
