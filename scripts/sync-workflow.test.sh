#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/sync-workflow.sh"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_file_exists() {
  local file="$1"
  [[ -f "$file" ]] || fail "expected file to exist: $file"
}

assert_dir_exists() {
  local dir="$1"
  [[ -d "$dir" ]] || fail "expected directory to exist: $dir"
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  grep -q "$pattern" "$file" || fail "expected '$pattern' in $file"
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  grep -q "$pattern" "$file" && fail "expected '$pattern' NOT in $file" || true
}

# ── 准备临时目录 ────────────────────────────────────────────

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

SOURCE="$TMP_DIR/source"
TARGET="$TMP_DIR/target"
mkdir -p "$SOURCE" "$TARGET"

mkdir -p "$SOURCE/.cursor/rules"
mkdir -p "$SOURCE/skills/example-skill"
mkdir -p "$SOURCE/references"
mkdir -p "$SOURCE/commands/viktor"

printf "agents\n" > "$SOURCE/AGENTS.md"
printf "claude\n" > "$SOURCE/CLAUDE.md"
printf "cursor\n" > "$SOURCE/.cursor/rules/workflow.mdc"
printf "skill\n"  > "$SOURCE/skills/example-skill/SKILL.md"
printf "ref\n"    > "$SOURCE/references/example.md"
printf "cmd\n"    > "$SOURCE/commands/viktor/example.md"

# ── 用例 1：首次同步（目标文件均不存在）─────────────────────

"$SCRIPT" "$SOURCE" "$TARGET" >/dev/null 2>&1 || fail "sync should succeed on first run"

assert_file_exists "$TARGET/AGENTS.md"
assert_file_exists "$TARGET/CLAUDE.md"
assert_file_exists "$TARGET/.cursor/rules/workflow.mdc"
assert_dir_exists  "$TARGET/skills"
assert_dir_exists  "$TARGET/references"
assert_dir_exists  "$TARGET/.claude/commands/viktor"
assert_file_exists "$TARGET/skills/example-skill/SKILL.md"
assert_file_exists "$TARGET/references/example.md"
assert_file_exists "$TARGET/.claude/commands/viktor/example.md"

# AGENTS.md / CLAUDE.md 应包含标记和内容
assert_contains "$TARGET/AGENTS.md" "<!-- fe-ai-workflow-start -->"
assert_contains "$TARGET/AGENTS.md" "<!-- fe-ai-workflow-end -->"
assert_contains "$TARGET/AGENTS.md" "agents"
assert_contains "$TARGET/CLAUDE.md" "<!-- fe-ai-workflow-start -->"
assert_contains "$TARGET/CLAUDE.md" "claude"

# ── 用例 2：重复执行幂等性 ───────────────────────────────────

"$SCRIPT" "$SOURCE" "$TARGET" >/dev/null 2>&1 || fail "sync should be idempotent"

# 标记不应重复
marker_count=$(grep -c "fe-ai-workflow-start" "$TARGET/AGENTS.md")
[[ "$marker_count" -eq 1 ]] || fail "start marker should appear exactly once, got $marker_count"

# ── 用例 3：目标文件已有内容但无标记（追加模式）──────────────

TARGET2="$TMP_DIR/target2"
mkdir -p "$TARGET2"
printf "existing content\n" > "$TARGET2/AGENTS.md"

"$SCRIPT" "$SOURCE" "$TARGET2" >/dev/null 2>&1 || fail "sync should succeed on existing file without markers"

assert_contains     "$TARGET2/AGENTS.md" "existing content"
assert_contains     "$TARGET2/AGENTS.md" "<!-- fe-ai-workflow-start -->"
assert_contains     "$TARGET2/AGENTS.md" "agents"

# ── 用例 4：标记已存在，更新内容（替换模式）─────────────────

TARGET3="$TMP_DIR/target3"
mkdir -p "$TARGET3"
cat > "$TARGET3/AGENTS.md" << 'EOF'
user header
<!-- fe-ai-workflow-start -->
old workflow content
<!-- fe-ai-workflow-end -->
user footer
EOF

printf "new workflow content\n" > "$SOURCE/AGENTS.md"
"$SCRIPT" "$SOURCE" "$TARGET3" >/dev/null 2>&1 || fail "sync should succeed on update"

assert_contains     "$TARGET3/AGENTS.md" "user header"
assert_contains     "$TARGET3/AGENTS.md" "user footer"
assert_contains     "$TARGET3/AGENTS.md" "new workflow content"
assert_not_contains "$TARGET3/AGENTS.md" "old workflow content"

# ── 用例 5：源目录不存在应报错 ──────────────────────────────

"$SCRIPT" "$TMP_DIR/missing" "$TARGET" >/dev/null 2>&1 \
  && fail "sync should fail when source is missing" || true

echo "PASS"
