---
description: 代码审查 五轴框架（正确性/可维护性/性能/安全/测试）
---

# /viktor:cr

当用户输入此命令时：

## 1. 加载 Skill

读取并严格遵循 `skills/04-code-review/SKILL.md`。

## 2. 需要的输入

**必须**：
- 所有实现代码文件（`src/` 目录下的变更）
- 所有测试文件（`*.test.ts` / `*.test.tsx`）
- `docs/plans/YYYY-MM-DD--tasks.md`（验收标准对照）

**前置检查**：
1. 确认 tasks.md 存在
2. 运行 `npx vitest run`，如有测试失败，提示先修复：
   > "发现 N 个测试失败，请先修复后再进行 Review。返回 `/viktor:code` 处理。"

## 3. 执行过程

按照 `skills/04-code-review/SKILL.md` 的步骤执行：

1. **自动化检查**：运行 vitest / tsc / eslint，记录结果
2. **功能完整性**：逐条对照 tasks.md 验收标准核实
3. **五轴审查**：
   - 轴 1 — 正确性（功能、边界条件、错误处理、TypeScript 类型）
   - 轴 2 — 可维护性（命名、文件长度、重复代码、规范符合）
   - 轴 3 — 性能（重渲染、next/image、N+1 查询）
   - 轴 4 — 安全性（XSS、权限校验、敏感数据）
   - 轴 5 — 测试质量（覆盖、行为测试、覆盖率）
4. **生成报告**：保存到 `docs/reviews/YYYY-MM-DD--review.md`

## 4. 完成后提示

**如有 [BLOCKING] 问题**：
> "❌ Review 结果：BLOCK
>
> 发现 N 个 [BLOCKING] 问题（详见 `docs/reviews/YYYY-MM-DD--review.md`）：
> - [问题 1 摘要]
> - [问题 2 摘要]
>
> 请按修复建议处理后返回 `/viktor:code`，完成后再次运行 `/viktor:cr`。"

**无 [BLOCKING] 问题**：
> "✅ Review 结果：PASS
>
> 发现 X 个 [SUGGESTED]、Y 个 [NIT] 问题（可选处理）。
> 详见 `docs/reviews/YYYY-MM-DD--review.md`。
>
> 输入 `/viktor:doc` 进行文档沉淀，完成本次需求。"
