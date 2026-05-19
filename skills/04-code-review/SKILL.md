---
name: 04-code-review
description: 代码审查 - 六轴审查框架（正确性/可维护性/性能/安全性/测试质量/类型合约一致性），生成结构化报告并控制合并流程
---

# REVIEW — 代码审查

## 触发条件

以下任一情况触发本 Skill：
- 用户输入 `/viktor:cr` 命令
- TDD 阶段完成，所有任务标记为完成
- 用户明确请求 code review

## 前置步骤：会话感知冷启动检测

检查当前对话历史中，是否存在 **TDD 节点刚完成的信号**（导航卡中含有指向 `/viktor:cr` 的 `▶` 提示）：

**在流模式（检测到信号）**：
- 直接使用对话中 TDD 对应的 tasks.md，跳过以下扫描步骤
- 继续执行前置条件检查

**冷启动模式（未检测到信号）**：

1. 扫描 `docs/plans/` 下所有 `*tasks.md`：
   - **有多个文件** → 列出让用户选择
   - **只有一个文件** → 直接告知「将使用 [文件名]」，无需选择，继续执行
2. 检查选定 tasks.md 中未勾选的任务数量：
   - **有未完成任务** → 警告：
     ```
     ⚠️ 检测到 tasks.md 中还有 N 个任务未完成。
     在所有任务完成前进行 CR 可能导致审查不完整。
     确认继续 CR？(y/n)
     ```
3. 检查 `docs/reviews/` 下是否已有同功能 review.md：
   - **存在** → 提示：「检测到已有 Review 文件 [文件名]，是否覆盖？(y/n)」

---

**前置条件检查**（缺少时停止并提示）：
- `tasks.md` 必须存在（用于对照验收标准）
- 所有实现代码文件已存在
- 运行 `npx vitest run` 无失败（如有失败，提示先修复）

## 五轴审查框架

---

### 轴 1：正确性

检查功能是否按设计工作，边界是否处理。

```
审查清单：
□ 功能是否与 tasks.md 中每条验收标准完全匹配？
□ null / undefined / 空数组 / 空字符串等边界条件是否处理？
□ 错误处理是否完整（try/catch、API 错误状态）？
□ 异步操作是否处理三态：loading / error / success？
□ TypeScript 类型是否严格？（无 any，无不合理的 as 强转）
□ 表单校验是否在前端和服务端均有实现？
```

### 轴 2：可维护性

检查代码是否易于理解和修改。

```
审查清单：
□ 函数/组件命名是否清晰表达意图？
□ 单个文件是否超过 300 行？（如是，考虑拆分组件或提取逻辑）
□ 单个函数是否超过 30 行？（如是，考虑提取子函数）
□ 是否有明显的重复代码可以提取？（DRY 原则）
□ 是否符合 references/react-nextjs-conventions.md 规范？
□ 导入顺序是否正确？（React → 第三方 → 内部 → 相对路径）
□ 组件职责是否单一？（不要一个组件既获取数据又处理 UI 又管理状态）
```

### 轴 3：性能

检查可能影响用户体验的性能问题。

```
审查清单：
□ 是否有不必要的重渲染？（组件 props 变化导致子树重渲染）
□ 回调函数是否需要 useCallback？（作为 props 传给子组件时）
□ 计算密集型逻辑是否需要 useMemo？
□ 大型列表（> 100 项）是否需要虚拟化？
□ 图片是否使用 next/image？（自动优化、懒加载）
□ 是否有 N+1 查询问题？（循环中发起请求）
□ 是否有不必要的客户端 bundle？（可以用 Server Component 替代）
```

### 轴 4：安全性

检查可能引入安全漏洞的代码。

```
审查清单：
□ 是否使用了 dangerouslySetInnerHTML？（需要确认输入已消毒）
□ 用户输入是否经过验证和消毒？（前端 + 服务端均需验证）
□ API 路由是否有身份认证检查？
□ 敏感数据（API keys、token、个人信息）是否不在客户端代码中暴露？
□ Server Component 中读取的数据是否有权限校验？
□ 环境变量是否正确区分 NEXT_PUBLIC_ 和服务端专用变量？
```

### 轴 5：测试质量

检查测试是否真正有价值。

```
审查清单：
□ 测试是否覆盖正常路径（主要用户流程）？
□ 测试是否覆盖边界条件（空值、极值、边缘情况）？
□ 测试是否覆盖错误场景（API 失败、网络错误）？
□ 测试命名是否描述行为而非实现？（"点击提交后显示成功" 而非 "测试 handleSubmit"）
□ 是否在测试实现细节而非用户行为？（避免测试内部状态、私有方法）
□ 是否使用了正确的查询优先级？（role > label > testId）
□ 覆盖率是否 > 80%？
```

