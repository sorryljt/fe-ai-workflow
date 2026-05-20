---
description: 类型合约生成 — 从 tasks.md / design.md 提取 TypeScript 类型定义，锁定节点间共享类型
---

# /viktor:contract

当用户输入此命令时：

## 1. 加载 Skill

读取并严格遵循 `skills/07-type-contract/SKILL.md`。

## 2. 需要的输入

**主要输入**（按优先级选一）：
- `docs/plans/YYYY-MM-DD--tasks.md`（`/viktor:plan` 产物，推荐，精度最高）
- `docs/specs/YYYY-MM-DD--design.md`（`/viktor:think` 产物，仅无 tasks.md 时使用）

**前置检查**（按 SKILL.md 前置产物检查逻辑执行）：
- 存在 tasks.md → 读取并开始提取
- 只有 design.md → 读取并执行，产物中标注精度说明
- 两者均不存在 → 停止，提示：
  > "缺少上游产物。请先运行 `/viktor:plan` 生成任务列表，或 `/viktor:think` 生成设计文档。"

$ARGUMENTS

如果 `$ARGUMENTS` 不为空，将其作为功能名称提示，优先查找对应文件。

## 3. 执行过程

按照 `skills/07-type-contract/SKILL.md` 的步骤执行：

1. **前置检查**：确认上游产物存在（见上方逻辑）
2. **读取输入**：提取实体 / Props / API / 状态 / 工具函数等类型信息
3. **整理分组**：按依赖关系排序，归入对应分组
4. **生成合约文件**：`docs/contracts/YYYY-MM-DD--<feature>.types.ts`
5. **自审**：无 `any`、无 `TODO`、PascalCase、每个 export 有 JSDoc
6. **单轮确认**：展示完整文件，用户指出需调整的类型

## 4. 完成后提示

合约文件获得用户确认后输出导航卡：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CONTRACT 已完成
📄 产物：docs/contracts/YYYY-MM-DD--<feature>.types.ts
──────────────────────────────
▶ 下一步：输入 /viktor:code
  TDD 实现时请 import 合约文件中的类型，以确保实现与合约一致
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 5. 执行中约束（会话锁）

**仅在 CONTRACT 执行过程中生效：合约文件尚未获用户确认时，不响应 `/viktor:code` 请求。**

提示：
> "合约文件尚未确认，请先确认类型结构再开始 TDD 实现。"

> **注**：CONTRACT 节点为可选节点。若用户从未触发 `/viktor:contract`，可直接使用 `/viktor:code`，无需先执行 CONTRACT。
