---
name: 03-tdd-cycle
description: 测试驱动开发循环 - 针对 React/Next.js/Vitest 项目的完整 TDD 红绿重构规范，每个任务单元循环执行
---

# TDD — 测试驱动开发循环

## 触发条件

以下任一情况触发本 Skill：
- 用户输入 `/viktor:code` 命令
- ANALYZE 节点完成，用户确认了 `tasks.md`
- 准备实现 tasks.md 中的任何任务单元

**前置条件检查**（缺少时停止并提示）：
- `docs/plans/` 下必须存在 `tasks.md`
- 如果没有：停止，提示 "请先运行 `/viktor:plan` 生成任务列表"

## TDD 分层规范（React/Next.js 特化）

> **框架适配**：以下分层规范默认以 React/Next.js/Vitest 为示例。
> 如 `docs/project-context.md` 显示其他框架（Vue / Svelte 等），参照相应框架测试实践，
> 测试工具替换为对应生态（如 Vitest + Vue Test Utils），其余 TDD 循环原则不变。

### 强制 TDD（必须先写测试再写实现）

| 类型 | 示例 | 测试工具 |
|------|------|---------|
| 工具函数 | `formatDate()`, `validateEmail()`, `calculateTotal()` | Vitest |
| 自定义 Hooks | `useForm()`, `useAuth()`, `usePagination()` | Vitest + renderHook |
| 状态管理 | Zustand store, Context provider | Vitest |
| 数据处理 | API 响应转换、数据格式化 | Vitest |
| 表单校验 | 校验规则、错误消息生成 | Vitest |
| Server Actions | 表单提交处理、数据变更 | Vitest + MSW |
| API 路由 | Next.js route handlers | Vitest + MSW |

### 适度 TDD（有明确交互行为时写测试）

| 类型 | 测试重点 | 测试工具 |
|------|---------|---------|
| 有状态组件 | 用户交互行为（点击、输入、选择） | RTL + userEvent |
| 表单组件 | 提交、验证触发、错误展示 | RTL + userEvent |
| 列表组件 | 渲染、空状态、加载状态 | RTL |
| 模态框/弹窗 | 打开/关闭、确认/取消回调 | RTL + userEvent |

### 不适合 TDD（跳过，使用其他方式验证）

| 类型 | 原因 | 替代验证方式 |
|------|------|------------|
| 纯样式/布局 | 视觉测试不可靠，快照维护成本高 | Storybook / 视觉走查 |
| 动画过渡 | 难以量化，测试不稳定 | 手动验证 |
| 第三方库集成层 | 库本身已有测试 | 集成测试即可 |
| 无交互的纯展示组件 | 无行为可测 | Storybook 快照 |

## TDD 执行循环（每个任务单元）

---

### 前置步骤 0：会话感知冷启动检测（进入任务循环前执行一次）

检查当前对话历史中，是否存在 **ANALYZE 节点刚完成的信号**（导航卡中含有指向 `/viktor:code` 的 `▶` 提示）：

**在流模式（检测到信号）**：
- 直接使用对话中 ANALYZE 刚输出的 tasks.md 路径，跳过以下扫描步骤
- 继续执行"前置步骤：检查类型合约文件"

**冷启动模式（未检测到信号）**：

1. 扫描 `docs/plans/` 下所有 `*tasks.md`，按日期倒序排列
2. 在对话中输出选择列表：
   ```
   找到以下任务文件：

   A. 2026-05-19 · session-aware-confirmation（9 个任务，0/9 完成）
   B. 2026-05-18 · contract-node（12 个任务，12/12 完成）⚠️ 已全部完成

   请选择操作：
     输入 A / B / ...  → 继续对应任务
     输入 N            → 开始新功能（将引导执行 /viktor:think）
   ```
3. 等待用户输入：
   - **选择有未完成任务的文件** → 使用该文件，继续执行后续步骤
   - **选择已全部完成的文件** → 追加二次确认：
     ```
     ⚠️ 该任务文件已全部完成，对应代码可能已存在。
     继续前建议先确认 src/ 中是否已有实现，避免重复覆盖。
     确认继续？(y/n)
     ```
   - **输入 N** → 停止，提示：「请执行 `/viktor:think <需求描述>` 开始新功能设计。」
4. `docs/plans/` 下无任何文件 → 停止，提示：「请先运行 `/viktor:plan` 生成任务列表。」

---

### 前置步骤：检查类型合约文件（进入任务循环前执行一次）

检查 `docs/contracts/` 下是否存在与当前功能对应的 `.types.ts` 文件：

