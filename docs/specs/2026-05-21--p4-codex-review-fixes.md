---
feature: p4-codex-review-fixes
date: 2026-05-21
status: confirmed
confirmed_at: 2026-05-21
---

# P4 Codex Review 修复批次 设计文档

**日期**：2026-05-21
**状态**：已确认
**来源**：Codex 对 fe-ai-workflow 的分析建议（6 条）

> **设计假设**：
> 1. T04 只回填 P3 的 spec/plan（模板改完后第一批漏网）；P0~P2 历史产物不回填
> 2. T03 Workflow-Meta Lane 在 AGENTS.md 写精简版（与 BRAINSTORM/ANALYZE 等节点同级）；在 workflow.mdc 写同等级定义块
> 3. 验证脚本不在本批次扩展（扩展校验深度留作后续批次，性价比需单独评估）
> 4. T01 只在文档中注明环境要求，不新增 .ps1 脚本（ps1 版本是可选项，不是阻塞项）

## 1. 背景

P0~P3 四轮优化完成后，Codex 对整个仓库做了一次独立审查，发现 6 处遗留问题：
文档旧文案、三端概念半暴露、路径格式漂移、frontmatter 缺失、环境要求不明确、日期未更新。
这些问题不影响核心功能，但削弱了工作流的可信度和可维护性。

## 2. 目标

**要做的事**：
- [ ] T01：在 README 和 team-workflow-guide 中明确 validate-workflow.sh 的运行环境要求（Git Bash / WSL）
- [ ] T02：修复 team-workflow-guide 中两处"ADR 累积到 5 的倍数"旧描述
- [ ] T03：在 AGENTS.md 和 workflow.mdc 补充 Workflow-Meta Lane 说明
- [ ] T04：为 P3 的 spec 和 plan 补写 YAML frontmatter
- [ ] T05：统一三处路径占位格式（`--review.md` → `--<feature>--review.md`）
- [ ] T06：更新 team-workflow-guide 日期为 2026-05-21，清理正文旧行为描述

**不做的事**：
- 不新增 PowerShell 版本的验证脚本（不是阻塞项）
- 不扩展 validate-workflow.sh 的校验深度（留作独立批次评估）
- 不回填 P0~P2 历史产物的 frontmatter

## 3. 方案说明

### T01 — 运行环境说明

在 README 和 team-workflow-guide 的验证脚本相关位置补注运行环境要求。

格式：
```
> **运行环境**：`validate-workflow.sh` 需在 **Git Bash 或 WSL** 下执行。
> PowerShell 用户请先启动 Git Bash：右键项目目录 → "Git Bash Here"，再运行：
> ```bash
> bash scripts/validate-workflow.sh
> ```
```

### T03 — Workflow-Meta Lane 三端同步

AGENTS.md：在节点说明区域新增独立块，内容对齐 CLAUDE.md 的精简描述（跳过 TDD、grep 验收、每文件 commit、三端同步粒度）。

workflow.mdc：在节点路由规则区域新增同等级定义块，与 CLAUDE.md 的 Workflow-Meta Lane 描述保持语义一致。

### T04 — P3 产物 frontmatter 回填

`docs/specs/2026-05-21--p3-framework-agnostic.md`：在文件顶部插入：
```yaml
---
feature: p3-framework-agnostic
date: 2026-05-21
status: confirmed
confirmed_at: 2026-05-21
---
```

`docs/plans/2026-05-21--p3-framework-agnostic--tasks.md`：在文件顶部插入：
```yaml
---
feature: p3-framework-agnostic
date: 2026-05-21
status: completed
spec: docs/specs/2026-05-21--p3-framework-agnostic.md
---
```

### T05 — 路径格式统一

三处旧写法 `YYYY-MM-DD--review.md` 改为 `YYYY-MM-DD--<feature>--review.md`：
- `skills/05-documentation/SKILL.md:59`
- `.cursor/rules/workflow.mdc:102`
- `docs/team-workflow-guide.md:130`

### T06 — team-workflow-guide 日期与内容更新

- 第 4 行日期 `2026-05-19` → `2026-05-21`
- 第 134、152 行"ADR 累积到 5 的倍数"→ "每次 DOCUMENT 完成后导航卡固定提供 `/viktor:digest` 选项"

## 4. 验收标准

- [ ] README 和 team-workflow-guide 均有 Git Bash / WSL 运行说明
- [ ] team-workflow-guide 中无"5 的倍数"字样
- [ ] AGENTS.md 和 workflow.mdc 均有 Workflow-Meta Lane 说明块
- [ ] P3 spec 和 plan 顶部有合法 YAML frontmatter
- [ ] 三处路径占位格式统一为 `--<feature>--review.md`
- [ ] team-workflow-guide 日期为 2026-05-21
- [ ] `bash scripts/validate-workflow.sh` 仍 37/37 PASS
