# 设计文档：新增 /viktor:context 和 /viktor:digest 节点

**日期**：2026-05-19
**状态**：已确认
**提出者**：Dawson

---

## 背景

当前工作流的 5 个活文档（`project-context.md`、`component-catalog.md`、`api-catalog.md`、`architecture.md`、`adrs/README.md`）由 INIT 初始化、DOCUMENT 更新，但没有便捷的方式让用户在任意时刻快速获取项目全貌，也没有机制将历史文档定期整合沉淀。

两个问题：
1. **缺少随时可用的快照视图**：用户需要手动打开多个文件才能了解项目当前状态，特别是新成员接入或需求开始前。
2. **缺少周期性整合**：随着 ADR 和 specs 积累，文档碎片化，没有统一的"阶段性回顾"文档。

---

## 方案

新增两个工具节点：

### /viktor:context

**定位**：只读快照命令，随时可用，无副作用。

**行为**：
- 读取 5 个活文档（project-context.md / component-catalog.md / api-catalog.md / architecture.md / adrs/README.md）
- 将内容格式化后输出到对话
- 不生成文件，不创建 commit
- 任何文件缺失时，给出说明（"尚未初始化，建议执行 `/viktor:init`"）

**工作流集成**：
- BRAINSTORM 节点（`/viktor:think`）开始时，若检测到 `docs/project-context.md` 存在，输出一行非阻塞提示：
  > 💡 检测到项目知识地图，可执行 `/viktor:context` 快速回顾现有组件和接口，再开始需求设计。

**输出格式（对话内）**：
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 项目概览（来自 docs/project-context.md）
[project-context.md 关键内容摘要]

🧩 现有组件（来自 component-catalog.md）
[组件目录表格]

🔌 API 接口（来自 api-catalog.md）
[接口目录表格]

🏛 架构决策（来自 architecture.md）
[架构速览表格]

📋 ADR 列表（来自 adrs/README.md）
[ADR 索引表格]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### /viktor:digest

**定位**：周期性整合命令，将 docs/ 下所有文档内容整合为一份阶段性摘要。

**行为**：
- 读取 `docs/` 下所有相关文档（specs/、plans/、reviews/、adrs/、5 个活文档）
- 生成整合摘要文档：`docs/digest/YYYY-MM-DD--digest.md`
- 包含：项目状态快照 + 本阶段完成的需求列表 + 关键架构决策 + 未解决问题
- commit 产物

**工作流集成**：
- DOCUMENT 节点（`/viktor:doc`）完成后，若当前 ADR 数量为 5 的倍数（即 ADR-005、ADR-010 等），输出一行非阻塞建议：
  > 💡 已累积 N 个 ADR，建议执行 `/viktor:digest` 生成阶段性整合文档。

**输出文件结构**：
```markdown
# 项目阶段性摘要

**生成日期**：YYYY-MM-DD
**包含范围**：[文档列表]

## 项目当前状态
[来自 project-context.md 的关键信息]

## 本阶段完成需求
[来自 specs/ 的需求列表 + 对应 ADR]

## 关键架构决策
[来自 adrs/ 的决策摘要，含状态]

## 活文档现状
[component-catalog / api-catalog 的组件/接口数量概述]

## 待关注问题
[来自 reviews/ 中标注为 TODO 或待处理的问题]
```

---

## 方案对比

### /viktor:context 输出方式

| 方案 | 说明 | 选择 |
|------|------|------|
| A：输出到对话 | 无副作用，随时可查 | ✅ 选择 |
| B：输出到文件 | 产生冗余文件，与活文档重复 | ❌ 排除 |
| C：输出到文件 + 对话 | 两者都有，但文件意义不大 | ❌ 排除 |

### /viktor:digest 触发方式

| 方案 | 说明 | 选择 |
|------|------|------|
| A：纯手动 | 自由，但用户可能忘记 | ❌ 太被动 |
| B：每次 DOCUMENT 后自动生成 | 产物过多，价值低 | ❌ 太频繁 |
| C：ADR 达到 5 的倍数时在 DOCUMENT 结束后提示 | 有节奏，不强制 | ✅ 选择 |

---

## 验收标准

### /viktor:context
- [ ] 执行后输出格式化的 5 个活文档内容
- [ ] 任一文件缺失时，给出说明而非报错
- [ ] BRAINSTORM 开始时，若 project-context.md 存在，显示非阻塞提示
- [ ] 不生成任何文件，不创建 commit

### /viktor:digest
- [ ] 执行后生成 `docs/digest/YYYY-MM-DD--digest.md`
- [ ] 文件包含 5 个必需章节
- [ ] DOCUMENT 完成后，ADR 数量为 5 的倍数时显示非阻塞建议
- [ ] 生成后自动 commit

---

## 影响范围

**新增文件**：
- `skills/08-context/SKILL.md`
- `skills/09-digest/SKILL.md`
- `commands/viktor/context.md`
- `commands/viktor/digest.md`

**修改文件**：
- `skills/01-brainstorming/SKILL.md` — 开始时加非阻塞提示
- `skills/05-documentation/SKILL.md` — 完成后加 ADR 数量检测提示
- `skills/using-fe-workflow/SKILL.md` — 路由表新增两个节点
- `CLAUDE.md` — 节点定义新增 context / digest
- `AGENTS.md` — 同步
- `.cursor/rules/workflow.mdc` — 同步
- `README.md` — 工作流说明表格新增两行
- `docs/team-workflow-guide.md` — 命令总览新增两节
