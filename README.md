# fe-ai-workflow

> 前端团队 AI 辅助开发标准工作流，兼容 Claude Code、Cursor、OpenAI Codex。

## 核心理念

本工作流融合三个层次的思想：

- **[obra/superpowers](https://github.com/obra/superpowers)** 的调度机制：Skill-First 原则、1% 规则、流程编排哲学
- **[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)** 的工程规范：每个节点的具体工程实践内容骨架
- **前端特化**：针对 React / Next.js / TypeScript / Vitest 的具体规范和测试模式

**核心原则**：AI 先调度，再执行。没有设计文档，不开始编码。没有失败的测试，不写实现代码。

## 快速开始

### 首次接入新项目

> **必须在业务项目根目录下执行**（即用 Claude Code / Cursor 打开的那个目录）。
> 若结构为 `mywork/business-project/`，先 `cd mywork/business-project` 再执行。
> 在上层目录安装会导致 `/viktor:*` 命令不可用。

```bash
# 1. 引入 workflow 仓库并锁定版本
git submodule add https://github.com/sorryljt/fe-ai-workflow.git .workflow/fe-ai-workflow
cd .workflow/fe-ai-workflow && git checkout v0.8.0 && cd ../..

# 2. 同步入口文件到项目根目录
./.workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow .

# 3. 将 postinstall 写入 package.json（之后 npm install 会自动同步）
npm pkg set scripts.postinstall=".workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow . || true"

# 4. 提交
git add .gitmodules .workflow/fe-ai-workflow package.json
git commit -m "chore: add fe-ai-workflow v0.8.0"
```

同步后，各 AI 工具会自动读取对应的入口文件：

| 工具 | 入口文件 | 命令格式 |
|------|---------|---------|
| Claude Code | 根目录 `CLAUDE.md` | `/viktor:*` |
| OpenAI Codex | 根目录 `AGENTS.md` | `viktor:*`（不加前导 `/`） |
| Cursor | `.cursor/rules/workflow.mdc` | `viktor:*` |

> Codex 说明：`viktor:*` 不依赖平台命令面板，直接发送文本即可触发节点，也兼容自然语言路由（如"先做需求澄清"）。

### 克隆已接入 workflow 的项目（新成员）

```bash
git clone --recurse-submodules <项目地址>
cd <项目目录>
npm install
```

`postinstall` 会自动完成同步，无需额外操作。

### 安装后第一步

**推荐**：先执行 `/viktor:init`，扫描项目结构并生成知识地图，再开始需求。尤其适合已有大量代码（组件库、现有 API、Hooks）的项目——提前建立知识地图，后续每次 BRAINSTORM 都能复用，避免重复探索。

> `/viktor:init` 支持幂等执行，重复运行不会覆盖已有内容，安全。

如果跳过 init 直接执行 `/viktor:think <需求描述>`，工作流会在 BRAINSTORM 开始前自动触发一次基础扫描，适合快速上手的场景。

### 更新 workflow 版本

```bash
.workflow/fe-ai-workflow/scripts/upgrade-workflow.sh <新版本tag>
```

### 验证三端一致性

workflow 提供了一个自动化验证脚本，检查 9 个 `viktor:*` 命令在三端入口文件（CLAUDE.md / AGENTS.md / workflow.mdc）中的存在性，以及 10 个 Skill 文件是否存在于磁盘，共 37 项检查：

```bash
bash scripts/validate-workflow.sh
```

> **运行环境**：脚本需在 **Git Bash 或 WSL** 下执行，不支持 PowerShell。
> Windows 用户：右键项目目录 → "Git Bash Here"，再运行上述命令。

输出示例：

```
[PASS] CLAUDE.md 包含 viktor:think
[PASS] AGENTS.md 包含 viktor:think
...
37/37 checks passed
```

每次修改三端入口文件后运行，确保命令名称未遗漏。

## 工作流说明

```
/viktor:think → /viktor:plan → [/viktor:contract] → /viktor:code → /viktor:cr → /viktor:doc
```

> `[/viktor:contract]` 为可选节点，由 `/viktor:plan` 根据任务构成智能推荐。
> 工具节点（随时可用）：`/viktor:context` 查看项目快照 / `/viktor:digest` 生成阶段性整合文档

| 命令 | 阶段 | 节点作用 | 输入 |
|------|------|---------|------|
| `/viktor:init` | 项目初始化 | 扫描项目结构，生成知识地图和活文档骨架；让后续每个节点都能读取项目上下文，而不是每次重新探索 | 现有项目代码结构 |
| `/viktor:think` | 需求澄清 | 把模糊需求转成结构化设计文档，明确方案对比、假设声明和可测试验收标准；没有此产物不能开始拆任务 | 模糊需求/想法 |
| `/viktor:plan` | 需求分析 | 把设计文档拆成粒度合适的任务列表（每条约 2-5 分钟一个 TDD 循环），并自动评估是否需要生成类型合约 | design.md 或 PRD |
| `/viktor:contract` | 类型合约（可选） | 在编码前将接口/Hook/Store 类型固化为可 import 的 `.types.ts` 文件，消除节点间类型漂移；ANALYZE 检测到 API/Hook/Store 任务时会主动推荐 | tasks.md 或 design.md |
| `/viktor:code` | 测试驱动开发 | 强制先写测试再写实现，确保每个任务都有可验证的测试用例；RED → GREEN → REFACTOR 循环 | tasks.md |
| `/viktor:cr` | 代码审查 | 按六轴框架（正确性/可维护性/性能/安全性/测试质量/类型合约一致性）系统审查，输出结构化报告，BLOCKING 问题必须修复才能继续 | 代码 + tasks.md |
| `/viktor:doc` | 文档沉淀 | 生成 ADR（自动编号、支持替代历史决策），更新活文档（组件目录/接口目录/架构速览/ADR 索引），更新 CHANGELOG；检测到工作流自身变更或 `references/` 规范变更时分别提示同步；完成后导航卡固定提供 `/viktor:digest` 可选入口 | 所有产物 |
| `/viktor:context` | 项目快照（工具节点） | 读取 5 个活文档并格式化输出到对话；随时可用，无副作用；BRAINSTORM 开始时若知识地图存在会非阻塞提示 | 5 个活文档 |
| `/viktor:digest` | 文档整合（工具节点） | 读取 docs/ 下所有文档，生成阶段性摘要，包含：项目状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题 | docs/ 下所有文档 |

每个节点的详细执行规范见 `skills/` 目录下对应的 SKILL.md。

## 产物目录结构

```
docs/
├── project-context.md      # 项目知识地图（/viktor:init 产物，持续更新）
├── component-catalog.md    # 组件目录（/viktor:init 初始化，/viktor:doc 持续更新）
├── api-catalog.md          # API 接口目录（/viktor:init 初始化，/viktor:doc 持续更新）
├── architecture.md         # 架构决策速览（/viktor:init 初始化，/viktor:doc 持续更新）
├── specs/                  # 设计文档（/viktor:think 产物）
│   └── 2026-01-15--user-auth.md
├── plans/                  # 任务计划（/viktor:plan 产物）
│   └── 2026-01-15--user-auth--tasks.md
├── contracts/              # 类型合约（/viktor:contract 产物，可选）
│   └── 2026-01-15--user-auth.types.ts
├── reviews/                # Code Review 报告（/viktor:cr 产物）
│   └── 2026-01-15--user-auth--review.md
├── adrs/                   # 架构决策记录（/viktor:doc 产物）
│   ├── README.md           # ADR 索引（/viktor:doc 持续更新）
│   └── 2026-01-15--user-auth--adr.md
└── digest/                 # 阶段性整合摘要（/viktor:digest 产物）
    └── 2026-01-15--digest.md
```

## 目录说明

```
fe-ai-workflow/
├── CLAUDE.md                    # Claude Code 配置入口
├── AGENTS.md                    # OpenAI Codex 配置入口
├── .cursor/rules/workflow.mdc   # Cursor Rules
├── skills/                      # 工作流技能文件
│   ├── using-fe-workflow/       # 元调度器（必读）
│   ├── 06-project-init/         # 项目知识地图初始化
│   ├── 01-brainstorming/        # 需求澄清
│   ├── 02-requirements-analysis/ # 任务拆分
│   ├── 07-type-contract/        # 类型合约（可选节点）
│   ├── 03-tdd-cycle/            # TDD 循环
│   ├── 04-code-review/          # 代码审查
│   ├── 05-documentation/        # 文档沉淀
│   ├── 08-context/              # 项目快照（工具节点）
│   └── 09-digest/               # 文档整合（工具节点）
├── references/                  # 编码规范参考
│   ├── react-nextjs-conventions.md
│   ├── testing-patterns.md
│   ├── prd-input-template.md
│   └── living-docs-conventions.md  # 活文档体系规范
├── commands/                    # 快捷命令说明
│   └── viktor/
│       ├── init.md / think.md / plan.md / contract.md
│       ├── code.md / cr.md / doc.md
│       └── context.md / digest.md
└── examples/                    # 工作流产物示例
```

## 常见问题

**Q：工作流运行后会产生大量文档，会拖慢 AI 的上下文吗？**

不会。`docs/` 目录下的文件不会自动进入上下文，只在 Skill 步骤中被显式读取时才加载。每条命令只加载当次需要的文件（通常 1-2 个），不会累积。文档积累多了之后，定期运行一次 `/viktor:digest`，会把所有历史文档压缩成一个摘要文件，后续会话读摘要而不是读所有原始文件，保持上下文轻量。

**Q：我的项目不用 React / Next.js，也能用这套工作流吗？**

可以。工作流是框架无关的。`/viktor:init` 会自动探测项目的 `package.json`，将实际技术栈写入 `docs/project-context.md`，后续所有节点读取这个文件而非硬编码框架。TDD 节点内置框架 → 测试工具对照表（React / Vue / Svelte / 其他），非 React 项目按对应工具类比执行即可。

**Q：CONTRACT 节点和 REVIEW 节点是必须执行的吗？**

不是。CONTRACT 是可选节点，适合有明确 API / Hook / Store 边界的功能；ANALYZE 完成后会根据任务构成自动推荐，用户决定是否执行。REVIEW 节点理论上应在 TDD 完成后执行，但对于小改动或工作流自身的 meta 修改，可以酌情跳过直接进入 DOCUMENT。

**Q：我只用 Claude Code，不用 Cursor 或 Codex，需要维护三端文件吗？**

不需要额外维护。`sync-workflow.sh` 会自动同步三端文件，不产生额外负担。三端文件的存在不影响 Claude Code 的使用，且当团队将来引入其他 AI 工具时无需迁移。

**Q：已有历史代码的项目也能接入吗？**

可以。`/viktor:init` 会扫描项目现有的 `package.json`、`tsconfig.json` 和目录结构，生成项目知识地图，不修改任何业务代码。接入后，从下一个新功能开始按工作流执行即可，存量代码无需补写文档或测试。

## 贡献指南

1. **新增 Skill**：需同步完成以下步骤——
   - 在 `skills/<编号>-<name>/` 下创建 `SKILL.md`（frontmatter 含 name/description）
   - 创建 `commands/viktor/<name>.md`（命令描述 + 加载 Skill 指令）
   - 创建 `.claude/commands/viktor/<name>.md`（单行内容，指向 `../../../commands/viktor/<name>.md`）
   - 更新 `skills/using-fe-workflow/SKILL.md` 命令速查表和路由表
   - 同步 `CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` 节点定义
2. **修改规范**：修改 `references/` 下的对应文件，在 PR 描述中说明修改原因；同时检查引用该文件的 Skill 是否需要同步更新
3. **添加示例**：在 `examples/` 下添加真实项目的工作流产物，帮助新成员理解产物质量标准
4. **提交格式**：`feat/fix/docs/nit: 简短描述`

每次修改 Skill 后，请用一个最小示例验证 Skill 按预期工作后再合并。

## 团队试点

详见 [`docs/team-workflow-guide.md`](docs/team-workflow-guide.md)，包含背景、安装步骤、平台差异、命令说明与反馈入口。
