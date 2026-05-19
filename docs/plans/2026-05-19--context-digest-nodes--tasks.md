# context + digest 节点 任务列表

**日期**：2026-05-19
**关联设计**：[docs/specs/2026-05-19--context-digest-nodes.md](../specs/2026-05-19--context-digest-nodes.md)
**总任务数**：11（P0: 6, P1: 3, P2: 2）

## 功能概述

新增两个工具节点：`/viktor:context`（随时可用的只读项目快照）和 `/viktor:digest`（周期性文档整合），并将两者集成到现有工作流（BRAINSTORM 提示 context、DOCUMENT 提示 digest），同步更新三端入口、元调度器和对外文档。

## 技术方案

两个节点均为纯文档/配置型节点，没有代码实现，只涉及 SKILL.md、命令入口和现有节点的少量修改。所有任务类型均为 `[utils]`（工作流规则文件），无需 TDD。三端同步在最后统一处理，README 和团队指南最后更新。

## 任务列表

### P0 核心任务（阻塞性，最先完成）

#### T001：创建 `skills/08-context/SKILL.md` [utils]

- **描述**：定义 CONTEXT 节点的完整执行规范，包括：读取 5 个活文档、格式化输出到对话、文件缺失处理、不生成文件/commit 的约束
- **文件路径**：
  - 实现：`skills/08-context/SKILL.md`
- **验收标准**：
  - [x] frontmatter 包含 name / description 字段
  - [x] 明确列出读取的 5 个文件路径
  - [x] 输出格式模板完整（5 个区块标题）
  - [x] 文件缺失时的处理逻辑（给出说明而非报错）
  - [x] 明确声明：不生成文件，不创建 commit
  - [x] 包含导航卡（无下一步，因为是工具节点）
- **依赖**：无

#### T002：创建 `commands/viktor/context.md` [utils]

- **描述**：定义 `/viktor:context` 命令的入口，说明加载哪个 Skill、无需前置检查
- **文件路径**：
  - 实现：`commands/viktor/context.md`
- **验收标准**：
  - [x] description frontmatter 存在
  - [x] 明确指向 `skills/08-context/SKILL.md`
  - [x] 说明无前置条件（随时可用）
- **依赖**：T001

#### T003：创建 `skills/09-digest/SKILL.md` [utils]

- **描述**：定义 DIGEST 节点的完整执行规范，包括：读取范围、输出文件结构（5 个必需章节）、commit 规则
- **文件路径**：
  - 实现：`skills/09-digest/SKILL.md`
- **验收标准**：
  - [x] frontmatter 包含 name / description 字段
  - [x] 明确读取范围（specs/、plans/、reviews/、adrs/、5 个活文档）
  - [x] 输出路径：`docs/digest/YYYY-MM-DD--digest.md`
  - [x] 输出模板包含 5 个章节：项目当前状态 / 本阶段完成需求 / 关键架构决策 / 活文档现状 / 待关注问题
  - [x] 包含 commit 命令
  - [x] 包含导航卡
- **依赖**：无

#### T004：创建 `commands/viktor/digest.md` [utils]

- **描述**：定义 `/viktor:digest` 命令的入口，说明加载哪个 Skill
- **文件路径**：
  - 实现：`commands/viktor/digest.md`
- **验收标准**：
  - [x] description frontmatter 存在
  - [x] 明确指向 `skills/09-digest/SKILL.md`
  - [x] 说明可随时手动执行
- **依赖**：T003

#### T005：更新 `skills/01-brainstorming/SKILL.md` — 第 1 步加非阻塞提示 [utils]

- **描述**：在 BRAINSTORM 第 1 步「情况 A — project-context.md 存在」分支下，紧接着加一行非阻塞提示，让用户知道可以执行 `/viktor:context`
- **文件路径**：
  - 修改：`skills/01-brainstorming/SKILL.md`
- **验收标准**：
  - [x] 仅在情况 A（project-context.md 存在）时显示提示
  - [x] 提示为 💡 非阻塞格式（不影响流程推进）
  - [x] 提示文案：「💡 可执行 `/viktor:context` 快速回顾现有组件和接口，再开始需求设计。」
  - [x] 原有步骤内容不变
- **依赖**：T001

#### T006：更新 `skills/05-documentation/SKILL.md` — 完成后加 digest 提示 [utils]

- **描述**：在 DOCUMENT 节点最后（输出导航卡之前），检测当前 ADR 数量，若为 5 的倍数则输出非阻塞建议
- **文件路径**：
  - 修改：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [x] ADR 计数逻辑：读取 `docs/adrs/` 下的 `.md` 文件数（排除 README.md）
  - [x] 仅当数量 > 0 且为 5 的倍数时显示建议
  - [x] 建议为非阻塞格式，用户可忽略
  - [x] 建议文案：「💡 已累积 N 个 ADR，建议执行 `/viktor:digest` 生成阶段性整合文档。」
  - [x] 原有导航卡和步骤不变
