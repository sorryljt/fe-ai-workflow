# P1 修复批次 任务列表

**日期**：2026-05-21
**关联设计**：[docs/specs/2026-05-21--p1-stability-fixes.md](../specs/2026-05-21--p1-stability-fixes.md)
**总任务数**：7（P0: 7, P1: 0, P2: 0）
**改动性质**：Workflow-Meta（纯文档修正 + 新增配置文件，不走 TDD）

## 功能概述

修复 5 组 P1 级运行时稳定性问题：git diff 检测范围、TDD 合约遗漏提醒、DIGEST 技术债务收集、BRAINSTORM 更新模式上下文遗漏、UTF-8/LF 编码约束。

## 技术方案

精确文本替换 + 新建配置文件，每个文件独立 commit，完成后运行 grep 验收。

## 任务列表

### P0 核心任务（全部，无依赖关系）

#### T001：修复 `skills/05-documentation/SKILL.md` git diff 检测范围 [docs]

- **描述**：Step 1 两条 git diff 命令只检测 `HEAD~1 HEAD`（最后一次 commit），多 commit feature 中早期的 skills/ 变更会被静默漏检。改为相对 main 的 merge-base
- **文件路径**：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [ ] 文件中不再出现 `HEAD~1 HEAD`（用于 git diff 检测的两处）
  - [ ] 两处均替换为 `$(git merge-base HEAD main) HEAD`
- **具体改动**（2 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `git diff --name-only HEAD~1 HEAD \| grep -E "^(skills/\|commands/)"` | `git diff --name-only $(git merge-base HEAD main) HEAD \| grep -E "^(skills/\|commands/)"` |
  | 2 | `git diff --name-only HEAD~1 HEAD \| grep -E "^references/"` | `git diff --name-only $(git merge-base HEAD main) HEAD \| grep -E "^references/"` |

- **依赖**：无

---

#### T002：TDD 冷启动补充合约遗漏提醒 [docs]

- **描述**：当 tasks.md 含 [api]/[hook]/[store] 任务但 contracts/ 目录下无对应合约文件时，当前行为是无条件静默继续。用户可能未意识到跳过了 CONTRACT 节点。改为有条件非阻塞提醒
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [ ] "不存在时"分支不再是无条件静默
  - [ ] 有对 [api]/[hook]/[store] 任务的检查逻辑
  - [ ] 提醒为非阻塞（可跳过，不影响继续执行）
- **具体改动**（1 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `**不存在时**：静默继续，无需提示，正常执行 TDD 循环。` | `**不存在时**：检查当前 tasks.md 中是否含有 \`[api]\` / \`[hook]\` / \`[store]\` 类型任务：\n- **含有**：输出非阻塞提醒后继续：\n  > 💡 检测到任务含 [api] / [hook] / [store] 类型，但未发现类型合约文件。\n  >    建议先执行 /viktor:contract 锁定接口类型。（可跳过，不阻塞继续）\n- **不含有**：静默继续，无需提示。` |

- **依赖**：无

---

#### T003：DIGEST step 2 新增 [SUGGESTED] 提取规则 [docs]

- **描述**：当前 step 2 只从 reviews/ 提取 [BLOCKING] 和 TODO，[SUGGESTED] 技术债务在 digest 摘要中消失，团队失去对已知但延后处理问题的可见性
- **文件路径**：`skills/09-digest/SKILL.md`
- **验收标准**：
  - [ ] step 2 中 reviews 提取规则包含 [SUGGESTED] 说明
  - [ ] [SUGGESTED] 被分配到"已知技术债务"，有别于"待关注问题"
- **具体改动**（1 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `**reviews/**：每个文件中标注为 \`[BLOCKING]\` 或 \`TODO\` 的条目` | `**reviews/**：提取两类条目：① 标注为 \`[BLOCKING]\` 或 \`TODO\` 的条目（归入"待关注问题"）；② 标注为 \`[SUGGESTED]\` 的条目（归入"已知技术债务"）` |

- **依赖**：无

---

#### T004：DIGEST 摘要模板新增第 6 章节 [docs]

