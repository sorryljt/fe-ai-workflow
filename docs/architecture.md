# 架构决策速览

> 由 `/viktor:init` 初始化，由 `/viktor:doc` 在每次产出 ADR 后自动追加摘要。
> 完整决策背景见 `docs/adrs/` 目录。

## 决策记录

| 编号 | 决策摘要 | 日期 | 状态 | ADR 链接 |
|------|---------|------|------|---------|
| ADR-001 | 新增可选 CONTRACT 节点，ANALYZE 完成后智能推荐，TDD/REVIEW 感知合约文件 | 2026-05-18 | 已接受 | [ADR-001](adrs/2026-05-18--contract-node--adr.md) |
| ADR-002 | 建立 5 文件活文档体系，DOCUMENT 新增自动编号/替代流程/条件更新，INIT 生成骨架 | 2026-05-18 | 已接受 | [ADR-002](adrs/2026-05-18--doc-system-upgrade--adr.md) |
| ADR-003 | 新增 CONTEXT（只读项目快照）和 DIGEST（阶段性整合）两个工具节点，集成到 BRAINSTORM 和 DOCUMENT | 2026-05-19 | 已接受 | [ADR-003](adrs/2026-05-19--context-digest-nodes--adr.md) |
| ADR-004 | 引入会话感知冷启动检测：对话内在流零打扰，跨会话冷启动扫描产物并确认；修复 context/digest 命令入口缺失 | 2026-05-19 | 已接受 | [ADR-004](adrs/2026-05-19--session-aware-confirmation--adr.md) |
| ADR-005 | 补全工作流完整性缺口：BRAINSTORM 冷启动（检测已有 spec）、INIT 幂等化（A/B 两模式）、digest 固定导航卡选项、references 变更检测 | 2026-05-19 | 已接受 | [ADR-005](adrs/2026-05-19--workflow-completeness-polish--adr.md) |
| ADR-006 | P0 修复批次：统一三端 viktor:* 命令协议、六轴命名、digest 触发描述，清理框架专属术语和措辞 bug | 2026-05-20 | 已接受 | [ADR-006](adrs/2026-05-20--p0-consistency-fixes--adr.md) |
| ADR-007 | P1 修复批次：git merge-base 检测、TDD 合约提醒、DIGEST 技术债务可见性、BRAINSTORM 更新模式上下文、编码规范约束 | 2026-05-21 | 已接受 | [ADR-007](adrs/2026-05-21--p1-stability-fixes--adr.md) |
| ADR-008 | P2 打磨批次：frontmatter 规范化（specs/plans/reviews）、Workflow-Meta Lane 正式化、TDD commit 粒度建议 | 2026-05-21 | 已接受 | [ADR-008](adrs/2026-05-21--p2-workflow-polish--adr.md) |
| ADR-009 | P3 批次：TDD SKILL 框架无关化（中度重构，保留 React/Next.js 参考实现）+ 三端一致性验证脚本 | 2026-05-21 | 已接受 | [ADR-009](adrs/2026-05-21--p3-framework-agnostic--adr.md) |
| ADR-010 | P4 批次：Codex Review 修复——validate-workflow.sh 文档补全、旧文案修正、Workflow-Meta Lane 三端完整化、路径格式统一 | 2026-05-21 | 已接受 | [ADR-010](adrs/2026-05-21--p4-codex-review-fixes--adr.md) |