**存在时**：
1. 读取合约文件内容
2. 在对话中记录：
   ```
   已加载类型合约：docs/contracts/YYYY-MM-DD--<feature>.types.ts
   共 N 个类型定义。写测试和实现时，import 类型应来自此文件，不要另行定义。
   ```
3. 后续每个任务的测试和实现文件中，相关类型均 `import type` 自该合约文件

**不存在时**：检查当前 tasks.md 中是否含有 `[api]` / `[hook]` / `[store]` 类型任务：
- **含有**：输出非阻塞提醒后继续：
  > 💡 检测到任务含 [api] / [hook] / [store] 类型，但未发现类型合约文件。
  >    建议先执行 `/viktor:contract` 锁定接口类型。（可跳过，不阻塞继续）
- **不含有**：静默继续，无需提示。

---

### 第 1 步：从 tasks.md 取任务

读取 `docs/plans/YYYY-MM-DD--tasks.md`，选择一个未完成的任务：
- 按优先级顺序（P0 → P1 → P2）
- 确认依赖任务已完成

在对话中记录当前任务：
```
当前任务：T001 - validateEmail [utils]
实现文件：src/lib/utils/validateEmail.ts
测试文件：src/lib/utils/validateEmail.test.ts
验收标准：[列出标准]
```

---

### 第 2 步：RED — 写失败的测试

**规则：在创建任何实现文件之前，先创建测试文件。**

**工具函数测试模板**：

```typescript
// src/lib/utils/validateEmail.test.ts
import { describe, it, expect } from 'vitest'
import { validateEmail } from './validateEmail'

describe('validateEmail', () => {
  describe('有效邮箱', () => {
    it('接受标准格式邮箱', () => {
      expect(validateEmail('user@example.com')).toBe(true)
    })

    it('接受子域名邮箱', () => {
      expect(validateEmail('user@mail.example.com')).toBe(true)
    })
  })

  describe('无效邮箱', () => {
    it('拒绝缺少 @ 的字符串', () => {
      expect(validateEmail('notanemail')).toBe(false)
    })

    it('拒绝空字符串', () => {
      expect(validateEmail('')).toBe(false)
    })

    it('拒绝 null', () => {
      expect(validateEmail(null as any)).toBe(false)
    })
  })
})
```

**Hook 测试模板**：

```typescript
// src/lib/hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('初始值为 0', () => {
    const { result } = renderHook(() => useCounter())
    expect(result.current.count).toBe(0)
  })

  it('increment 使计数加 1', () => {
    const { result } = renderHook(() => useCounter())
    act(() => { result.current.increment() })
    expect(result.current.count).toBe(1)
  })
})
```

**组件测试模板（RTL）**：

```typescript
// src/components/LoginForm.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('提交有效表单后显示成功消息', async () => {
    const user = userEvent.setup()
    render(<LoginForm />)

    await user.type(screen.getByLabelText('邮箱'), 'test@example.com')
    await user.type(screen.getByLabelText('密码'), 'password123')
    await user.click(screen.getByRole('button', { name: '登录' }))

    expect(await screen.findByText('登录成功')).toBeInTheDocument()
  })

  it('空表单提交时显示验证错误', async () => {
    const user = userEvent.setup()
    render(<LoginForm />)

    await user.click(screen.getByRole('button', { name: '登录' }))

    expect(screen.getByText('请输入邮箱')).toBeInTheDocument()
  })
})
```

运行测试，确认红色失败：
```bash
npx vitest run src/lib/utils/validateEmail.test.ts
```

**期望输出**：`FAIL` 且错误信息合理（模块不存在，或断言失败）

**如果测试意外通过**：停止检查——要么测试写错了方向，要么模块已经存在。解决后继续。

---

### 第 3 步：GREEN — 写最少实现代码

**原则：只写让测试通过的最少代码，不过度设计，不提前抽象。**

**工具函数示例**：

```typescript
// src/lib/utils/validateEmail.ts
export function validateEmail(email: unknown): boolean {
  if (!email || typeof email !== 'string') return false
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
}
```

**Hook 示例**：

```typescript
// src/lib/hooks/useCounter.ts
import { useState } from 'react'

export function useCounter(initialValue = 0) {
  const [count, setCount] = useState(initialValue)
  return {
    count,
    increment: () => setCount(c => c + 1),
    decrement: () => setCount(c => c - 1),
    reset: () => setCount(initialValue),
  }
}
```

运行测试，确认绿色通过：
```bash
npx vitest run src/lib/utils/validateEmail.test.ts
```

**期望输出**：所有测试 `PASS`

---

### 第 4 步：REFACTOR — 重构，确保测试仍通过

