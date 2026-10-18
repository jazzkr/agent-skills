# agent-skills

Agent skills for Claude Code, Codex, and other agents that read `~/.agents/skills`.

## Install

This repository and its submodules are public. Installation needs Git and Bash, but no GitHub login.

```bash
git clone --recurse-submodules https://github.com/jazzkr/agent-skills.git
./agent-skills/install.sh
```

`install.sh` links each folder in `skills.txt` into `~/.agents/skills` and `~/.claude/skills`. If a real folder already has the same name, the script skips it and shows a warning.

## Custom PR review

Use `/pr-review <PR URL or number>` in Claude Code or `$pr-review <PR URL or number>` in Codex. Invoke it explicitly; it is not started by the model on its own.

The skill gathers the PR and stack, explains the change, checks correctness and simplicity, and reports findings with stable IDs. It stops after the report. Only IDs you select are posted as separate comments; it never submits a GitHub review.

The skill uses `show-me`, `ponytail-review`, and `code-review`, which are included in `skills.txt`. It supports both `skill://` loaders and direct reads of installed skill files.

## PR cycle

Use `/pr-cycle <PR URL or number>` in Claude Code or `$pr-cycle <PR URL or number>` in Codex.

The cycle uses three separate roles: a fixer/coordinator, a normal reviewer that follows `pr-review`, and an additional adversarial reviewer that tries to break the change. The normal reviewer may use the fixer's model. The adversarial reviewer must use a different model from both; a different agent name or reasoning level does not count.

Both reviewers inspect the same unchanged local tree against the PR base. The fixer addresses their open P1/P2 findings, then both review again in fresh contexts. Completion requires no open P1/P2 findings from either reviewer and passing verification. Missing agents or a distinct adversarial model produce a blocked report; there is no silent self-review or same-model fallback.

The final summary lists each agent's actual provider/model ID, both final review results, findings, fixes, checks, remaining P3/P4 items, stack dependencies, and the location of the local changes. Fixes stay local unless you explicitly request commits or pushes. The skill does not post comments, submit reviews, approve, or merge. The normal `/pr-review` selection gate is unchanged.

## Shared agent instructions

`AGENTS.md` adapts [Fabien Sanglard's coding guidance](https://fabiensanglard.net/agent.md/index.html) for this setup. It is kept in Git, not fetched from the website at session start. Review and commit any later changes.

The installer links that one file into:

| Agent | Global instructions |
|---|---|
| Codex | `~/.codex/AGENTS.md` (or `$CODEX_HOME/AGENTS.md`) |
| Claude Code | `~/.claude/CLAUDE.md` (or `$CLAUDE_CONFIG_DIR/CLAUDE.md`) |

Existing real files are left in place, with a warning and exit code 1. Review and merge those instructions by hand before replacing them with links. Start a new agent session after installation. A Codex `AGENTS.override.md` takes precedence over its global `AGENTS.md`.

Every commit must use Conventional Commits, including merge, squash, and revert commits. PR titles use the same format. This replaces the article's capitalized subject rule. Renovate is also set to use Conventional Commits explicitly.

These are agent instructions, not a Git commit hook. They do not block commits made by other tools.


## Impeccable

[Impeccable](https://github.com/pbakaus/impeccable) is pinned to the `skill-v4.5.2` release. The install script links its complete `.agents` skill bundle, including command references, nested agent definitions, and its launcher, into both skill folders.

Use `/impeccable init` in Claude Code or `$impeccable init` in Codex to start. The launcher downloads its pinned engine on first use, so that first run needs network access. This installs the skill only; project hooks are not enabled.

Renovate tracks only `skill-vX.Y.Z` tags for this source. Engine and CLI tags do not produce skill update PRs.

## Update

Updates use the [hosted Renovate GitHub App](https://github.com/apps/renovate), not a GitHub Actions workflow. No `RENOVATE_TOKEN` secret is needed.

The account owner must [install or configure the app](https://github.com/apps/renovate/installations/new), choose **Only select repositories**, and add `jazzkr/agent-skills`. The app uses the existing `renovate.json`. After authorization, check the repository's Dependency Dashboard and Renovate PRs for activity.

Renovate opens a PR when an upstream source has a new version:

- Sources with a release tag in the `branch` field of `.gitmodules` get release updates. Impeccable uses `skill-vX.Y.Z`; the other tagged sources use `vX.Y.Z`.
- Sources without a `branch` line get a PR for each new commit on the default branch.

Read the diff before you merge. Skills are prompts that run with your agent's permissions. After you merge, run `git pull && ./install.sh` on each machine.

Do not use `git submodule update --remote`. It fails for submodules that are pinned to a tag. To update one by hand, run `git fetch --tags && git checkout <tag>` in the submodule, then change its `branch` value in `.gitmodules`.

## Add a skill

- From a current source: add its path to `skills.txt`.
- From a new source: `git submodule add <url> vendor/<name>`, pin it to a release tag (see above), then add its paths to `skills.txt`.
- Custom: create `skills/<name>/SKILL.md`, then add `skills/<name>` to `skills.txt`.
