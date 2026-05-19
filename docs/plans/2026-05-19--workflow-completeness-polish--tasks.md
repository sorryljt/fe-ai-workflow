# 工作流完整性补全 任务列表

**日期**：2026-05-19
**关联设计**：对话驱动（context 分析产出）
**总任务数**：12（P0: 3, P1: 7, P2: 2）

## 功能概述

补全工作流中已识别的 7 处缺口：BRAINSTORM 冷启动检测、INIT 幂等保护说明、PRD 输入路径、digest 触发时机优化、references 变更检测、NIT 修复（CONTRACT/REVIEW 单文件逻辑）、init vs think 入口说明。

## 技术方案

workflow meta repo，无可运行代码。所有任务验收方式为内容自审 + 跨文件一致性核查。
变更类型：[skill] = Skill 规则文件 | [config] = CLAUDE.md 节点描述 | [sync] = 三端同步

---

## 任务列表

### P0 核心任务（影响实际使用体验）

#### T001：BRAINSTORM 冷启动前置步骤 [skill]

- **描述**：`/viktor:think` 目前是唯一无冷启动检测的主流程节点。用户在新对话中执行时若已有 spec 文件，应提示选择创建新文档还是更新已有文档，防止静默覆盖。
- **文件路径**：`skills/01-brainstorming/SKILL.md`
- **验收标准**：
  - [x] 在"执行步骤"第 1 步之前，新增"前置步骤：冷启动检测"
  - [x] 检测 `docs/specs/` 下已有 .md 文件：有则列出并询问"新建还是更新已有文档"；无则直接继续
  - [x] 用户选择"更新"时，将已有文件内容作为初始上下文读入，跳到第 4 步（修改模式）
- **依赖**：无

#### T002：CLAUDE.md BRAINSTORM 节点冷启动行为描述 [config]

- **描述**：CLAUDE.md 中其他 5 个节点均有"冷启动行为"说明，BRAINSTORM 缺失。
- **文件路径**：`CLAUDE.md`
- **验收标准**：
  - [x] 节点 1（BRAINSTORM）描述中新增"冷启动行为"一行
  - [x] 描述与 T001 实现一致
- **依赖**：T001

#### T003：三端同步 BRAINSTORM 冷启动 [sync]

- **描述**：将 T002 变更同步到 AGENTS.md 和 workflow.mdc。
- **文件路径**：`AGENTS.md`、`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [x] AGENTS.md BRAINSTORM 节点新增冷启动行为说明
  - [x] workflow.mdc BRAINSTORM 节点新增冷启动行为说明
- **依赖**：T002

---

### P1 主要任务

#### T004：BRAINSTORM PRD 输入路径明确化 [skill]

- **描述**：`references/prd-input-template.md` 已存在但从未在 BRAINSTORM Skill 中被显式引用。当用户带着完整 PRD 进来时，当前流程没有明确指引如何处理，导致 AI 可能跳过 prd-input-template.md 的结构校验。
- **文件路径**：`skills/01-brainstorming/SKILL.md`
- **验收标准**：
  - [x] 第 1 步"探索项目上下文"中，新增检测输入类型的分支：用户粘贴的内容符合 PRD 结构时，提示引用 `references/prd-input-template.md` 验证完整性
  - [x] 说明 PRD 输入与需求描述输入的处理差异（PRD 已有结构 → 跳过第 3 步提问，直接进第 4 步）
- **依赖**：无

#### T005：BRAINSTORM init vs think 入口说明 [skill]

- **描述**：新用户不清楚应该先 `init` 还是先 `think`。INIT 导航卡已指向 think，但 BRAINSTORM 第 1 步"情况 B（project-context.md 不存在）"目前是自动触发 init 扫描，对新用户来说这个行为不透明。需要在"情况 B"的提示中补充说明，让用户理解"也可以手动先运行 `/viktor:init` 建立更完整的知识地图"。
- **文件路径**：`skills/01-brainstorming/SKILL.md`
- **验收标准**：
  - [x] "情况 B"中的自动扫描提示补充一行说明：对于有大量已有代码的项目，建议先单独执行 `/viktor:init` 以获得更完整的知识地图
  - [x] 不改变现有自动扫描行为，仅补充说明
- **依赖**：无

#### T006：INIT 幂等保护行为明文化 [skill]

- **描述**：INIT 第 6 步已有"文件已存在则跳过"的逻辑，但 CLAUDE.md 节点说明中未提及，用户不清楚二次执行是否安全。同时，`project-context.md` 若已存在，第 1-5 步（扫描）是否重新执行也未说明。
- **文件路径**：`skills/06-project-init/SKILL.md`
- **验收标准**：
  - [x] 在"执行步骤"开头（第 1 步之前）新增一段幂等说明：`project-context.md` 已存在时询问"重新扫描更新知识地图，还是仅补全缺失的活文档骨架"
  - [x] 两条路径的行为差异说明清晰（重新扫描 vs 仅骨架补全）
- **依赖**：无

#### T007：CLAUDE.md INIT 节点幂等行为描述 [config]

- **描述**：同步 T006 到 CLAUDE.md 和三端。
- **文件路径**：`CLAUDE.md`、`AGENTS.md`、`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [x] CLAUDE.md INIT 节点说明新增幂等行为描述（二次执行安全）
  - [x] AGENTS.md + workflow.mdc 同步
