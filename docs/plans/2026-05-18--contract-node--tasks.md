# CONTRACT 节点 任务列表

**日期**：2026-05-18
**关联设计**：[docs/specs/2026-05-18--contract-node.md](../specs/2026-05-18--contract-node.md)
**总任务数**：12（P0: 2, P1: 8, P2: 2）

## 功能概述

新增 `/viktor:contract` 节点，将类型合约作为工作流一等公民接入。
同步改动 ANALYZE / TDD / REVIEW / 元调度器节点，并更新所有平台入口配置文件至 v0.3.0。

## 技术方案

本项目为 workflow meta 项目，无业务代码，无可运行测试。
任务类型标注：`[skill]`（Skill 文件）/ `[command]`（命令入口）/ `[config]`（配置改动）/ `[sync]`（多端同步）。
验收方式：内容自审（无占位符、无歧义、逻辑自洽）+ 跨文件一致性核对。

---

## P0 核心任务（阻塞性，最先完成）

### T001：新建 skills/07-type-contract/SKILL.md [skill]

- **描述**：CONTRACT 节点的完整规范文件，是所有下游改动的参照基准
- **文件路径**：`skills/07-type-contract/SKILL.md`
- **验收标准**：
  - [ ] frontmatter 包含 name / description 字段
  - [ ] 触发条件说明（命令触发 + 自然语言路由）
  - [ ] 前置产物检查逻辑（tasks.md > design.md > 停止并引导）
  - [ ] 执行步骤完整（检查前置 → 识别类型分组 → 生成 .types.ts → 自审 → 确认 → commit）
  - [ ] 产物格式示例（TypeScript + JSDoc 分组注释）
  - [ ] 自审规则（无 any / 无 TODO / 命名 PascalCase / 每个 export 有 JSDoc）
  - [ ] 边界条件处理（重复触发时询问覆盖/追加；只有 design.md 时标注精度说明）
  - [ ] 导航卡模板
  - [ ] 验证标准 checklist
- **依赖**：无

### T002：新建命令入口文件 [command]

- **描述**：新建两个命令路由文件，让 Claude Code 的 `/viktor:contract` 命令可被识别
- **文件路径**：
  - `commands/viktor/contract.md`
  - `.claude/commands/viktor/contract.md`（内容：`../../../commands/contract.md`，与其他命令一致）
- **验收标准**：
  - [ ] `commands/viktor/contract.md` 包含：description frontmatter、加载 Skill 指令、前置检查说明、$ARGUMENTS 处理、完成后导航卡说明
  - [ ] `.claude/commands/viktor/contract.md` 内容格式与其他 `.claude/commands/viktor/*.md` 一致
- **依赖**：T001（需先有 SKILL.md 才能正确引用路径）

---

## P1 主要任务

### T003：改 skills/02-requirements-analysis/SKILL.md — 推荐逻辑 [skill]

- **描述**：在第 5 步（输出 tasks.md）之后增加"是否推荐 CONTRACT"评估逻辑，并替换导航卡为双路版本
- **文件路径**：`skills/02-requirements-analysis/SKILL.md`
- **验收标准**：
  - [ ] 第 5 步后新增推荐评估小节，包含推荐规则表格（6 条规则）
  - [ ] 导航卡（推荐走 CONTRACT 时）包含两个选项 A/B，格式与设计文档一致
  - [ ] 导航卡（建议跳过时）包含推荐 code + 可选 contract 两行
  - [ ] 原有导航卡完整替换，无残留旧版本内容
- **依赖**：T001

### T004：改 skills/03-tdd-cycle/SKILL.md — 合约感知步骤 [skill]

- **描述**：在"第 1 步：从 tasks.md 取任务"之前插入合约文件检查步骤
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [ ] 新步骤位于第 1 步之前（或作为第 0 步）
  - [ ] 检查逻辑：存在 → 读取并在对话中标注；不存在 → 静默继续
  - [ ] 标注文案与设计文档一致
  - [ ] 不影响原有 TDD 循环步骤编号逻辑
- **依赖**：T001

### T005：改 skills/04-code-review/SKILL.md — 第六检查轴 [skill]

- **描述**：在现有五个检查轴之后增加"轴六：类型合约一致性"，仅在合约文件存在时执行
- **文件路径**：`skills/04-code-review/SKILL.md`
- **验收标准**：
  - [ ] 轴六标题与条件说明（仅合约文件存在时）
  - [ ] 包含 4 条检查项（见设计文档 §4.5）
  - [ ] 与现有检查轴格式一致
