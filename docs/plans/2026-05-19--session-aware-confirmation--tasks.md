# 会话感知确认机制 任务列表

**日期**：2026-05-19
**关联设计**：对话讨论（无独立 spec 文件）
**总任务数**：9（P0: 2, P1: 5, P2: 2）

## 功能概述

两项优化：
1. **修复命令入口缺失**：`/viktor:context` 和 `/viktor:digest` 在 `.claude/commands/viktor/` 下缺少入口文件，导致 Claude Code 命令列表不显示这两个命令。
2. **统一会话感知确认机制**：为 5 个节点 Skill（plan/contract/code/cr/doc）添加前置冷启动检测。规则：当前对话中存在上游节点完成信号（导航卡）时直接执行，否则扫描现有产物并请用户确认，避免因历史遗留文件导致重复实现或基于过期产物执行。

## 技术方案

纯文档/配置项目，无业务代码，无可运行测试。
- T001~T002：新建单行内容的命令入口文件（与现有 `.claude/commands/viktor/*.md` 格式一致）
- T003~T007：在各 SKILL.md 的"触发条件"之后、"执行步骤"之前插入"前置步骤：会话感知冷启动检测"章节

**会话感知判断逻辑（各 Skill 共用的模式）**：
```
检查当前对话历史中，是否存在上游节点的完成导航卡（含"▶ 下一步"指向本命令）。
  存在 → 在流模式：直接执行，跳过冷启动检测
  不存在 → 冷启动模式：扫描产物 + 请用户确认
```

---

## 任务列表

### P0 核心任务（阻塞性，最先完成）

#### T001：创建 `.claude/commands/viktor/context.md` [command]

- **描述**：补全 context 命令的 `.claude` 入口文件，使 `/viktor:context` 出现在 Claude Code 命令列表中
- **文件路径**：
  - 创建：`.claude/commands/viktor/context.md`
- **验收标准**：
  - [ ] 文件内容为单行相对路径 `../../../commands/viktor/context.md`
  - [ ] 格式与现有 `.claude/commands/viktor/contract.md` 完全一致
  - [ ] Claude Code 命令列表可识别 `/viktor:context`
- **依赖**：无

#### T002：创建 `.claude/commands/viktor/digest.md` [command]

- **描述**：补全 digest 命令的 `.claude` 入口文件，使 `/viktor:digest` 出现在 Claude Code 命令列表中
- **文件路径**：
  - 创建：`.claude/commands/viktor/digest.md`
- **验收标准**：
  - [ ] 文件内容为单行相对路径 `../../../commands/viktor/digest.md`
  - [ ] 格式与现有 `.claude/commands/viktor/contract.md` 完全一致
  - [ ] Claude Code 命令列表可识别 `/viktor:digest`
- **依赖**：无

---

### P1 主要任务

#### T003：更新 `skills/03-tdd-cycle/SKILL.md` — 会话感知冷启动检测 [skill]

- **描述**：在现有"前置步骤：检查类型合约文件"之前，插入会话感知冷启动检测。这是风险最高的节点，冷启动时需列出所有 tasks.md 并让用户确认。
- **文件路径**：
  - 修改：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [ ] 新章节标题为"前置步骤 0：会话感知冷启动检测"，位于合约文件检查之前
  - [ ] 在流模式：检测到对话中有 ANALYZE 导航卡 → 直接使用对应 tasks.md，跳过以下检测
  - [ ] 冷启动模式：扫描 `docs/plans/` 下所有 `*tasks.md`，按日期倒序列出，每项显示（文件名、功能名、总任务数/已完成数）
  - [ ] 全部任务已完成的文件标注 `⚠️ 已全部完成`
  - [ ] 交互提示格式：让用户输入 A/B/... 选择文件，或输入 N 重定向到 `/viktor:think`
  - [ ] 用户选择"已全部完成"文件时，追加二次确认警告（提醒先核查 src/ 是否已有实现）
  - [ ] `docs/plans/` 下无文件时：停止并提示运行 `/viktor:plan`（与原逻辑一致）
  - [ ] 原有"前置步骤：检查类型合约文件"章节内容不变、编号不变
- **依赖**：无

#### T004：更新 `skills/02-requirements-analysis/SKILL.md` — 会话感知冷启动检测 [skill]

- **描述**：在第 1 步之前插入会话感知冷启动检测。冷启动时处理"多个 spec 文件选择"和"已有 tasks.md 覆盖确认"两种情形。
- **文件路径**：
  - 修改：`skills/02-requirements-analysis/SKILL.md`
- **验收标准**：
  - [ ] 新章节标题为"前置步骤：会话感知冷启动检测"，位于"第 1 步：解析文档结构"之前
  - [ ] 在流模式：检测到对话中有 BRAINSTORM 导航卡 → 直接使用对应 spec，跳过以下检测
  - [ ] 冷启动 - 多个 spec 文件：列出 `docs/specs/*.md`，让用户选择输入来源
  - [ ] 冷启动 - 仅有一个 spec 文件：直接确认使用，无需选择
  - [ ] 冷启动 - `docs/plans/` 下已有同功能 tasks.md：提示"检测到已有任务文件 [文件名]，是覆盖还是新建？"
  - [ ] 无任何 spec 文件时：提示用户提供 PRD 文本或运行 `/viktor:think`（与原触发条件说明一致）
  - [ ] 原有执行步骤 1~6 内容和编号不变
- **依赖**：无

#### T005：更新 `skills/07-type-contract/SKILL.md` — 会话感知冷启动检测 [skill]

