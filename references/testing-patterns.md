# 测试模式与最佳实践

## Vitest 配置

### 完整配置示例

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,                          // 无需 import describe/it/expect
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.{ts,tsx}'],
      exclude: [
        'src/**/*.stories.tsx',
        'src/test/**',
        'src/**/*.d.ts',
        'src/**/index.ts',                  // 仅做 re-export 的文件
      ],
      reporter: ['text', 'lcov', 'html'],
      thresholds: {
        global: { lines: 80, branches: 80, functions: 80, statements: 80 },
      },
    },
  },
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
})
```

### 测试环境 Setup

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom'          // 扩展 expect 断言（toBeInTheDocument 等）
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

const server = setupServer(...handlers)

beforeAll(() => server.listen({ onUnhandledRequest: 'warn' }))
afterEach(() => server.resetHandlers())     // 每个测试后重置 handler
afterAll(() => server.close())
```

### 常用 Jest-DOM 断言

```typescript
// DOM 存在性
expect(element).toBeInTheDocument()
expect(element).not.toBeInTheDocument()

// 可见性
expect(element).toBeVisible()
expect(element).not.toBeVisible()
expect(element).toBeHidden()              // display:none 或 visibility:hidden

// 表单元素状态
expect(input).toBeDisabled()
expect(input).toBeEnabled()
expect(input).toBeRequired()
expect(checkbox).toBeChecked()
expect(input).toHaveValue('test@example.com')
expect(select).toHaveValue('option-a')

// 属性
expect(link).toHaveAttribute('href', '/home')
expect(button).toHaveAttribute('aria-expanded', 'true')
expect(element).not.toHaveAttribute('disabled')

// 文本内容
expect(element).toHaveTextContent('Hello World')
expect(element).toHaveTextContent(/hello/i)          // 正则（推荐）

// 类名
expect(element).toHaveClass('active')
expect(element).toHaveClass('btn', 'btn-primary')    // 同时有多个类名

// 焦点
expect(input).toHaveFocus()
```

---

## React Testing Library 最佳实践

### 查询优先级（从高到低使用）

```typescript
// 优先级 1：无障碍查询（最推荐，贴近用户感知）
screen.getByRole('button', { name: '提交' })
screen.getByRole('heading', { name: /欢迎/i, level: 1 })
screen.getByRole('textbox', { name: '邮箱地址' })
screen.getByRole('checkbox', { name: '记住我' })
screen.getByRole('combobox')                         // select 元素
screen.getByRole('listitem')                         // li 元素

// 优先级 2：语义查询
screen.getByLabelText('邮箱地址')                    // label 关联的 input
screen.getByPlaceholderText('请输入邮箱')
screen.getByText('Hello World')                      // 文本内容
screen.getByDisplayValue('current value')            // input 当前值

// 优先级 3：测试 ID（最后手段，仅当语义查询无法使用时）
screen.getByTestId('custom-element')
// 对应 HTML：<div data-testid="custom-element">
```

**getBy vs queryBy vs findBy 选择**：

```typescript
// getBy：期望元素存在（不存在则抛错）
const button = screen.getByRole('button', { name: '提交' })

// queryBy：期望元素可能不存在（不存在返回 null）
const error = screen.queryByText('错误提示')
expect(error).not.toBeInTheDocument()

// findBy：等待元素出现（内置 waitFor，返回 Promise）
const message = await screen.findByText('操作成功')
```

---

## userEvent 使用规范

