# 命令入口目录

> 由 `/viktor:init` 初始化，由 `/viktor:doc` 在每次需求完成后自动维护。
>
> **本仓库为 workflow meta 项目，此文件记录命令入口文件而非 API 路由。**

## 命令入口文件

每个命令由两层文件组成：
- **源文件**（`commands/viktor/<name>.md`）：命令的完整描述，含加载 Skill 的指令
- **平台入口**（`.claude/commands/viktor/<name>.md`）：仅一行内容，指向源文件路径

| 命令 | 源文件 | Claude Code 入口 | 状态 |
|------|-------|----------------|------|
| `/viktor:think` | `commands/viktor/think.md` | `.claude/commands/viktor/think.md` | ✅ |
| `/viktor:plan` | `commands/viktor/plan.md` | `.claude/commands/viktor/plan.md` | ✅ |
| `/viktor:contract` | `commands/viktor/contract.md` | `.claude/commands/viktor/contract.md` | ✅ |
| `/viktor:code` | `commands/viktor/code.md` | `.claude/commands/viktor/code.md` | ✅ |
| `/viktor:cr` | `commands/viktor/cr.md` | `.claude/commands/viktor/cr.md` | ✅ |
| `/viktor:doc` | `commands/viktor/doc.md` | `.claude/commands/viktor/doc.md` | ✅ |
| `/viktor:init` | `commands/viktor/init.md` | `.claude/commands/viktor/init.md` | ✅ |
| `/viktor:context` | `commands/viktor/context.md` | `.claude/commands/viktor/context.md` | ✅ |
| `/viktor:digest` | `commands/viktor/digest.md` | `.claude/commands/viktor/digest.md` | ✅ |

## 新增命令清单（操作步骤）

新增命令时需同步完成：
1. 创建 `skills/<编号>-<name>/SKILL.md`
2. 创建 `commands/viktor/<name>.md`（描述 + 加载 Skill 指令）
3. 创建 `.claude/commands/viktor/<name>.md`（单行路径指向 commands/）
4. 更新 `skills/using-fe-workflow/SKILL.md` 路由表
5. 同步 `CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc`
