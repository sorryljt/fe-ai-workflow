---
name: 06-project-init
description: 项目知识地图初始化 - 扫描现有代码库生成 docs/project-context.md，供后续所有工作流节点共享，避免重复探索
---

# INIT — 项目知识地图

## 概述

在将工作流接入一个已有项目时，执行一次性扫描，生成 `docs/project-context.md`。
这份文档是项目的「知识地图」，后续每次 BRAINSTORM 时直接读取，无需重新探索项目结构。

## 触发条件

- 用户输入 `/viktor:init` 命令
- 首次在已有项目中使用工作流，`docs/project-context.md` 不存在
- 项目经过较大重构后需要更新知识地图

## 执行步骤

### 第 1 步：扫描项目结构

```bash
# 获取目录树（忽略 node_modules / .git / .next 等）
find . -type f \( -name "*.ts" -o -name "*.tsx" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.next/*" \
  -not -path "*/dist/*" \
  | sort
```

同时读取：
- `package.json`（依赖清单，了解可用的库）
- `tsconfig.json`（路径别名配置）
- `tailwind.config.ts`（设计系统配置）
- `vitest.config.ts` 或 `jest.config.ts`（测试环境）

### 第 2 步：识别并分类现有内容

按以下维度扫描并分类：

**组件（components/）**：
- UI 基础组件（Button, Input, Modal, Toast 等）
- 业务功能组件（各业务模块的组件）
- 布局组件（Header, Sidebar, Footer 等）

**自定义 Hooks（lib/hooks/ 或 hooks/）**：
- 列出所有 `use*.ts` 文件及其功能

**工具函数（lib/utils/ 或 utils/）**：
- 列出所有工具函数文件及其功能

**API 路由（app/api/）**：
- 列出现有路由路径和 HTTP 方法

**状态管理（store/ 或 lib/store/）**：
- Zustand store 文件列表

**类型定义（lib/types/ 或 types/）**：
- 核心类型文件

### 第 3 步：提取技术选型信息

从 `package.json` 的 `dependencies` 提取：

```
UI 框架：React + Next.js [版本]
样式方案：Tailwind CSS [版本] + [是否有 shadcn/ui 等组件库]
表单处理：[react-hook-form / 原生 useState / 其他]
数据获取：[SWR / React Query / 原生 fetch / 其他]
状态管理：[Zustand / Jotai / 无 / 其他]
HTTP 客户端：[axios / 原生 fetch]
日期处理：[dayjs / date-fns / 无]
测试：Vitest + [React Testing Library] + [MSW]
```

### 第 4 步：识别项目约定

通过读取现有代码，识别：

**命名约定**：
- 组件文件：PascalCase.tsx？camelCase.tsx？
- Hooks：use 前缀？
- 工具函数：camelCase？

**目录约定**：
- 组件和其测试是同目录（`Button.tsx` + `Button.test.tsx`）还是分离（`__tests__/`）？
- 组件和其类型是否分开放？

**已有设计系统**：
- 主色调配置（tailwind.config.ts 中的 theme.extend.colors）
- 已有的 cn() 工具？
- 已有的基础 Button/Input 组件（避免重复实现）

### 第 5 步：生成 project-context.md

保存到 `docs/project-context.md`，使用下方模板。

### 第 6 步：生成活文档骨架

`project-context.md` 保存后，逐一检查以下 4 个活文档文件。若文件**已存在**，跳过并提示"已存在，跳过"；若**不存在**，使用下方对应骨架模板创建：

**`docs/component-catalog.md`**：

```markdown
# 组件目录

> 由 `/viktor:init` 初始化，由 `/viktor:doc` 在每次需求完成后自动维护。
> 新增组件前先查阅此目录，避免重复实现。

## UI 基础组件

| 组件 | 文件路径 | 功能描述 | 引入版本 |
|------|---------|---------|---------|
| （示例）Button | `components/ui/Button.tsx` | 通用按钮，支持 variant/size | - |

## 业务组件

| 组件 | 文件路径 | 功能描述 | 引入版本 |
|------|---------|---------|---------|
| - | - | - | - |
```

**`docs/api-catalog.md`**：

```markdown
# API 接口目录

> 由 `/viktor:init` 初始化，由 `/viktor:doc` 在每次需求完成后自动维护。

## API 路由 / Server Actions

| 路由 / 函数 | 方法 | 功能描述 | 引入版本 |
|------------|------|---------|---------|
| （示例）/api/auth/login | POST | 用户登录，返回 JWT | - |
```

**`docs/architecture.md`**：

```markdown
# 架构决策速览

> 由 `/viktor:init` 初始化，由 `/viktor:doc` 在每次产出 ADR 后自动追加摘要。
> 完整决策背景见 `docs/adrs/` 目录。

## 决策记录

| 编号 | 决策摘要 | 日期 | 状态 | ADR 链接 |
|------|---------|------|------|---------|
| - | - | - | - | - |
```

