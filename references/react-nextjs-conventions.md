# React / Next.js / TypeScript 编码规范

> **使用说明**：标注 `[仅 Next.js]` 的章节（第 2 节 App Router 规范）仅适用于 Next.js 项目。
> 非 Next.js 项目跳过这些章节，遵循 `docs/project-context.md` 中记录的项目实际约定。
> 其余章节（组件规范、TypeScript、状态管理、导入顺序、CSS、错误处理）适用于所有 React 项目。

## 1. 组件规范

### 函数组件写法

```typescript
// ✅ 函数声明式（推荐，调试堆栈显示组件名）
export function UserCard({ user, onDelete }: UserCardProps) {
  return (
    <div className="rounded-lg border p-4">
      <h2 className="text-lg font-semibold">{user.name}</h2>
      <button onClick={() => onDelete(user.id)}>删除</button>
    </div>
  )
}

// ✅ 箭头函数（可接受，但避免匿名）
export const UserCard = ({ user, onDelete }: UserCardProps) => {
  return <div>{user.name}</div>
}

// ❌ 匿名导出（难以调试，堆栈显示为 anonymous）
export default () => <div>...</div>
```

### Props 类型定义

```typescript
// ✅ interface 定义 Props（可扩展，IDE 提示友好）
interface UserCardProps {
  user: User
  onDelete: (id: string) => void
  className?: string                  // 可选 Props 使用 ?
  children?: React.ReactNode          // 子元素
}

// ✅ 复杂业务类型单独定义，不内联
interface User {
  id: string
  name: string
  email: string
  role: 'admin' | 'user' | 'guest'
  createdAt: Date
}

// ❌ 不要内联复杂类型
function UserCard({ user }: { user: { id: string; name: string } }) {}
```

### 命名约定

| 类型 | 规范 | 示例 |
|------|------|------|
| 组件文件 | PascalCase | `UserCard.tsx`, `LoginForm.tsx` |
| 组件名称 | PascalCase | `UserCard`, `LoginForm` |
| Hook 文件 | camelCase | `useAuth.ts`, `useForm.ts` |
| Hook 名称 | `use` 前缀 + 动词/名词 | `useAuth`, `usePagination` |
| 工具函数 | camelCase | `formatDate.ts`, `validateEmail.ts` |
| 类型/接口 | PascalCase | `UserProps`, `ApiResponse` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| 布尔变量 | `is/has/can/should` 前缀 | `isLoading`, `hasError`, `canEdit` |

---

## 2. Next.js App Router 规范 `[仅 Next.js]`

### Server vs Client Components 选择原则

```typescript
// ✅ Server Component（默认）—— 无 'use client' 指令
// 适用：数据获取、静态内容、访问后端资源、大型依赖
async function UsersPage() {
  const users = await fetchUsers()           // 直接 async/await
  return <UserList initialUsers={users} />
}

// ✅ Client Component —— 顶部添加 'use client'
// 适用：交互事件、useState/useEffect、浏览器 API
'use client'
import { useState } from 'react'

export function UserFilter({ onFilter }: UserFilterProps) {
  const [query, setQuery] = useState('')
  return <input value={query} onChange={e => setQuery(e.target.value)} />
}
```

**使用 Server Component 的场景**：
- 数据获取（fetch、数据库查询）
- 访问服务端资源（文件系统、环境变量）
- 保持敏感逻辑在服务端（API keys）
- 减少客户端 JavaScript bundle 大小

**使用 Client Component 的场景**：
- onClick, onChange 等交互事件处理
- useState, useEffect 等 React Hooks
- localStorage, geolocation 等浏览器 API
- 需要实时更新的数据（WebSocket、轮询）

**最佳实践**：将 Client Component 下推到叶子节点，尽量保持父级为 Server Component。

### 数据获取模式

```typescript
// ✅ Server Component 直接 fetch（推荐）
async function ProductList() {
  const products = await fetch('/api/products', {
    next: { revalidate: 3600 },           // ISR: 每小时重新验证
  }).then(res => res.json())

  return <ul>{products.map(p => <ProductItem key={p.id} product={p} />)}</ul>
}

// ✅ Server Action（表单提交）
'use server'
import { revalidatePath } from 'next/cache'

async function createProduct(formData: FormData) {
  const name = formData.get('name') as string
  if (!name) throw new Error('名称不能为空')
  await db.product.create({ data: { name } })
  revalidatePath('/products')
}

// ✅ Client Component + SWR（需要实时性的页面）
'use client'
import useSWR from 'swr'

function UserDashboard() {
  const { data, error, isLoading } = useSWR('/api/user/stats', fetcher, {
    refreshInterval: 30000,
  })
  if (isLoading) return <DashboardSkeleton />
  if (error) return <ErrorMessage error={error} />
  return <StatsGrid stats={data} />
}
```

### 文件组织结构

```
app/
├── (auth)/                    # 路由分组（不影响 URL）
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── dashboard/
│   ├── page.tsx               # 主页面
│   ├── layout.tsx             # 布局（持久 UI）
│   ├── loading.tsx            # 加载状态（自动 Suspense）
│   └── error.tsx              # 错误边界
└── api/
    └── users/
        └── route.ts           # API 路由

components/
├── ui/                        # 通用 UI 组件（Button, Input, Modal, Badge）
├── features/                  # 业务功能组件（UserCard, ProductList）
└── layouts/                   # 布局组件（Header, Sidebar, Footer）

lib/
├── utils/                     # 工具函数（validateEmail, formatDate）
├── hooks/                     # 自定义 Hooks（useAuth, useForm）
├── types/                     # 全局类型定义（user.ts, product.ts）
├── constants/                 # 常量（routes.ts, config.ts）
└── actions/                   # Server Actions（auth.ts, product.ts）
```

