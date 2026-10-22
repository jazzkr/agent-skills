# Agent instructions

Adapted from [Fabien Sanglard's coding guidance](https://fabiensanglard.net/agent.md/index.html). These are shared defaults; use the project's language and tool conventions where they differ. Every commit must use Conventional Commits.

## Communication

- Use short, direct text in replies, comments, and commit messages. State facts, decisions, and risks. Omit praise and superlatives.

## Code

- Keep changes small and limited to the requested work. Keep the existing style in code you do not change.
- Use the simplest design that meets the requirement. Add abstractions only where they are needed.
- Name repeated or meaningful values with constants or enums. Use named constants for values defined by a specification. Keep clear, one-use literals inline.
- Reduce nesting with early returns and `continue`.
- Keep function names short and clear; aim for fewer than 30 characters.
- Use enums instead of boolean function parameters that hide the meaning of a call.
- Separate logical blocks with blank lines. Add short comments where the purpose or reason is not clear. Use examples or ASCII diagrams for complex systems.
- Keep fields and functions private unless the design requires wider access. Ask before changing an existing member from private to internal or public.
- Keep low-level I/O, parsing, and network mechanics behind focused interfaces. Calling code should use domain concepts.
- Respect existing layer boundaries. Each layer calls the next lower layer; UI and controller code must go through the service layer rather than call storage or low-level clients directly.
- In languages with brace-delimited control flow, use braces even for a one-line `if`.

## Bug fixes

1. Write a regression test for the reported behavior.
2. Run it and observe the expected failure.
3. Apply the fix and observe the test passing.

## Commits

- Every commit, including merge, squash, and revert commits, must use `<type>[optional scope][!]: <description>`.
- Use a lowercase type: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- Use an imperative description and no final period. Example: `feat(skills): add shared agent guidance`.
- Aim for a subject of 50 characters or fewer; never exceed 72 characters, including the prefix.
- Mark a breaking change with `!` before the colon or a `BREAKING CHANGE:` footer.
- When a body is needed, separate it from the subject with one blank line. Wrap body text at 72 characters. Explain what changed and why; leave implementation details to the code.
- Use the same format for PR titles so squash commits retain it. Set an explicit Conventional Commit subject when creating a merge or revert commit; Git's default messages do not meet this rule.

## Pull requests

- The user reviews and merges every PR. Open the PR, report its URL and check status, then stop. This includes deploy, revert, and urgent security PRs.
- Change `main` and other protected branches only through a PR.