**`docs/adrs/README.md`**：

```markdown
# ADR 索引

> Architecture Decision Records — 记录项目中所有重要的架构和技术决策。
> 每次 `/viktor:doc` 完成后自动追加新条目。

## 决策列表

| 编号 | 标题 | 日期 | 状态 | 链接 |
|------|------|------|------|------|
| - | - | - | - | - |
```

完成后统一 commit：

```bash
git add docs/project-context.md docs/component-catalog.md docs/api-catalog.md docs/architecture.md docs/adrs/README.md
git commit -m "docs: init project context and living doc skeleton"
```

---

## project-context.md 模板

```markdown
# 项目知识地图

**生成日期**：YYYY-MM-DD
**最后更新**：YYYY-MM-DD

> 此文件由 /viktor:init 命令生成，供工作流所有节点共享。项目有较大改动时重新运行 /viktor:init 更新。

## 技术选型

| 类别 | 选型 | 版本 | 备注 |
|------|------|------|------|
| 框架 | Next.js App Router | 14.x | - |
| 样式 | Tailwind CSS | 3.x | 有 cn() 工具 |
| 表单 | useState | - | 未引入 react-hook-form |
| 数据获取 | SWR | 2.x | Client Component 用 |
| 状态管理 | Zustand | 4.x | store/ 目录 |
| 测试 | Vitest + RTL + MSW | - | setup 在 src/test/ |

## 现有组件清单

### UI 基础组件（components/ui/）

| 组件 | 文件 | 功能 |
|------|------|------|
| Button | `components/ui/Button.tsx` | 通用按钮，支持 variant/size |
| Input | `components/ui/Input.tsx` | 文本输入框，支持 error 状态 |
| Modal | `components/ui/Modal.tsx` | 弹窗，支持 onClose 回调 |
| Toast | `components/ui/Toast.tsx` | 轻提示，使用 Zustand 驱动 |

> **新增 UI 组件前先检查此列表，避免重复实现。**

### 业务组件（components/features/）

| 组件 | 文件 | 功能 |
|------|------|------|
| [组件名] | `components/features/xxx.tsx` | [一句话描述] |

## 现有 Hooks（lib/hooks/）

| Hook | 文件 | 功能 |
|------|------|------|
| useAuth | `lib/hooks/useAuth.ts` | 用户认证状态，提供 user/logout |
| useToast | `lib/hooks/useToast.ts` | 调用 Toast 组件的便捷 hook |

## 现有工具函数（lib/utils/）

| 函数 | 文件 | 功能 |
|------|------|------|
| cn() | `lib/utils/cn.ts` | Tailwind 类名合并 |
| formatDate() | `lib/utils/formatDate.ts` | 日期格式化 |

## 现有 API 路由（app/api/）

| 路由 | 方法 | 功能 |
|------|------|------|
| /api/auth/login | POST | 用户登录 |
| /api/products | GET | 商品列表（分页） |

## 目录约定

```
组件位置：components/features/<feature-name>/
测试位置：与实现文件同目录（*.test.ts 或 *.test.tsx）
类型位置：lib/types/<domain>.ts
路径别名：@/ → src/
```

## 设计约束

- 已有 Toast 系统，错误提示统一用 `useToast()` hook，不要自己写 alert()
- 按钮统一用 `<Button>` 组件，不要裸写 `<button>`
- 表单错误展示参考 `components/features/LoginForm.tsx` 的现有模式
```

---

## 导航卡

执行完成后**必须**输出：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ INIT 已完成
📄 产物：docs/project-context.md（项目知识地图）
         docs/component-catalog.md（组件目录）
         docs/api-catalog.md（API 目录）
         docs/architecture.md（架构决策速览）
         docs/adrs/README.md（ADR 索引）
──────────────────────────────
▶ 下一步：输入 /viktor:think 开始第一个需求
  后续每次 BRAINSTORM 会自动读取知识地图
  每次 DOCUMENT 会自动更新活文档
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 验证标准

- [ ] `docs/project-context.md` 已生成并 committed
- [ ] 现有 UI 组件清单完整（覆盖 components/ui/）
- [ ] 技术选型信息准确（与 package.json 一致）
- [ ] 目录约定已记录（测试文件放哪、别名怎么用）
- [ ] `docs/component-catalog.md` 已生成（或已存在跳过）
- [ ] `docs/api-catalog.md` 已生成（或已存在跳过）
- [ ] `docs/architecture.md` 已生成（或已存在跳过）
- [ ] `docs/adrs/README.md` 已生成（或已存在跳过）
- [ ] 「设计约束」列出了至少 2-3 条团队已有的决策（避免 AI 重复造轮子）