- **依赖**：T003

### P1 主要任务

#### T007：更新 `skills/using-fe-workflow/SKILL.md` — 路由表和命令速查 [utils]

- **描述**：在元调度器的「命令速查」表和「Skill 映射」表中新增 context 和 digest 两行；在自然语言意图路由表中新增对应意图示例
- **文件路径**：
  - 修改：`skills/using-fe-workflow/SKILL.md`
- **验收标准**：
  - [x] 命令速查表新增：`/viktor:context` — CONTEXT — 随时可用，快速查看项目现状
  - [x] 命令速查表新增：`/viktor:digest` — DIGEST — 周期性整合，生成阶段性摘要
  - [x] Skill 映射表新增：CONTEXT → `skills/08-context/SKILL.md`
  - [x] Skill 映射表新增：DIGEST → `skills/09-digest/SKILL.md`
  - [x] 自然语言路由表新增 context 意图示例（"看看项目现状" "查一下现有组件"）
  - [x] 自然语言路由表新增 digest 意图示例（"生成整合文档" "做一个阶段总结"）
- **依赖**：T001, T003

#### T008：更新 `CLAUDE.md` — 新增节点定义 [utils]

- **描述**：在 CLAUDE.md 的「工作流节点定义」章节新增 CONTEXT 和 DIGEST 两个节点，包含触发方式、加载 Skill、输入、输出、约束
- **文件路径**：
  - 修改：`CLAUDE.md`
- **验收标准**：
  - [x] 新增「节点 0.5：CONTEXT（项目快照）」— 随时可用，加载 skills/08-context/SKILL.md，无文件输出
  - [x] 新增「节点 5.5：DIGEST（文档整合）」— 随时手动，或 DOCUMENT 提示时执行，加载 skills/09-digest/SKILL.md，输出 docs/digest/YYYY-MM-DD--digest.md
  - [x] 与现有节点格式一致
- **依赖**：T007

#### T009：三端同步 — `AGENTS.md` + `.cursor/rules/workflow.mdc` [utils]

- **描述**：将 CLAUDE.md 中新增的 context/digest 节点内容同步到 AGENTS.md 和 .cursor/rules/workflow.mdc；Codex 文本触发规则表中新增 `viktor:context` 和 `viktor:digest`
- **文件路径**：
  - 修改：`AGENTS.md`
  - 修改：`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [x] AGENTS.md 节点描述与 CLAUDE.md 一致（精简版）
  - [x] AGENTS.md 文本触发规则新增 `viktor:context` 和 `viktor:digest`
  - [x] .cursor/rules/workflow.mdc 同步对应节点说明
  - [x] 三端描述逻辑无矛盾
- **依赖**：T008

### P2 优化任务（可选）

#### T010：更新 `README.md` — 工作流说明表格新增两行 [utils]

- **描述**：在 README 的工作流节点表格中新增 context 和 digest 两行，保持 5 列格式（命令/阶段/节点作用/输入/输出）
- **文件路径**：
  - 修改：`README.md`
- **验收标准**：
  - [x] 表格新增 `/viktor:context` 行（随时可用工具）
  - [x] 表格新增 `/viktor:digest` 行（周期性整合工具）
  - [x] 目录说明中 commands/ 部分新增 context.md 和 digest.md
- **依赖**：T008

#### T011：更新 `docs/team-workflow-guide.md` — 命令总览新增两节 [utils]

- **描述**：在团队指南第 4 节「命令总览」新增 4.7 /viktor:context 和 4.8 /viktor:digest 说明
- **文件路径**：
  - 修改：`docs/team-workflow-guide.md`
- **验收标准**：
  - [x] 4.7 节描述 context 的用途和执行时机
  - [x] 4.8 节描述 digest 的用途和触发场景（手动 + DOCUMENT 提示）
  - [x] 与现有格式一致
- **依赖**：T010

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T006 | ⚠️ 逻辑风险 | ADR 计数需排除 README.md，否则编号偏移 | SKILL 中明确说明「排除 README.md」 |
| T009 | ⚠️ 一致性风险 | 三端同步易出现描述不一致 | 以 CLAUDE.md 为主，AGENTS.md/workflow.mdc 按精简版同步后对比 |

## 验收总结

- [ ] 所有 P0 任务完成
- [ ] `/viktor:context` 可在对话中正常触发，输出格式化快照
- [ ] `/viktor:digest` 可正常触发，生成 docs/digest/ 下的整合文档
- [ ] BRAINSTORM 第 1 步情况 A 分支下显示非阻塞 context 提示
- [ ] DOCUMENT 节点在 ADR 为 5 的倍数时显示非阻塞 digest 建议
- [ ] 三端入口（CLAUDE.md / AGENTS.md / workflow.mdc）逻辑一致
- [ ] 元调度器路由表覆盖新节点
