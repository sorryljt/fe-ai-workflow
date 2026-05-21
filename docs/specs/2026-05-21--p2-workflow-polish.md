# P2 工作流打磨批次 设计文档

**日期**：2026-05-21
**状态**：已确认
**关联 PRD**：内部优化（来自整体分析清单 P2 级别）

> **设计假设**（以下判断来自项目上下文推断，如有不符请在确认时指出具体条目）：
> 1. P2-1 frontmatter 格式采用 YAML（`---` 包裹），与 SKILL.md 本身的 frontmatter 风格保持一致
> 2. P2-1 同时更新"写入方"（BRAINSTORM / ANALYZE / REVIEW 模板）和"读取方"（DIGEST step 2），否则 frontmatter 无实际价值
> 3. P2-1 不更新 BRAINSTORM 冷启动展示逻辑（目前按文件名展示 spec 列表已够用）
> 4. P2-2 Workflow-Meta Lane 补充到 `skills/using-fe-workflow/SKILL.md`，同时在 `CLAUDE.md` 工作流概览注释中添加一行说明
> 5. P2-3 commit 粒度以文档建议形式写入 TDD SKILL，不引入新的用户交互（用户无需在 TDD 开始时选择模式）

## 1. 背景

P0/P1 批次完成了一致性修复和运行时稳定性修复。P2 批次解决三组"易用性与可维护性"问题，这些问题不导致行为错误，但在长期使用中会引发摩擦：

1. **P2-1：产物文档缺少机器可读状态字段**。当前 specs/plans/reviews 的状态（已确认/完成/PASS）只存在于文档正文，DIGEST 需要扫描正文文字来识别状态，脆弱且难以扩展。引入 YAML frontmatter 后，状态字段结构化，未来工具（脚本/验证器）可直接解析。

2. **P2-2：Workflow-Meta Lane 未正式化**。对工作流自身（skills/、commands/）做修改时，不走 TDD（无可运行代码），但当前 SKILL 文档中没有正式描述这条"元通道"的触发条件、行为约定和验收方式，导致每次执行时需要临时判断。

3. **P2-3：TDD commit 粒度无指导**。TDD SKILL 规定了任务循环（红→绿→重构），但没有说明何时提交 git commit。实践中有两种合理选择：每任务提交 vs. 按里程碑提交，缺少建议导致行为不一致。

## 2. 目标

**要做的事**：
- [x] P2-1：为 BRAINSTORM / ANALYZE / REVIEW 的输出模板添加 YAML frontmatter，为 DIGEST step 2 添加 frontmatter 读取逻辑
- [x] P2-2：在 `skills/using-fe-workflow/SKILL.md` 新增"Workflow-Meta Lane"章节，在 CLAUDE.md 工作流概览添加注释行
- [x] P2-3：在 TDD SKILL 任务循环中添加 commit 粒度建议

**不做的事（明确边界）**：
- 不修改 BRAINSTORM 冷启动 spec 列表展示逻辑（文件名展示已够用）
- 不引入 frontmatter 解析脚本（P3-2 的范围）
- 不让 TDD 开始时增加"选择 commit 模式"的交互（过度设计）
- 不修改三端入口（P2 均为 SKILL 内部逻辑，不改节点行为语义）

## 3. 方案对比

### P2-1 frontmatter 字段设计

| 方案 | 描述 | 选择结果 |
|------|------|---------|
| 正文字段（现状） | 状态写在正文 `**状态**：已确认` | ❌ 不可机器解析 |
| YAML frontmatter（选择） | `---\nstatus: confirmed\n---` 放在文件开头 | ✅ 结构化、可解析 |
| JSON sidecar 文件 | 每个 .md 旁放一个 .json | ❌ 文件数翻倍，维护成本高 |

### P2-2 Lane 文档位置

| 方案 | 描述 | 选择结果 |
|------|------|---------|
| 新建独立 SKILL 文件 | `skills/10-workflow-meta/SKILL.md` | ❌ 过重，与 using-fe-workflow 职责重叠 |
| 写入 using-fe-workflow/SKILL.md（选择） | 元调度器本就负责路由决策，在此描述最合适 | ✅ |
| 只写入 CLAUDE.md | 仅有精简描述，无执行细节 | ❌ 不够完整 |

### P2-3 commit 粒度