- **描述**：在摘要模板的第 5 章节（待关注问题）之后添加第 6 章节"已知技术债务"，收录 [SUGGESTED] 问题
- **文件路径**：`skills/09-digest/SKILL.md`
- **验收标准**：
  - [ ] 摘要模板中有 `## 6. 已知技术债务` 章节
  - [ ] 验证标准中"必需章节"数量从 5 更新为 6
- **具体改动**（2 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `> 若无待关注问题，此节显示「暂无」。\n\`\`\`` | `> 若无待关注问题，此节显示「暂无」。\n\n## 6. 已知技术债务\n\n以下 [SUGGESTED] 问题来自 Review 报告，非阻塞，可在后续迭代处理：\n\n| 来源 | 问题描述 |\n|------|----------|\n| [review 文件名] | [SUGGESTED 问题描述] |\n\n> 若无技术债务，此节显示「暂无」。\n\`\`\`` |
  | 2 | `文件包含 5 个必需章节（当前状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题）` | `文件包含 6 个必需章节（当前状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题 / 已知技术债务）` |

- **依赖**：T003（逻辑上依赖，但文件编辑上可独立执行）

---

#### T005：BRAINSTORM 更新模式补充 step 1 执行 [docs]

- **描述**：冷启动"选择已有文件（更新模式）"分支当前跳过 step 1-3，导致在项目上下文（project-context.md）发生变化后，AI 可能用旧上下文修改 spec。仅跳过 step 2-3（评估/提问），step 1（读上下文）应保留
- **文件路径**：`skills/01-brainstorming/SKILL.md`
- **验收标准**：
  - [ ] 更新模式分支不再写"跳过第 1-3 步"
  - [ ] 明确说明先执行 step 1（读 project-context.md），然后跳过 step 2-3
- **具体改动**（1 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `- 跳过第 1-3 步（探索/评估/提问），直接进入第 4 步` | `- 先执行第 1 步（读取 project-context.md），确保基于最新项目上下文修改\n- 跳过第 2-3 步（评估范围/批量提问），直接进入第 4 步` |

- **依赖**：无

---

#### T006：新增 `.editorconfig` [docs]

- **描述**：仓库缺少强制 UTF-8 和换行符规范的配置，中文文档在 Windows 环境下可能出现 CRLF 混入（git 已发出 LF→CRLF 警告）
- **文件路径**：`.editorconfig`（新建）
- **验收标准**：
  - [ ] 文件存在于仓库根目录
  - [ ] 包含 `charset = utf-8`
  - [ ] 包含 `end_of_line = lf`
  - [ ] `[*.md]` 节有 `trim_trailing_whitespace = false`（保留 Markdown 换行语义）
- **依赖**：无

---

#### T007：新增 `.gitattributes` [docs]

- **描述**：补充 git 层面的换行符约束，确保跨平台 checkout 时不引入 CRLF
- **文件路径**：`.gitattributes`（新建）
- **验收标准**：
  - [ ] 文件存在于仓库根目录
  - [ ] 包含 `* text=auto eol=lf`
  - [ ] 包含 `*.md text eol=lf`
- **依赖**：无

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T002 | ⚠️ 多行替换 | new_string 含换行，需确认 Edit 工具正确处理 | 改完后立即 Read 文件核查实际内容 |
| T004 | ⚠️ 多行替换 | 模板新增章节涉及多行 | 同上 |
| T006/T007 | — | 新建文件，git 可能提示 CRLF 警告 | 正常现象，.gitattributes 生效后解决 |

## 验收总结

- [ ] 所有 P1 任务完成，改动已 committed
- [ ] `grep "HEAD~1 HEAD" skills/05-documentation/SKILL.md` 无输出
- [ ] `grep "静默继续，无需提示，正常执行" skills/03-tdd-cycle/SKILL.md` 无输出
- [ ] `grep "SUGGESTED" skills/09-digest/SKILL.md` 有输出
- [ ] `grep "6 个必需章节" skills/09-digest/SKILL.md` 有输出
- [ ] `grep "跳过第 1-3 步" skills/01-brainstorming/SKILL.md` 无输出
- [ ] `.editorconfig` 和 `.gitattributes` 均存在
