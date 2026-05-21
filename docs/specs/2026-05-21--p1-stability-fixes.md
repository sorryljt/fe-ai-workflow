# P1 修复批次：运行时稳定性与环境健壮性

**日期**：2026-05-21
**状态**：已确认
**改动性质**：Workflow-Meta（4 个 SKILL 文字改动 + 2 个新配置文件）

> **设计假设**（均来自项目上下文推断，用户已确认）：
> 1. 本次为 Workflow-Meta 改动，不走 TDD 节点
> 2. P1-3 新增的 DIGEST 章节命名为"已知技术债务"，区别于"待关注问题"（BLOCKING/TODO）
> 3. P1-4 修复方案：更新模式仅跳过 step 2-3，step 1（读 project-context.md）保留执行
> 4. .editorconfig 和 .gitattributes 使用 UTF-8 + LF，与仓库现有风格一致
> 5. git diff 检测改为 `$(git merge-base HEAD main) HEAD`，适配直接在 main 上开发的工作模式

## 1. 背景

P0 完成后，P1 包含 5 个影响工作流运行时稳定性的问题。相比 P0 的"标签和措辞修正"，P1 是"行为缺口和环境健壮性"——这些问题不会导致 AI 走错节点，但会在特定场景下产生静默失效：

- 多 commit feature 的 skills/ 变更漏检
- 含接口任务却未被提醒使用合约
- 技术债务在 DIGEST 里消失
- BRAINSTORM 更新模式可能用过时的项目上下文
- 中文文档在 Windows 环境下换行符不稳定

## 2. 目标

**要做的事**：
- [ ] 修复 DOCUMENT git diff 检测范围，覆盖整个 feature 的所有 commit
- [ ] TDD 冷启动新增"接口类任务无合约"非阻塞提醒
- [ ] DIGEST 新增"已知技术债务"章节收集 [SUGGESTED] 问题
- [ ] BRAINSTORM 更新模式补充 step 1（读最新项目上下文）
- [ ] 新增 `.editorconfig` 和 `.gitattributes`，强制 UTF-8 + LF

**不做的事**：
- 不涉及 P2/P3 改动
- 不改变任何流程顺序或门控条件

## 3. 变更详情（按文件）

### 文件 1：`skills/05-documentation/SKILL.md`（2 处）

Step 1 两条 git diff 命令，均从 `HEAD~1 HEAD` 改为 `$(git merge-base HEAD main) HEAD`：

| # | 当前 | 修改为 |
|---|------|--------|
| 1 | `git diff --name-only HEAD~1 HEAD \| grep -E "^(skills/\|commands/)"` | `git diff --name-only $(git merge-base HEAD main) HEAD \| grep -E "^(skills/\|commands/)"` |
| 2 | `git diff --name-only HEAD~1 HEAD \| grep -E "^references/"` | `git diff --name-only $(git merge-base HEAD main) HEAD \| grep -E "^references/"` |

### 文件 2：`skills/03-tdd-cycle/SKILL.md`（1 处）

"前置步骤：检查类型合约文件"的不存在时分支，从无条件静默改为有条件提醒：

当前：
```
**不存在时**：静默继续，无需提示，正常执行 TDD 循环。
```

修改为：
```
**不存在时**：检查当前 tasks.md 中是否含有 `[api]` / `[hook]` / `[store]` 类型任务：
- **含有**：输出非阻塞提醒后继续：
  > 💡 检测到任务含 [api] / [hook] / [store] 类型，但未发现类型合约文件。
  >    建议先执行 /viktor:contract 锁定接口类型。（可跳过，不阻塞继续）
- **不含有**：静默继续，无需提示。
```

### 文件 3：`skills/09-digest/SKILL.md`（3 处）

**改动 1** — Step 2 review 提取规则：

| 当前 | 修改为 |
|------|--------|
| `**reviews/**：每个文件中标注为 [BLOCKING] 或 TODO 的条目` | `**reviews/**：提取两类条目：① 标注为 [BLOCKING] 或 TODO 的条目（归入"待关注问题"）；② 标注为 [SUGGESTED] 的条目（归入"已知技术债务"）` |

**改动 2** — 摘要模板新增第 6 章节（接在第 5 章节之后）：

```markdown
## 6. 已知技术债务

以下 [SUGGESTED] 问题来自 Review 报告，非阻塞，可在后续迭代处理：

| 来源 | 问题描述 |
|------|---------|
| [review 文件名] | [SUGGESTED 问题描述] |

> 若无技术债务，此节显示「暂无」。
```

**改动 3** — 验证标准：

| 当前 | 修改为 |
|------|--------|
| `文件包含 5 个必需章节（当前状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题）` | `文件包含 6 个必需章节（当前状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题 / 已知技术债务）` |

### 文件 4：`skills/01-brainstorming/SKILL.md`（1 处）

冷启动"选择已有文件（更新模式）"分支，修改跳过步骤说明：

| 当前 | 修改为 |
|------|--------|
| `跳过第 1-3 步（探索/评估/提问），直接进入第 4 步` | `跳过第 2-3 步（评估范围/批量提问），直接进入第 4 步` |

并在该分支说明中补充一条：
```
- 先执行第 1 步（读取 project-context.md），确保基于最新项目上下文修改
```

### 文件 5：新增 `.editorconfig`

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false
```

### 文件 6：新增 `.gitattributes`

```
* text=auto eol=lf
*.md text eol=lf
*.ts text eol=lf
*.sh text eol=lf
```

## 4. 验收标准

- [ ] `skills/05-documentation/SKILL.md` 中两处 git diff 命令均不含 `HEAD~1 HEAD`
- [ ] `skills/03-tdd-cycle/SKILL.md` "不存在时"分支有条件判断，不再无条件静默
- [ ] `skills/09-digest/SKILL.md` step 2 包含 [SUGGESTED] 提取说明
- [ ] `skills/09-digest/SKILL.md` 模板有第 6 章节"已知技术债务"
- [ ] `skills/09-digest/SKILL.md` 验证标准为"6 个必需章节"
- [ ] `skills/01-brainstorming/SKILL.md` 更新模式仅跳过 step 2-3，step 1 保留
- [ ] `.editorconfig` 存在，包含 `charset = utf-8` 和 `end_of_line = lf`
- [ ] `.gitattributes` 存在，包含 `* text=auto eol=lf`
