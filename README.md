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
git submodule add git@git.hzfapi.com:lijiangtao/fe-ai-workflow.git .workflow/fe-ai-workflow
cd .workflow/fe-ai-workflow && git checkout v0.2.9 && cd ../..

# 2. 同步入口文件到项目根目录
./.workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow .

# 3. 将 postinstall 写入 package.json（之后 npm install 会自动同步）
npm pkg set scripts.postinstall=".workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow . || true"

# 4. 提交
git add .gitmodules .workflow/fe-ai-workflow package.json
git commit -m "chore: add fe-ai-workflow v0.2.9"
```

同步后，各 AI 工具会自动读取对应的入口文件：

| 工具 | 入口文件 | 命令格式 |
|------|---------|---------|
| Claude Code | 根目录 `CLAUDE.md` | `/viktor:*` |
| OpenAI Codex | 根目录 `AGENTS.md` | `viktor:*`（不加前导 `/`） |
| Cursor | `.cursor/rules/workflow.mdc` | `viktor:*` |

> Codex 说明：`viktor:*` 不依赖平台命令面板，直接发送文本即可触发节点，也兼容自然语言路由（如”先做需求澄清”）。

### 克隆已接入 workflow 的项目（新成员）

```bash
git clone --recurse-submodules <项目地址>
cd <项目目录>
npm install
```

`postinstall` 会自动完成同步，无需额外操作。

### 安装后第一步

直接用 `/viktor:think <需求描述>` 开始第一个需求即可。

如果项目知识地图（`docs/project-context.md`）不存在，工作流会在 BRAINSTORM 开始前自动扫描项目并生成，无需手动执行 `/viktor:init`。

> 也可以提前手动执行 `/viktor:init`，适合想先了解项目结构再开始需求的场景。

### Windows 安装

> **前提**：需要安装 [Git for Windows](https://git-scm.com/download/win)。安装时勾选默认选项，安装完成后**重新打开终端**使 PATH 生效。

Windows 用户有两种方式，推荐优先使用 Git Bash。

#### 方式一：Git Bash（推荐）

Git for Windows 安装后，在项目根目录右键 → **Git Bash Here** 打开 Git Bash 终端，执行与 macOS/Linux 完全相同的命令。

唯一差异：`postinstall` 需要加 `bash` 前缀：

```bash
npm pkg set scripts.postinstall="bash .workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow . || true"
```

#### 方式二：PowerShell

`&&` 在旧版 PowerShell 不可用，`.sh` 脚本需要通过 `bash` 调用：

```powershell
# 1. 引入 workflow 仓库并锁定版本
git submodule add git@git.hzfapi.com:lijiangtao/fe-ai-workflow.git .workflow/fe-ai-workflow
cd .workflow/fe-ai-workflow
git checkout v0.2.9
cd ../..

# 2. 同步入口文件到项目根目录
bash .workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow .

# 3. 将 postinstall 写入 package.json
npm pkg set scripts.postinstall="bash .workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow . || true"

# 4. 提交
git add .gitmodules .workflow/fe-ai-workflow package.json
git commit -m "chore: add fe-ai-workflow v0.2.9"
```

升级版本同理：

```powershell
bash .workflow/fe-ai-workflow/scripts/upgrade-workflow.sh v0.2.9
```

> **`bash` 无法识别？** 有两种原因：
> 1. Git for Windows 未安装 → 先安装，安装后**重新打开 PowerShell**
> 2. 已安装但 PATH 未生效 → 在 PowerShell 中运行以下命令将 Git Bash 临时加入 PATH，然后重试：
>    ```powershell
>    $env:PATH += ";C:\Program Files\Git\bin"
>    ```
>    若想永久生效，在系统环境变量中将 `C:\Program Files\Git\bin` 加入 Path。

### 更新 workflow 版本

```bash
.workflow/fe-ai-workflow/scripts/upgrade-workflow.sh v0.2.9
```

## 工作流说明

```
/viktor:think → /viktor:plan → /viktor:code → /viktor:cr → /viktor:doc
```

| 命令 | 阶段 | 输入 | 输出 |
|------|------|------|------|
| `/viktor:init` | 项目初始化 | 现有项目代码结构 | `docs/project-context.md` |
| `/viktor:think` | 需求澄清 | 模糊需求/想法 | `docs/specs/YYYY-MM-DD--design.md` |
| `/viktor:plan` | 需求分析 | design.md 或 PRD | `docs/plans/YYYY-MM-DD--tasks.md` |
| `/viktor:code` | 测试驱动开发 | tasks.md | 代码 + 测试 |
| `/viktor:cr` | 代码审查 | 代码 + tasks.md | `docs/reviews/YYYY-MM-DD--review.md` |
| `/viktor:doc` | 文档沉淀 | 所有产物 | `docs/adrs/YYYY-MM-DD--adr.md` |

> 旧的 `/brainstorm`、`/analyze`、`/tdd`、`/review`、`/document` 仅作为历史说明保留，不再作为对外入口。

每个节点的详细执行规范见 `skills/` 目录下对应的 SKILL.md。

## 产物目录结构

```
docs/
├── project-context.md # 项目知识地图（/viktor:init 产物）
├── specs/          # 设计文档（/viktor:think 产物）
│   └── 2026-01-15--user-auth.md
├── plans/          # 任务计划（/viktor:plan 产物）
│   └── 2026-01-15--user-auth--tasks.md
├── reviews/        # Code Review 报告（/viktor:cr 产物）
│   └── 2026-01-15--user-auth--review.md
└── adrs/           # 架构决策记录（/viktor:doc 产物）
    └── 2026-01-15--user-auth--adr.md
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
│   ├── 03-tdd-cycle/            # TDD 循环
│   ├── 04-code-review/          # 代码审查
│   └── 05-documentation/        # 文档沉淀
├── references/                  # 编码规范参考
│   ├── react-nextjs-conventions.md
│   ├── testing-patterns.md
│   └── prd-input-template.md
├── commands/                    # 快捷命令说明
│   ├── init.md
│   ├── think.md
│   ├── plan.md
│   ├── code.md
│   ├── cr.md
│   └── doc.md
└── examples/                    # 工作流产物示例
```

## 贡献指南

1. **新增 Skill**：在 `skills/` 下创建新目录，遵循现有 SKILL.md 的 frontmatter 格式（name/description/触发条件）
2. **修改规范**：修改 `references/` 下的对应文件，在 PR 描述中说明修改原因
3. **添加示例**：在 `examples/` 下添加真实项目的工作流产物，帮助新成员理解产物质量标准
4. **提交格式**：`docs/feat/fix: 简短描述`

每次修改 Skill 后，请用一个最小示例验证 Skill 按预期工作后再合并。

## 团队试点

详见 [`docs/team-workflow-guide.md`](docs/team-workflow-guide.md)，包含背景、安装步骤、平台差异、命令说明与反馈入口。
