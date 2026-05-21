# P2 工作流打磨批次 任务列表

**日期**：2026-05-21
**关联设计**：[docs/specs/2026-05-21--p2-workflow-polish.md](../specs/2026-05-21--p2-workflow-polish.md)
**总任务数**：7（P0: 7, P1: 0, P2: 0）
**改动性质**：Workflow-Meta（纯规则文件修改，不走 TDD）

## 功能概述

打磨工作流三个可用性细节：产物文档引入机器可读 YAML frontmatter、正式化 Workflow-Meta Lane 描述、补充 TDD commit 粒度建议。

## 技术方案

精确文本追加/替换，每文件独立 commit，完成后 grep 验收。
T001-T004 处理 frontmatter（写入方 → 读取方）；T005-T006 处理 Meta Lane 文档；T007 处理 TDD commit 建议。

## 任务列表

### P0 核心任务（全部必需，按组顺序执行）

---

#### T001：BRAINSTORM 设计文档模板 — 追加 frontmatter [skill]

- **描述**：在 `skills/01-brainstorming/SKILL.md` 的设计文档模板（`## 设计文档模板` 章节）开头插入 YAML frontmatter 块，使 BRAINSTORM 生成的 spec 文件包含机器可读状态字段
- **文件路径**：`skills/01-brainstorming/SKILL.md`
- **验收标准**：
  - [x] 模板中含 `status: draft | confirmed` 字段
  - [x] 模板中含 `confirmed_at: YYYY-MM-DD | null` 字段
  - [x] frontmatter 位于模板的 `# [功能名称] 设计文档` 标题之前
- **具体改动**：

  将设计文档模板中：
  ```markdown
  # [功能名称] 设计文档
  
  **日期**：YYYY-MM-DD
  **状态**：已确认
  ```
  改为：
  ```markdown
  ---
  feature: <feature-name>
  date: YYYY-MM-DD
  status: draft | confirmed
  confirmed_at: YYYY-MM-DD | null
  ---
  
  # [功能名称] 设计文档
  
  **日期**：YYYY-MM-DD
  **状态**：已确认
  ```

- **依赖**：无

---

#### T002：ANALYZE 任务列表模板 — 追加 frontmatter [skill]

- **描述**：在 `skills/02-requirements-analysis/SKILL.md` 的 `tasks.md 模板` 章节开头插入 YAML frontmatter 块
- **文件路径**：`skills/02-requirements-analysis/SKILL.md`
- **验收标准**：
  - [x] 模板中含 `status: active | completed` 字段
  - [x] 模板中含 `spec: docs/specs/...` 引用字段
  - [x] frontmatter 位于模板标题之前
- **具体改动**：

  将 tasks.md 模板中：
  ```markdown
  # [功能名称] 任务列表
  
  **日期**：YYYY-MM-DD
  **关联设计**：[docs/specs/YYYY-MM-DD--design.md](../specs/...)
  ```
  改为：
  ```markdown
  ---
  feature: <feature-name>
  date: YYYY-MM-DD
  status: active | completed
  spec: docs/specs/YYYY-MM-DD--<feature>.md
  ---
  
  # [功能名称] 任务列表
  
  **日期**：YYYY-MM-DD
  **关联设计**：[docs/specs/YYYY-MM-DD--design.md](../specs/...)
  ```

- **依赖**：无

---

#### T003：REVIEW 报告模板 — 追加 frontmatter [skill]

- **描述**：在 `skills/04-code-review/SKILL.md` 的 `review-report.md 模板` 章节开头插入 YAML frontmatter 块
- **文件路径**：`skills/04-code-review/SKILL.md`
- **验收标准**：
  - [x] 模板中含 `result: PASS | BLOCK` 字段
  - [x] 模板中含 `reviewed_at: YYYY-MM-DD` 字段
  - [x] frontmatter 位于模板标题之前
- **具体改动**：

  将 review 模板中：
  ```markdown
  # Code Review 报告：[功能名称]
  
  **日期**：YYYY-MM-DD
  **审查者**：AI Code Reviewer
  ```
  改为：
  ```markdown
  ---
  feature: <feature-name>
  date: YYYY-MM-DD
  result: PASS | BLOCK
  reviewed_at: YYYY-MM-DD
  plan: docs/plans/YYYY-MM-DD--<feature>--tasks.md
  ---
  
  # Code Review 报告：[功能名称]
  
  **日期**：YYYY-MM-DD
  **审查者**：AI Code Reviewer
  ```

- **依赖**：无

---

#### T004：DIGEST step 2 — 新增 frontmatter 优先读取说明 [skill]

- **描述**：在 `skills/09-digest/SKILL.md` 的 step 2 中，为 specs/plans/reviews 的读取逻辑各追加一句"若文件有 frontmatter，优先读取对应字段；否则降级正文扫描"，保证向后兼容
- **文件路径**：`skills/09-digest/SKILL.md`
- **验收标准**：
  - [x] step 2 specs 条目说明"优先读取 frontmatter `status` 字段"
  - [x] step 2 plans 条目说明"优先读取 frontmatter `status` 字段"
  - [x] step 2 reviews 条目说明"优先读取 frontmatter `result` 字段"
  - [x] 说明中包含"降级正文扫描"的向后兼容描述
