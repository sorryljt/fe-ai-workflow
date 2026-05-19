# Changelog

本文件记录 fe-ai-workflow 的所有版本变更。
格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

---

## [Unreleased]

### Added

- **`/viktor:context` 节点**：只读项目快照命令，读取 5 个活文档并格式化输出到对话，无副作用，随时可用。文件缺失时给出说明而非报错。([ADR-003](docs/adrs/2026-05-19--context-digest-nodes--adr.md))
- **`/viktor:digest` 节点**：阶段性文档整合命令，读取 `docs/` 下所有文档，生成 `docs/digest/YYYY-MM-DD--digest.md`，包含项目状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题五个章节。([ADR-003](docs/adrs/2026-05-19--context-digest-nodes--adr.md))
- **`/viktor:context` 和 `/viktor:digest` 命令入口**：补全 `.claude/commands/viktor/context.md` 和 `digest.md`，两个命令现可在 Claude Code 命令列表中直接找到。([ADR-004](docs/adrs/2026-05-19--session-aware-confirmation--adr.md))

### Changed

- **BRAINSTORM 节点**：`/viktor:think` 执行第 1 步时，若 `docs/project-context.md` 存在，非阻塞提示用户可执行 `/viktor:context` 回顾项目现状。
- **DOCUMENT 节点**：`/viktor:doc` 完成后，自动检测 ADR 数量，若为 5 的倍数则非阻塞建议执行 `/viktor:digest`。
- **三端入口同步**：`CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` 全部新增 CONTEXT 和 DIGEST 节点定义；Cursor frontmatter description 更新。
- **元调度器**：`skills/using-fe-workflow/SKILL.md` 命令速查表 / Skill 映射表 / 自然语言路由表均新增两个节点。
- **会话感知冷启动检测**：ANALYZE / CONTRACT / TDD / REVIEW / DOCUMENT 五个节点均新增前置检测步骤。对话内连续执行（在流模式）零打扰；跨会话冷启动时自动扫描历史产物，展示完成状态，让用户明确选择操作目标或重定向到 `/viktor:think`。([ADR-004](docs/adrs/2026-05-19--session-aware-confirmation--adr.md))

---

## [0.4.0] - 2026-05-18

### Added

- **活文档体系**（5 文件 Markdown）：`/viktor:init` 新增第 6 步，在生成知识地图后自动创建 `docs/component-catalog.md`、`docs/api-catalog.md`、`docs/architecture.md`、`docs/adrs/README.md` 四个骨架文件（已存在则跳过）。
- **ADR 自动编号**：`/viktor:doc` 自动读取 `docs/adrs/` 文件数推算三位数编号（ADR-001、ADR-002 等），不再需要手动填写占位符。
- **ADR 替代流程**：`/viktor:doc` 询问本次是否替代历史 ADR，用户指定编号后自动将旧 ADR 状态字段更新为 `已替代（见 ADR-XXX）`。
- **ADR 状态机制**：ADR 模板新增四个合法状态：`草稿 / 已接受 / 已废弃 / 已替代（见 ADR-XXX）`，写入模板和 `references/living-docs-conventions.md`。
- **工作流自身变更检测**：`/viktor:doc` 第 1 步自动检测本次是否修改了 `skills/` 或 `commands/`，若是则输出专项提示，引导更新三端入口文件。
- **条件更新活文档**：`/viktor:doc` 新增第 4 步，根据变更类型有条件地更新 `component-catalog.md`、`api-catalog.md`、`architecture.md`、`adrs/README.md`。
- **活文档规范**：新增 `references/living-docs-conventions.md`，定义 5 文件职责、更新原则、ADR 状态机制、工作流同步规范、退化识别与修复指南。

### Changed

- **INIT 节点**：`skills/06-project-init/SKILL.md` 新增第 6 步，导航卡更新显示 5 个产物文件。
- **DOCUMENT 节点**：`skills/05-documentation/SKILL.md` 步骤重编号（原 4/5/6 步 → 5/6/7 步），新增第 4 步「条件更新活文档」。
- **三端入口同步**：`CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` 全部更新，包含 INIT 和 DOCUMENT 新能力描述及新产物目录。
- **版本号**：README.md 和 docs/team-workflow-guide.md 版本更新至 v0.4.0。

---

## [0.3.0] - 2026-05-18

### Added

- **CONTRACT 节点**（`/viktor:contract`）：新增可选的类型合约生成节点，位于 ANALYZE 和 TDD 之间。从 `tasks.md` 或 `design.md` 提取结构化 TypeScript 类型定义，输出 `docs/contracts/YYYY-MM-DD--<feature>.types.ts`，作为 TDD 实现和 REVIEW 检查的共享类型锚点。([ADR](docs/adrs/2026-05-18--contract-node--adr.md))
- **ANALYZE 智能推荐**：`/viktor:plan` 完成后，根据任务构成（是否含 `[api]`/`[hook]`/`[store]` 类型任务）自动给出是否建议执行 CONTRACT 的双路导航卡，用户最终决定。
- **REVIEW 第六检查轴**：在合约文件存在时，`/viktor:cr` 新增类型合约一致性检查（实现类型是否与合约一致、是否有未声明的新类型、API 类型是否匹配）。

### Changed

- **TDD 节点**：`/viktor:code` 进入任务循环前新增前置步骤，自动感知 `docs/contracts/` 目录，存在合约文件时在上下文中标注，引导实现时 import 合约类型。
- **工作流图**：全流程从五节点扩展为六节点（CONTRACT 为可选）：`think → plan → [contract] → code → cr → doc`。
- **三端入口同步**：`CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` / `skills/using-fe-workflow/SKILL.md` 全部更新，包含 CONTRACT 节点定义、命令路由和产物目录。
- **版本号**：README.md 和 docs/team-workflow-guide.md 版本更新至 v0.3.0。
