# CONTRACT 节点设计文档

**日期**：2026-05-18
**状态**：已确认
**功能名**：新增 CONTRACT 节点 — 类型合约接入工作流

---

> **设计假设**（以下判断来自对话上下文推断，如有不符请在确认时指出具体条目）：
> 1. 节点编号为 `07`（`06` 已被 project-init 占用），命令为 `/viktor:contract`
> 2. 产物为纯 `.ts` 文件 + JSDoc 注释，而非另加 `.md` 说明文档（TypeScript 本身即是"可读的共享语言"，JSDoc 足够表达设计决策）
> 3. ANALYZE 给建议、用户自由选择，不设强制跳过理由
> 4. 前置产物优先级：`tasks.md` > `design.md` > 停止并引导
> 5. 版本号升级至 `v0.3.0`（新增节点 = workflow 行为变更）

---

## 1. 背景

工作流各节点间的类型定义目前是**隐式的**：

- `design.md` 的 §5.3 接口定义只是模板建议，不强制
- ANALYZE → TDD 之间靠 AI 自由解读自然语言来推断类型
- 每次对话重启后，AI 重新"发明"类型，与上次可能不一致
- REVIEW 没有明确的类型基准可供核对

结果：相邻节点之间存在"类型漂移"，节点越多漂移越大。

## 2. 目标

**要做的事**：
- [ ] 新增 `CONTRACT` 节点（`/viktor:contract`），生成机器可读的类型合约文件
- [ ] `ANALYZE` 节点根据任务构成智能推荐是否执行 CONTRACT，导航卡提供双路选项
- [ ] `TDD` 节点感知合约文件，存在时将其作为类型锚点
- [ ] `REVIEW` 节点在合约存在时增加类型一致性检查轴
- [ ] 所有配置入口文件（CLAUDE.md / AGENTS.md / workflow.mdc / README.md）同步更新

**不做的事**：
- 不做 JSON Schema 格式（TypeScript 与业务代码直接兼容，无需额外格式）
- 不做类型合约的运行时校验（静态定义即可）
- 不做合约版本管理（当前阶段无此需求）
- 不改变其他节点（BRAINSTORM / DOCUMENT）的核心行为

## 3. 方案对比

| 维度 | 方案 A：CONTRACT 作为独立节点 | 方案 B：在 ANALYZE 内集成 |
|---|---|---|
| 职责清晰度 | 独立、一等公民 | 混入 ANALYZE，职责混合 |
| 命令可见性 | `/viktor:contract` 可单独触发 | 无独立命令 |
| 小需求适配 | ANALYZE 推荐 + 用户选择，灵活 | 强制执行，不灵活 |
| 改动范围 | 新增 SKILL + 改 4 个节点 | 只改 ANALYZE，但效果打折 |
| 一致性 | 与现有节点模式完全一致 | 破坏节点单一职责 |

**选择方案 A**：CONTRACT 作为独立节点，通过 ANALYZE 的智能推荐实现"按需触发"。

## 4. 技术细节

### 4.1 工作流新全貌

```
/viktor:think → /viktor:plan → [/viktor:contract] → /viktor:code → /viktor:cr → /viktor:doc
                                      ↑
                              ANALYZE 智能推荐，用户决定执行与否
```

### 4.2 CONTRACT 节点规范

**命令**：`/viktor:contract`
**Skill 文件**：`skills/07-type-contract/SKILL.md`
**产物路径**：`docs/contracts/YYYY-MM-DD--<feature>.types.ts`

**产物格式**（TypeScript + JSDoc）：

```typescript
/**
 * @feature 用户登录
 * @design  docs/specs/2026-05-18--user-login.md
 * @tasks   docs/plans/2026-05-18--user-login--tasks.md
 * @date    2026-05-18
 * @status  confirmed
 */

// ─── 实体类型 ────────────────────────────────────────
/** 已认证用户的核心数据结构 */
export interface User {
  id: string
  email: string
  name: string
}

// ─── 组件 Props ──────────────────────────────────────
export interface LoginFormProps {
  onSuccess: (user: User) => void
  redirectUrl?: string
}

// ─── API 请求 / 响应 ─────────────────────────────────
export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  user: User
  token: string
}

// ─── 内部状态 ────────────────────────────────────────
export interface LoginFormState {
  email: string
  password: string
  errors: Partial<Record<'email' | 'password', string>>
  isSubmitting: boolean
}
```

**前置产物检查逻辑**：

```
/viktor:contract 触发时：
  ├── docs/plans/ 存在 tasks.md  → 读取，提取类型（精度最高）
  ├── 只有 docs/specs/ 存在 design.md → 读取，从接口定义章节提取（精度次之）
  └── 两者都不存在 → 停止，提示：
      "缺少上游产物，请先运行 /viktor:plan 生成任务列表，
       或运行 /viktor:think 生成设计文档。"
```

**执行步骤**：
1. 检查前置产物（见上）
2. 识别需要定义的类型分组：实体 / 组件 Props / API 请求响应 / 内部状态 / 工具函数签名
3. 生成 `.types.ts`，按分组用分隔注释组织，每个 `export` 附 JSDoc
4. 自审：无 `any`、无 `TODO`、无重复定义、命名符合 PascalCase
5. 展示并单轮确认
6. Commit + 输出导航卡

