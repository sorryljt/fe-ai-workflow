---
name: using-fe-workflow
description: 前端 AI 开发工作流元调度器 - 对话开始时加载，提供命令速查和 Hard Gate 规则，工作流通过 /viktor:* 命令手动触发
---

# 前端 AI 开发工作流 — 元调度器

## Skill-First 原则

在执行任何开发任务之前，必须先确定当前处于工作流的哪个节点，并加载对应的 Skill。

**1% 规则**：只要有 1% 的可能性某个 Skill 适用，就必须先加载该 Skill 再行动。不要以"需求很清楚"、"时间紧"、"这步很小"为由跳过。

## 命令速查

| 命令 | 节点 | 触发时机 |
|------|------|---------|
| `/viktor:init` | INIT | 首次接入项目，扫描代码库生成知识地图 + 活文档骨架 |
| `/viktor:think <需求>` | BRAINSTORM | 有新需求时，附带需求描述一步触发 |
| `/viktor:plan` | ANALYZE | design.md 确认后，拆解为任务列表 |
| `/viktor:contract` | CONTRACT | tasks.md 完成后（可选），生成 TypeScript 类型合约文件 |
| `/viktor:code` | TDD | tasks.md 确认后，测试驱动实现 |
| `/viktor:cr` | REVIEW | 实现完成后，六轴代码审查 |
| `/viktor:doc` | DOCUMENT | CR 通过后，生成 ADR（自动编号）、更新活文档、沉淀 CHANGELOG |

## Codex 触发规则

在 OpenAI Codex 中，工作流不能依赖“命令面板里必须存在 `/viktor:*`”这一前提，也不能依赖输入前导 `/`。

必须同时支持两种触发方式：

### 1. 文本协议触发

当用户消息中出现以下文本时，直接视为对应节点触发：

- `viktor:init`
- `viktor:think`
- `viktor:plan`
- `viktor:contract`
- `viktor:code`
- `viktor:cr`
- `viktor:doc`

即使平台 UI 没有展示 slash command，也不得拒绝执行。

### 2. 自然语言意图触发

如果用户没有输入标准命令，但表达了明确节点意图，也必须路由：

| 用户意图示例 | 对应节点 |
|-------------|---------|
| “先扫一下项目结构” “初始化项目上下文” | INIT |
| “先做需求澄清” “先设计方案” | BRAINSTORM |
| “拆成任务” “给我一个可执行任务列表” | ANALYZE |
| “生成类型合约” “锁定接口定义” “先定义类型” | CONTRACT |
| “开始写代码” “按任务实现” | TDD |
| “帮我做 code review” “审一下这版实现” | REVIEW |
| “补 ADR” “整理最终文档” | DOCUMENT |

如果用户同时给出了需求描述，直接带入对应节点，不要求重复输入标准命令。

## 平台说明

- 在 Claude Code 中，`commands/*.md` 可能表现为更接近原生命令的体验。
- 在 Codex 中，`commands/*.md` 主要是说明文档；真正的兼容关键是 `AGENTS.md` + `skills/*.md` 中的路由规则。
- 因此，**“命令面板里看不到 `viktor:*`” 不等于 workflow 不可用。**
- 在 Codex CLI 中，用户应直接输入 `viktor:*` 或自然语言意图，不要输入前导 `/`，否则可能被平台先当作自身 slash command 处理。

## 工作流节点与 Skill 映射

| 节点 | 加载 Skill |
|------|-----------|
| INIT | `skills/06-project-init/SKILL.md` |
| BRAINSTORM | `skills/01-brainstorming/SKILL.md` |
| ANALYZE | `skills/02-requirements-analysis/SKILL.md` |
| CONTRACT | `skills/07-type-contract/SKILL.md` |
| TDD | `skills/03-tdd-cycle/SKILL.md` |
| REVIEW | `skills/04-code-review/SKILL.md` |
| DOCUMENT | `skills/05-documentation/SKILL.md` |

## Hard Gate 规则（强制）

**写任何实现代码之前，以下条件必须满足其一：**

1. `docs/specs/` 下存在用户已明确确认的 `design.md`，**或**
2. `docs/plans/` 下存在 `tasks.md`

**两者均不存在时**：
- 停止一切实现行为
- 提示用户：
  > "缺少设计文档，请先输入 `/viktor:think <需求描述>` 完成需求澄清。"

## 强制规则

1. **语言**：所有输出必须使用中文，包括对话回复、文档产物、代码注释、审查报告和错误提示
2. **Skill 优先**：收到任何开发任务时，先确认节点、加载 Skill，再行动
2. **顺序不可跳过**：BRAINSTORM → ANALYZE → TDD → REVIEW → DOCUMENT，不可倒退、不可跳跃
3. **确认后推进**：每个节点完成后，必须获得用户明确确认才能进入下一节点
4. **文档先行**：所有文档产物在对应代码 commit 之前必须存在且已确认

## 反理由表（常见跳过借口及反驳）

| 借口 | 反驳 |
|------|------|
| "需求很清楚，直接写代码" | 清楚是你的感受。design.md 是团队对齐的载体，不是给 AI 看的。 |
| "先搭结构，设计边做边想" | 没有设计就开始写的代码，重构成本远高于前期 30 分钟的设计。 |
| "这个功能很小，走完整流程太重了" | 小功能的 ANALYZE 和 BRAINSTORM 可以很短，但不能没有。 |
| "先写代码，测试之后再补" | 测试补写率接近零。事后补的测试只测正常路径，价值极低。 |
| "这个我很熟，不需要 brainstorm" | 个人熟悉 ≠ 团队对齐。design.md 是团队沟通的载体。 |
| "现在时间紧" | 跳过流程节省的时间，会在后续 bug 和返工中加倍偿还。 |
| "AI 帮我想就好了，不用文档" | 没有文档，AI 下次对话没有上下文，从头来过更慢。 |

## 调试路由（遇到 bug 时）

当用户描述以下情况时，切换到系统性 debug 模式，不要直接猜测原因：

- 测试失败且原因不明
- 出现运行时错误
- 功能行为与预期不符

**系统性 debug 步骤**：

1. **复现**：确认最小复现步骤，排除环境问题
2. **隔离**：确定问题边界（哪个文件/函数/组件）
3. **假设**：列出 2-3 个可能原因（不要只猜一个）
4. **验证**：针对每个假设写一个最小验证测试
5. **修复**：修复后运行完整测试套件，确认无回归
6. **记录**：如果 bug 源于设计缺陷，更新 design.md 或 tasks.md

## 验证标准

调度器正常工作的标志：
- [ ] Hard Gate 有效阻止无 design.md / tasks.md 时的编码行为
- [ ] 所有 `viktor:*` 文本触发能正确加载对应 Skill（Codex）
- [ ] 所有 `/viktor:*` 文本触发能正确加载对应 Skill（Claude Code）
- [ ] 用户用自然语言表达节点意图时也能正确路由
- [ ] 节点间推进总是先获得用户确认
