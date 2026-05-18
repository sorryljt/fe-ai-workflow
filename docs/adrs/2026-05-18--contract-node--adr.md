# ADR-001: 新增 CONTRACT 节点，将类型合约接入工作流

**日期**：2026-05-18
**状态**：已接受
**提出者**：Dawson
**关联需求**：CONTRACT 节点 — 类型合约接入工作流（v0.3.0）

---

## 背景

工作流在 v0.2.x 阶段，各节点间的类型定义是**隐式**的：

- `design.md` 的 §5.3 接口定义是模板建议，不强制填写
- ANALYZE → TDD 之间的数据类型靠 AI 自由解读自然语言推断
- 每次对话重启（上下文断裂），AI 会重新"发明"类型，与前次定义可能不一致
- REVIEW 没有明确的类型基准可供核对，只能凭感觉判断

随着工作流被多个业务项目接入，这种"类型漂移"在多人协作和多轮需求迭代中逐渐成为痛点：
- 不同成员用同一套 tasks.md 各自实现，产出的 TypeScript 接口往往不一致
- AI 下游节点消费上游产物时，靠解读自然语言推断，精度不稳定

需要一种机制，在 ANALYZE 完成后、TDD 开始前，将类型定义**固化为可执行文件**，作为所有下游节点的共享语言。

---

## 决策

**我们决定新增 CONTRACT 作为独立的可选节点（`/viktor:contract`）**，在 ANALYZE 和 TDD 之间生成 TypeScript 类型合约文件（`docs/contracts/YYYY-MM-DD--<feature>.types.ts`），作为 TDD 实现和 REVIEW 检查的类型锚点。

---

## 方案对比

### 主方案选择：CONTRACT 的接入位置

| 方案 | 描述 | 优势 | 劣势 | 选择 |
|------|------|------|------|------|
| A：独立节点 `/viktor:contract` | 单独命令，独立 Skill，可选执行 | 职责清晰，与现有节点模式一致，小需求可跳过 | 新增命令，学习成本略增 | ✅ 选择 |
| B：嵌入 ANALYZE 内部 | ANALYZE 完成后自动生成类型文件 | 用户无感知，零学习成本 | 职责混乱，无法单独触发，总是执行（小需求浪费） | ❌ 排除 |
| C：新增强制节点 | 所有流程必须经过 CONTRACT | 最彻底的类型保障 | 小需求负担重，流程变长，团队阻力大 | ❌ 排除 |

**选择理由**：方案 A 在"流程完整性"和"灵活度"之间取得最佳平衡。通过 ANALYZE 的智能推荐（检测到 `[api]`/`[hook]`/`[store]` 类型任务时推荐），让"可选"不等于"被忽略"。

### 次方案选择：产物格式

| 方案 | 描述 | 优势 | 劣势 | 选择 |
|------|------|------|------|------|
| 纯 `.ts` + JSDoc 注释 | TypeScript 接口文件，注释内嵌说明 | 可直接 import，机器可读，符合 TS 生态习惯 | 字段说明不如 Markdown 直观 | ✅ 选择 |
| `.ts` + `.md` 配对 | 类型文件 + 单独说明文档 | 说明更丰富，团队沟通友好 | 两个文件需同步维护，容易漂移 | ❌ 排除 |

**选择理由**：JSDoc 注释足以表达设计意图，且"单文件、可 import"的特性使其成为真正的"共享语言"而非文档附属物。

### 次方案选择：推荐强制程度

| 方案 | 描述 | 选择 |
|------|------|------|
| ANALYZE 推荐，用户自由选择 | 不强制，不记录跳过理由 | ✅ 选择 |
| ANALYZE 推荐，跳过需说明理由 | 有约束力，但增加摩擦 | ❌ 排除 |
| 完全自愿（无推荐） | 不易被发现，CONTRACT 形同虚设 | ❌ 排除 |

---

## 结果

### 正面影响

- 工作流新增结构化的"类型锚点"层，消除节点间类型漂移
- ANALYZE 导航卡的双路设计（推荐 CONTRACT / 建议跳过）将"可选"转化为"主动判断"，而非被遗忘
- TDD 节点感知合约文件后，AI 在写测试和实现时有明确的 import 来源，减少幻觉
- REVIEW 第六轴（类型合约一致性）在合约存在时提供客观核查基准

### 负面影响 / 已知问题

- CONTRACT 节点为 workflow 新增概念，团队成员需要一次性学习（成本低，但非零）
- 合约文件基于 tasks.md 提取，若 tasks.md 本身类型信息不足（任务描述过于简略），合约精度有限
- Review 中发现并已修复：REVIEW Skill 中轴 5/6 顺序颠倒（已修复）；Hard Gate 措辞歧义（已澄清）

### 影响的文件范围（v0.3.0 变更清单）

**新增**：
- `skills/07-type-contract/SKILL.md`
- `commands/viktor/contract.md`
- `.claude/commands/viktor/contract.md`
- `docs/contracts/`（目录规范，实际文件由业务项目生成）

**改动**：
- `skills/02-requirements-analysis/SKILL.md` — 推荐逻辑 + 双路导航卡
- `skills/03-tdd-cycle/SKILL.md` — 前置步骤：合约感知
- `skills/04-code-review/SKILL.md` — 第六检查轴（类型合约一致性）
- `skills/using-fe-workflow/SKILL.md` — 命令速查表 + Codex 触发 + 自然语言路由
- `CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` — 三端同步
- `README.md` / `docs/team-workflow-guide.md` — 版本号 v0.3.0

---

## 后续行动

- [ ] 在真实业务项目中试用 `/viktor:contract`，收集一次完整流程的使用反馈
- [ ] 若合约文件与实际代码频繁漂移，考虑增加"合约变更时提示更新"的机制
- [ ] 考虑为 `docs/contracts/` 目录添加 `.gitkeep`，让目录在项目初始化时即存在

---

## 相关文档

- 设计文档：[docs/specs/2026-05-18--contract-node.md](../specs/2026-05-18--contract-node.md)
- 任务列表：[docs/plans/2026-05-18--contract-node--tasks.md](../plans/2026-05-18--contract-node--tasks.md)
- Review 报告：[docs/reviews/2026-05-18--contract-node--review.md](../reviews/2026-05-18--contract-node--review.md)