### 轴 6：类型合约一致性（仅在 docs/contracts/ 存在合约文件时执行）

检查实现代码与类型合约文件是否保持一致。

```
审查清单：
□ 检查 docs/contracts/ 下是否存在对应 .types.ts 文件
  → 不存在：跳过本轴
  → 存在：继续以下检查
□ 实现代码中的 interface / type 定义是否与合约文件中的对应类型一致？
□ 是否有未在合约中声明的新类型？（若有，评估是否需要补入合约）
□ API 请求 / 响应类型是否与合约中的 Request / Response 完全匹配？
□ 是否存在绕过合约的情况？（如直接定义与合约重名但字段不同的本地 interface）
```

**问题分级**：
- 实现类型与合约定义字段不一致 → `[BLOCKING]`
- 新增类型未同步到合约文件 → `[SUGGESTED]`
- 绕过合约直接定义本地重复类型 → `[SUGGESTED]`

## 问题严重级别

### [BLOCKING] — 必须修复才能合并

触发以下任一情况标记为 BLOCKING：
- 功能与 tasks.md 验收标准不符（功能缺失或行为错误）
- 安全漏洞（XSS 风险、未授权 API 访问、敏感数据泄露）
- TypeScript 类型错误（`npx tsc --noEmit` 有错误）
- 测试覆盖率 < 60%
- 严重性能问题（内存泄漏、页面无响应）

### [SUGGESTED] — 建议修复，不阻塞合并

- 可维护性问题（命名不清、函数过长、重复代码）
- 轻微性能优化机会（非关键路径）
- 测试质量可提升（覆盖率 60-80%，缺少边界测试）
- 代码结构可以更好（不影响功能）

### [NIT] — 细节优化，完全可选

- 注释缺失或可以更清晰
- 格式问题（Prettier 可自动处理的）
- 变量命名的细微改善
- 代码顺序建议

## 执行步骤

### 第 1 步：运行自动化检查

```bash
# 运行测试
npx vitest run

# 查看覆盖率
npx vitest run --coverage

# TypeScript 类型检查
npx tsc --noEmit

# ESLint 检查
npx eslint src/ --ext .ts,.tsx
```

记录输出结果。

### 第 2 步：对照 tasks.md 验证功能完整性

逐条读取 tasks.md 中的验收标准，逐一验证：

```
T001 validateEmail
  ✅ 标准格式邮箱返回 true — 已验证
  ✅ 缺少 @ 返回 false — 已验证
  ❌ 空字符串返回 false — 测试存在但实现有 bug（发现问题记录）

T002 useLoginForm
  ✅ 初始状态正确
  ...
```

### 第 3 步：按五轴框架逐一审查

对每条代码改动，检查对应轴的审查清单。

发现问题时，记录：
- 位置（文件路径 + 行号）
- 问题描述（具体说明是什么问题）
- 级别（BLOCKING / SUGGESTED / NIT）
- 修复建议（具体说明如何修复，包含示例代码）

### 第 4 步：生成结构化 review 报告

按下方模板生成报告，保存到：
`docs/reviews/YYYY-MM-DD--<feature-name>--review.md`

### 第 5 步：流程控制

**如有 [BLOCKING] 问题**：
1. 清晰输出每个 BLOCKING 问题的修复建议
2. 提示：
   > "发现 N 个 [BLOCKING] 问题（详见 docs/reviews/YYYY-MM-DD--review.md）。
   > 请修复后返回 `/viktor:code` 重新实现，完成后再次运行 `/viktor:cr`。"

**无 [BLOCKING] 问题**：
> "✅ Review 通过！发现 X 个 [SUGGESTED] 和 Y 个 [NIT] 问题（可选处理）。
> 输入 `/viktor:doc` 进行文档沉淀。"

---

## review-report.md 模板

