# ADR-009: P3 批次（TDD SKILL 框架无关化 + 三端一致性验证脚本）

**日期**：2026-05-21
**状态**：已接受
**提出者**：Dawson
**关联需求**：P3 框架无关化与验证脚本批次

## 背景

在完成 P0/P1/P2 三轮修复和打磨后，遗留两个影响长期可维护性的深层问题：

**P3-1：TDD SKILL 与框架声明不符**

项目在 README、CLAUDE.md 等文档中声明"框架无关（React / Vue / Svelte 等均适用）"，但 `skills/03-tdd-cycle/SKILL.md` 标题明写"React/Next.js 特化"，内容中大量使用 Next.js 专有概念：
- 分层规范表：Server Actions、Next.js route handlers
- 组件测试工具：RTL（React Testing Library）硬编码
- REFACTOR 规范检查：`references/react-nextjs-conventions.md` 无条件引用
- 测试模板：`@testing-library/react` import 无任何说明

非 React 项目接入后，AI 执行 TDD SKILL 时遇到大量不适用的指令，需要自行判断如何处理，行为不可预期。

**P3-2：三端一致性无自动化验证**

工作流有三个平台入口（CLAUDE.md / AGENTS.md / workflow.mdc），每次修改后需手动对照确认命令名称一致。此前 P0 批次已发现 workflow.mdc 存在旧命令名（`/brainstorm`、`/tdd` 等），说明纯靠人工检查不可靠。没有自动化验证工具，一致性保证依赖记忆和习惯。

## 决策

**P3-1：TDD SKILL 中度框架无关化（保留 React/Next.js 示例，显式标注为参考实现）**

选择"中度重构"而非"完全抽象"：
- React/Next.js 仍是最主流的接入场景，删除示例会损失实用性
- 显式标注"参考实现"可让 Vue/Svelte 用户知道如何类比，代价极低
- 框架对照表（React/Vue/Svelte/其他）明确各框架对应的测试工具

具体改动（7 处）：
1. frontmatter description 改为"框架无关…以 React/Next.js 为参考实现"
2. 章节标题"React/Next.js 特化"→"框架无关"
3. 框架适配块扩展为含 4 行对照表的说明区
4. 强制TDD 表：Server Actions / Next.js route handlers → 通用描述
5. 适度TDD 表：RTL → "组件测试库（React: RTL）"
6. REFACTOR 规范引用改为条件性说明
7. 第 2 步代码模板前加"React/Next.js 参考实现"标注

**P3-2：新建 `scripts/validate-workflow.sh`**

bash 脚本，37 项检查：
- 9 个 viktor:* 命令 × 3 端入口 = 27 项命令存在性检查
- 10 个 Skill 文件存在性检查

彩色 PASS/FAIL 输出，exit 0/1，支持 CI 集成。

## 方案对比

### P3-1 重构深度

| 方案 | 优势 | 劣势 | 选择结果 |
|------|------|------|---------|
| 仅重命名标题 | 改动最小 | 内容仍有大量 Next.js 专有词汇，治标不治本 | ❌ 排除 |
| 中度重构（选择） | 保留示例价值，消除歧义，框架对照表实用 | 需多处改动，review 工作量较大 | ✅ 选择 |
| 完全抽象 | 理论上最"纯粹" | 删除示例损失现有用户价值，维护多套示例成本高 | ❌ 排除 |

### P3-2 验证范围

| 检查维度 | 包含 | 说明 |
|---------|------|------|
| 命令名三端一致性 | ✅ | 27 项，防止 P0 类问题复发 |
| Skill 文件存在性 | ✅ | 10 项，防止孤立引用 |
| Skill 内容语义一致性 | ❌ | 需 NLP，bash 无法实现，留给人工 review |
| ADR/spec 文档完整性 | ❌ | 超出三端一致性范畴，不在此次范围 |

## 结果

**正面影响**：
- TDD SKILL 与项目"框架无关"定位一致，Vue/Svelte 用户接入后有明确的适配指引
- `scripts/validate-workflow.sh` 可在每次修改三端入口后立即验证，防止遗漏
- 验证脚本 37/37 当前全通过，确认三端现状一致

**负面影响 / 已知问题**：
- 框架对照表中"组件测试库"一栏对 Svelte 的推荐（`@testing-library/svelte`）未经实际验证，若 Svelte 生态推荐发生变化需手动更新
- 验证脚本不检查 Skill 内容语义，三端在措辞层面的不一致仍依赖人工 review

**实际效果**：validate-workflow.sh 在当前状态下运行：37/37 通过，exit 0。

## 后续行动

- [ ] 可选：验证脚本加入 pre-commit hook（`.git/hooks/pre-commit`）实现自动化门控
- [ ] 可选：REVIEW SKILL 轴 3 的 `next/image` 检查项改为条件性说明（与 P3-1 风格对齐）
- [ ] 可选：扩展 validate-workflow.sh 检查 CHANGELOG 版本号与 git tag 的一致性

## 相关文档

- 设计文档：[docs/specs/2026-05-21--p3-framework-agnostic.md](../specs/2026-05-21--p3-framework-agnostic.md)
- 任务列表：[docs/plans/2026-05-21--p3-framework-agnostic--tasks.md](../plans/2026-05-21--p3-framework-agnostic--tasks.md)
- Review 报告：[docs/reviews/2026-05-21--p3-framework-agnostic--review.md](../reviews/2026-05-21--p3-framework-agnostic--review.md)
- 前序决策：[ADR-008](2026-05-21--p2-workflow-polish--adr.md)（P2 打磨批次）
