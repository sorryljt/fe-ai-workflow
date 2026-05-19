---
description: 文档整合 — 将 docs/ 下所有文档整合为阶段性摘要，输出 docs/digest/YYYY-MM-DD--digest.md
---

# /viktor:digest

当用户输入此命令时：

## 1. 加载 Skill

读取并严格遵循 `skills/09-digest/SKILL.md`。

## 2. 前置条件

**无强制前置条件**，随时可手动执行。

建议在以下时机执行：
- 一批需求完成后，做阶段性回顾
- DOCUMENT 节点提示 ADR 数量达到 5 的倍数时

## 3. 执行过程

按照 `skills/09-digest/SKILL.md` 的步骤执行：

1. **扫描**：列出 docs/ 下各子目录文件数量
2. **提取**：读取各文件关键信息（需求列表、ADR 状态、Review 问题）
3. **生成**：输出 `docs/digest/YYYY-MM-DD--digest.md`（5 个必需章节）
4. **Commit**：提交产物
5. **导航卡**：输出完成提示

## 4. 产物

`docs/digest/YYYY-MM-DD--digest.md`
