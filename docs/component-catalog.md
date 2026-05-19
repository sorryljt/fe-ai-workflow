# Skill 目录

> 由 `/viktor:init` 初始化，由 `/viktor:doc` 在每次需求完成后自动维护。
> 新增 Skill 前先查阅此目录，避免重复定义节点。
>
> **本仓库为 workflow meta 项目，此文件记录工作流节点（Skill）而非 UI 组件。**

## 主流程节点

| 命令 | Skill 文件 | 节点作用 | 引入版本 |
|------|-----------|---------|---------|
| `/viktor:think` | `skills/01-brainstorming/SKILL.md` | 需求澄清，苏格拉底式提问，输出 specs/ 设计文档；含冷启动检测（检测已有 spec）、PRD 输入路径 | v0.1.0 |
| `/viktor:plan` | `skills/02-requirements-analysis/SKILL.md` | 需求分析拆任务，输出 plans/ 任务列表，智能推荐 CONTRACT | v0.1.0 |
| `/viktor:contract` | `skills/07-type-contract/SKILL.md` | 可选类型合约生成，输出 contracts/ .types.ts | v0.3.0 |
| `/viktor:code` | `skills/03-tdd-cycle/SKILL.md` | TDD 红绿重构循环，会话感知冷启动检测 | v0.1.0 |
| `/viktor:cr` | `skills/04-code-review/SKILL.md` | 六轴代码审查（含类型合约一致性轴），输出 reviews/ | v0.1.0 |
| `/viktor:doc` | `skills/05-documentation/SKILL.md` | ADR 自动编号/替代流程，活文档条件更新，CHANGELOG | v0.1.0 |
| `/viktor:init` | `skills/06-project-init/SKILL.md` | 项目知识地图扫描，生成 project-context.md 和活文档骨架；幂等执行（重复运行安全） | v0.1.0 |

## 工具节点（随时可用）

| 命令 | Skill 文件 | 节点作用 | 引入版本 |
|------|-----------|---------|---------|
| `/viktor:context` | `skills/08-context/SKILL.md` | 只读项目快照，读取 5 个活文档格式化输出，无副作用 | v0.5.0 |
| `/viktor:digest` | `skills/09-digest/SKILL.md` | 阶段性文档整合，生成 digest/ 摘要 + commit | v0.5.0 |

## 元调度器

| 文件 | 作用 |
|------|------|
| `skills/using-fe-workflow/SKILL.md` | 命令速查表、意图路由、Skill 映射，每次对话开始时加载 |
