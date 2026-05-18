# ADR-002: 建立活文档体系，改造 DOCUMENT 和 INIT 节点

**日期**：2026-05-18
**状态**：已接受
**提出者**：Dawson
**关联需求**：升级文档能力（v0.4.0）

---

## 背景

工作流在 v0.3.0 阶段，文档体系存在以下问题：

1. **无活文档**：每次需求完成后只生成 ADR + CHANGELOG，不维护任何随项目演进的持久文档。团队成员无法从工作流中获取"现有组件有哪些"、"API 路由有哪些"等信息，每次 BRAINSTORM 都需要重新探索。

2. **ADR 编号手动**：ADR 模板标题为 `ADR-XXX` 占位符，靠人工填写，经常遗漏或填错，导致编号不连续。

3. **ADR 只有"已接受"状态**：没有状态机制，当一个决策被后续需求替代时，旧 ADR 仍然显示"已接受"，阅读历史 ADR 时无法判断其是否仍有效。

4. **无 ADR 索引**：`docs/adrs/` 下只有单独文件，没有统一索引，随着项目演进，ADR 数量增多后难以快速找到相关决策。

5. **工作流自身变更无提示**：修改 `skills/` 或 `commands/` 后，DOCUMENT 节点不提示同步三端入口文件（CLAUDE.md / AGENTS.md / workflow.mdc），容易造成平台间不一致。

---

## 决策

**我们决定建立 5 文件活文档体系，同时改造 DOCUMENT 和 INIT 节点**，具体包含：

1. INIT 节点新增第 6 步，生成 4 个活文档骨架文件
2. DOCUMENT 节点新增工作流变更检测、ADR 自动编号、ADR 替代流程、条件更新活文档
3. 新增 `references/living-docs-conventions.md` 将规范固化

---

## 方案对比

### 活文档文件结构

| 方案 | 描述 | 优势 | 劣势 | 选择 |
|------|------|------|------|------|
| A：5 文件 Markdown | project-context + component-catalog + api-catalog + architecture + adrs/README | 职责单一，DOCUMENT 可精准更新对应文件 | 文件数量略多 | ✅ 选择 |
| B：单文件汇总 | 所有活文档合并成 `docs/overview.md` | 简单，一处查阅 | 文件过大，更新时易误伤其他章节 | ❌ 排除 |
| C：CSV + MD 混合 | 组件/接口用 CSV，叙述用 MD | 表格可被工具解析 | 需两种格式，当前无 CSV 消费工具 | ❌ 排除 |

### ADR 编号方案

| 方案 | 描述 | 选择 |
|------|------|------|
| 读取 docs/adrs/ 文件数 +1 | 无需外部配置，自然递增 | ✅ 选择 |
| 用户手动指定 | 灵活但易遗漏 | ❌ 排除 |
| 全局计数器文件 | 需额外维护 `.adr-counter` | ❌ 排除 |

### ADR 替代自动化方案

| 方案 | 描述 | 选择 |
|------|------|------|
| DOCUMENT 询问，用户指定编号，自动更新旧文件 | 交互一次，精准修改 | ✅ 选择 |
| 完全手动（只写规范） | 零开发成本，但容易被遗忘 | ❌ 排除 |
| 自动扫描语义相关 ADR | 技术复杂，误判风险高 | ❌ 排除 |

---

## 结果

### 正面影响

- INIT 执行后项目即拥有完整活文档骨架，后续每次 DOCUMENT 有文件可追加
- DOCUMENT 节点新增 4 项能力：变更检测 / 自动编号 / 替代流程 / 条件更新活文档，文档维护成本从"完全手动"降为"按需引导"
- ADR 状态机制（草稿 / 已接受 / 已废弃 / 已替代）使历史决策的有效性一目了然
- 工作流变更检测解决了"修改 skills/ 后忘记同步三端入口"的隐患
- `references/living-docs-conventions.md` 将规范固化，后续迭代有据可查

### 负面影响 / 已知问题

- 活文档的"条件更新"依赖 AI 对本次变更的正确分类（判断是否属于组件变更、API 变更等）；若分类不准，更新可能遗漏或多余。当前版本无自动纠错机制。
- ADR 编号基于文件计数，若有 ADR 被手动删除，编号会产生跳跃。目前认为 ADR 不应被删除，可接受。
- DOCUMENT step 4"若文件不存在先建骨架"的说明中，骨架模板引用路径在 CR 时被发现不准确（指向了不存在模板的 living-docs-conventions.md），已在 Review 阶段修复（改为 INIT SKILL.md 第 6 步）。
- commit 命令遗漏 `project-context.md`（Review 时发现，已修复）。

### 影响的文件范围（v0.4.0 变更清单）

**新增**：
- `references/living-docs-conventions.md`

**改动**：
- `skills/05-documentation/SKILL.md` — 新增步骤（变更检测 / ADR 编号 / 替代流程 / 条件更新活文档）、验证标准、ADR 模板
- `skills/06-project-init/SKILL.md` — 新增第 6 步（活文档骨架生成）、导航卡、验证标准
- `skills/using-fe-workflow/SKILL.md` — INIT / DOCUMENT 描述更新
- `CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` — 三端同步
- `commands/viktor/doc.md` / `commands/viktor/init.md` — description 更新
- `README.md` / `docs/team-workflow-guide.md` — 版本 v0.4.0

---

## 后续行动

- [ ] 在真实业务项目中试用活文档体系，验证 component-catalog / api-catalog 的追加质量
- [ ] 若 AI 对变更类型分类不准（误追加或漏追加），考虑在 DOCUMENT step 4 增加用户确认步骤
- [ ] 考虑为 ADR 编号碰撞（文件手动删除场景）添加校验提示

---

## 相关文档

- 设计文档：[docs/specs/2026-05-18--doc-system-upgrade.md](../specs/2026-05-18--doc-system-upgrade.md)
- 任务列表：[docs/plans/2026-05-18--doc-system-upgrade--tasks.md](../plans/2026-05-18--doc-system-upgrade--tasks.md)
- Review 报告：[docs/reviews/2026-05-18--doc-system-upgrade--review.md](../reviews/2026-05-18--doc-system-upgrade--review.md)
