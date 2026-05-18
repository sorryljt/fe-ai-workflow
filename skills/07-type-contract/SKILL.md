---
name: 07-type-contract
description: 类型合约生成 - 从 tasks.md 或 design.md 提取结构化 TypeScript 类型定义，输出 docs/contracts/YYYY-MM-DD--<feature>.types.ts，作为 TDD 和 REVIEW 的共享类型锚点
---

# CONTRACT — 类型合约生成

## 概述

将 `tasks.md`（或 `design.md`）中散落的类型信息提取并规范化，生成一份机器可读的 TypeScript 类型合约文件。

**核心价值**：为工作流所有下游节点（TDD / REVIEW / DOCUMENT）提供统一的类型语言，消除节点间的"类型漂移"。

## 触发条件

- 用户输入 `/viktor:contract` 命令
- ANALYZE 节点完成后，用户选择先生成类型合约
- 自然语言触发：「生成类型合约」「锁定接口定义」「先定义类型」

## 前置产物检查

触发后，按以下优先级检查输入来源：

```
优先级 1 — docs/plans/ 下存在 tasks.md
  → 读取，从任务描述和验收标准中提取类型（精度最高）

优先级 2 — docs/specs/ 下存在 design.md（无 tasks.md）
  → 读取，从 §5.3 接口定义章节提取类型
  → 在产物顶部注释中标注："本合约基于 design.md 生成，精度次于 tasks.md 版本，
    建议在 /viktor:plan 完成后重新生成以补充细节"

优先级 3 — 两者均不存在
  → 停止，输出提示：
    "缺少上游产物。请先运行 /viktor:plan 生成任务列表，
     或运行 /viktor:think 生成设计文档，再执行 /viktor:contract。"
```

**重复触发处理**：若 `docs/contracts/` 下已存在对应合约文件，提示：
> "检测到已有合约文件：`docs/contracts/<existing>.types.ts`
> A) 覆盖（重新生成） B) 追加（补充新类型）
> 请选择："

## 执行步骤（严格按顺序）

### 第 1 步：读取输入文档

按前置产物检查结果读取对应文件，提取以下信息：
- 实体名称和字段（User、Order、Product 等）
- 组件名称和 Props（从 `[component]` 类型任务）
- API 端点的请求/响应结构（从 `[api]` 类型任务）
- 自定义 Hook 的状态和返回值（从 `[hook]` 类型任务）
- 状态管理的 store 结构（从 `[store]` 类型任务）
- 工具函数的参数和返回类型（从 `[utils]` 类型任务）

### 第 2 步：整理类型分组

将提取的类型按以下分组归类：

| 分组 | 内容 | 对应任务类型 |
|---|---|---|
| 实体类型 | 业务核心数据结构 | 所有任务共用 |
| 组件 Props | React 组件的输入接口 | `[component]` |
| API 请求/响应 | 接口通信类型 | `[api]` |
| 内部状态 | Hook / Store 的状态结构 | `[hook]` `[store]` |
| 工具函数签名 | 纯函数的参数/返回类型 | `[utils]` |

每个分组内：
- 按依赖关系排序（被依赖的类型在前）
- 相互独立的类型按字母顺序排列

### 第 3 步：生成 .types.ts 文件

按下方模板生成文件，保存到：
`docs/contracts/YYYY-MM-DD--<feature-name>.types.ts`

文件命名规则：与 design.md / tasks.md 的功能名保持一致。

### 第 4 步：自审（展示之前内部执行）

- [ ] 无 `any` 类型（若确实需要，改为 `unknown` 并添加注释说明原因）
- [ ] 无 `TODO` / `TBD` / `// 待定` 占位符
- [ ] 无重复定义（同一概念只定义一次）
- [ ] 所有类型名称使用 PascalCase
- [ ] 每个 `export` 都有 JSDoc 注释（至少一句话描述用途）
- [ ] 可选字段（`?`）使用合理（非可选字段不随意加 `?`）
- [ ] 联合类型优先使用字符串字面量而非宽泛的 `string`

### 第 5 步：单轮确认

