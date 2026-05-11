#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <source-workflow-dir> <target-project-dir>" >&2
  exit 1
fi

SOURCE_DIR="$1"
TARGET_DIR="$2"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source workflow directory does not exist: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.cursor/rules"

START_MARKER="<!-- fe-ai-workflow-start -->"
END_MARKER="<!-- fe-ai-workflow-end -->"

# 覆盖式同步（用于 skills/ references/ 等无用户内容的目录）
copy_path() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    return 0
  fi

  rm -rf "$target"
  cp -R "$source" "$target"
}

# 标记注入式同步（用于 CLAUDE.md / AGENTS.md，保留用户已有内容）
inject_or_update() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    return 0
  fi

  if [[ ! -f "$target" ]]; then
    # 目标不存在，直接创建并包裹标记
    { echo "$START_MARKER"; cat "$source"; echo "$END_MARKER"; } > "$target"
  elif grep -qF "$START_MARKER" "$target"; then
    # 标记已存在，替换标记之间的内容
    awk -v start="$START_MARKER" -v end="$END_MARKER" -v src="$source" '
      $0 == start {
        print
        while ((getline line < src) > 0) print line
        close(src)
        skip = 1
        next
      }
      $0 == end { skip = 0; print; next }
      !skip { print }
    ' "$target" > "$target.tmp" && mv "$target.tmp" "$target"
  else
    # 目标已存在但无标记，追加到末尾
    { echo ""; echo "$START_MARKER"; cat "$source"; echo "$END_MARKER"; } >> "$target"
  fi
}

inject_or_update "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
inject_or_update "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
copy_path "$SOURCE_DIR/skills" "$TARGET_DIR/skills"
copy_path "$SOURCE_DIR/references" "$TARGET_DIR/references"
copy_path "$SOURCE_DIR/commands" "$TARGET_DIR/.claude/commands"
copy_path "$SOURCE_DIR/.cursor/rules/workflow.mdc" "$TARGET_DIR/.cursor/rules/workflow.mdc"

echo "Workflow synced from $SOURCE_DIR to $TARGET_DIR"
