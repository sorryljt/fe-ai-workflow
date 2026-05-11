---
description: 需求分析 → 拆解为可执行任务列表
---

# /viktor:plan

当用户输入此命令时：

## 1. 加载 Skill

读取并严格遵循 `skills/02-requirements-analysis/SKILL.md`。

## 2. 需要的输入

**主要输入**（任选其一）：
- `docs/specs/YYYY-MM-DD--design.md`（`/viktor:think` 产物，推荐）
- 用户粘贴的 PRD 文档（Markdown 格式）
- 用户直接描述的已明确需求

**前置检查**：
- 如果 `docs/specs/` 下存在 design.md，自动读取并作为输入
- 如果既无 design.md 也无用户提供的 PRD，提示：
  > "需要先提供需求文档。请粘贴 PRD 内容，或输入 `/viktor:think` 先完成需求澄清。"

## 3. 执行过程

按照 `skills/02-requirements-analysis/SKILL.md` 的步骤执行：

1. **解析文档**：提取功能点列表、验收标准、边界条件、技术约束
2. **识别风险**：标注外部依赖、技术不确定点（`⚠️ 风险`）
3. **拆解任务**：每条任务 = 一个 TDD 红绿循环（约 2-5 分钟）
4. **标注类型**：`[utils]` / `[hook]` / `[component]` / `[api]` / `[store]` / `[style]`
5. **标注优先级**：P0（核心）/ P1（主要）/ P2（优化）
6. **标注依赖**：`depends: T001, T002`
7. **生成 tasks.md**：保存到 `docs/plans/YYYY-MM-DD--tasks.md` 并 commit
8. **请用户确认粒度**

## 4. 完成后提示

任务列表生成后：

> "任务分解完成：
> - P0 核心任务：X 个
> - P1 主要任务：Y 个
> - P2 优化任务：Z 个
> - ⚠️ 风险标注：N 处
>
> 已保存至 `docs/plans/YYYY-MM-DD--tasks.md`。
>
> 请确认粒度是否合适（每条任务约能在 5 分钟内完成一个 TDD 循环）。
> 确认后输入 `/viktor:code` 开始实现。"