- **依赖**：T001

### T006：改 skills/using-fe-workflow/SKILL.md — 命令速查表 [skill]

- **描述**：在命令速查表中新增 CONTRACT 行，并在工作流节点与 Skill 映射表中新增对应行
- **文件路径**：`skills/using-fe-workflow/SKILL.md`
- **验收标准**：
  - [ ] 命令速查表新增：`/viktor:contract` | CONTRACT | 触发时机说明
  - [ ] Skill 映射表新增：CONTRACT → `skills/07-type-contract/SKILL.md`
  - [ ] Codex 文本触发规则新增 `viktor:contract`
  - [ ] 自然语言路由表新增对应意图示例
- **依赖**：T001

### T007：改 CLAUDE.md — 产物目录 + 节点说明 [config]

- **描述**：更新 CLAUDE.md 中的产物目录规范、节点说明和工作流图
- **文件路径**：`CLAUDE.md`
- **验收标准**：
  - [ ] 工作流图新增 `[/viktor:contract]` 节点（位于 plan 与 code 之间）
  - [ ] 产物目录规范新增 `docs/contracts/` 说明
  - [ ] 节点详细说明新增 CONTRACT 节点（触发方式、Skill 路径、输入、输出、完成条件）
  - [ ] 节点顺序与 using-fe-workflow 保持一致
- **依赖**：T001

### T008：同步 AGENTS.md [sync]

- **描述**：将 CLAUDE.md 的 CONTRACT 节点相关改动同步到 AGENTS.md（Codex 入口）
- **文件路径**：`AGENTS.md`
- **验收标准**：
  - [ ] 工作流图与 CLAUDE.md 一致
  - [ ] CONTRACT 节点说明存在（可适度精简，但逻辑不缺失）
  - [ ] 命令触发规则包含 `viktor:contract`（无前导 `/`）
- **依赖**：T007

### T009：同步 .cursor/rules/workflow.mdc [sync]

- **描述**：将 CONTRACT 节点相关内容同步到 Cursor Rules
- **文件路径**：`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [ ] 工作流节点列表包含 CONTRACT
  - [ ] 命令格式与 Cursor 规范一致
- **依赖**：T007

---

## P2 优化任务

### T010：更新 README.md — v0.3.0 [sync]

- **描述**：更新版本号、工作流说明图、命令表
- **文件路径**：`README.md`
- **验收标准**：
  - [ ] 版本号（快速开始章节中的 submodule 命令）更新为 v0.3.0
  - [ ] 工作流说明图新增 `/viktor:contract`
  - [ ] 命令表新增 CONTRACT 行
- **依赖**：T007

### T011：更新 docs/team-workflow-guide.md — v0.3.0 [sync]

- **描述**：更新团队指南的版本号及 CONTRACT 节点说明
- **文件路径**：`docs/team-workflow-guide.md`
- **验收标准**：
  - [ ] 版本号更新为 v0.3.0
  - [ ] 包含 CONTRACT 节点的使用说明
- **依赖**：T007

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|---|---|---|---|
| T008/T009 | ⚠️ 同步风险 | CLAUDE.md / AGENTS.md / workflow.mdc 三端描述同一行为，容易不一致 | T007 完成后逐一对照 CLAUDE.md 同步，最后统一做三端一致性核查 |
| T003 | ⚠️ 逻辑风险 | 推荐规则判断条件需要准确，条件过宽则每次都推荐，过窄则失效 | 严格按设计文档 §4.3 的 6 条规则实现，不扩展 |

---

## 验收总结

- [ ] T001 ~ T002 完成（P0 核心，所有后续任务的基础）
- [ ] T003 ~ T009 完成（P1 主要改动）
- [ ] T010 ~ T011 完成（P2 同步更新）
- [ ] 三端一致性核查：CLAUDE.md / AGENTS.md / workflow.mdc 工作流图、命令列表、节点说明内容一致
- [ ] skills/using-fe-workflow/SKILL.md 中 CONTRACT 的触发条件与 skills/07-type-contract/SKILL.md 一致
- [ ] git tag v0.3.0 打出前，README.md 和 team-workflow-guide.md 版本号已更新