- **具体改动**（3 处，分别追加到 specs/plans/reviews 的说明末尾）：

  | # | 目标条目（追加位置） | 追加内容 |
  |---|-------------------|---------|
  | 1 | `- **specs/**：每个文件的功能名称 + 日期 + 状态（已确认/草稿）` | `（优先读取 frontmatter \`status\` 字段；无 frontmatter 时降级扫描正文 \`**状态**\` 字段）` |
  | 2 | `- **plans/**：每个文件的功能名称 + 任务总数 + 验收总结勾选情况` | `（优先读取 frontmatter \`status\` 字段；无 frontmatter 时降级扫描正文完成状态）` |
  | 3 | `- **reviews/**：提取两类条目...` | 在该行末尾追加：`（优先读取 frontmatter \`result\` 字段获取 PASS/BLOCK 结论；无 frontmatter 时降级扫描正文 \`**结论**\` 字段）` |

- **依赖**：T001、T002、T003（逻辑上依赖，文件编辑上可独立执行）

---

#### T005：`using-fe-workflow/SKILL.md` — 新增 Workflow-Meta Lane 章节 [skill]

- **描述**：在元调度器 Skill 中新增独立章节，正式描述"对工作流自身做修改"这条通道的触发条件、与 Feature Lane 的区别对比表、三端同步规则
- **文件路径**：`skills/using-fe-workflow/SKILL.md`
- **验收标准**：
  - [x] 文件中存在 `## Workflow-Meta Lane` 章节标题
  - [x] 章节中含 Feature Lane vs. Workflow-Meta Lane 对比表
  - [x] 对比表覆盖：TDD / 验收方式 / commit 粒度 / REVIEW / DOCUMENT 五个维度
  - [x] 章节中含触发条件描述（skills/ / commands/ / CLAUDE.md / AGENTS.md / workflow.mdc）
- **依赖**：无

---

#### T006：CLAUDE.md — 工作流概览追加 Meta Lane 注释 [config]

- **描述**：在 `CLAUDE.md` 的工作流概览（流程图注释处）追加一行说明 Workflow-Meta Lane 的存在
- **文件路径**：`CLAUDE.md`
- **验收标准**：
  - [x] CLAUDE.md 流程图注释中含 Workflow-Meta Lane 相关说明
  - [x] 说明指出触发条件（修改 skills/ 或 commands/）及验收方式（grep）
- **具体改动**：

  在工作流概览图的注释（`注：[CONTRACT] 为可选节点...`）之后，追加：

  ```
  Workflow-Meta Lane（修改 skills/ 或 commands/ 时）：
    跳过 TDD，以 grep 验收替代 vitest，每文件独立 commit。
    其余节点（BRAINSTORM → ANALYZE → REVIEW → DOCUMENT）照常执行。
  ```

- **依赖**：T005（Meta Lane 在 SKILL 中定义后再同步到 CLAUDE.md）

---

#### T007：TDD SKILL — 新增 commit 粒度建议块 [skill]

- **描述**：在 `skills/03-tdd-cycle/SKILL.md` 的 TDD 循环任务末尾（REFACTOR 步骤之后）追加 commit 时机建议块，说明每任务提交（默认）和里程碑提交（可选）两种模式
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] 文件中含"commit 时机建议"段落
  - [x] 说明"每任务提交"为默认推荐
  - [x] 说明"里程碑提交"为可选（通过 tasks.md 中 `# --- commit here ---` 标记）
  - [x] 说明"全部完成后一次性提交"为不推荐
- **依赖**：无

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T001 | ⚠️ 模板格式 | frontmatter 插入位置若有误会破坏模板结构 | 改完后 Read 文件目视核查 |
| T004 | ⚠️ 向后兼容 | 历史文件无 frontmatter，降级逻辑必须明确 | 验收标准中包含"降级"字样 |
| T005 | ⚠️ 章节位置 | using-fe-workflow/SKILL.md 较长，需确认插入位置合理 | 读文件确认后再插入 |

## 验收总结

- [x] 所有 7 个任务完成，改动已 committed
- [x] `grep "status: draft" skills/01-brainstorming/SKILL.md` 有输出
- [x] `grep "status: active" skills/02-requirements-analysis/SKILL.md` 有输出
- [x] `grep "result: PASS" skills/04-code-review/SKILL.md` 有输出
- [x] `grep "frontmatter" skills/09-digest/SKILL.md` 有输出
- [x] `grep "Workflow-Meta Lane" skills/using-fe-workflow/SKILL.md` 有输出
- [x] `grep "Workflow-Meta Lane" CLAUDE.md` 有输出
- [x] `grep "commit 时机建议" skills/03-tdd-cycle/SKILL.md` 有输出