```markdown
# Code Review 报告：[功能名称]

**日期**：YYYY-MM-DD
**审查者**：AI Code Reviewer
**关联任务**：[docs/plans/YYYY-MM-DD--tasks.md](../plans/...)
**结论**：✅ PASS / ❌ BLOCK

## 总体评价

[2-3 句话客观评价，指出亮点和主要问题。例："整体实现思路清晰，TDD 执行规范。
发现 1 个 BLOCKING 问题（错误处理缺失）和 2 个 SUGGESTED 优化项。"]

**总体评分**：⭐⭐⭐⭐ / 5

## 自动化检查结果

| 检查项 | 结果 |
|--------|------|
| vitest run | ✅ 全部通过（N 个测试） |
| 测试覆盖率 | ✅ 85%（lines）/ ❌ 58%（branches） |
| tsc --noEmit | ✅ 无类型错误 |
| eslint | ✅ 无 error |

## 功能完整性检查

| 任务 ID | 验收标准 | 状态 |
|---------|---------|------|
| T001 | validateEmail 正确返回 | ✅ 通过 |
| T002 | 提交时调用 API | ❌ 未实现 |

## 五轴审查结果

### 轴 1：正确性 ⭐⭐⭐

**发现问题**：

**[BLOCKING] 错误处理缺失**

位置：`src/components/LoginForm.tsx:45`

问题：API 返回 5xx 时，UI 无任何反馈，用户不知道登录失败。

当前代码：
```typescript
await fetch('/api/auth/login', { method: 'POST', body: JSON.stringify(data) })
router.push('/dashboard')
```

建议修复：
```typescript
try {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify(data),
    headers: { 'Content-Type': 'application/json' },
  })
  if (!response.ok) {
    const error = await response.json()
    setError(error.message ?? '登录失败，请重试')
    return
  }
  router.push('/dashboard')
} catch {
  setError('网络错误，请检查连接后重试')
}
```

### 轴 2：可维护性 ⭐⭐⭐⭐

**发现问题**：

**[SUGGESTED] LoginForm 组件过长**

位置：`src/components/LoginForm.tsx`（已有 260 行）

建议：将 `FormField` 系列元素提取为独立组件，减少单文件长度。

### 轴 3：性能 ⭐⭐⭐⭐⭐

无问题。

### 轴 4：安全性 ⭐⭐⭐⭐⭐

无问题。

### 轴 5：测试质量 ⭐⭐⭐⭐

**发现问题**：

**[SUGGESTED] 缺少网络错误场景的测试**

建议添加：
```typescript
it('网络错误时显示错误提示', async () => {
  server.use(
    http.post('/api/auth/login', () => {
      return HttpResponse.error()
    })
  )
  const user = userEvent.setup()
  render(<LoginForm />)
  await user.type(screen.getByLabelText('邮箱'), 'test@example.com')
  await user.click(screen.getByRole('button', { name: '登录' }))
  expect(await screen.findByText('网络错误，请检查连接后重试')).toBeInTheDocument()
})
```

## 问题汇总

| 级别 | 数量 | 描述 |
|------|------|------|
| [BLOCKING] | 1 | 错误处理缺失（LoginForm.tsx:45） |
| [SUGGESTED] | 2 | 组件过长、缺少网络错误测试 |
| [NIT] | 0 | - |

## 结论

❌ 发现 1 个 [BLOCKING] 问题，需修复后重新 Review。请返回 `/viktor:code` 处理。

[如果通过则写]：✅ 无 BLOCKING 问题，建议合并。推进到 `/viktor:doc` 阶段。
```

---

## 验证标准

Review 完成的标志：
- [ ] 五轴审查均已完成
- [ ] 自动化检查（vitest/tsc/eslint）结果已记录
- [ ] tasks.md 每条验收标准逐一核对
- [ ] 所有发现的问题已按三级分类
- [ ] BLOCKING 问题附有具体的修复建议和代码示例
- [ ] review.md 已保存到 `docs/reviews/`
- [ ] 流程控制已执行（有 BLOCKING → 回 TDD；无 BLOCKING → 进 DOCUMENT）

---

## 导航卡

Review 完成后**必须**输出（根据结论二选一）：

> ⚠️ **约束**：此导航卡**不得出现** `/viktor:digest` 选项。
> digest 依赖 doc 产出的 ADR 和 CHANGELOG，只有 DOCUMENT 节点完成后才有意义。
> 在 REVIEW 阶段提示 digest 会让用户误以为它是 doc 的替代路径，导致跳过主流程。

**通过时**：
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ REVIEW 通过
📄 产物：docs/reviews/YYYY-MM-DD--review.md
──────────────────────────────
▶ 下一步：输入 /viktor:doc
  沉淀架构决策记录（完成后可选择执行 /viktor:digest）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**未通过时**：
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ REVIEW 未通过（N 个 BLOCKING 问题）
📄 产物：docs/reviews/YYYY-MM-DD--review.md
──────────────────────────────
▶ 下一步：修复上方问题后输入 /code
  修复完成后重新执行 /viktor:cr
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
