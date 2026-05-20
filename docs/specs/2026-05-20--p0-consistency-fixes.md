# P0 修复批次：三端一致性 + 命名 Bug 修复

**日期**：2026-05-20
**状态**：已确认
**改动性质**：Workflow-Meta（纯文档修正，无代码）

> **设计假设**（以下判断来自项目上下文推断，用户已确认）：
> 1. 本次为 Workflow-Meta 改动，无可运行代码，不走 TDD 节点
> 2. P0-4 中的 `skills/08-context/SKILL.md` 缺失提示问题已在 ADR-005 期间修复（当前文件内容验证一致），本次不重复改动
> 3. `skills/05-documentation/SKILL.md` step 6 的 `project-context.md` 遗漏问题已在当前文件中修复（已包含在 git add 命令中），本次不重复改动
> 4. Cursor workflow.mdc 技术栈一节改为"从 project-context.md 读取"而非删除，保留指引价值

## 1. 背景

v0.7.0 后积累了 4 组 P0 级问题，均为文字层面的不一致或错误命名，会直接影响 AI 在三端（Claude Code / Codex / Cursor）的路由和执行行为。主要来源：Codex 的三端漂移分析 + 对所有 SKILL.md 的逐文件审查。

## 2. 目标

**要做的事**：
- [ ] 修复 Cursor 三处命令/行为漂移，使三端行为一致
- [ ] 修正 `using-fe-workflow` 中过时的 digest 触发描述
- [ ] 统一 REVIEW Skill 中"五轴 / 六轴"标签
- [ ] 修复 3 个遗留 [SUGGESTED] 问题（contract 歧义、documentation step4 框架标签、brainstorm step1 重叠）

**不做的事**：
- 不涉及 P1-P3 的改动（单独迭代）
- 不修改任何业务逻辑或流程顺序
- 不新增文件

## 3. 变更详情（按文件）

### 文件 1：`.cursor/rules/workflow.mdc`（8 处）

| 位置 | 当前内容 | 修改为 |
|------|---------|--------|
| BRAINSTORM 触发行 | `触发：/brainstorm 或检测到模糊需求` | `触发：/viktor:think 或检测到模糊需求` |
| BRAINSTORM 执行步骤 2 | `通过苏格拉底式提问逐步澄清需求（每次只问一个问题）` | `识别关键决策点，一次性批量提出最多 3 个问题；可由上下文推断的直接采用并在假设中声明` |
| BRAINSTORM 执行步骤 5 | `提示进入 /analyze` | `提示进入 /viktor:plan` |
| ANALYZE 触发行 | `触发：/analyze 或 BRAINSTORM 完成` | `触发：/viktor:plan 或 BRAINSTORM 完成` |
| TDD 触发行 | `触发：/tdd` | `触发：/viktor:code` |
| REVIEW 触发行 | `触发：/review` | `触发：/viktor:cr` |
| TDD 执行步骤 8 | `提示进入 /review` | `提示进入 /viktor:cr` |
| `## 技术栈` 一节 | 硬编码 `React / Next.js 14 App Router / TypeScript...` | 改为动态引用 project-context.md |

### 文件 2：`skills/using-fe-workflow/SKILL.md`（1 处）

| 位置 | 当前内容 | 修改为 |
|------|---------|--------|
| 命令速查表 digest 行 | `随时手动执行，或 ADR 累积到 5 的倍数时响应 DOCUMENT 建议` | `随时手动执行，或响应每次 DOCUMENT 完成后的非阻塞建议（无条件触发，不依赖 ADR 数量）` |

### 文件 3：`skills/04-code-review/SKILL.md`（2 处）

| 位置 | 当前内容 | 修改为 |
|------|---------|--------|
| 正文章节标题 | `## 五轴审查框架` | `## 六轴审查框架` |
| review.md 模板内 | `## 五轴审查结果` | `## 六轴审查结果` |

### 文件 4：`commands/viktor/contract.md`（1 处）

| 位置 | 当前内容 | 修改为 |
|------|---------|--------|
| 第 5 节标题 | `## 5. 执行中 Hard Gate` | `## 5. 执行中约束（会话锁）` |
| 第 5 节说明 | 措辞隐含"必须前置条件" | 补充说明本约束仅在执行过程中生效，CONTRACT 节点本身为可选 |

### 文件 5：`skills/05-documentation/SKILL.md`（2 处）

| 位置 | 当前内容 | 修改为 |
|------|---------|--------|
| Step 4 表格第 1 行 | `新增或修改了 React 组件` | `新增或修改了前端组件（React / Vue / Svelte 等）` |
| Step 4 表格第 2 行 | `新增或修改了 API 路由 / Server Action` | `新增或修改了 API 路由 / 接口函数` |

### 文件 6：`skills/01-brainstorming/SKILL.md`（1 处）

| 位置 | 当前内容 | 修改为 |
|------|---------|--------|
| Step 1 末尾"额外执行"列表 | `- 查看 docs/specs/ 下已有的 design.md（避免重复）` | 删除此行（冷启动步骤已完成此扫描，语义重叠） |

## 4. 验收标准

- [ ] `workflow.mdc` 中不再出现 `/brainstorm`、`/analyze`、`/tdd`、`/review` 旧命令名
- [ ] `workflow.mdc` BRAINSTORM 步骤描述与 `skills/01-brainstorming/SKILL.md` 行为一致（批量 3 问）
- [ ] `workflow.mdc` 技术栈一节不再硬编码框架版本
- [ ] `using-fe-workflow/SKILL.md` digest 描述与 `skills/05-documentation/SKILL.md` 第 7 步导航卡一致
- [ ] `skills/04-code-review/SKILL.md` 全文只出现"六轴"，不出现"五轴"
- [ ] `commands/viktor/contract.md` 第 5 节不再使用"Hard Gate"术语，措辞清楚区分可选节点与执行中约束
- [ ] `skills/05-documentation/SKILL.md` step 4 不再出现 React 专属术语
- [ ] `skills/01-brainstorming/SKILL.md` step 1 不再有重复的 docs/specs/ 扫描说明