展示完整文件内容，提问：
> "类型合约已生成，共 N 个类型定义，分 M 个分组。请确认类型结构是否符合预期，或指出需要调整的具体类型。"

收到确认后直接进入第 6 步；若有修改意见，只调整对应类型，修改完直接进第 6 步。

### 第 6 步：Commit 并输出导航卡

```bash
git add docs/contracts/
git commit -m "docs: add type contract for <feature-name>"
```

输出导航卡（见末尾「导航卡」章节）。

---

## 产物模板

```typescript
/**
 * @feature  [功能名称]
 * @design   docs/specs/YYYY-MM-DD--[feature].md
 * @tasks    docs/plans/YYYY-MM-DD--[feature]--tasks.md
 * @date     YYYY-MM-DD
 * @status   confirmed
 *
 * 本文件由 /viktor:contract 生成，作为以下节点的类型锚点：
 * - /viktor:code  (TDD 实现时 import 此文件中的类型)
 * - /viktor:cr    (REVIEW 时验证实现与合约的一致性)
 */

// ─── 实体类型 ─────────────────────────────────────────────────────────────────

/** [实体描述，一句话说明用途] */
export interface [EntityName] {
  id: string
  // ...字段
}

// ─── 组件 Props ───────────────────────────────────────────────────────────────

/** [ComponentName] 组件的输入 Props */
export interface [ComponentName]Props {
  // ...
}

// ─── API 请求 / 响应 ──────────────────────────────────────────────────────────

/** POST /api/[endpoint] 的请求体 */
export interface [ActionName]Request {
  // ...
}

/** POST /api/[endpoint] 的成功响应 */
export interface [ActionName]Response {
  // ...
}

// ─── 内部状态 ─────────────────────────────────────────────────────────────────

/** use[FeatureName] Hook 的状态结构 */
export interface [FeatureName]State {
  // ...
}

// ─── 工具函数签名 ─────────────────────────────────────────────────────────────

/** [functionName] 的参数类型 */
export type [FunctionName]Params = {
  // ...
}
```

---

## 边界条件处理

| 场景 | 处理方式 |
|---|---|
| 无上游产物 | 停止，引导先跑 `/viktor:plan` 或 `/viktor:think` |
| 只有 design.md | 执行，产物顶部标注精度说明 |
| 合约文件已存在 | 询问覆盖或追加，用户选择后执行 |
| 提取出 `any` 类型 | 自审阶段拦截，改为 `unknown` 或具体类型 |
| 类型之间存在循环依赖 | 提取为 `type` 而非 `interface`，或使用 `interface` 声明合并 |
| 某任务类型信息不足 | 在对应类型上方添加注释 `// NOTE: 字段待补充，依赖 T00X 实现细节` |

---

## 反理由表

| 借口 | 反驳 |
|---|---|
| "类型 TDD 写的时候再定义" | TDD 时临时定义的类型往往和设计意图有偏差，合约确保设计意图提前锁定 |
| "design.md 里已经有类型了" | design.md 是散落的 Markdown，不能直接 import，合约是结构化的可执行文件 |
| "小需求不需要合约" | ANALYZE 已经帮你判断了，如果你选择了 /viktor:contract，说明确实需要 |
| "类型后面会变的" | 变了就更新合约文件，合约是设计决策的记录，修改合约等于修改设计 |

---

## 验证标准

CONTRACT 成功完成的标志：
- [ ] `docs/contracts/YYYY-MM-DD--<feature>.types.ts` 已创建并 committed
- [ ] 文件顶部有完整的 JSDoc 文件头（@feature / @design / @tasks / @date / @status）
- [ ] 所有分组均有分隔注释（`// ─── 分组名 ───`）
- [ ] 无 `any` / 无 `TODO` / 无重复定义
- [ ] 每个 `export` 有 JSDoc 注释
- [ ] 用户已明确确认类型结构

---

## 导航卡

节点完成后**必须**输出：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ CONTRACT 已完成
📄 产物：docs/contracts/YYYY-MM-DD--<feature>.types.ts
──────────────────────────────
▶ 下一步：输入 /viktor:code
  TDD 实现时请 import 合约文件中的类型，以确保实现与合约一致
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