**导航卡**：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CONTRACT 已完成
📄 产物：docs/contracts/YYYY-MM-DD--<feature>.types.ts
──────────────────────────────
▶ 下一步：输入 /viktor:code
  TDD 实现将以合约文件作为类型锚点
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 4.3 ANALYZE 节点改动

在第 5 步生成 tasks.md 之后，增加一步评估：

**推荐规则**：

| 任务构成 | 推荐 |
|---|---|
| 含 `[api]` 类型任务 | ✅ 推荐 CONTRACT |
| 含 `[hook]` 或 `[store]` 类型任务 | ✅ 推荐 CONTRACT |
| 多个组件共享同一数据结构 | ✅ 推荐 CONTRACT |
| 涉及跨模块类型复用 | ✅ 强烈推荐 |
| 全部为 `[utils]` / `[style]` 类型 | ⏭ 建议跳过 |
| 任务总数 ≤ 3 且无 API 接口 | ⏭ 建议跳过 |

**导航卡（推荐执行 CONTRACT 时）**：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ANALYZE 已完成
📄 产物：docs/plans/YYYY-MM-DD--tasks.md（N 个任务）
──────────────────────────────
📋 检测到 [api] / [hook] 类型任务，建议先锁定类型合约

▶ 选项 A（推荐）：/viktor:contract  生成类型合约
▶ 选项 B：/viktor:code              跳过合约，直接 TDD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**导航卡（建议跳过 CONTRACT 时）**：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ANALYZE 已完成
📄 产物：docs/plans/YYYY-MM-DD--tasks.md（N 个任务）
──────────────────────────────
💡 本次需求较简单，可直接进入 TDD

▶ 下一步（推荐）：/viktor:code      开始 TDD
▶ 也可以：/viktor:contract          仍然生成类型合约
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 4.4 TDD 节点改动

在第 1 步"从 tasks.md 取任务"**之前**，增加合约感知步骤：

```
检查 docs/contracts/ 下是否存在对应 .types.ts 文件：
- 存在 → 读取，记录到对话上下文：
  "已加载类型合约：docs/contracts/YYYY-MM-DD--<feature>.types.ts
   写测试和实现时，import 类型应来自此文件"
- 不存在 → 正常继续，无需提示
```

### 4.5 REVIEW 节点改动

增加第六检查轴（仅当 `docs/contracts/` 存在合约文件时执行）：

**轴六：类型合约一致性**
- [ ] 实现代码中使用的 interface / type 与合约文件定义一致
- [ ] 无未声明的新类型（若有，评估是否需补入合约）
- [ ] API 请求/响应类型与合约完全匹配
- [ ] 无直接 `import type { X } from '../../../types'` 绕过合约的情况

### 4.6 产物目录新增

```
docs/
├── contracts/          ← 新增
│   └── YYYY-MM-DD--<feature>.types.ts
├── specs/
├── plans/
├── reviews/
└── adrs/
```

### 4.7 需要同步的文件清单

| 文件 | 改动内容 |
|---|---|
| `skills/07-type-contract/SKILL.md` | 新建 |
| `commands/viktor/contract.md` | 新建 |
| `.claude/commands/viktor/contract.md` | 新建 |
| `skills/02-requirements-analysis/SKILL.md` | 推荐逻辑 + 双路导航卡 |
| `skills/03-tdd-cycle/SKILL.md` | 合约感知步骤 |
| `skills/04-code-review/SKILL.md` | 轴六：类型一致性检查 |
| `skills/using-fe-workflow/SKILL.md` | 命令速查表新增 CONTRACT 行 |
| `CLAUDE.md` | 产物目录 + 节点说明 + 命令表 |
| `AGENTS.md` | 同步（Codex 入口） |
| `.cursor/rules/workflow.mdc` | 同步（Cursor 入口） |
| `README.md` | 版本号 v0.3.0 + 工作流图 + 命令表 |
| `docs/team-workflow-guide.md` | 版本号 v0.3.0 |

## 5. 边界条件与错误处理

| 场景 | 处理方式 |
|---|---|
| 单独触发，无任何上游产物 | 停止，引导先跑 `/viktor:plan` |
| 单独触发，只有 design.md | 执行，但在输出中标注"精度次于 tasks.md 版本" |
| ANALYZE 建议跳过，用户仍执行 | 正常执行，不阻拦 |
| 合约文件已存在（重复触发） | 提示已有合约，询问是否覆盖还是追加 |
| 生成的类型含 `any` | 自审阶段拦截，提示补充具体类型 |

## 6. 验收标准

- [ ] `/viktor:contract` 可独立触发，前置产物检查逻辑正确
- [ ] 前置产物缺失时给出明确引导，不报错退出
- [ ] 产物文件路径符合规范：`docs/contracts/YYYY-MM-DD--<feature>.types.ts`
- [ ] 产物无 `any`、无 `TODO`、每个 export 有 JSDoc
- [ ] ANALYZE 导航卡根据任务类型正确给出差异化推荐
- [ ] TDD 节点能感知合约文件并在对话中标注
- [ ] REVIEW 节点在合约存在时执行类型一致性检查（第六轴）
- [ ] 所有配置文件版本号更新到 v0.3.0
- [ ] `AGENTS.md` / `workflow.mdc` / `README.md` / `team-workflow-guide.md` 内容与 CLAUDE.md 一致
