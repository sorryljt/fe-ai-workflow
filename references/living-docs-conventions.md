# 活文档体系规范

> 本文件定义工作流中活文档（Living Documents）的维护规则，供所有团队成员和 AI 节点参照。
> 活文档随项目演进持续更新，而非一次性产出后就归档。

---

## 1. 文件清单与职责

工作流维护以下 5 个活文档文件，均位于 `docs/` 目录：

| 文件 | 职责 | 由谁初始化 | 由谁更新 |
|------|------|-----------|---------|
| `docs/project-context.md` | 项目技术选型、目录约定、设计约束（知识地图） | `/viktor:init` | `/viktor:init`（重跑）或人工 |
| `docs/component-catalog.md` | 现有组件目录，新增组件前必须查阅 | `/viktor:init`（骨架） | `/viktor:doc`（每次需求后） |
| `docs/api-catalog.md` | 现有 API 路由和 Server Action 目录 | `/viktor:init`（骨架） | `/viktor:doc`（每次需求后） |
| `docs/architecture.md` | 重要架构决策的速览摘要 | `/viktor:init`（骨架） | `/viktor:doc`（每次产出 ADR 后） |
| `docs/adrs/README.md` | 所有 ADR 的索引表 | `/viktor:init`（骨架） | `/viktor:doc`（每次产出 ADR 后） |

> `/viktor:init` 只生成骨架（文件已存在则跳过），不扫描填充内容。
> `/viktor:doc` 在每次需求的文档沉淀阶段，根据变更类型有条件地追加或更新对应文件。

---

## 2. 更新原则

**追加而非覆盖**：活文档的更新方式是在现有内容末尾追加新行，或修改已存在行，不得删除历史记录。

**保持机器可读格式**：活文档的核心内容使用 Markdown 表格，便于 AI 节点扫描和追加：

```markdown
| 列 A | 列 B | 列 C |
|------|------|------|
| 现有行 1 | ... | ... |
| 新追加行 | ... | ... |   ← 追加到这里
```

**每次 DOCUMENT 必须更新**：每次运行 `/viktor:doc` 时，至少更新 `docs/adrs/README.md`（追加当次 ADR 索引）。其他文件按变更类型有条件更新，不强制全部修改。

**不写"待填写"占位符**：若某个字段暂时未知，宁可省略该行，也不要写"TODO"或"待填写"。

---

## 3. ADR 状态机制

每篇 ADR（架构决策记录）都有一个 `**状态**` 字段，反映该决策当前的生命周期阶段。

### 合法状态值（四选一）

| 状态 | 含义 | 典型变更时机 |
|------|------|------------|
| `草稿` | 方案仍在讨论，尚未做出最终决策 | BRAINSTORM 期间创建的临时 ADR |
| `已接受` | 决策已确认，正在或已经执行 | `/viktor:doc` 节点默认写入 |
| `已废弃` | 此决策不再适用，且未被其他 ADR 替代 | 人工维护，例如某技术方案被放弃 |
| `已替代` | 此决策已被更新的 ADR 取代 | `/viktor:doc` 替代流程自动写入 |

### 替代流程

当新需求的决策覆盖了历史决策时，在 `/viktor:doc` 阶段：

1. 工作流询问用户："本次 ADR 是否替代了某条历史 ADR？请输入编号或输入「无」跳过。"
2. 用户指定编号后，工作流自动将对应历史 ADR 的 `**状态**` 字段更新为：
   ```
   已替代（见 ADR-{新 ADR 编号}）
   ```
3. 被替代 ADR 的正文内容**不删除**，完整保留供追溯。

### 状态字段格式

在 ADR 文件的元信息部分：

```markdown
**状态**：已接受
```

或（被替代时）：

```markdown
**状态**：已替代（见 ADR-003）
```

---

## 4. 工作流自身变更同步规范

当一次需求的实现内容涉及修改工作流本身的规则文件时（`skills/` 或 `commands/` 目录下的文件），必须同步更新以下四个入口文件，确保三端一致：

| 文件 | 平台 | 需要同步的内容 |
|------|------|-------------|
| `skills/using-fe-workflow/SKILL.md` | 所有平台（元调度器） | 命令速查表、自然语言路由、Skill 映射 |
| `CLAUDE.md` | Claude Code | 节点定义、产物目录、SKILL 对照 |
| `AGENTS.md` | OpenAI Codex | 触发表、节点说明、产物目录 |
| `.cursor/rules/workflow.mdc` | Cursor | 路由规则、节点说明、产物目录 |

**检测机制**：`/viktor:doc` 节点会在第 1 步自动执行 git diff 检测，若发现 `skills/` 或 `commands/` 路径变更，会输出提示列出上述四个文件，提醒人工确认。

**同步原则**：
- `CLAUDE.md` 是最完整的版本，以它为基准
- `AGENTS.md` 和 `workflow.mdc` 可以简化，但不能与 `CLAUDE.md` 逻辑矛盾
- `skills/using-fe-workflow/SKILL.md` 中的命令速查表必须与三端入口的命令列表一致

---

## 5. 活文档退化的识别与修复

活文档有时会与项目实际状态产生偏差，称为"退化"。以下情况说明需要更新：

### 识别退化信号

| 信号 | 对应文件 | 处理方式 |
|------|---------|---------|
| BRAINSTORM 时 AI 提出的组件与 component-catalog.md 中已有组件重复 | `component-catalog.md` | 说明目录未及时更新，手动补录缺失的组件 |
| API 路由在代码中存在但 api-catalog.md 没有记录 | `api-catalog.md` | 手动追加，或重跑 `/viktor:init` 重新扫描 |
| project-context.md 的技术选型与 package.json 不符 | `project-context.md` | 重跑 `/viktor:init` 更新知识地图 |
| ADR 索引与实际 ADR 文件数量不符 | `docs/adrs/README.md` | 手动对齐，补录缺失的索引行 |

### 重跑 `/viktor:init` 的时机

以下情况建议重跑 `/viktor:init` 而非手动修复：

- 项目进行了大规模重构（组件目录结构变化）
- 引入了新的技术栈（新增状态管理库、换了 HTTP 客户端等）
- `docs/project-context.md` 中有超过 30% 的内容已过期

重跑时，`/viktor:init` 会更新 `project-context.md`，**不会覆盖**其他 4 个活文档文件（需手动修订）。
