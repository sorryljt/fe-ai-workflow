# ADR-007: 修复 P1 运行时稳定性问题（git 检测范围、合约提醒、DIGEST 债务可见性、编码规范）

**日期**：2026-05-21
**状态**：已接受
**提出者**：Dawson
**关联需求**：P1 稳定性修复批次

## 背景

在 P0 批次（ADR-006）完成一致性修复后，对工作流做更深入的运行时分析，发现 5 组在实际使用中会静默失效或信息丢失的问题：

1. **git diff 检测范围偏窄**：`skills/05-documentation` 的工作流变更检测使用 `HEAD~1 HEAD`，只能检查最后一次提交。对于跨多个 commit 的 feature 分支，早期修改 skills/ 的提交会被漏检，用户不会收到同步提示。

2. **TDD 合约遗漏无提示**：当 tasks.md 含 `[api]`/`[hook]`/`[store]` 类型任务但 `docs/contracts/` 下无对应合约文件时，TDD 节点静默继续，用户可能完全不知道跳过了 CONTRACT 节点，导致后续类型不一致。

3. **DIGEST 丢失 [SUGGESTED] 技术债务**：DIGEST 的 step 2 只从 review 文件提取 `[BLOCKING]` 和 `TODO`，`[SUGGESTED]` 问题在生成的摘要中完全消失，团队失去对已知但延后处理问题的可见性。

4. **BRAINSTORM 更新模式丢失项目上下文**：更新模式（选择已有 spec 修改）跳过了 step 1-3，包括读取 `docs/project-context.md`。若项目在两次 spec 编辑之间新增了组件或更改了架构，AI 会用过时上下文修改文档。

5. **无编码规范约束**：仓库缺少 `.editorconfig` 和 `.gitattributes`，在 Windows 环境（CRLF）和不同编辑器下，Markdown 文档和 TypeScript 文件可能产生换行符混入，git 已在实际操作中发出 LF→CRLF 警告。

## 决策

**我们决定修复上述 5 组问题，具体为 7 项文件改动：**

1. `skills/05-documentation/SKILL.md`：git diff 检测改为 `$(git merge-base HEAD main) HEAD`，覆盖完整 feature 分支范围。
2. `skills/03-tdd-cycle/SKILL.md`：合约文件不存在时，有条件检查任务类型并输出非阻塞提醒。
3. `skills/09-digest/SKILL.md`：step 2 提取规则新增 [SUGGESTED]，模板新增第 6 章节"已知技术债务"。
4. `skills/01-brainstorming/SKILL.md`：更新模式保留 step 1（读 project-context.md），只跳过 step 2-3。
5. 新增 `.editorconfig`：强制 UTF-8 编码、LF 换行，Markdown 保留尾部空格。
6. 新增 `.gitattributes`：git 层面统一 LF，防止跨平台 checkout 引入 CRLF。

## 方案对比

| 方案 | 优势 | 劣势 | 选择结果 |
|------|------|------|---------|
| merge-base 检测 | 覆盖完整 feature 分支所有提交 | 在 main 直接开发时 diff 为空（已知局限） | ✅ 选择 |
| HEAD~1 HEAD（原方案） | 简单 | 多 commit feature 漏检 | ❌ 排除 |
| 合约提醒全量输出 | 最明显 | 无 api/hook/store 任务时噪音 | ❌ 排除 |
| 合约提醒有条件输出（选择方案） | 只在相关场景提示 | 实现略复杂 | ✅ 选择 |
| SUGGESTED 并入"待关注问题" | 简单 | 与 BLOCKING 混淆，丧失技术债务分层 | ❌ 排除 |
| SUGGESTED 独立章节（选择方案） | 语义清晰，优先级分层 | 增加一节 | ✅ 选择 |

## 结果

**正面影响**：
- 工作流变更检测在多 commit feature 中不再漏检
- 用户跳过 CONTRACT 节点时有明确的非阻塞提醒
- DIGEST 摘要完整收录技术债务，团队可见性提升
- BRAINSTORM 更新模式始终基于最新项目上下文
- 仓库级编码规范统一，消除跨平台换行符污染

**负面影响 / 已知问题**：
- merge-base 检测在直接对 main 提交时（如本次）diff 为空，无法自动检测变更。此为设计上的局限，适用于 feature 分支工作流；对 main 直接提交场景需手动标注。

**实际效果**：所有 7 项验收 grep 检查通过，改动已 committed。

## 后续行动

- [ ] P2：为 specs/plans/reviews 添加机器可读 frontmatter（status/confirmed_at 字段）
- [ ] P2：在 `skills/using-fe-workflow/SKILL.md` 正式化 Workflow-Meta Lane 说明
- [ ] P2：TDD commit 粒度选项（per-task vs. milestone）
- [ ] P3：框架无关全面重构（TDD SKILL 脱离 React/Next.js 硬编码）
- [ ] P3：`scripts/validate-workflow.sh` 三端一致性验证脚本

## 相关文档

- 设计文档：[docs/specs/2026-05-21--p1-stability-fixes.md](../specs/2026-05-21--p1-stability-fixes.md)
- 任务列表：[docs/plans/2026-05-21--p1-stability-fixes--tasks.md](../plans/2026-05-21--p1-stability-fixes--tasks.md)
- Review 报告：[docs/reviews/2026-05-20--p1-stability-fixes--review.md](../reviews/2026-05-20--p1-stability-fixes--review.md)
- 前序决策：[ADR-006](2026-05-20--p0-consistency-fixes--adr.md)（P0 一致性修复）
