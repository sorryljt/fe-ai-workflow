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
用户需求 → BRAINSTORM → ANALYZE → [CONTRACT] → TDD → REVIEW → DOCUMENT
              ↓              ↓          ↓          ↓      ↓           ↓
          design.md     tasks.md   types.ts      代码  review.md   adr.md

注：[CONTRACT] 为可选节点，由 ANALYZE 根据任务构成智能推荐，用户决定是否执行。

Workflow-Meta Lane（修改 skills/ 或 commands/ 时）：
  跳过 TDD，以 grep 验收替代 vitest，每文件独立 commit。
  其余节点（BRAINSTORM → ANALYZE → REVIEW → DOCUMENT）照常执行。
  详见 skills/using-fe-workflow/SKILL.md 的"Workflow-Meta Lane"章节。

工具节点（随时可用，不影响主流程）：
  /viktor:context — 只读输出 5 个活文档的格式化快照
  /viktor:digest  — 整合 docs/ 下所有文档，生成阶段性摘要
```

### 节点详细说明

#### 节点 1：BRAINSTORM（需求澄清）

- **触发方式**：用户输入 `/viktor:think <需求描述>`（手动触发）
- **加载 Skill**：`skills/01-brainstorming/SKILL.md`
- **输入**：用户的模糊需求描述、想法、PRD 草稿
- **输出**：`docs/specs/YYYY-MM-DD--<feature>.md`
- **完成条件**：用户明确确认设计文档内容
- **冷启动行为**：扫描 `docs/specs/` 下已有文件；有文件时询问新建还是更新已有文档，选择更新则加载该文件直接进入修改模式
- **Hard Gate**：用户未确认前，禁止进入任何实现阶段

#### 节点 2：ANALYZE（需求分析）

- **触发方式**：用户输入 `/viktor:plan`，或 brainstorming 完成后用户确认
- **加载 Skill**：`skills/02-requirements-analysis/SKILL.md`
- **输入**：`docs/specs/YYYY-MM-DD--design.md` 或 PRD 文档
- **输出**：`docs/plans/YYYY-MM-DD--<feature>--tasks.md`
- **完成条件**：tasks.md 中所有任务粒度合理（每条约 2-5 分钟一个 TDD 循环）
- **冷启动行为**：对话中无 BRAINSTORM 完成信号时，扫描 `docs/specs/` 下已有文件供用户选择；检测到已有 tasks.md 时询问覆盖或新建

#### 节点 2.5：CONTRACT（类型合约）【可选】

- **触发方式**：用户输入 `/viktor:contract`，或 ANALYZE 推荐后用户选择执行
- **加载 Skill**：`skills/07-type-contract/SKILL.md`
- **输入**：`docs/plans/YYYY-MM-DD--tasks.md`（优先）或 `docs/specs/YYYY-MM-DD--design.md`
- **输出**：`docs/contracts/YYYY-MM-DD--<feature>.types.ts`
- **完成条件**：用户明确确认类型结构
- **智能推荐**：ANALYZE 完成后，若检测到 `[api]`/`[hook]`/`[store]` 类型任务，自动建议执行本节点
- **冷启动行为**：对话中无 ANALYZE 完成信号时，扫描 tasks.md 供用户选择；已有合约文件时询问覆盖或追加

#### 节点 3：TDD（测试驱动开发）

- **触发方式**：用户输入 `/viktor:code`
- **加载 Skill**：`skills/03-tdd-cycle/SKILL.md`
- **输入**：`docs/plans/YYYY-MM-DD--tasks.md`
- **输出**：实现代码（`src/`）+ 测试文件（`__tests__/` 或 `*.test.ts`）
- **完成条件**：tasks.md 中所有任务均有对应测试，测试全部通过
- **冷启动行为**：对话中无 ANALYZE 完成信号时，列出所有 tasks.md 及完成度，全部完成的文件加警告；用户选择文件或选 N 重定向到 `/viktor:think`

#### 节点 4：REVIEW（代码审查）

- **触发方式**：用户输入 `/viktor:cr`
- **加载 Skill**：`skills/04-code-review/SKILL.md`
- **输入**：所有实现代码 + 测试文件 + `tasks.md`（+ `contracts/*.types.ts` 若存在）
- **输出**：`docs/reviews/YYYY-MM-DD--<feature>--review.md`
- **特别规则**：
  - 有 `[BLOCKING]` 问题 → 输出修复建议，提示返回 `/viktor:code`
  - 全部通过 → 提示进入 `/viktor:doc`
  - 若合约文件存在，执行第六检查轴（类型合约一致性）
- **冷启动行为**：对话中无 TDD 完成信号时，检查 tasks.md 未完成任务数并警告；已有 review.md 时询问是否覆盖

#### 节点 5：DOCUMENT（文档沉淀）

- **触发方式**：用户输入 `/viktor:doc`（前提：CR 已通过）
- **加载 Skill**：`skills/05-documentation/SKILL.md`
- **输入**：`design.md` + `tasks.md` + `review.md` + 所有代码
- **输出**：`docs/adrs/YYYY-MM-DD--<feature>--adr.md` + 更新活文档 + 更新 `CHANGELOG.md`
- **能力**：
  - **工作流变更检测**：自动检测本次是否修改了 `skills/` 或 `commands/`，若是则提示同步三端入口
  - **ADR 自动编号**：读取 `docs/adrs/` 文件数自动生成三位数编号（ADR-001、ADR-002 等）
  - **ADR 替代流程**：询问是否替代历史 ADR，用户指定编号后自动将旧 ADR 状态更新为 `已替代（见 ADR-XXX）`
  - **条件更新活文档**：根据变更类型更新 `component-catalog.md`、`api-catalog.md`、`architecture.md`、`adrs/README.md`
  - **digest 建议**：每次完成后在导航卡中固定提供 `/viktor:digest` 非阻塞选项，无需等到特定 ADR 数量
- **冷启动行为**：对话中无 REVIEW PASS 信号时，扫描 `docs/reviews/` 供用户选择；选中文件含 BLOCKING 时警告并确认

#### 节点 T：CONTEXT（项目快照）【工具节点，随时可用】

- **触发方式**：用户输入 `/viktor:context`（无前置条件）
- **加载 Skill**：`skills/08-context/SKILL.md`
- **输入**：5 个活文档（project-context / component-catalog / api-catalog / architecture / adrs/README）
- **输出**：格式化快照输出到对话（**不生成文件，不创建 commit**）
- **集成**：BRAINSTORM 开始时，若 `docs/project-context.md` 存在，自动提示用户可执行本命令

#### 节点 T+1：DIGEST（文档整合）【工具节点，随时可用】

- **触发方式**：用户输入 `/viktor:digest`（无前置条件），或响应 DOCUMENT 节点的非阻塞建议
- **加载 Skill**：`skills/09-digest/SKILL.md`
- **输入**：`docs/` 下所有文档（specs / plans / reviews / adrs / 活文档）
- **输出**：`docs/digest/YYYY-MM-DD--digest.md`（5 个必需章节）+ git commit

#### 节点 0：INIT（项目初始化）【首次接入时运行】

- **触发方式**：用户输入 `/viktor:init`
- **加载 Skill**：`skills/06-project-init/SKILL.md`
- **输入**：项目目录（`package.json` / `tsconfig.json` / 源码文件）
- **输出**：`docs/project-context.md`（项目知识地图）+ 4 个活文档骨架文件
- **幂等行为**：`project-context.md` 已存在时，询问"重新扫描更新"还是"仅补全缺失骨架"；活文档骨架已存在的文件一律跳过——**重复执行是安全的**

## 产物目录规范

所有文档产物统一放在 `docs/` 目录下：

```
docs/
├── project-context.md        # 项目知识地图（INIT 产物）
├── component-catalog.md      # 组件目录（INIT 初始化，DOCUMENT 持续更新）
├── api-catalog.md            # API 接口目录（INIT 初始化，DOCUMENT 持续更新）
├── architecture.md           # 架构决策速览（INIT 初始化，DOCUMENT 持续更新）
├── specs/                    # 设计文档（BRAINSTORM 产物）
│   └── YYYY-MM-DD--<feature>.md
├── plans/                    # 任务计划（ANALYZE 产物）
│   └── YYYY-MM-DD--<feature>--tasks.md
├── contracts/                # 类型合约（CONTRACT 产物，可选）
│   └── YYYY-MM-DD--<feature>.types.ts
├── reviews/                  # Code Review 报告（REVIEW 产物）
│   └── YYYY-MM-DD--<feature>--review.md
├── adrs/                     # 架构决策记录（DOCUMENT 产物）
│   ├── README.md             # ADR 索引（DOCUMENT 持续更新）
│   └── YYYY-MM-DD--<feature>--adr.md
└── digest/                   # 阶段性整合摘要（DIGEST 产物）
    └── YYYY-MM-DD--digest.md
```

文件命名规范：`YYYY-MM-DD--<feature-name>.<ext>`，使用双横线分隔日期和功能名。

## 全局编码规范

详见 `references/` 目录：

- `references/react-nextjs-conventions.md` — React/Next.js/TypeScript 编码规范
- `references/testing-patterns.md` — Vitest + RTL 测试模式与最佳实践
- `references/prd-input-template.md` — PRD 标准输入模板
- `references/living-docs-conventions.md` — 活文档体系规范（ADR 状态机制、更新原则、工作流同步规则）

在实现任何代码时，必须对照 `references/react-nextjs-conventions.md` 确认规范符合。

## AGENTS.md 与 SKILL.md 同步规则

修改 AGENTS.md 中任何节点的执行步骤时，必须对照对应的 `skills/0x-*/SKILL.md` 确认关键步骤没有遗漏。

AGENTS.md 是 Codex 的运行时指令，SKILL.md 是各节点的完整规范。两者描述同一套行为，AGENTS.md 是精简版，SKILL.md 是详细版，不能出现逻辑上的不一致。

对照顺序：
- BRAINSTORM → `skills/01-brainstorming/SKILL.md`
- ANALYZE → `skills/02-requirements-analysis/SKILL.md`
- CONTRACT → `skills/07-type-contract/SKILL.md`
- TDD → `skills/03-tdd-cycle/SKILL.md`
- REVIEW → `skills/04-code-review/SKILL.md`
- DOCUMENT → `skills/05-documentation/SKILL.md`
- CONTEXT → `skills/08-context/SKILL.md`
- DIGEST → `skills/09-digest/SKILL.md`

## Git Tag 发布规范

- **工作流变更**（skills/ 规则修改、scripts/ 脚本变更、节点行为调整、AGENTS.md / SKILL.md 更新）→ 先把 README.md 和 docs/team-workflow-guide.md 里的版本号改成新版本 → commit → 打 tag → push
- **文档修复**（错别字、说明补充、注意事项调整）→ 直接推 main，不打 tag

打 tag 前必须先更新文档版本号，确保 tag 内的文档引用的就是自身版本，不产生偏差。