- **描述**：在触发条件之后、执行步骤之前插入会话感知冷启动检测。冷启动时处理"多个 tasks.md 选择"和"已有合约文件覆盖/追加"两种情形。
- **文件路径**：
  - 修改：`skills/07-type-contract/SKILL.md`
- **验收标准**：
  - [ ] 新章节标题为"前置步骤：会话感知冷启动检测"
  - [ ] 在流模式：检测到对话中有 ANALYZE 导航卡（含 CONTRACT 选项）→ 直接使用对应 tasks.md，跳过以下检测
  - [ ] 冷启动 - 多个 tasks.md：列出让用户选择
  - [ ] 冷启动 - `docs/contracts/` 下已有合约文件：询问"覆盖现有合约？还是追加类型？"
  - [ ] 无 tasks.md 且无 spec 文件时：停止并提示先运行 `/viktor:plan`（与原前置条件逻辑一致）
- **依赖**：无

#### T006：更新 `skills/04-code-review/SKILL.md` — 会话感知冷启动检测 [skill]

- **描述**：在前置条件检查之前插入会话感知冷启动检测。冷启动时检查 tasks.md 完成度并警告，以及处理已有 review.md 的覆盖确认。
- **文件路径**：
  - 修改：`skills/04-code-review/SKILL.md`
- **验收标准**：
  - [ ] 新章节标题为"前置步骤：会话感知冷启动检测"，位于原"前置条件检查"之前
  - [ ] 在流模式：检测到对话中有 TDD 完成导航卡 → 跳过以下检测，直接进入原前置条件检查
  - [ ] 冷启动 - tasks.md 存在未勾选任务：显示未完成任务数量，警告"还有 N 个任务未完成，是否确认继续 CR？(y/n)"
  - [ ] 冷启动 - `docs/reviews/` 下已有同功能 review.md：询问是否覆盖
  - [ ] 冷启动 - 多个 tasks.md：列出让用户选择
  - [ ] 原有前置条件检查和五轴审查框架内容不变
- **依赖**：无

#### T007：更新 `skills/05-documentation/SKILL.md` — 会话感知冷启动检测 [skill]

- **描述**：在执行步骤之前插入会话感知冷启动检测。冷启动时处理"多个 review.md 选择"和"review 含 BLOCKING 问题时的警告"。
- **文件路径**：
  - 修改：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [ ] 新章节标题为"前置步骤：会话感知冷启动检测"
  - [ ] 在流模式：检测到对话中有 REVIEW PASS 导航卡 → 直接使用对应 review.md，跳过以下检测
  - [ ] 冷启动 - `docs/reviews/` 下有多个 review.md：列出让用户选择
  - [ ] 冷启动 - 仅一个 review.md：直接确认使用
  - [ ] 冷启动 - 选中的 review 文件包含 `[BLOCKING]` 标记：警告"该 Review 存在未解决的 BLOCKING 问题，建议先返回 `/viktor:code` 修复后再执行文档节点"，并给用户选择是否继续
  - [ ] 无任何 review.md 时：停止并提示先运行 `/viktor:cr`
  - [ ] 原有执行步骤内容不变
- **依赖**：无

---

### P2 优化任务

#### T008：更新 `CLAUDE.md` — 节点说明补充会话感知机制 [config]

- **描述**：在 CLAUDE.md 各节点的描述中，补充"会话感知"机制的简要说明，让读者理解节点的冷启动行为
- **文件路径**：
  - 修改：`CLAUDE.md`
- **验收标准**：
  - [ ] ANALYZE / CONTRACT / TDD / REVIEW / DOCUMENT 节点描述中，各加一行说明：「**冷启动行为**：对话中无上游节点信号时，自动扫描现有产物并请用户确认」
  - [ ] 格式与现有节点描述格式一致
- **依赖**：T003～T007 完成

#### T009：同步 `AGENTS.md` + `.cursor/rules/workflow.mdc` [sync]

- **描述**：将会话感知机制的说明同步到 Codex 和 Cursor 入口
- **文件路径**：
  - 修改：`AGENTS.md`
  - 修改：`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [ ] AGENTS.md 各节点说明包含冷启动行为的简要描述
  - [ ] .cursor/rules/workflow.mdc 同步对应说明
  - [ ] 三端描述逻辑无矛盾
- **依赖**：T008

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T003 | ⚠️ 逻辑风险 | 冷启动的列表展示和二次确认逻辑较复杂，易出现边界遗漏 | 严格按验收标准逐条实现，重点检查"无文件"和"全部完成"两个边界 |
| T003~T007 | ⚠️ 一致性风险 | 5 个 Skill 使用相同模式，容易出现措辞/格式不一致 | 先完成 T003 定下措辞模板，T004~T007 复用 |
| T009 | ⚠️ 同步风险 | 三端同步易出现描述不一致 | 以 CLAUDE.md (T008) 为主，AGENTS.md/workflow.mdc 按精简版同步 |

---

## 验收总结

- [ ] T001~T002 完成：`/viktor:context` 和 `/viktor:digest` 出现在 Claude Code 命令列表
- [ ] T003~T007 完成：5 个节点 Skill 均有"前置步骤：会话感知冷启动检测"章节
- [ ] 在流模式：上游节点刚完成 → 直接执行，无弹出确认
- [ ] 冷启动模式：无上游信号 → 扫描产物 + 显示选择/确认提示
- [ ] T008~T009 完成：三端入口文档同步
