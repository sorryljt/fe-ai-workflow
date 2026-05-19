# ADR-003: 新增 CONTEXT 和 DIGEST 两个工具节点

**日期**：2026-05-19
**状态**：已接受
**提出者**：Dawson
**关联需求**：新增 /viktor:context 和 /viktor:digest 节点（v0.5.0）

---

## 背景

工作流在 v0.4.0 阶段建立了 5 文件活文档体系（INIT 生成骨架，DOCUMENT 持续更新），但存在两个实际使用中的痛点：

1. **缺少随时可用的项目快照**：用户在开始新需求前，需要手动打开 `project-context.md`、`component-catalog.md`、`api-catalog.md` 等多个文件逐一查阅，才能了解项目当前状态。特别是新成员接入或两次需求之间间隔较长时，重建上下文的成本较高。BRAINSTORM 节点虽然会读取 `project-context.md`，但没有将其他活文档内容一并呈现。

2. **缺少周期性整合机制**：随着 ADR 和 specs 积累，文档碎片化加剧。工作流每次产出结构化文档，但没有机制将一个阶段的成果整合为完整的阶段性回顾，团队无法便捷地获取"我们这一阶段做了什么"的全貌。

两个问题的核心共同点：**活文档数据存在，但缺乏便捷的聚合呈现方式**。

---

## 决策

**我们决定新增两个工具节点：`/viktor:context` 和 `/viktor:digest`**，并将其集成到现有工作流的自然触发点。

- **CONTEXT**：只读快照命令，读取 5 个活文档并格式化输出到对话，无副作用，随时可用。
- **DIGEST**：周期性整合命令，读取 docs/ 下所有文档，生成 `docs/digest/YYYY-MM-DD--digest.md`，由 DOCUMENT 在 ADR 达到 5 的倍数时非阻塞建议。

---

## 方案对比

### CONTEXT 输出方式

| 方案 | 描述 | 选择 |
|------|------|------|
| A：输出到对话 | 无副作用，随时可查，不增加文件数量 | ✅ 选择 |
| B：输出到文件（如 docs/context-snapshot.md） | 产生冗余文件，与 5 个活文档内容重复，维护成本高 | ❌ 排除 |
| C：合并到 /viktor:init 输出 | 强绑定，init 不应每次都重新输出快照 | ❌ 排除 |

### CONTEXT 工作流集成方式

| 方案 | 描述 | 选择 |
|------|------|------|
| A：纯手动，不集成 | 用户可能忘记 | ❌ 太被动 |
| B：每次 BRAINSTORM 自动执行 | 每次必须读完 5 个文件后才能开始提问，增加延迟，用户可能不需要 | ❌ 太强制 |
| C：BRAINSTORM 开始时非阻塞提示（情况 A 分支） | 用户自主决定是否查看，不增加强制步骤 | ✅ 选择 |

### DIGEST 触发方式

| 方案 | 描述 | 选择 |
|------|------|------|
| A：纯手动 | 自由，但用户可能持续忘记 | ❌ 太被动 |
| B：每次 DOCUMENT 后自动生成 | 频率过高，大多数时候整合没有必要 | ❌ 太频繁 |
| C：ADR 到 5 的倍数时在 DOCUMENT 完成后提示 | 有节奏感，按自然里程碑触发，不强制 | ✅ 选择 |

---

## 结果

### 正面影响

- CONTEXT 为团队提供了零成本的项目状态回顾方式：一条命令代替手动翻阅多个文件
- BRAINSTORM 的集成提示让用户在最有价值的时机（设计开始前）想到去查看现状，而不打断工作流
- DIGEST 为阶段性回顾提供了标准化产物格式，5 个章节覆盖状态 / 需求 / 决策 / 文档 / 问题
- DOCUMENT 的 ADR 计数触发机制将建议时机与自然里程碑绑定，避免成为"每次都出现的噪音"
- 两个节点均为工具节点（tool node），不进入主工作流的 Hard Gate 体系，不影响现有节点的门禁规则

### 负面影响 / 已知问题

- CONTEXT 输出内容随活文档的完善程度变化：若项目尚未执行 `/viktor:init`，5 个区块均为空，实用性低。短期内需要用户先养成使用 INIT 的习惯。
- DIGEST 依赖 AI 对 docs/ 内容的正确提取与分类。若 review.md 中的问题格式不标准（未使用 `[BLOCKING]`/`TODO` 标注），"待关注问题"章节可能提取不准确。当前版本无自动校验机制。
- "ADR 数量为 5 的倍数"的触发逻辑基于文件计数（排除 README.md）。若用户手动删除 ADR，计数会跳跃，触发时机可能提前或错过。目前认为 ADR 不应被删除，可接受。

### 影响的文件范围（v0.5.0 变更清单）

**新增**：
- `skills/08-context/SKILL.md`
- `skills/09-digest/SKILL.md`
- `commands/viktor/context.md`
- `commands/viktor/digest.md`

**改动**：
- `skills/01-brainstorming/SKILL.md` — 第 1 步情况 A 新增非阻塞 context 提示
- `skills/05-documentation/SKILL.md` — 第 7 步新增 ADR 计数与 digest 非阻塞建议
- `skills/using-fe-workflow/SKILL.md` — 命令速查表 / Skill 映射表 / 自然语言路由均新增两个节点
- `CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` — 三端同步，新增 CONTEXT / DIGEST 节点定义
- `README.md` — 工作流节点表格新增两行；目录结构说明更新
- `docs/team-workflow-guide.md` — 命令总览新增 4.7 / 4.8 节；各节点说明补充

---

## 后续行动

- [ ] 在真实业务项目中试用 `/viktor:context`，验证 5 个活文档全部初始化后的输出质量
- [ ] 观察 `/viktor:digest` 对 Review 报告中问题的提取准确率，若提取不准考虑在 DIGEST step 2 中增加格式说明
- [ ] 当 ADR 累积到 5 个时，执行首次 `/viktor:digest` 验证整合质量

---

## 相关文档

- 设计文档：[docs/specs/2026-05-19--context-digest-nodes.md](../specs/2026-05-19--context-digest-nodes.md)
- 任务列表：[docs/plans/2026-05-19--context-digest-nodes--tasks.md](../plans/2026-05-19--context-digest-nodes--tasks.md)
- Review 报告：[docs/reviews/2026-05-19--context-digest-nodes--review.md](../reviews/2026-05-19--context-digest-nodes--review.md)
