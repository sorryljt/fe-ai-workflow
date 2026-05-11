# 项目知识地图

**生成日期**：2026-05-07
**最后更新**：2026-05-07

> 此文件为 `/viktor:init` 产物示例，用于说明 `docs/project-context.md` 的预期结构和信息密度。

## 技术选型

| 类别 | 选型 | 版本 | 备注 |
|------|------|------|------|
| 框架 | Next.js App Router | 14.x | 示例值 |
| 样式 | Tailwind CSS | 3.x | 有 `cn()` 工具 |
| 表单 | useState | - | 未引入 `react-hook-form` |
| 数据获取 | SWR | 2.x | Client Component 用 |
| 状态管理 | Zustand | 4.x | `store/` 目录 |
| 测试 | Vitest + RTL + MSW | - | 示例值 |

## 现有组件清单

### UI 基础组件（components/ui/）

| 组件 | 文件 | 功能 |
|------|------|------|
| Button | `components/ui/Button.tsx` | 通用按钮，支持 variant/size |
| Input | `components/ui/Input.tsx` | 文本输入框，支持 error 状态 |
| Modal | `components/ui/Modal.tsx` | 弹窗，支持 `onClose` 回调 |

### 业务组件（components/features/）

| 组件 | 文件 | 功能 |
|------|------|------|
| LoginForm | `components/features/auth/LoginForm.tsx` | 登录表单和校验反馈 |

## 现有 Hooks（lib/hooks/）

| Hook | 文件 | 功能 |
|------|------|------|
| useAuth | `lib/hooks/useAuth.ts` | 用户认证状态和登出逻辑 |
| useToast | `lib/hooks/useToast.ts` | Toast 调用封装 |

## 现有工具函数（lib/utils/）

| 函数 | 文件 | 功能 |
|------|------|------|
| cn | `lib/utils/cn.ts` | Tailwind 类名合并 |
| formatDate | `lib/utils/formatDate.ts` | 日期格式化 |

## 现有 API 路由（app/api/）

| 路由 | 方法 | 功能 |
|------|------|------|
| /api/auth/login | POST | 用户登录 |
| /api/products | GET | 商品列表查询 |

## 目录约定

```text
组件位置：components/features/<feature-name>/
测试位置：与实现文件同目录（*.test.ts 或 *.test.tsx）
类型位置：lib/types/<domain>.ts
路径别名：@/ → src/
```

## 设计约束

- 错误提示统一通过 `useToast()` 输出，不直接使用 `alert()`
- 按钮优先复用 `<Button>`，不要重复造基础交互组件
- 表单校验模式优先参考现有 `LoginForm` 实现