- **依赖**：T006

#### T008：DOCUMENT digest 建议触发时机优化 [skill]

- **描述**：当前 digest 建议仅在"ADR 数量为 5 的倍数"时触发，条件过严且不自然。实际上每次完成一个功能阶段后都适合整合一次，建议改为：**每次 `/viktor:doc` 完成时均在导航卡里提供 digest 选项**，而不是等到特定倍数。
- **文件路径**：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [x] 移除"ADR 数量为 5 的倍数"的条件判断
  - [x] 在 DOCUMENT 完成后的导航卡中，**固定**新增一个非阻塞选项：`▶ 可选：/viktor:digest  整合本阶段所有文档`
  - [x] digest 选项标注为非阻塞（用户可忽略）
- **依赖**：无

#### T009：三端同步 DOCUMENT digest 触发描述 [config]

- **描述**：将 T008 的触发条件变更同步到三端。
- **文件路径**：`CLAUDE.md`、`AGENTS.md`、`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [x] CLAUDE.md DOCUMENT 节点 digest 建议描述更新（移除"5 的倍数"说法）
  - [x] AGENTS.md + workflow.mdc 同步
- **依赖**：T008

#### T010：DOCUMENT references 变更检测 [skill]

- **描述**：`references/` 下的 `react-nextjs-conventions.md` 和 `testing-patterns.md` 被 TDD/REVIEW 节点引用，但没有机制确保这些文件被更新时对应 Skill 也同步。在 DOCUMENT 节点的"工作流变更检测"步骤中新增：若本次变更涉及 `references/`，提示检查引用该文件的 Skill 是否需要同步。
- **文件路径**：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [x] "前置步骤"或"工作流变更检测"步骤新增 `references/` 变更检测分支
  - [x] 若检测到 `references/` 下有变动，输出提示：列出哪些 Skill 引用了该文件，建议逐一确认
- **依赖**：无

---

### P2 优化任务

#### T011：CONTRACT 冷启动"单文件直接使用"明文补充 [skill]

- **描述**：NIT（来自 2026-05-19-session-aware-confirmation review）。CONTRACT 冷启动扫描多文件时会列出选择，但单文件时"直接使用"是隐含逻辑，未明文说明。
- **文件路径**：`skills/07-type-contract/SKILL.md`
- **验收标准**：
  - [x] 冷启动检测章节"只有一个文件"分支补充一行说明：「直接使用 [文件名] 作为输入，无需选择」
- **依赖**：无

#### T012：REVIEW 冷启动"单文件直接使用"明文补充 [skill]

- **描述**：同 T011，REVIEW 的冷启动章节也缺少单文件直接使用的明文说明。
- **文件路径**：`skills/04-code-review/SKILL.md`
- **验收标准**：
  - [x] 冷启动检测章节"只有一个 tasks.md"分支补充一行说明：「直接使用 [文件名]，无需选择」
- **依赖**：无

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T001 | ⚠️ 逻辑风险 | BRAINSTORM 是入口节点，冷启动检测逻辑若太复杂会干扰正常流程 | 保持轻量：仅一次询问，用户回答后直接继续，无二次确认 |
| T008 | ⚠️ 体验权衡 | 每次 doc 完成都显示 digest 选项，信息量增加 | 标注为非阻塞，放在导航卡最后一行，不与主流程选项混淆 |

---

## 验收总结

- [x] 所有 P0 任务完成
- [x] 所有 P1 任务完成
- [x] P2 任务完成
- [x] 三端一致性：CLAUDE.md / AGENTS.md / workflow.mdc 相关节点描述同步
- [x] 所有修改的 Skill 文件内部逻辑自洽（无矛盾步骤）
- [x] 与其他节点的冷启动检测模式一致（统一风格）