检查实现代码的以下维度：
- **命名**：函数名、变量名是否清晰表达意图？
- **重复**：有没有相似逻辑可以提取？
- **复杂度**：函数是否超过 30 行？
- **规范**：是否符合 `references/react-nextjs-conventions.md`？
- **类型**：TypeScript 类型是否完整、严格？

重构后立即运行测试：
```bash
npx vitest run src/lib/utils/validateEmail.test.ts
```

**如果重构导致测试失败**：立即回滚重构，分析原因后重新尝试。

---

### 第 5 步：Commit

```bash
git add src/lib/utils/validateEmail.ts src/lib/utils/validateEmail.test.ts
git commit -m "feat: add validateEmail utility with tests"
```

**Commit 消息格式**：
- `feat:` — 新功能
- `fix:` — Bug 修复
- `test:` — 仅测试变更
- `refactor:` — 重构（无功能变化）

**commit 时机建议**：
- **推荐（每任务）**：每个任务完成红→绿→重构后立即 commit，保持原子粒度，便于单任务回滚
- **可选（里程碑）**：对于关联性极强的连续小任务，可在 `tasks.md` 中用注释 `# --- commit here ---` 标记里程碑，到达标记后统一提交
- **不推荐**：所有任务全部完成后一次性提交（回滚粒度过大，问题定位困难）

---

### 第 6 步：标记完成，取下一个任务

在 `tasks.md` 中标记当前任务完成：
```markdown
- [x] T001：validateEmail [utils] ✓
```

然后回到**第 1 步**，取下一个任务，重复循环。

**所有任务完成后**，运行完整测试套件：
```bash
npx vitest run
npx vitest run --coverage
npx tsc --noEmit
```

确认全部通过后，提示：
> "所有任务实现完成！测试覆盖率：XX%，TypeScript 无类型错误。输入 `/viktor:cr` 进行代码审查。"

---

## 技术规范

### Vitest 配置

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.stories.tsx', 'src/test/**', 'src/**/*.d.ts'],
      reporter: ['text', 'lcov'],
      thresholds: { global: { lines: 80, branches: 80, functions: 80 } },
    },
  },
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
})
```

### MSW Mock 配置

```typescript
// src/test/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users', () =>
    HttpResponse.json([{ id: '1', name: '张三' }])
  ),
  http.post('/api/auth/login', async ({ request }) => {
    const body = await request.json() as { email: string; password: string }
    if (body.email === 'wrong@email.com') {
      return HttpResponse.json({ error: '邮箱或密码错误' }, { status: 401 })
    }
    return HttpResponse.json({ token: 'mock-token' })
  }),
]

// src/test/setup.ts
import '@testing-library/jest-dom'
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

const server = setupServer(...handlers)
beforeAll(() => server.listen({ onUnhandledRequest: 'warn' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

---

## 强制规则

1. **测试先于代码**：任何实现文件创建之前，测试文件必须存在且处于红色状态
2. **违规处理**：如果发现已先写实现再补测试 → 删除实现文件，从测试重新开始
3. **最小实现**：GREEN 阶段只写让测试通过的最少代码，不做未被测试覆盖的功能
4. **重构必测**：REFACTOR 阶段每次修改后都必须运行测试，确认绿色才继续
5. **按任务 commit**：每完成一个任务 commit 一次，不积攒多个任务一起 commit

## 反理由表

| 借口 | 反驳 |
|------|------|
| "先搭结构再补测试" | 结构搭完后测试补写率接近零，且事后测试只测正常路径 |
| "这个太简单，不用测" | 简单的函数今天不测，明天被修改就是 bug 的温床 |
| "测试之后再写" | TDD 的价值在于测试驱动设计，事后补测试只是凑覆盖率 |
| "Mock 太麻烦" | MSW 已在 setup.ts 配置好，参考 references/testing-patterns.md |
| "这块逻辑很难测" | 难以测试通常意味着设计有问题，TDD 是在强迫你改善设计 |
| "时间不够了" | 没有测试的代码，review 和上线的时间成本会更高 |

## 验证标准

TDD 循环成功完成的标志：
- [ ] 每个 commit 都有对应测试文件（实现与测试同步提交）
- [ ] `npx vitest run` 全部通过，无失败
- [ ] `npx vitest run --coverage` 覆盖率 > 80%（lines/branches/functions）
- [ ] `npx tsc --noEmit` 无类型错误
- [ ] tasks.md 中所有任务已标记为完成 `[x]`
- [ ] 每个任务的验收标准都有对应的测试用例覆盖

---

## 导航卡

所有任务完成后**必须**输出：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TDD 已完成
📊 N 个任务全部实现，测试覆盖率 XX%
──────────────────────────────
▶ 下一步：输入 /viktor:cr
  进行代码审查
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
