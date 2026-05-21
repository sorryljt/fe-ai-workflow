# 项目知识地图

**生成日期**：2026-05-19
**最后更新**：2026-05-21

> 此文件由 /viktor:init 命令生成，供工作流所有节点共享。
> 本仓库为 **workflow meta 项目**（非业务项目），无 src/ 代码，无可运行测试。
> 所有"实现"均为 Skill 规则文件（.md）和命令入口文件，验收方式为内容自审 + 跨文件一致性核查。

## 项目性质

| 属性 | 值 |
|------|-----|
| 项目类型 | AI 开发工作流配置库（workflow meta repo） |
| 用途 | 以 git submodule 方式接入业务项目，为 Claude Code / Cursor / Codex 提供标准化工作流 |
| 当前版本 | v0.5.0（见 README.md） |
| 兼容平台 | Claude Code（CLAUDE.md）/ OpenAI Codex（AGENTS.md）/ Cursor（.cursor/rules/workflow.mdc） |

## 目录结构

```
fe-ai-workflow/
├── CLAUDE.md                    # Claude Code 入口：节点定义、产物规范、全局约定
├── AGENTS.md                    # Codex 入口：节点触发规则、精简版执行步骤
├── .cursor/rules/workflow.mdc   # Cursor 入口：节点路由规则
├── CHANGELOG.md                 # 版本变更记录
├── commands/viktor/             # 命令源文件（各 AI 平台共享）
│   └── think / plan / contract / code / cr / doc / init / context / digest
├── .claude/commands/viktor/     # Claude Code 专用命令入口（指向 commands/viktor/）
├── skills/                      # 各节点 Skill 规范（核心内容）
│   ├── using-fe-workflow/       # 元调度器：意图路由 + 命令速查
│   ├── 01-brainstorming/        # BRAINSTORM 节点
│   ├── 02-requirements-analysis/# ANALYZE 节点
│   ├── 03-tdd-cycle/            # TDD 节点
│   ├── 04-code-review/          # REVIEW 节点
│   ├── 05-documentation/        # DOCUMENT 节点
│   ├── 06-project-init/         # INIT 节点
│   ├── 07-type-contract/        # CONTRACT 节点
│   ├── 08-context/              # CONTEXT 工具节点
│   └── 09-digest/               # DIGEST 工具节点
├── references/                  # 外部规范参考文档（供 Skill 引用）
│   ├── react-nextjs-conventions.md
│   ├── testing-patterns.md
│   ├── prd-input-template.md
│   └── living-docs-conventions.md
├── docs/                        # 工作流自身的产物文档
│   ├── project-context.md       # 本文件
│   ├── architecture.md          # 架构决策速览
│   ├── adrs/                    # ADR 记录（目前 4 个）
│   ├── specs/                   # 需求设计文档
│   ├── plans/                   # 任务列表
│   ├── reviews/                 # CR 报告
│   └── team-workflow-guide.md   # 团队使用指南
├── examples/                    # 示例文件（供参考）
└── scripts/                     # 安装/升级脚本
    ├── sync-workflow.sh
    └── upgrade-workflow.sh
```

## 工作流节点清单

| 命令 | Skill 文件 | 功能 |
|------|-----------|------|
| `/viktor:think` | `skills/01-brainstorming/SKILL.md` | 需求澄清，输出 docs/specs/ |
| `/viktor:plan` | `skills/02-requirements-analysis/SKILL.md` | 需求分析拆任务，输出 docs/plans/ |
| `/viktor:contract` | `skills/07-type-contract/SKILL.md` | 类型合约生成（可选），输出 docs/contracts/ |
| `/viktor:code` | `skills/03-tdd-cycle/SKILL.md` | TDD 实现循环 |
| `/viktor:cr` | `skills/04-code-review/SKILL.md` | 六轴代码审查，输出 docs/reviews/ |
| `/viktor:doc` | `skills/05-documentation/SKILL.md` | ADR + 活文档沉淀，输出 docs/adrs/ |
| `/viktor:init` | `skills/06-project-init/SKILL.md` | 项目知识地图初始化 |
| `/viktor:context` | `skills/08-context/SKILL.md` | 只读项目快照（工具节点） |
| `/viktor:digest` | `skills/09-digest/SKILL.md` | 阶段性文档整合（工具节点） |

## 关键约定

**文件命名**：
- 产物文档：`YYYY-MM-DD--<feature-name>.<ext>`（双横线分隔日期和功能名）
- Skill 文件：`skills/<编号>-<name>/SKILL.md`（两位数编号前缀）

**三端同步规则**：
- 修改任何节点行为时，必须同步更新 CLAUDE.md / AGENTS.md / .cursor/rules/workflow.mdc
- CLAUDE.md 为主，AGENTS.md 为精简版，workflow.mdc 为 Cursor 格式版

**版本发布规则**：
- 工作流行为变更（Skill / 命令修改）→ 更新版本号 → commit → 打 git tag → push
- 纯文档修复 → 直接推 main，不打 tag

**任务类型（本仓库专用）**：
- `[skill]` — Skill 规则文件修改
- `[command]` — 命令入口文件
- `[config]` — 配置文件修改（CLAUDE.md / AGENTS.md）
- `[sync]` — 多端同步（三端一致性更新）

## 设计约束

- 本仓库无业务代码，所有任务验收方式为内容自审 + 跨文件一致性核查，无可运行测试
- 修改 Skill 步骤后必须对照 CLAUDE.md 中对应节点的冷启动行为描述确认一致
- 新增节点时需同步更新：Skill 文件 + 命令文件（commands/ 和 .claude/commands/）+ 三端入口 + using-fe-workflow/SKILL.md 路由表
- ADR 自动编号：读取 docs/adrs/ 下 .md 文件数（排除 README.md）+1