```typescript
import userEvent from '@testing-library/user-event'

// ✅ 推荐：在每个测试中独立 setup
describe('LoginForm', () => {
  it('提交有效表单', async () => {
    const user = userEvent.setup()          // 独立实例，模拟真实用户时序
    render(<LoginForm />)

    // 输入文本（逐字符模拟真实输入）
    await user.type(screen.getByLabelText('邮箱'), 'test@example.com')

    // 清空再输入
    await user.clear(screen.getByLabelText('邮箱'))
    await user.type(screen.getByLabelText('邮箱'), 'new@example.com')

    // 点击
    await user.click(screen.getByRole('button', { name: '登录' }))

    // 键盘操作
    await user.tab()                         // Tab 切换焦点
    await user.keyboard('{Enter}')           // 回车
    await user.keyboard('{Escape}')          // Esc

    // 选择下拉
    await user.selectOptions(
      screen.getByRole('combobox'),
      screen.getByRole('option', { name: '选项 A' })
    )

    // 文件上传
    const file = new File(['内容'], 'test.txt', { type: 'text/plain' })
    await user.upload(screen.getByLabelText('上传文件'), file)
  })
})

// ❌ 避免：fireEvent（不模拟真实用户行为序列，可能漏掉中间事件）
fireEvent.click(button)                     // 只触发 click，没有 pointerdown/up
```

---

## MSW Mock 模式

### Handler 定义

```typescript
// src/test/handlers.ts
import { http, HttpResponse, delay } from 'msw'

export const handlers = [
  // GET - 正常响应
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: '1', name: '张三', email: 'zhang@example.com' },
      { id: '2', name: '李四', email: 'li@example.com' },
    ])
  }),

  // GET - 分页
  http.get('/api/products', ({ request }) => {
    const url = new URL(request.url)
    const page = Number(url.searchParams.get('page') ?? '1')
    return HttpResponse.json({
      data: [{ id: page, name: `产品 ${page}` }],
      total: 100,
      page,
    })
  }),

  // POST - 创建资源
  http.post('/api/users', async ({ request }) => {
    const body = await request.json() as { name: string; email: string }
    return HttpResponse.json({ id: '3', ...body }, { status: 201 })
  }),

  // 模拟网络延迟
  http.get('/api/slow-data', async () => {
    await delay(500)
    return HttpResponse.json({ data: 'loaded' })
  }),

  // 服务器错误
  http.get('/api/broken', () => {
    return HttpResponse.json({ message: '服务器内部错误' }, { status: 500 })
  }),
]
```

### 在测试中覆盖 Handler

```typescript
it('处理 API 未授权错误', async () => {
  // 临时覆盖 handler（仅在本测试中生效，afterEach 自动重置）
  server.use(
    http.get('/api/users', () => {
      return HttpResponse.json({ message: '未授权访问' }, { status: 401 })
    })
  )

  render(<UserList />)

  expect(await screen.findByText('请先登录')).toBeInTheDocument()
})

it('处理网络断开', async () => {
  server.use(
    http.get('/api/users', () => {
      return HttpResponse.error()           // 模拟网络错误（连接失败）
    })
  )

  render(<UserList />)

  expect(await screen.findByText('网络连接失败')).toBeInTheDocument()
})
```

---

## Hooks 测试模式

```typescript
import { renderHook, act } from '@testing-library/react'

// 纯逻辑 Hook 测试
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

  it('reset 恢复初始值', () => {
    const { result } = renderHook(() => useCounter(5))
    act(() => {
      result.current.increment()
      result.current.reset()
    })
    expect(result.current.count).toBe(5)
  })
})

// 需要 Provider 的 Hook 测试
const wrapper = ({ children }: { children: React.ReactNode }) => (
  <AuthProvider initialUser={mockUser}>
    <ThemeProvider>{children}</ThemeProvider>
  </AuthProvider>
)

const { result } = renderHook(() => useAuth(), { wrapper })
expect(result.current.user).toEqual(mockUser)

// 异步 Hook 测试
it('useUserData 加载数据', async () => {
  const { result } = renderHook(() => useUserData('user-1'))

  expect(result.current.isLoading).toBe(true)

  await waitFor(() => {
    expect(result.current.isLoading).toBe(false)
  })

  expect(result.current.data).toEqual({ id: 'user-1', name: '张三' })
})
```

---

## 异步测试模式

