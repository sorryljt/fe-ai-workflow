# P0 修复批次 任务列表

**日期**：2026-05-20
**关联设计**：[docs/specs/2026-05-20--p0-consistency-fixes.md](../specs/2026-05-20--p0-consistency-fixes.md)
**总任务数**：6（P0: 6, P1: 0, P2: 0）
**改动性质**：Workflow-Meta（纯文档修正，无代码，不走 TDD）

## 功能概述

修复 v0.7.0 积累的 4 组 P0 级问题：Cursor 三端命令漂移、digest 触发描述过时、REVIEW 五轴/六轴命名混乱、3 个遗留 [SUGGESTED] 文字 bug。全部为现有文件的精确文字替换，无逻辑变更。

## 技术方案

直接用编辑工具对 6 个文件做精确 old_string → new_string 替换，每个文件 commit 一次，最终运行验收检查确认无残留旧字符串。

## 任务列表

### P0 核心任务（全部阻塞性，无依赖关系，可并行）

#### T001：修复 `.cursor/rules/workflow.mdc` [docs]

- **描述**：修复 Cursor 规则文件中 7 处漂移：旧命令名（/brainstorm、/analyze、/tdd、/review）、BRAINSTORM 提问策略（苏格拉底式→批量3问）、技术栈硬编码
- **文件路径**：`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [ ] 文件中不再出现 `/brainstorm`、`/analyze`（作为触发命令）、`/tdd`、`/review`
  - [ ] BRAINSTORM 步骤 2 描述为"一次性批量提出最多 3 个问题"
  - [ ] BRAINSTORM 步骤 5 指向 `/viktor:plan`
  - [ ] TDD 步骤 8 指向 `/viktor:cr`
  - [ ] `## 技术栈` 一节不再包含 `Next.js 14 App Router` 等硬编码版本
- **具体改动**（8 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `触发：/brainstorm 或检测到模糊需求` | `触发：/viktor:think 或检测到模糊需求` |
  | 2 | `通过苏格拉底式提问逐步澄清需求（每次只问一个问题）` | `识别关键决策点，一次性批量提出最多 3 个问题；可由上下文推断的直接采用并在假设中声明` |
  | 3 | `提示进入 /analyze` | `提示进入 /viktor:plan` |
  | 4 | `触发：/analyze 或 BRAINSTORM 完成` | `触发：/viktor:plan 或 BRAINSTORM 完成` |
  | 5 | `触发：/tdd` | `触发：/viktor:code` |
  | 6 | `提示进入 /review` | `提示进入 /viktor:cr` |
  | 7 | `触发：/review` | `触发：/viktor:cr` |
  | 8 | `## 技术栈\n\nReact / Next.js 14 App Router / TypeScript（strict mode）/ Vitest / React Testing Library / MSW\n\n参考规范：\n- \`references/react-nextjs-conventions.md\`\n- \`references/testing-patterns.md\`\n- \`references/living-docs-conventions.md\`` | `## 技术栈\n\n由 \`docs/project-context.md\` 提供（执行 \`/viktor:init\` 后自动生成，框架无关）。\n\nReact/Next.js 参考实现见 \`references/react-nextjs-conventions.md\`。` |

- **依赖**：无

---

#### T002：修正 `skills/using-fe-workflow/SKILL.md` digest 触发描述 [docs]

- **描述**：命令速查表中 digest 行仍写"ADR 累积到 5 的倍数时"，与 ADR-005 后的实际行为（每次 DOCUMENT 完成后无条件触发）不符
- **文件路径**：`skills/using-fe-workflow/SKILL.md`
- **验收标准**：
  - [ ] 命令速查表 digest 行不再包含"5 的倍数"字样
  - [ ] 新描述与 `skills/05-documentation/SKILL.md` 第 7 步导航卡说明一致
- **具体改动**（1 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `随时手动执行，或 ADR 累积到 5 的倍数时响应 DOCUMENT 建议` | `随时手动执行，或响应每次 DOCUMENT 完成后的非阻塞建议（无条件触发，不依赖 ADR 数量）` |

- **依赖**：无

---