| 方案 | 描述 | 选择结果 |
|------|------|---------|
| 每任务提交（选择） | 每个任务红→绿→重构完成后立即 commit | ✅ 默认推荐，原子粒度，便于回滚 |
| 里程碑提交 | 一组关联任务完成后合并提交 | ✅ 允许，用户在 tasks.md 注释 `[commit]` 标记里程碑 |
| 全部完成后提交 | 所有任务完成才 commit | ❌ 回滚单位太大，不推荐 |

## 4. 选定方案

**方案说明见上方对比表中 ✅ 标记项。**

## 5. 技术细节

### 5.1 P2-1：Frontmatter 字段规范

**specs（BRAINSTORM 输出）**：
```yaml
---
feature: <feature-name>
date: YYYY-MM-DD
status: draft | confirmed
confirmed_at: YYYY-MM-DD | null
---
```

**plans（ANALYZE 输出）**：
```yaml
---
feature: <feature-name>
date: YYYY-MM-DD
status: active | completed
spec: docs/specs/YYYY-MM-DD--<feature>.md
---
```

**reviews（REVIEW 输出）**：
```yaml
---
feature: <feature-name>
date: YYYY-MM-DD
result: PASS | BLOCK
plan: docs/plans/YYYY-MM-DD--<feature>--tasks.md
---
```

**DIGEST step 2 变更**：

当前 step 2 扫描正文提取状态。更新后：
- 若文件有 frontmatter，读取 `status`/`result` 字段
- 若文件无 frontmatter（历史文件），降级为正文扫描（向后兼容）

### 5.2 P2-2：Workflow-Meta Lane 内容

在 `skills/using-fe-workflow/SKILL.md` 新增章节，包含：

- **触发条件**：用户意图涉及修改 `skills/`、`commands/`、`CLAUDE.md`、`AGENTS.md`、`.cursor/rules/workflow.mdc`
- **与普通 Feature Lane 的区别**：

| 维度 | Feature Lane | Workflow-Meta Lane |
|------|-------------|-------------------|
| TDD | 必须（有可运行代码） | 跳过（无代码，验收为 grep 检查） |
| 验收方式 | vitest + tsc + eslint | grep 精确文本核查 |
| commit 粒度 | 每任务 | 每文件 |
| REVIEW | 六轴完整执行 | 六轴适配为文档正确性框架 |
| DOCUMENT | 照常生成 ADR | 照常生成 ADR |

- **三端同步规则**：修改节点行为时须同步 CLAUDE.md / AGENTS.md / workflow.mdc

### 5.3 P2-3：TDD commit 粒度

在 TDD SKILL 的"任务执行循环"末尾添加 commit 建议块：

```
**commit 时机建议**：
- **推荐（每任务）**：每个任务完成红→绿→重构后立即 commit
  `git commit -m "feat: <task-desc> [T00N]"`
- **可选（里程碑）**：对于关联性极强的连续小任务，可在 tasks.md 中用
  注释 `# --- commit here ---` 标记里程碑，到达标记后统一提交
- **不推荐**：所有任务完成后一次性提交（回滚粒度过大）
```

## 6. 边界条件与错误处理

| 场景 | 触发条件 | 处理方式 |
|------|---------|---------|
| 历史 spec 无 frontmatter | DIGEST 读取旧文件 | 降级正文扫描，不报错 |
| frontmatter 字段拼写错误 | status 写成 statue | DIGEST 降级正文扫描 |
| tasks.md 有里程碑标记 | TDD 执行到 `# --- commit here ---` | AI 在此节点提示"建议 commit" |

## 7. 验收标准

- [ ] P2-1：BRAINSTORM SKILL 的设计文档模板包含 frontmatter 块
- [ ] P2-1：ANALYZE SKILL 的任务列表模板包含 frontmatter 块
- [ ] P2-1：REVIEW SKILL 的 review 报告模板包含 frontmatter 块
- [ ] P2-1：DIGEST step 2 说明优先读取 frontmatter，历史文件降级正文扫描
- [ ] P2-2：`skills/using-fe-workflow/SKILL.md` 含"Workflow-Meta Lane"独立章节
- [ ] P2-2：CLAUDE.md 工作流概览有一行 Workflow-Meta Lane 注释
- [ ] P2-3：TDD SKILL 任务循环末尾有 commit 粒度建议块
- [ ] 所有改动已 committed，无 TBD 占位符
