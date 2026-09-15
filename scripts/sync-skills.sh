#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_ROOT="$REPO_ROOT/.claude/skills"
MIRROR_ROOT="$REPO_ROOT/.agents/skills"

if [[ ! -d "$SOURCE_ROOT" ]]; then
  echo "Source skills directory not found: $SOURCE_ROOT" >&2
  exit 1
fi

mkdir -p "$MIRROR_ROOT"
shopt -s nullglob

count=0
for source_dir in "$SOURCE_ROOT"/*/; do
  source_file="${source_dir}SKILL.md"
  [[ -f "$source_file" ]] || continue

  skill_name="$(basename "$source_dir")"
  mirror_dir="$MIRROR_ROOT/$skill_name"

  mkdir -p "$mirror_dir"
  cp -- "$source_file" "$mirror_dir/SKILL.md"
  ((count += 1))
done

for mirror_dir in "$MIRROR_ROOT"/*/; do
  skill_name="$(basename "$mirror_dir")"
  if [[ ! -f "$SOURCE_ROOT/$skill_name/SKILL.md" ]]; then
    rm -rf -- "$mirror_dir"
  fi
done

echo "Synced $count skill(s) from .claude/skills to .agents/skills."