#### T003：统一 `skills/04-code-review/SKILL.md` 五轴/六轴标签 [docs]

- **描述**：frontmatter description 已正确写"六轴"，但正文章节标题和 review.md 模板内仍写"五轴"，造成同一文件内标签不一致
- **文件路径**：`skills/04-code-review/SKILL.md`
- **验收标准**：
  - [ ] 文件中不再出现"五轴"字样
  - [ ] 正文章节标题为"## 六轴审查框架"
  - [ ] review.md 模板中为"## 六轴审查结果"
- **具体改动**（2 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `## 五轴审查框架` | `## 六轴审查框架` |
  | 2 | `## 五轴审查结果` | `## 六轴审查结果` |

- **依赖**：无

---

#### T004：修正 `commands/viktor/contract.md` Hard Gate 措辞 [docs]

- **描述**：第 5 节标题"执行中 Hard Gate"使用了"Hard Gate"术语，但 CONTRACT 是可选节点，此约束仅在执行过程中生效，与"Hard Gate = 必须前置条件"的通用语义冲突，容易误导 AI 和用户
- **文件路径**：`commands/viktor/contract.md`
- **验收标准**：
  - [ ] 第 5 节标题不再使用"Hard Gate"
  - [ ] 说明文字明确区分"CONTRACT 节点可选"与"执行中会话锁"两个概念
- **具体改动**（2 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `## 5. 执行中 Hard Gate` | `## 5. 执行中约束（会话锁）` |
  | 2 | `**当前正在执行 CONTRACT 且合约文件尚未获用户确认时，不响应 \`/viktor:code\` 请求。**` | `**仅在 CONTRACT 执行过程中生效：合约文件尚未获用户确认时，不响应 \`/viktor:code\` 请求。**` |

- **依赖**：无

---

#### T005：移除 `skills/05-documentation/SKILL.md` step 4 框架专属标签 [docs]

- **描述**：Step 4 条件更新活文档的触发表格中，"React 组件"和"Server Action"是框架专属术语，与工作流框架无关定位不符
- **文件路径**：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [ ] 表格中不再出现"React 组件"字样
  - [ ] 表格中不再出现"Server Action"字样
  - [ ] 替换后措辞对 React/Vue/Svelte 等框架均适用
- **具体改动**（2 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `新增或修改了 React 组件` | `新增或修改了前端组件（React / Vue / Svelte 等）` |
  | 2 | `新增或修改了 API 路由 / Server Action` | `新增或修改了 API 路由 / 接口函数` |

- **依赖**：无

---

#### T006：删除 `skills/01-brainstorming/SKILL.md` step 1 重复扫描说明 [docs]

- **描述**：Step 1 末尾"额外执行"列表中有"查看 docs/specs/ 下已有的 design.md（避免重复）"，但冷启动步骤已完成同样的扫描，语义重叠，造成 AI 执行两次相同操作
- **文件路径**：`skills/01-brainstorming/SKILL.md`
- **验收标准**：
  - [ ] Step 1"额外执行"列表中不再包含 docs/specs/ 扫描这一条
  - [ ] 其余"额外执行"内容（检查 references/react-nextjs-conventions.md、检测输入类型）保持不变
- **具体改动**（1 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `- 查看 \`docs/specs/\` 下已有的 design.md（避免重复）\n` | （删除此行） |

- **依赖**：无

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T001 | ⚠️ 替换风险 | workflow.mdc 改动点最多（8 处），需精确匹配避免误改 | 逐条使用精确 old_string 替换，改完后 grep 验证旧字符串已消除 |

## 验收总结

- [ ] 所有 P0 任务完成，改动已 committed
- [ ] `grep -r "/brainstorm\|/analyze\b\|/tdd\b\|/review\b" .cursor/` 无输出
- [ ] `grep "五轴" skills/04-code-review/SKILL.md` 无输出
- [ ] `grep "5 的倍数" skills/using-fe-workflow/SKILL.md` 无输出
- [ ] `grep "Hard Gate" commands/viktor/contract.md` 无输出
- [ ] `grep "React 组件\|Server Action" skills/05-documentation/SKILL.md` 在 step 4 表格中无输出
