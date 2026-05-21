# ADR-010: P4 批次（Codex Review 修复：文档一致性、三端概念完整性、路径格式统一）

**日期**：2026-05-21
**状态**：已接受
**提出者**：Dawson
**关联需求**：Codex 独立审查后的 6 条遗留问题修复

## 背景

P0~P3 四轮优化完成并发布 v0.8.0 后，使用 Codex 对仓库进行了一次独立审查。审查发现 6 处遗留问题，这些问题不影响核心工作流功能，但会削弱工作流的可信度和可维护性：

1. **validate-workflow.sh 在用户文档中完全未提及**：README 和 team-workflow-guide 均无使用说明，且脚本在 PowerShell 环境下无法直接运行，需明确环境要求。
2. **旧文案未同步**：team-workflow-guide 第 134、152 行仍保留"ADR 累积到 5 的倍数才建议 digest"的旧描述，该行为在 ADR-005（P0 批次）已更正。
3. **Workflow-Meta Lane 概念半暴露**：已在 CLAUDE.md 和 using-fe-workflow/SKILL.md 正式定义，但 AGENTS.md 和 workflow.mdc 均无对应说明，Codex 和 Cursor 用户无法感知。
4. **P3 产物 frontmatter 缺失**：P2 批次已更新 spec/plan 模板，但 P3 执行时两份文件漏写 frontmatter（模板改完后第一批漏网产物）。
5. **路径占位格式漂移**：多处文件中 review 产物路径写为 `YYYY-MM-DD--review.md`，缺少 `<feature>` 段，与实际命名规范不符。共发现 7 处（计划 3 处，执行时额外发现 4 处）。
6. **team-workflow-guide 日期未更新**：文档头部日期仍为 2026-05-19（v0.4.0 发布日），而当前版本为 v0.8.0。

## 决策

**逐条修复，不扩展验证脚本**

- T01：在 README 和 team-workflow-guide 新增 validate-workflow.sh 介绍段落，明确 Git Bash / WSL 运行环境要求
- T02：替换 team-workflow-guide 两处旧文案为正确的 digest 触发描述
- T03：在 AGENTS.md 新增 Workflow-Meta Lane 完整对照表（4 维度），在 workflow.mdc 新增精简版定义块，两者均引用 SKILL.md 作为权威来源
- T04：为 P3 spec 和 plan 补写 YAML frontmatter
- T05：全局搜索并统一路径占位格式（实际修复 7 处）
- T06：更新 team-workflow-guide 日期为 2026-05-21

**关于验证脚本扩展的决策**：Codex 建议将校验深度扩展到"旧命令名禁用"、"版本号与 tag 一致"等语义检查。本批次暂不扩展——文档修复完成后，旧文案问题已从源头消除；版本一致性校验成本较高（需解析多文件），留作独立批次评估。

## 方案对比

### T03 Workflow-Meta Lane 三端暴露策略

| 方案 | 描述 | 选择结果 |
|------|------|---------|
| 仅在 SKILL.md 定义 | 最少重复，但 Codex/Cursor 用户看不到 | ❌ 排除（问题根源）|
| 三端完全一致（复制粘贴） | 最完整，但三端维护负担高 | ❌ 排除 |
| 分层定义（选择）| AGENTS.md 详版 + workflow.mdc 精简版 + SKILL.md 权威版，三端均引用 SKILL.md | ✅ 选择 |

分层定义的优势：AGENTS.md 目标用户（Codex）需要明确的操作指引，详版对照表更实用；workflow.mdc 目标用户（Cursor）通常有 SKILL.md 作为补充，精简版足够；两端均显式引用 SKILL.md，避免语义分叉。

## 结果

**正面影响**：
- validate-workflow.sh 有了用户文档入口，Windows 用户有明确的运行路径
- team-workflow-guide 内容与实际行为一致，"文档即事实"可信度提升
- Workflow-Meta Lane 成为真正的三端一等概念，Codex 和 Cursor 用户可感知
- P3 产物补齐 frontmatter，DIGEST 可机读状态
- 路径命名规范全局统一

**负面影响 / 已知问题**：
- README 中 validate-workflow.sh 的输出示例格式（`[PASS] ...`）与实际彩色 emoji 输出不完全一致，可读性略有偏差 [SUGGESTED，未修复]
- Workflow-Meta Lane 的三端定义仍存在详略差异，未来若 SKILL.md 层更新，AGENTS.md 需手动同步对照表

## 后续行动

- [ ] 可选：修正 README 中 validate-workflow.sh 输出示例为实际格式
- [ ] 可选：将验证脚本扩展到检查 CHANGELOG 版本号与 git tag 一致性（独立批次评估）

## 相关文档

- 设计文档：[docs/specs/2026-05-21--p4-codex-review-fixes.md](../specs/2026-05-21--p4-codex-review-fixes.md)
- 任务列表：[docs/plans/2026-05-21--p4-codex-review-fixes--tasks.md](../plans/2026-05-21--p4-codex-review-fixes--tasks.md)
- Review 报告：[docs/reviews/2026-05-21--p4-codex-review-fixes--review.md](../reviews/2026-05-21--p4-codex-review-fixes--review.md)
- 前序决策：[ADR-009](2026-05-21--p3-framework-agnostic--adr.md)（P3 框架无关化批次）
