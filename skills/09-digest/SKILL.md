---
name: 09-digest
description: 文档整合 - 读取 docs/ 下所有文档，生成阶段性摘要文件 docs/digest/YYYY-MM-DD--digest.md
---

# DIGEST — 阶段性文档整合

## 概述

读取 `docs/` 下所有文档，将内容整合为一份阶段性摘要，输出到 `docs/digest/YYYY-MM-DD--digest.md`。
适合在一批需求完成后做阶段性回顾，将碎片化文档沉淀为完整的项目快照。

## 触发条件

以下任一情况触发本 Skill：
- 用户输入 `/viktor:digest` 命令
- 用户输入自然语言意图（"生成整合文档" / "做阶段总结" / "整理一下文档"）
- DOCUMENT 节点完成后，ADR 数量为 5 的倍数时用户响应非阻塞建议

## 读取范围

| 来源 | 内容 |
|------|------|
| `docs/project-context.md` | 项目知识地图 |
| `docs/component-catalog.md` | 组件目录 |
| `docs/api-catalog.md` | API 接口目录 |
| `docs/architecture.md` | 架构决策速览 |
| `docs/adrs/README.md` | ADR 索引 |
| `docs/adrs/*.md`（排除 README.md） | 所有 ADR 全文 |
| `docs/specs/*.md` | 所有设计文档标题 + 状态 |
| `docs/plans/*.md` | 所有任务列表标题 + 验收总结状态 |
| `docs/reviews/*.md` | 所有 Review 报告中的 BLOCKING/TODO 条目 |

## 执行步骤

### 第 1 步：扫描文档清单

列出 `docs/` 下各子目录的文件数量：

```
扫描结果：
- specs/：N 个设计文档
- plans/：N 个任务列表
- reviews/：N 个 Review 报告
- adrs/：N 个 ADR（含 README.md）
- digest/：N 个历史摘要
```

### 第 2 步：提取关键信息

逐一读取文件，提取：

- **specs/**：每个文件的功能名称 + 日期 + 状态（已确认/草稿）
- **plans/**：每个文件的功能名称 + 任务总数 + 验收总结勾选情况
- **reviews/**：每个文件中标注为 `[BLOCKING]` 或 `TODO` 的条目
- **adrs/**：每个 ADR 的编号 + 标题 + 状态（已接受/已替代/已废弃）
- **活文档**：组件数量、接口数量、架构决策数量

### 第 3 步：生成摘要文件

输出路径：`docs/digest/YYYY-MM-DD--digest.md`（使用当天日期）

按以下模板生成：

```markdown
# 项目阶段性摘要

**生成日期**：YYYY-MM-DD
**文档范围**：specs N 个 / plans N 个 / reviews N 个 / adrs N 个

---

## 1. 项目当前状态

[来自 project-context.md 的核心信息：技术栈、目录结构、主要约定]

---

## 2. 本阶段完成需求

| 需求名称 | 日期 | 设计文档 | ADR |
|----------|------|---------|-----|
| [功能名] | YYYY-MM-DD | [specs/文件名] | [ADR-XXX] |

**任务完成情况**：
- [功能名]：P0 N/N ✅ / P1 N/N ✅ / P2 N/N ✅

---

## 3. 关键架构决策

| 编号 | 决策摘要 | 日期 | 状态 |
|------|---------|------|------|
| ADR-001 | [决策摘要] | YYYY-MM-DD | 已接受 |

---

## 4. 活文档现状

| 维度 | 数量 | 最近更新 |
|------|------|---------|
| 组件（component-catalog） | N 个 | YYYY-MM-DD |
| API 接口（api-catalog） | N 个 | YYYY-MM-DD |
| 架构决策（architecture） | N 条 | YYYY-MM-DD |

---

## 5. 待关注问题

以下问题来自 Review 报告，尚未标记为已解决：

| 来源 | 级别 | 问题描述 |
|------|------|---------|
| [review 文件名] | [BLOCKING/TODO] | [问题描述] |

> 若无待关注问题，此节显示「暂无」。
```

### 第 4 步：Commit

```bash
git add docs/digest/
git commit -m "docs: add digest for YYYY-MM-DD"
```

### 第 5 步：输出导航卡

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ DIGEST 已完成
📄 产物：docs/digest/YYYY-MM-DD--digest.md
──────────────────────────────
💡 摘要已生成，可分享给团队或归档备查
▶ 继续开发：/viktor:think <下一个需求>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 验证标准

DIGEST 成功执行的标志：
- [ ] 输出文件路径为 `docs/digest/YYYY-MM-DD--digest.md`
- [ ] 文件包含 5 个必需章节（当前状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题）
- [ ] 若某章节无内容，明确写「暂无」而非留空或跳过
- [ ] 已创建 git commit
