#!/usr/bin/env bash
# validate-workflow.sh — 验证三端工作流入口与 Skill 文件一致性
#
# 用法：bash scripts/validate-workflow.sh
# 退出码：0 = 全部通过，1 = 有失败项
#
# 检查内容：
#   1. 9 个 viktor:* 命令在 CLAUDE.md / AGENTS.md / workflow.mdc 中均存在
#   2. 10 个 Skill 文件在磁盘上均存在

set -euo pipefail

# ── 颜色 ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

# ── 辅助函数 ─────────────────────────────────────────────────────────
check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    printf "${GREEN}✅${RESET} %s\n" "$label"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    printf "${RED}❌${RESET} %s\n" "$label"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# ── 前置检查：必须在仓库根目录运行 ────────────────────────────────────
if [[ ! -d ".git" ]]; then
  echo "错误：请在仓库根目录运行此脚本" >&2
  exit 1
fi

echo "═══════════════════════════════════════════"
echo "  fe-ai-workflow 一致性验证"
echo "═══════════════════════════════════════════"
echo ""

# ── 检查组 1：三端命令存在性 ──────────────────────────────────────────
COMMANDS=(think plan code cr doc contract context digest init)

echo "【检查组 1】三端入口命令一致性（共 $((${#COMMANDS[@]} * 3)) 项）"
echo ""

for cmd in "${COMMANDS[@]}"; do
  check "CLAUDE.md        含 viktor:${cmd}" \
    "grep -q 'viktor:${cmd}' CLAUDE.md"
  check "AGENTS.md        含 viktor:${cmd}" \
    "grep -q 'viktor:${cmd}' AGENTS.md"
  check "workflow.mdc     含 viktor:${cmd}" \
    "grep -q 'viktor:${cmd}' .cursor/rules/workflow.mdc"
done

echo ""

# ── 检查组 2：Skill 文件存在性 ────────────────────────────────────────
SKILLS=(
  "skills/using-fe-workflow/SKILL.md"
  "skills/01-brainstorming/SKILL.md"
  "skills/02-requirements-analysis/SKILL.md"
  "skills/03-tdd-cycle/SKILL.md"
  "skills/04-code-review/SKILL.md"
  "skills/05-documentation/SKILL.md"
  "skills/06-project-init/SKILL.md"
  "skills/07-type-contract/SKILL.md"
  "skills/08-context/SKILL.md"
  "skills/09-digest/SKILL.md"
)

echo "【检查组 2】Skill 文件存在性（共 ${#SKILLS[@]} 项）"
echo ""

for skill in "${SKILLS[@]}"; do
  check "存在: ${skill}" "[ -f '${skill}' ]"
done

echo ""

# ── 汇总 ──────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════"
TOTAL=$((PASS_COUNT + FAIL_COUNT))
if [[ $FAIL_COUNT -eq 0 ]]; then
  printf "${GREEN}✅ 全部通过：${PASS_COUNT}/${TOTAL}${RESET}\n"
  exit 0
else
  printf "${RED}❌ 有失败项：${FAIL_COUNT} 失败 / ${PASS_COUNT} 通过 / ${TOTAL} 总计${RESET}\n"
  exit 1
fi
