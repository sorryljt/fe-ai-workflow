# 升级文档能力 设计文档

**日期**：2026-05-18
**状态**：已确认
**关联 PRD**：无

> **设计假设**（以下判断来自项目上下文推断，如有不符请指出具体条目）：
> 1. 活文档体系采用纯 Markdown，不引入 CSV 或数据库
> 2. ADR 编号从 `docs/adrs/` 目录下现有文件数量自动推算（不依赖外部计数器）
> 3. INIT 生成骨架时若文件已存在则跳过（不覆盖用户已有内容）
> 4. 工作流变更检测基于 git diff 对 `skills/` 和 `commands/` 路径的判断（在 DOCUMENT 第 1 步汇总产物时顺带执行）
> 5. ADR 状态变更：历史 ADR 是否被替代由用户判断，DOCUMENT 节点通过一次交互提示引导，用户指定编号后自动更新旧文件的状态字段

## 1. 背景

工作流 v0.3.0 完成类型合约节点后，文档体系暴露出以下短板：

1. **没有活文档**：DOCUMENT 节点只生成 ADR + CHANGELOG，不维护任何随项目演进的持久文档（组件目录、接口目录、架构速览）
2. **ADR 无编号无状态**：ADR 模板中编号为 `ADR-XXX` 占位符，状态永远是"已接受"，无废弃/替代机制，没有索引文件
3. **INIT 只生成知识地图**：不生成活文档骨架，新项目接入后其他 4 个活文档需要手动创建
4. **工作流自身变更无提示**：当需求修改了 `skills/` 或 `commands/` 时，DOCUMENT 不提示更新 `using-fe-workflow/SKILL.md` 和三端入口文件，容易造成平台间不一致

## 2. 目标

**要做的事**：

- [ ] INIT 节点新增第 6 步：生成 5 文件活文档骨架（已有文件跳过）
- [ ] DOCUMENT 节点改造：ADR 自动编号、条件更新活文档、维护 ADR 索引、CHANGELOG 归档指南
- [ ] ADR 状态机制：4 个状态，写入规范和 ADR 模板
- [ ] ADR 替代自动化：DOCUMENT 节点询问本次是否替代历史 ADR，用户指定编号后自动将旧 ADR 状态更新为 `已替代（见 ADR-XXX）`
- [ ] 工作流自身变更适配：检测到 `skills/` / `commands/` 变更时输出专项提示
- [ ] 新增 `references/living-docs-conventions.md`：活文档体系规范，供后续所有迭代参照

**不做的事**：

- 不新增 `/viktor:context`、`/viktor:digest` 节点（单独做）
- 不改变 `specs/plans/reviews/adrs` 的目录结构

## 3. 方案对比

### 活文档文件结构

| 方案 | 描述 | 优势 | 劣势 | 选择 |
|------|------|------|------|------|
| 方案 A：5 文件 Markdown | project-context + component-catalog + api-catalog + architecture + adrs/README | 结构清晰，每个文件职责单一，DOCUMENT 可精准更新对应文件 | 文件数量略多 | ✅ 选择 |
| 方案 B：单文件汇总 | 所有活文档合并成一个大 `docs/overview.md` | 简单，一处查阅 | 文件过大，DOCUMENT 更新时容易误伤其他章节 | ❌ 排除 |
| 方案 C：CSV + MD 混合 | 组件/接口用 CSV，叙述用 MD | 表格可被工具解析 | 需要两种格式维护，当前项目无 CSV 消费工具 | ❌ 排除 |

### ADR 编号方案

| 方案 | 描述 | 选择 |
|------|------|------|
| 读取 docs/adrs/ 文件数 +1 | 无需外部配置，自然递增 | ✅ 选择 |
| 用户手动指定 | 灵活但易遗漏 | ❌ 排除 |
| 全局计数器文件 | 需额外维护 `.adr-counter` | ❌ 排除 |

### ADR 替代自动化方案

| 方案 | 描述 | 选择 |
|------|------|------|
| DOCUMENT 主动询问，用户指定编号，自动更新旧文件 | 交互一次，精准修改 | ✅ 选择 |
| 完全手动（只写规范） | 零开发成本，但容易被遗忘 | ❌ 排除 |
| 自动扫描语义相关 ADR | 技术复杂，误判风险高 | ❌ 排除 |

## 4. 选定方案

**方案 A（5 文件 Markdown 活文档）+ docs/adrs/ 文件数自动编号 + DOCUMENT 引导式 ADR 替代更新**

原因：职责分离便于 DOCUMENT 节点针对性更新；编号自动推算无需用户介入；替代自动化通过一次交互实现，在"零负担"和"语义正确"之间取得最佳平衡。

## 5. 技术细节

### 5.1 活文档体系：5 个文件

```
docs/
├── project-context.md       # 项目知识地图（INIT 生成，已有）
├── component-catalog.md     # 组件目录（新，INIT 生成骨架，DOCUMENT 更新）
├── api-catalog.md           # API 接口目录（新，INIT 生成骨架，DOCUMENT 更新）
├── architecture.md          # 架构决策速览（新，INIT 生成骨架，DOCUMENT 更新）
└── adrs/
    └── README.md            # ADR 索引（新，DOCUMENT 维护）
```

### 5.2 ADR 状态机制

状态值（四选一）：

| 状态 | 含义 | 变更时机 |
|------|------|---------|
| `草稿` | 方案讨论中，未定稿 | BRAINSTORM 期间可用 |
| `已接受` | 决策已确认，正在执行 | DOCUMENT 节点默认写入 |
| `已废弃` | 此决策不再适用，未被替代 | 人工维护 |
| `已替代` | 被后续 ADR 取代，注明后继编号 | DOCUMENT 替代流程自动写入，格式：`已替代（见 ADR-002）` |