---

## 3. TypeScript 规范

### Strict Mode 配置

```json
// tsconfig.json（必须开启）
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

### 类型定义风格

```typescript
// ✅ interface 用于对象类型（可扩展、可 implements）
interface ApiResponse<T> {
  data: T
  error?: string
  status: number
  meta?: {
    total: number
    page: number
  }
}

// ✅ type 用于联合类型、工具类型、函数类型
type Status = 'idle' | 'loading' | 'success' | 'error'
type Nullable<T> = T | null
type Handler = (event: React.MouseEvent<HTMLButtonElement>) => void

// ✅ as const 用于字面量常量枚举
const ROUTES = {
  HOME: '/',
  LOGIN: '/login',
  DASHBOARD: '/dashboard',
} as const
type Route = typeof ROUTES[keyof typeof ROUTES]

// ❌ 避免 any
function process(data: any) { return data.value }      // 不好

// ✅ 用 unknown 代替 any（强制类型收窄）
function process(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as { value: string }).value
  }
}

// ❌ 避免不必要的类型断言
const user = response.data as User     // 危险，可能错误

// ✅ 使用类型守卫
function isUser(data: unknown): data is User {
  return typeof data === 'object' && data !== null && 'id' in data
}
```

---

## 4. 状态管理规范

```
状态分类原则：

URL 状态         → useSearchParams（可分享、可书签）
服务端状态        → SWR / React Query（缓存、同步、乐观更新）
全局 UI 状态      → Zustand（主题、通知、用户偏好）
局部组件状态      → useState（表单输入、展开/收起、hover）
派生状态         → useMemo 或直接计算（不用 useState 存储可以计算出的值）
```

```typescript
// ✅ Zustand store（全局状态）
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface ThemeStore {
  theme: 'light' | 'dark'
  setTheme: (theme: 'light' | 'dark') => void
}

export const useThemeStore = create<ThemeStore>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    { name: 'theme-storage' }
  )
)

// ✅ 派生状态直接计算，不用 useState 存储
function UserList({ users }: { users: User[] }) {
  const activeUsers = users.filter(u => u.isActive)    // 直接计算
  // ❌ const [activeUsers, setActiveUsers] = useState(...)
}
```

---

## 5. 导入顺序规范

```typescript
// 1. React 及 Next.js 核心
import { useState, useCallback, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import Link from 'next/link'

// 2. 第三方库（按字母顺序）
import { z } from 'zod'
import { useForm } from 'react-hook-form'
import useSWR from 'swr'

// 3. 内部模块（绝对路径 @/ 别名）
import { Button } from '@/components/ui/Button'
import { useAuth } from '@/lib/hooks/useAuth'
import { validateEmail } from '@/lib/utils/validateEmail'
import type { User, ApiResponse } from '@/lib/types'

// 4. 相对路径（当前目录及父目录）
import { UserAvatar } from './UserAvatar'
import { useUserForm } from './hooks/useUserForm'

// 5. 样式（最后）
import styles from './UserCard.module.css'
```

---

## 6. CSS / Tailwind 规范

```typescript
// ✅ 使用 cn() 合并类名（来自 clsx + tailwind-merge）
import { cn } from '@/lib/utils/cn'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive'
  size?: 'sm' | 'md' | 'lg'
}

export function Button({ variant = 'primary', size = 'md', className, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        // 基础样式
        'inline-flex items-center justify-center rounded-md font-medium transition-colors',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
        'disabled:pointer-events-none disabled:opacity-50',
        // 变体样式
        variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
        variant === 'secondary' && 'border border-gray-300 bg-white hover:bg-gray-50',
        variant === 'ghost' && 'hover:bg-gray-100 hover:text-gray-900',
        variant === 'destructive' && 'bg-red-600 text-white hover:bg-red-700',
        // 尺寸样式
        size === 'sm' && 'h-8 px-3 text-sm',
        size === 'md' && 'h-10 px-4',
        size === 'lg' && 'h-12 px-6 text-lg',
        className
      )}
      {...props}
    />
  )
}

// ❌ 避免内联样式（除动态数值外）
<div style={{ color: 'red', marginTop: '16px' }}>...</div>

// ✅ 动态数值使用 CSS 变量
<div
  style={{ '--progress': `${percent}%` } as React.CSSProperties}
  className="relative before:w-[var(--progress)]"
>
```

---

## 7. 错误处理规范

```typescript
// ✅ async/await 统一使用 try/catch
async function submitForm(data: FormData) {
  try {
    const response = await fetch('/api/submit', {
      method: 'POST',
      body: JSON.stringify(data),
      headers: { 'Content-Type': 'application/json' },
    })
    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.message ?? '提交失败')
    }
    return await response.json()
  } catch (error) {
    if (error instanceof Error) {
      throw error                       // 已知错误，继续抛出
    }
    throw new Error('发生未知错误')      // 未知错误，包装后抛出
  }
}

// ✅ 组件层面处理异步三态
function DataComponent() {
  const { data, error, isLoading } = useSWR('/api/data', fetcher)

  if (isLoading) return <LoadingSkeleton />
  if (error) return <ErrorMessage message={error.message} onRetry={mutate} />
  if (!data) return <EmptyState />
  return <DataView data={data} />
}
```
