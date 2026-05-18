# Changelog

本文件记录 fe-ai-workflow 的所有版本变更。
格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

---

## [Unreleased]

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
