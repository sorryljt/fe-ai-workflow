# ADR-006: 集中修复 P0 级三端一致性问题与命名 Bug

**日期**：2026-05-20
**状态**：已接受
**提出者**：Dawson + AI 联合审查（Claude Codex 双端分析）
**关联需求**：P0 修复批次

## 背景

v0.7.0 发布后，通过 Codex 三端漂移分析和对所有 SKILL.md 的逐文件审查，发现 4 组 P0 级问题：

1. **Cursor 规则文件与另两端命令名不一致**：`.cursor/rules/workflow.mdc` 仍使用 `/brainstorm`、`/analyze`、`/tdd`、`/review` 旧命令名，而 Claude Code（CLAUDE.md）和 Codex（AGENTS.md）已统一使用 `viktor:*` 协议（ADR-004 后的正式约定）。此外，Cursor 中 BRAINSTORM 提问策略仍是"苏格拉底式逐个提问"，与 SKILL.md 规定的"批量最多 3 问"相反。

2. **REVIEW 框架名称内部不一致**：`skills/04-code-review/SKILL.md` frontmatter description 已标注"六轴"，但正文 section heading 和 review.md 模板中仍写"五轴"，同一文件内标签矛盾。

3. **DIGEST 触发描述过时**：`skills/using-fe-workflow/SKILL.md` 命令速查表 digest 行仍写"ADR 累积到 5 的倍数时"，与 ADR-005 后的实际行为（每次 DOCUMENT 无条件触发）不符。

4. **遗留 [SUGGESTED] bug 未清理**：包括 `commands/viktor/contract.md` 将可选节点的执行中约束错误命名为"Hard Gate"（与工作流强制前置条件语义冲突）、`skills/05-documentation/SKILL.md` step 4 使用框架专属术语"React 组件"/"Server Action"（与框架无关定位矛盾）、`skills/01-brainstorming/SKILL.md` step 1 中与冷启动步骤重复的 docs/specs/ 扫描说明。

## 决策

**我们决定将上述 4 组 P0 问题打包为一个修复批次，集中处理，每个文件单独 commit。**

不拆分为多个独立需求，原因：所有问题均为纯文字修正（无逻辑变更），彼此独立（无依赖），批量处理可降低工作流启动摩擦，同时通过 grep 验收确保无遗漏。

## 方案对比

| 方案 | 优势 | 劣势 | 选择结果 |
|------|------|------|---------|
| 打包修复（本次采用） | 一次走完工作流，减少 spec/plan/review/adr 文件数 | 单次 PR 改动文件较多 | ✅ 选择 |
| 逐问题独立需求 | 每次改动更小，追溯更清晰 | 4 个需求 × 完整流程 = 过度摩擦（纯文字修正不值当） | ❌ 排除 |
| 直接 hotfix 不走流程 | 最快 | 无 spec/adr 记录，下次审查找不到决策依据 | ❌ 排除 |

## 变更清单

| 文件 | 改动类型 | 具体内容 |
|------|---------|---------|
| `.cursor/rules/workflow.mdc` | 命令名 + 策略 + 技术栈 | 旧命令名 → viktor:*；苏格拉底式 → 批量3问；硬编码栈 → 引用 project-context.md |
| `skills/using-fe-workflow/SKILL.md` | 描述修正 | digest 触发："5的倍数" → "每次无条件触发" |
| `skills/04-code-review/SKILL.md` | 命名统一 | "五轴" → "六轴"（4 处，含正文标题、step3、验证清单、模板） |
| `commands/viktor/contract.md` | 措辞修正 | "执行中 Hard Gate" → "执行中约束（会话锁）" |
| `skills/05-documentation/SKILL.md` | 框架无关化 | "React 组件" → "前端组件（React / Vue / Svelte 等）"；"Server Action" → "接口函数" |
| `skills/01-brainstorming/SKILL.md` | 冗余清理 | 删除 step 1 中与冷启动重复的 docs/specs/ 扫描说明 |

## 结果

**正面影响**：
- Cursor 用户与 Claude Code / Codex 用户命令体验一致，消除三端分歧
- REVIEW 框架名称在整个工作流文档中统一，AI 执行不再产生混淆
- "Hard Gate" 术语仅保留用于真正的强制前置条件，语义更精准
- documentation SKILL 对所有前端框架均适用，不再隐含 React/Next.js 假设

**负面影响 / 已知问题**：
- `skills/01-brainstorming/SKILL.md` step 1"额外执行"列表删除一行后，剩余唯一一条仍为 `references/react-nextjs-conventions.md` 框架专属引用，属 P3（框架无关化）范围，待后续迭代处理
- `workflow.mdc` TDD 节仍提及"Vitest"（既有措辞，P1 范围）

## 后续行动

- [ ] P1 迭代：修复 git diff 检测范围（HEAD~1 → merge-base）、TDD 合约遗漏提醒、DIGEST SUGGESTED 收集
- [ ] P3 迭代：framework agnostic 全面改造（brainstorming 模板、TDD 配置模板、REVIEW 检查清单去 Next.js 专属条目）

## 相关文档

- 设计文档：[docs/specs/2026-05-20--p0-consistency-fixes.md](../specs/2026-05-20--p0-consistency-fixes.md)
- 任务列表：[docs/plans/2026-05-20--p0-consistency-fixes--tasks.md](../plans/2026-05-20--p0-consistency-fixes--tasks.md)
- Review 报告：[docs/reviews/2026-05-20--p0-consistency-fixes--review.md](../reviews/2026-05-20--p0-consistency-fixes--review.md)
