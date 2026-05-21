---
feature: p4-codex-review-fixes
date: 2026-05-21
status: completed
spec: docs/specs/2026-05-21--p4-codex-review-fixes.md
---

# P4 Codex Review 修复批次 任务列表

**日期**：2026-05-21
**关联设计**：[docs/specs/2026-05-21--p4-codex-review-fixes.md](../specs/2026-05-21--p4-codex-review-fixes.md)
**总任务数**：6（P0: 1, P1: 3, P2: 2）
**改动性质**：Workflow-Meta（文档/配置修改，无可运行代码，以 grep 验收替代 TDD）

## 功能概述

响应 Codex 对 fe-ai-workflow 的独立审查建议，修复 6 处遗留问题：
文档旧文案、三端概念半暴露、路径格式漂移、frontmatter 缺失、环境要求不明确、日期未更新。

## 任务列表

### P0 核心任务

#### T01：在 README 和 team-workflow-guide 中新增 validate-workflow.sh 介绍 [config]

- **描述**：`validate-workflow.sh` 目前在两份面向用户的文档中完全未提及，T01 需新增介绍段落（含运行环境要求：Git Bash / WSL）
- **文件路径**：
  - `README.md` — 在"更新 workflow 版本"节后新增"三端一致性验证"小节
  - `docs/team-workflow-guide.md` — 在升级脚本说明附近新增对应说明
- **验收标准**：
  - [ ] README 含 `validate-workflow.sh` 用法说明和 Git Bash / WSL 环境要求
  - [ ] team-workflow-guide 含同等说明
  - [ ] `grep -n "validate-workflow" README.md` 有输出
  - [ ] `grep -n "Git Bash\|WSL" README.md` 有输出
- **依赖**：无

### P1 主要任务

#### T02：修复 team-workflow-guide 中"5 的倍数"旧描述 [config]

- **描述**：第 134 行和第 152 行仍写"ADR 累积到 5 的倍数才建议 digest"，与 ADR-005/P0 批次已更正的行为不符
- **文件路径**：`docs/team-workflow-guide.md`
- **验收标准**：
  - [ ] `grep -n "5 的倍数\|倍数" docs/team-workflow-guide.md` 无输出
  - [ ] 替换后文案为"每次 DOCUMENT 完成后导航卡固定提供 `/viktor:digest` 选项"
- **依赖**：无

#### T03：在 AGENTS.md 和 workflow.mdc 补充 Workflow-Meta Lane [sync]

- **描述**：Workflow-Meta Lane 已在 CLAUDE.md 和 using-fe-workflow/SKILL.md 正式定义，但 AGENTS.md 和 workflow.mdc 均无对应说明，造成三端概念半暴露
- **文件路径**：
  - `AGENTS.md` — 在 DOCUMENT 节点后、"核心约束"节前新增 `### Workflow-Meta Lane` 块
  - `.cursor/rules/workflow.mdc` — 在 DIGEST 节点后、"产物目录规范"节前新增 `### Workflow-Meta Lane` 块
- **验收标准**：
  - [ ] `grep -n "Workflow-Meta" AGENTS.md` 有输出
  - [ ] `grep -n "Workflow-Meta" .cursor/rules/workflow.mdc` 有输出
  - [ ] 两处内容语义与 CLAUDE.md 中的描述一致（跳过 TDD、grep 验收、每文件 commit）
- **依赖**：无

#### T04：为 P3 的 spec 和 plan 补写 YAML frontmatter [config]

- **描述**：P2 批次已更新 BRAINSTORM/ANALYZE 产物模板，但 P3 执行时两份文件漏写 frontmatter，是模板改完后第一批漏网产物
- **文件路径**：
  - `docs/specs/2026-05-21--p3-framework-agnostic.md` — 顶部插入 frontmatter
  - `docs/plans/2026-05-21--p3-framework-agnostic--tasks.md` — 顶部插入 frontmatter
- **验收标准**：
  - [ ] `head -6 docs/specs/2026-05-21--p3-framework-agnostic.md` 含 `feature:` / `status: confirmed`
  - [ ] `head -6 docs/plans/2026-05-21--p3-framework-agnostic--tasks.md` 含 `feature:` / `status: completed`
- **依赖**：无

### P2 优化任务

#### T05：统一三处路径占位格式 [skill] + [config]

- **描述**：三处文件中的旧写法 `YYYY-MM-DD--review.md`（缺少 `<feature>` 段）与实际产物命名规范不符
- **文件路径**：
  - `skills/05-documentation/SKILL.md:59` — `docs/reviews/YYYY-MM-DD--review.md` → `docs/reviews/YYYY-MM-DD--<feature>--review.md`
  - `.cursor/rules/workflow.mdc:102` — 同上
  - `docs/team-workflow-guide.md:130` — 同上
- **验收标准**：
  - [ ] `grep -rn "YYYY-MM-DD--review\.md" skills/ .cursor/ docs/team-workflow-guide.md` 无输出
  - [ ] 三处均已更新为 `YYYY-MM-DD--<feature>--review.md`
- **依赖**：无

#### T06：更新 team-workflow-guide 日期并清理过时内容 [config]

- **描述**：文档头部日期仍为 2026-05-19（v0.7.0 发布日），当前版本 v0.8.0，日期应更新
- **文件路径**：`docs/team-workflow-guide.md`
- **验收标准**：
  - [ ] 第 4 行日期改为 `2026-05-21`
  - [ ] `grep -n "2026-05-19" docs/team-workflow-guide.md` 无输出（日期行）
- **依赖**：T02（同文件，合并修改避免冲突）

## 验收总结

- [x] T01：README 和 team-workflow-guide 均有 validate-workflow.sh 说明及环境要求
- [x] T02：team-workflow-guide 中无"5 的倍数"字样
- [x] T03：AGENTS.md 和 workflow.mdc 均有 Workflow-Meta Lane 块
- [x] T04：P3 spec 和 plan 有合法 YAML frontmatter
- [x] T05：三处路径占位格式统一
- [x] T06：team-workflow-guide 日期为 2026-05-21
- [ ] `bash scripts/validate-workflow.sh` 仍 37/37 PASS
