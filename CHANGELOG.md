# Changelog

本文件记录 fe-ai-workflow 的所有版本变更。
格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

---

## [Unreleased]

### Added

- **产物文档 YAML frontmatter**：`/viktor:think`、`/viktor:plan`、`/viktor:cr` 生成的文件现在包含机器可读的状态字段（specs: `status/confirmed_at`，plans: `status/spec`，reviews: `result/reviewed_at/plan`），DIGEST 优先读取 frontmatter，向后兼容无 frontmatter 的历史文件。([ADR-008](docs/adrs/2026-05-21--p2-workflow-polish--adr.md))
- **Workflow-Meta Lane 正式化**：`skills/using-fe-workflow/SKILL.md` 新增独立章节，定义修改工作流文件时的专用通道（无 TDD、grep 验收、每文件 commit、三端同步粒度规则）；`CLAUDE.md` 流程图注释同步引用。([ADR-008](docs/adrs/2026-05-21--p2-workflow-polish--adr.md))
- **TDD commit 粒度建议**：TDD SKILL commit 步骤新增三模式说明（每任务提交为默认推荐，里程碑提交为可选，全量一次性提交为不推荐），并说明 tasks.md 里程碑标记机制。([ADR-008](docs/adrs/2026-05-21--p2-workflow-polish--adr.md))

### Fixed

- **git diff 检测范围修正**：`/viktor:doc` 工作流变更检测从 `HEAD~1 HEAD` 改为 `$(git merge-base HEAD main) HEAD`，多 commit feature 分支中早期的 `skills/` 变更不再被漏检。([ADR-007](docs/adrs/2026-05-21--p1-stability-fixes--adr.md))
- **TDD 合约遗漏提醒**：tasks.md 含 `[api]`/`[hook]`/`[store]` 类型任务但无合约文件时，TDD 冷启动输出非阻塞提醒，帮助用户感知跳过了 CONTRACT 节点。([ADR-007](docs/adrs/2026-05-21--p1-stability-fixes--adr.md))
- **DIGEST 技术债务可见性**：`/viktor:digest` 现从 review 文件提取 `[SUGGESTED]` 条目归入新增的"已知技术债务"章节（第 6 节），技术债务不再在摘要中消失。([ADR-007](docs/adrs/2026-05-21--p1-stability-fixes--adr.md))
- **BRAINSTORM 更新模式上下文遗漏**：更新已有 spec 时不再跳过 step 1（读取 `docs/project-context.md`），确保基于最新项目上下文修改文档。([ADR-007](docs/adrs/2026-05-21--p1-stability-fixes--adr.md))
- **编码规范约束**：新增 `.editorconfig` 和 `.gitattributes`，统一 UTF-8 编码和 LF 换行符，消除 Windows 环境 CRLF 混入问题。([ADR-007](docs/adrs/2026-05-21--p1-stability-fixes--adr.md))

- **三端命令协议对齐**：`.cursor/rules/workflow.mdc` 中旧命令名（`/brainstorm`、`/analyze`、`/tdd`、`/review`）已统一更新为 `viktor:*` 协议，与 Claude Code 和 Codex 端保持一致。([ADR-006](docs/adrs/2026-05-20--p0-consistency-fixes--adr.md))
- **Cursor BRAINSTORM 策略对齐**：`workflow.mdc` 中 BRAINSTORM 步骤描述从"苏格拉底式逐个提问"更正为"批量最多 3 问"，与 SKILL.md 实际行为一致。([ADR-006](docs/adrs/2026-05-20--p0-consistency-fixes--adr.md))
- **技术栈去硬编码**：`workflow.mdc` 技术栈节不再写死 Next.js 14 版本，改为引用 `docs/project-context.md`（由 `/viktor:init` 生成）。([ADR-006](docs/adrs/2026-05-20--p0-consistency-fixes--adr.md))
- **REVIEW 框架名称统一**：`skills/04-code-review/SKILL.md` 内"五轴"全部更正为"六轴"（共 4 处：章节标题、step 3、验证清单、review 模板）。([ADR-006](docs/adrs/2026-05-20--p0-consistency-fixes--adr.md))
- **DIGEST 触发描述更正**：`skills/using-fe-workflow/SKILL.md` 命令速查表 digest 行从"ADR 累积到 5 的倍数"更正为"每次 DOCUMENT 完成后无条件触发"。([ADR-006](docs/adrs/2026-05-20--p0-consistency-fixes--adr.md))
- **CONTRACT 措辞修正**：`commands/viktor/contract.md` 第 5 节从"执行中 Hard Gate"重命名为"执行中约束（会话锁）"，避免与强制前置条件的"Hard Gate"概念混淆。([ADR-006](docs/adrs/2026-05-20--p0-consistency-fixes--adr.md))
- **DOCUMENT 活文档触发条件去框架专属**：`skills/05-documentation/SKILL.md` step 4 表格中"React 组件"改为"前端组件（React / Vue / Svelte 等）"，"Server Action"改为"接口函数"。([ADR-006](docs/adrs/2026-05-20--p0-consistency-fixes--adr.md))

### Added

- **`/viktor:context` 节点**：只读项目快照命令，读取 5 个活文档并格式化输出到对话，无副作用，随时可用。文件缺失时给出说明而非报错。([ADR-003](docs/adrs/2026-05-19--context-digest-nodes--adr.md))
- **`/viktor:digest` 节点**：阶段性文档整合命令，读取 `docs/` 下所有文档，生成 `docs/digest/YYYY-MM-DD--digest.md`，包含项目状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题五个章节。([ADR-003](docs/adrs/2026-05-19--context-digest-nodes--adr.md))
- **`/viktor:context` 和 `/viktor:digest` 命令入口**：补全 `.claude/commands/viktor/context.md` 和 `digest.md`，两个命令现可在 Claude Code 命令列表中直接找到。([ADR-004](docs/adrs/2026-05-19--session-aware-confirmation--adr.md))
- **DOCUMENT references 变更检测**：`/viktor:doc` 第 1 步新增 `references/` 变更检测，若规范文件有变更则输出映射表，提示确认相关 Skill 是否需要同步。([ADR-005](docs/adrs/2026-05-19--workflow-completeness-polish--adr.md))

### Changed

- **BRAINSTORM 节点**：新增冷启动前置检测——扫描 `docs/specs/` 已有文件，询问新建还是更新；支持 PRD 文档输入路径（引用 `prd-input-template.md`，自动跳过提问轮次）；新增"新项目建议先 `/viktor:init`"非阻塞提示。([ADR-005](docs/adrs/2026-05-19--workflow-completeness-polish--adr.md))
- **INIT 节点**：幂等化——`project-context.md` 已存在时询问"重新扫描"或"仅补全缺失骨架"，重复执行安全；`CLAUDE.md` 新增 INIT 节点独立说明块。([ADR-005](docs/adrs/2026-05-19--workflow-completeness-polish--adr.md))
- **DOCUMENT 节点**：`/viktor:doc` 完成后，导航卡固定提供 `/viktor:digest` 非阻塞选项，不再依赖 ADR 数量倍数条件。([ADR-005](docs/adrs/2026-05-19--workflow-completeness-polish--adr.md))
- **CONTRACT / REVIEW 节点**：冷启动单文件场景"直接使用"逻辑明文化，消除隐含行为。([ADR-005](docs/adrs/2026-05-19--workflow-completeness-polish--adr.md))
- **三端入口同步**：`CLAUDE.md` / `AGENTS.md` / `.cursor/rules/workflow.mdc` 同步以上所有变更。
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
