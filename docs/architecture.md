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
