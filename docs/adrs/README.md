# ADR 索引

> Architecture Decision Records — 记录项目中所有重要的架构和技术决策。
> 每次 `/viktor:doc` 完成后自动追加新条目。

## 决策列表

| 编号 | 标题 | 日期 | 状态 | 链接 |
|------|------|------|------|------|
| ADR-001 | 新增 CONTRACT 节点，将类型合约接入工作流 | 2026-05-18 | 已接受 | [链接](2026-05-18--contract-node--adr.md) |
| ADR-002 | 建立活文档体系，改造 DOCUMENT 和 INIT 节点 | 2026-05-18 | 已接受 | [链接](2026-05-18--doc-system-upgrade--adr.md) |
| ADR-003 | 新增 CONTEXT 和 DIGEST 两个工具节点 | 2026-05-19 | 已接受 | [链接](2026-05-19--context-digest-nodes--adr.md) |
| ADR-004 | 引入会话感知冷启动检测机制，修复 context/digest 命令入口 | 2026-05-19 | 已接受 | [链接](2026-05-19--session-aware-confirmation--adr.md) |
| ADR-005 | 补全工作流完整性缺口：BRAINSTORM 冷启动、INIT 幂等化、digest 触发优化、references 变更检测 | 2026-05-19 | 已接受 | [链接](2026-05-19--workflow-completeness-polish--adr.md) |
| ADR-006 | P0 修复批次：统一三端 viktor:* 命令协议、六轴命名、digest 触发描述，清理框架专属术语和措辞 bug | 2026-05-20 | 已接受 | [链接](2026-05-20--p0-consistency-fixes--adr.md) |
| ADR-007 | P1 修复批次：git merge-base 检测、TDD 合约提醒、DIGEST 技术债务可见性、BRAINSTORM 更新模式上下文、编码规范约束 | 2026-05-21 | 已接受 | [链接](2026-05-21--p1-stability-fixes--adr.md) |
| ADR-008 | P2 打磨批次：frontmatter 规范化（specs/plans/reviews）、Workflow-Meta Lane 正式化、TDD commit 粒度建议 | 2026-05-21 | 已接受 | [链接](2026-05-21--p2-workflow-polish--adr.md) |
| ADR-009 | P3 批次：TDD SKILL 框架无关化（中度重构，保留 React/Next.js 参考实现）+ 三端一致性验证脚本 | 2026-05-21 | 已接受 | [链接](2026-05-21--p3-framework-agnostic--adr.md) |
| ADR-010 | P4 批次：Codex Review 修复——validate-workflow.sh 文档补全、旧文案修正、Workflow-Meta Lane 三端完整化、路径格式统一 | 2026-05-21 | 已接受 | [链接](2026-05-21--p4-codex-review-fixes--adr.md) |
