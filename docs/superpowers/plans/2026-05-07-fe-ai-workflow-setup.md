# fe-ai-workflow 仓库搭建实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 ~/workspace/ 下创建完整的前端 AI 开发工作流仓库 fe-ai-workflow，包含 19 个文件。

**Architecture:** 纯文档仓库，无代码依赖。文件按功能分为 skills（流程技能）、references（规范参考）、commands（快捷指令）三类，兼容 Claude Code、Cursor、OpenAI Codex 三种 AI 工具。

**Tech Stack:** Markdown, YAML frontmatter

---

### Task 1: 根配置文件

**Files:**
- Create: `~/workspace/fe-ai-workflow/CLAUDE.md`
- Create: `~/workspace/fe-ai-workflow/AGENTS.md`
- Create: `~/workspace/fe-ai-workflow/README.md`
- Create: `~/workspace/fe-ai-workflow/.cursor/rules/workflow.mdc`

- [x] **Step 1:** 创建 CLAUDE.md（Claude Code 主入口）
- [x] **Step 2:** 创建 AGENTS.md（OpenAI Codex 入口）
- [x] **Step 3:** 创建 .cursor/rules/workflow.mdc（Cursor Rules）
- [x] **Step 4:** 创建 README.md

### Task 2: Skill 文件

**Files:**
- Create: `skills/using-fe-workflow/SKILL.md`
- Create: `skills/01-brainstorming/SKILL.md`
- Create: `skills/02-requirements-analysis/SKILL.md`
- Create: `skills/03-tdd-cycle/SKILL.md`
- Create: `skills/04-code-review/SKILL.md`
- Create: `skills/05-documentation/SKILL.md`

- [x] **Step 1:** 创建元调度器 Skill
- [x] **Step 2:** 创建各节点 Skill（01-05）

### Task 3: References 和 Commands

- [x] **Step 1:** 创建 references/ 三个文件
- [x] **Step 2:** 创建 commands/ 五个文件
- [x] **Step 3:** 创建 examples/README.md
