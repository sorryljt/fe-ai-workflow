# 前端 AI 开发工作流 — Claude Code 配置

## 项目说明

本仓库为前端团队提供基于 AI 的标准化开发工作流，**框架无关**（React / Vue / Svelte 等均适用）。
具体技术栈由 `/viktor:init` 从项目 `package.json` 探测后写入 `docs/project-context.md`，工作流所有节点读取该文件而非硬编码框架。

工作流融合两个开源项目的思想：
- **obra/superpowers**：自动调度机制、brainstorming + spec 沉淀、流程编排哲学
- **addyosmani/agent-skills**：每个节点的工程规范内容骨架

兼容三种 AI 编程工具：Claude Code、Cursor、OpenAI Codex。

## 启动规则

**每次对话开始时，必须加载 `skills/using-fe-workflow/SKILL.md` 并遵循其调度规则。**

该文件是整个工作流的元调度器，负责根据用户意图自动路由到正确的 Skill。读取它，然后根据路由表决定下一步。

## 工作流节点定义

### 流程概览

```
用户需求 → BRAINSTORM → ANALYZE → TDD → REVIEW → DOCUMENT
              ↓              ↓         ↓        ↓           ↓
          design.md     tasks.md    代码   review.md    adr.md
```

### 节点详细说明

#### 节点 1：BRAINSTORM（需求澄清）

- **触发方式**：用户输入 `/viktor:think <需求描述>`（手动触发）
- **加载 Skill**：`skills/01-brainstorming/SKILL.md`
- **输入**：用户的模糊需求描述、想法、PRD 草稿
- **输出**：`docs/specs/YYYY-MM-DD--<feature>.md`
- **完成条件**：用户明确确认设计文档内容
- **Hard Gate**：用户未确认前，禁止进入任何实现阶段

#### 节点 2：ANALYZE（需求分析）

- **触发方式**：用户输入 `/viktor:plan`，或 brainstorming 完成后用户确认
- **加载 Skill**：`skills/02-requirements-analysis/SKILL.md`
- **输入**：`docs/specs/YYYY-MM-DD--design.md` 或 PRD 文档
- **输出**：`docs/plans/YYYY-MM-DD--<feature>--tasks.md`
- **完成条件**：tasks.md 中所有任务粒度合理（每条约 2-5 分钟一个 TDD 循环）

#### 节点 3：TDD（测试驱动开发）

- **触发方式**：用户输入 `/viktor:code`
- **加载 Skill**：`skills/03-tdd-cycle/SKILL.md`
- **输入**：`docs/plans/YYYY-MM-DD--tasks.md`
- **输出**：实现代码（`src/`）+ 测试文件（`__tests__/` 或 `*.test.ts`）
- **完成条件**：tasks.md 中所有任务均有对应测试，测试全部通过

#### 节点 4：REVIEW（代码审查）

- **触发方式**：用户输入 `/viktor:cr`
- **加载 Skill**：`skills/04-code-review/SKILL.md`
- **输入**：所有实现代码 + 测试文件 + `tasks.md`
- **输出**：`docs/reviews/YYYY-MM-DD--<feature>--review.md`
- **特别规则**：
  - 有 `[BLOCKING]` 问题 → 输出修复建议，提示返回 `/viktor:code`
  - 全部通过 → 提示进入 `/viktor:doc`

#### 节点 5：DOCUMENT（文档沉淀）

- **触发方式**：用户输入 `/viktor:doc`（前提：CR 已通过）
- **加载 Skill**：`skills/05-documentation/SKILL.md`
- **输入**：`design.md` + `tasks.md` + `review.md` + 所有代码
- **输出**：`docs/adrs/YYYY-MM-DD--<feature>--adr.md` + 更新 `CHANGELOG.md`

## 产物目录规范

所有文档产物统一放在 `docs/` 目录下：

```
docs/
├── specs/          # 设计文档（BRAINSTORM 产物）
│   └── YYYY-MM-DD--<feature>.md
├── plans/          # 任务计划（ANALYZE 产物）
│   └── YYYY-MM-DD--<feature>--tasks.md
├── reviews/        # Code Review 报告（REVIEW 产物）
│   └── YYYY-MM-DD--<feature>--review.md
└── adrs/           # 架构决策记录（DOCUMENT 产物）
    └── YYYY-MM-DD--<feature>--adr.md
```

文件命名规范：`YYYY-MM-DD--<feature-name>.<ext>`，使用双横线分隔日期和功能名。

## 全局编码规范

详见 `references/` 目录：

- `references/react-nextjs-conventions.md` — React/Next.js/TypeScript 编码规范
- `references/testing-patterns.md` — Vitest + RTL 测试模式与最佳实践
- `references/prd-input-template.md` — PRD 标准输入模板

在实现任何代码时，必须对照 `references/react-nextjs-conventions.md` 确认规范符合。

## AGENTS.md 与 SKILL.md 同步规则

修改 AGENTS.md 中任何节点的执行步骤时，必须对照对应的 `skills/0x-*/SKILL.md` 确认关键步骤没有遗漏。

AGENTS.md 是 Codex 的运行时指令，SKILL.md 是各节点的完整规范。两者描述同一套行为，AGENTS.md 是精简版，SKILL.md 是详细版，不能出现逻辑上的不一致。

对照顺序：
- BRAINSTORM → `skills/01-brainstorming/SKILL.md`
- ANALYZE → `skills/02-requirements-analysis/SKILL.md`
- TDD → `skills/03-tdd-cycle/SKILL.md`
- REVIEW → `skills/04-code-review/SKILL.md`
- DOCUMENT → `skills/05-documentation/SKILL.md`

## Git Tag 发布规范

- **工作流变更**（skills/ 规则修改、scripts/ 脚本变更、节点行为调整、AGENTS.md / SKILL.md 更新）→ 先把 README.md 和 docs/team-workflow-guide.md 里的版本号改成新版本 → commit → 打 tag → push
- **文档修复**（错别字、说明补充、注意事项调整）→ 直接推 main，不打 tag

打 tag 前必须先更新文档版本号，确保 tag 内的文档引用的就是自身版本，不产生偏差。