```typescript
import { waitFor, waitForElementToBeRemoved } from '@testing-library/react'

// 模式 1：findBy（等待元素出现，推荐）
it('加载后显示用户列表', async () => {
  render(<UserList />)
  const user = await screen.findByText('张三')    // 内置超时（默认 1000ms）
  expect(user).toBeInTheDocument()
})

// 模式 2：waitFor（等待条件满足）
it('表单提交后清空输入框', async () => {
  const user = userEvent.setup()
  render(<SearchForm />)

  await user.type(screen.getByRole('searchbox'), '关键词')
  await user.click(screen.getByRole('button', { name: '搜索' }))

  await waitFor(() => {
    expect(screen.getByRole('searchbox')).toHaveValue('')
  })
})

// 模式 3：waitForElementToBeRemoved（等待元素消失）
it('加载完成后隐藏 Loading 动画', async () => {
  render(<DataView />)

  await waitForElementToBeRemoved(
    () => screen.queryByTestId('loading-spinner')
  )

  expect(screen.getByText('数据已加载')).toBeInTheDocument()
})

// 模式 4：超时控制（慢请求）
it('处理超时响应', async () => {
  server.use(
    http.get('/api/data', async () => {
      await delay(2000)
      return HttpResponse.json({})
    })
  )

  render(<DataView />)

  // 增加超时时间
  const element = await screen.findByText('数据已加载', {}, { timeout: 3000 })
  expect(element).toBeInTheDocument()
})
```

---

## 常见反模式及纠正

### 反模式 1：测试实现细节而非用户行为

```typescript
// ❌ 错误：测试内部 state 或函数调用次数
it('点击后 isOpen 变为 true', () => {
  const { result } = renderHook(() => useDropdown())
  act(() => result.current.toggle())
  expect(result.current.isOpen).toBe(true)  // 测试内部状态
})

// ✅ 正确：测试用户能观察到的行为
it('点击触发器后下拉菜单可见', async () => {
  const user = userEvent.setup()
  render(<Dropdown trigger="打开" items={['选项 A', '选项 B']} />)

  await user.click(screen.getByRole('button', { name: '打开' }))

  expect(screen.getByRole('menu')).toBeVisible()
  expect(screen.getByRole('menuitem', { name: '选项 A' })).toBeInTheDocument()
})
```

### 反模式 2：忘记等待异步操作

```typescript
// ❌ 错误：没有 await，数据未加载完就断言
it('显示用户数据', () => {
  render(<UserProfile userId="1" />)
  expect(screen.getByText('张三')).toBeInTheDocument()  // 此时数据还在加载
})

// ✅ 正确：使用 findBy 等待数据
it('加载后显示用户名', async () => {
  render(<UserProfile userId="1" />)
  expect(await screen.findByText('张三')).toBeInTheDocument()
})
```

### 反模式 3：共享可变测试状态

```typescript
// ❌ 错误：多个测试共享同一 mock 实例，可能互相影响
const mockFn = vi.fn()
it('测试 A', () => { ... })   // mockFn 被调用 1 次
it('测试 B', () => {
  expect(mockFn).toHaveBeenCalledTimes(1)  // 实际被调用了 2 次（上个测试也调用了）
})

// ✅ 正确：每个测试独立，使用 beforeEach 重置
beforeEach(() => {
  vi.clearAllMocks()                         // 重置所有 mock 状态
})
```

### 反模式 4：测试太细，一个操作一个测试

```typescript
// ❌ 过度细化：每个断言一个测试（会导致测试数量爆炸）
it('显示邮箱输入框', () => { ... })
it('显示密码输入框', () => { ... })
it('显示提交按钮', () => { ... })

// ✅ 按用户故事组织：一个完整交互场景一个测试
it('显示完整登录表单', () => {
  render(<LoginForm />)
  expect(screen.getByLabelText('邮箱')).toBeInTheDocument()
  expect(screen.getByLabelText('密码')).toBeInTheDocument()
  expect(screen.getByRole('button', { name: '登录' })).toBeInTheDocument()
})
```

### 反模式 5：使用 getByText 测试动态数据

```typescript
// ❌ 脆弱：文案变化即测试失败
expect(screen.getByText('用户 张三 已创建')).toBeInTheDocument()

// ✅ 健壮：使用正则或 role 查询
expect(screen.getByText(/张三/)).toBeInTheDocument()
expect(screen.getByRole('alert')).toHaveTextContent(/已创建/)
```
