---
description: 测试驱动开发 红→绿→重构
---

# /viktor:code

当用户输入此命令时：

## 1. 加载 Skill

读取并严格遵循 `skills/03-tdd-cycle/SKILL.md`。

## 2. 需要的输入

**必须**：`docs/plans/YYYY-MM-DD--tasks.md`（`/viktor:plan` 产物）

**前置检查**：
- 如果 `docs/plans/` 下不存在 tasks.md，停止并提示：
  > "tasks.md 不存在。请先输入 `/viktor:plan` 生成任务列表，再开始 TDD 实现。"
- 如果存在多个 tasks.md，询问用户选择哪个

## 3. 执行过程

按照 `skills/03-tdd-cycle/SKILL.md` 的步骤，对每个任务循环执行：

**每个任务循环**：
1. 从 tasks.md 取下一个未完成任务（按 P0→P1→P2 顺序）
2. 确认依赖任务已完成
3. **RED**：先创建测试文件，运行 `npx vitest run <test-file>` 确认失败
4. **GREEN**：写最少实现代码，运行测试确认通过
5. **REFACTOR**：重构代码，确认测试仍通过
6. `git commit -m "feat/fix/refactor: 描述"`
7. 在 tasks.md 中标记任务 `[x]`
8. 回到步骤 1

**强制规则**：先写测试再写实现，违反则删除实现代码重来。

## 4. 完成后提示

所有任务完成后，运行完整检查：

```
npx vitest run             ← 全部测试通过
npx vitest run --coverage  ← 覆盖率 > 80%
npx tsc --noEmit           ← 无 TypeScript 错误
```

输出：
> "✅ 所有任务实现完成！
> - 测试：N 个全部通过
> - 覆盖率：XX%（lines）/ XX%（branches）
> - TypeScript：无类型错误
>
> 输入 `/viktor:cr` 进行代码审查。"

## 5. 中途中断处理

如果用户中途停止并稍后继续：
- 读取 tasks.md 找到第一个未完成（`[ ]`）的任务
- 从该任务继续执行，不需要从头开始
