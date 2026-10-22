#!/usr/bin/env bash
# Link shared skills and global agent instructions.
# Safe to run again after `git pull`.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGETS=("$HOME/.agents/skills" "$HOME/.claude/skills")

git -C "$ROOT" submodule update --init

# Remove broken links to custom skills that were renamed or removed.
for target in "${TARGETS[@]}"; do
  for dest in "$target"/*; do
    [[ -L "$dest" && ! -e "$dest" ]] || continue
    case "$(readlink "$dest")" in
      "$ROOT/skills/"*) rm -- "$dest" ;;
    esac
  done
done

status=0
while read -r path; do
  [[ -z "$path" || "$path" == \#* ]] && continue
  src="$ROOT/$path"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "missing: $path/SKILL.md" >&2
    status=1
    continue
  fi
  name="$(basename "$path")"
  for target in "${TARGETS[@]}"; do
    mkdir -p "$target"
    dest="$target/$name"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      echo "skip: $dest exists and is not a symlink" >&2
      status=1
      continue
    fi
    ln -sfn "$src" "$dest"
  done
done < "$ROOT/skills.txt"

for dest in "${CODEX_HOME:-$HOME/.codex}/AGENTS.md" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md"; do
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "skip: $dest exists and is not a symlink" >&2
    status=1
    continue
  fi
  ln -sfn "$ROOT/AGENTS.md" "$dest"
done

exit "$status"