ADR 模板元信息变更：

```markdown
**状态**：草稿 / 已接受 / 已废弃 / 已替代（见 ADR-XXX）  ← 四选一
```

### 5.3 DOCUMENT 节点改造（新增逻辑）

在现有 5 步流程基础上，新增以下逻辑：

**第 1 步（扩展）—— 工作流自身变更检测**

汇总产物时额外执行：
```bash
git diff --name-only HEAD~1 HEAD | grep -E "^(skills/|commands/)"
```
若有输出（本次涉及 skills/ 或 commands/ 文件变更），在第 1 步末尾追加专项提示：

> ⚠️ **检测到工作流自身变更**
> 本次需求修改了 `skills/` 或 `commands/` 文件。
> 请在生成 ADR 后，手动确认以下文件是否已同步更新：
> - `skills/using-fe-workflow/SKILL.md`（命令速查表 / 自然语言路由）
> - `CLAUDE.md`（节点定义 / 产物目录）
> - `AGENTS.md`（Codex 触发表 / 节点说明）
> - `.cursor/rules/workflow.mdc`（Cursor 路由规则）

**第 3 步（扩展）—— ADR 自动编号 + 替代流程**

生成 ADR 前：
1. 统计 `docs/adrs/` 下 `.md` 文件数（排除 `README.md`）
2. 当前 ADR 编号 = 文件数 + 1，格式 `ADR-{三位数}`（如 `ADR-002`）
3. 询问用户：
   > "本次 ADR 是否替代了某条历史决策？请输入被替代的 ADR 编号（如 `ADR-001`），或输入「无」跳过。"
4. 若用户指定编号：
   - 定位对应的 ADR 文件（`docs/adrs/` 下文件名含该编号）
   - 将其 `**状态**` 字段更新为 `已替代（见 ADR-{当前编号}）`
   - 将其加入本次 git commit
5. 写入当前 ADR，状态默认为 `已接受`

**第 4 步（扩展）—— 条件更新活文档**

根据本次需求的变更类型，有条件地更新：

| 变更类型 | 更新目标 | 更新规则 |
|---------|---------|---------|
| 新增/修改组件 | `docs/component-catalog.md` | 追加或更新组件行 |
| 新增/修改 API 路由 | `docs/api-catalog.md` | 追加或更新接口行 |
| 重要架构决策 | `docs/architecture.md` | 追加决策摘要一行 |
| 任意文档变更 | `docs/adrs/README.md` | 追加新 ADR 索引行 |

若 `project-context.md` 存在，同步更新其「最后更新」日期。
若上述活文档不存在，先创建骨架再更新。

### 5.4 INIT 节点改造（新增第 6 步）

生成 `project-context.md` 后，检查并生成其余 4 个活文档骨架（文件已存在则跳过）：

```
component-catalog.md  → 骨架：表头 + 维护说明
api-catalog.md        → 骨架：表头 + 维护说明
architecture.md       → 骨架：章节标题 + 维护说明
docs/adrs/README.md   → 骨架：ADR 索引表头 + 维护说明
```

### 5.5 references/living-docs-conventions.md 内容结构

```
## 1. 文件清单与职责
   5 个文件各自的更新触发条件和负责节点

## 2. 更新原则
   追加不覆盖；保持机器可读的 Markdown 表格格式；每次 DOCUMENT 必须更新

## 3. ADR 状态机制
   4 个状态的定义、变更时机、替代流程说明

## 4. 工作流自身变更同步规范
   修改 skills/ 或 commands/ 时必须同步的文件清单

## 5. 活文档退化的识别与修复
   何时需要 /viktor:init 重新扫描；如何判断活文档已过期
```

## 6. 边界条件与错误处理

| 场景 | 处理方式 |
|------|---------|
| `docs/adrs/` 不存在 | DOCUMENT 第 3 步前自动创建目录，编号从 001 开始 |
| `docs/adrs/README.md` 不存在 | DOCUMENT 自动创建并写入表头 + 第一条记录 |
| INIT 时活文档文件已存在 | 跳过，不覆盖，提示"文件已存在，跳过" |
| git diff 命令不可用（非 git 项目） | 跳过工作流变更检测，不报错 |
| 活文档不存在但本次有对应变更 | 先创建骨架再追加 |
| 用户输入不存在的 ADR 编号 | 提示"未找到该编号对应文件，请重新输入或输入「无」跳过" |

## 7. 验收标准

- [ ] 执行 `/viktor:init` 后，`docs/` 下生成 5 个活文档文件（已存在的跳过）
- [ ] 执行 `/viktor:doc` 后，ADR 文件名和标题中有正确的三位数编号（不含 XXX 占位符）
- [ ] `docs/adrs/README.md` 中有当次 ADR 的索引条目
- [ ] 本次需求涉及组件变更时，`component-catalog.md` 有对应更新
- [ ] 本次需求涉及 API 变更时，`api-catalog.md` 有对应更新
- [ ] `architecture.md` 有当次重要决策的摘要条目
- [ ] 本次需求修改 `skills/` 时，DOCUMENT 输出工作流变更提示
- [ ] DOCUMENT 在生成 ADR 前询问是否替代历史 ADR
- [ ] 用户指定被替代 ADR 编号后，旧文件状态字段自动更新为 `已替代（见 ADR-XXX）`
- [ ] ADR 模板的状态字段体现 4 个可选值
- [ ] `references/living-docs-conventions.md` 存在且包含 ADR 状态说明、替代流程和工作流同步规范
