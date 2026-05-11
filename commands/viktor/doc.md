---
description: 文档沉淀 生成 ADR + 更新 CHANGELOG
---

# /viktor:doc

当用户输入此命令时：

## 1. 加载 Skill

读取并严格遵循 `skills/05-documentation/SKILL.md`。

## 2. 需要的输入

**必须**：
- `docs/reviews/YYYY-MM-DD--review.md`（结论必须为 PASS）

**同时收集**：
- `docs/specs/YYYY-MM-DD--design.md`（设计决策来源）
- `docs/plans/YYYY-MM-DD--tasks.md`（任务完成情况）
- 所有实现文件和测试文件

**前置检查**：
1. 如果 review.md 不存在：
   > "请先运行 `/viktor:cr` 完成代码审查。"
2. 如果 review.md 结论为 BLOCK：
   > "Review 尚有 BLOCKING 问题未解决，请先返回 `/viktor:code` 修复，通过 Review 后再运行 `/viktor:doc`。"

## 3. 执行过程

按照 `skills/05-documentation/SKILL.md` 的步骤执行：

1. **汇总产物**：收集所有文档和代码，记录关键数据（任务数、覆盖率）
2. **提取决策**：从 design.md 提取架构决策、技术权衡
3. **识别已知问题**：来自 review.md 的 [SUGGESTED] 问题
4. **生成 ADR**：保存到 `docs/adrs/YYYY-MM-DD--adr.md`
5. **更新 CHANGELOG**：在 `[Unreleased]` 部分添加本次变更
6. **最终 commit**：`git commit -m "docs: add ADR and update changelog for <feature>"`

## 4. 完成后提示

> "🎉 文档沉淀完成！本次需求已走完完整工作流。
>
> 产物汇总：
> - 设计文档：docs/specs/YYYY-MM-DD--<feature>.md
> - 任务列表：docs/plans/YYYY-MM-DD--<feature>--tasks.md
> - Review 报告：docs/reviews/YYYY-MM-DD--<feature>--review.md
> - 架构决策：docs/adrs/YYYY-MM-DD--<feature>--adr.md
> - CHANGELOG 已更新
>
> 如需开始下一个需求，输入 `/viktor:think`。"

## 5. ADR 质量检查（生成后自检）

在保存 ADR 之前，自问以下问题：
- 背景部分是否足够具体？6 个月后的新成员能重建当时的决策环境吗？
- 方案对比是否清晰说明了为什么**不选**其他方案（而不只是为什么选这个）？
- 结果部分是否诚实记录了负面影响和已知问题？

任何一个问题答案为否，补充完善后再保存。
