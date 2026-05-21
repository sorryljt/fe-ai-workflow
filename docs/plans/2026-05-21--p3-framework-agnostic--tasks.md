# P3 框架无关化与验证脚本 任务列表

**日期**：2026-05-21
**关联设计**：[docs/specs/2026-05-21--p3-framework-agnostic.md](../specs/2026-05-21--p3-framework-agnostic.md)
**总任务数**：8（P0: 8, P1: 0, P2: 0）
**改动性质**：Workflow-Meta（SKILL 规则文件修改 + 新建脚本，TDD SKILL 中无可运行代码需测试）

## 功能概述

P3-1：将 `skills/03-tdd-cycle/SKILL.md` 从 Next.js 专有描述改为框架无关（保留 React/Next.js 示例，显式标注为参考实现）。
P3-2：新建 `scripts/validate-workflow.sh`，自动化检查三端命令一致性与 Skill 文件存在性。

## 技术方案

P3-1：精确文本替换，7 处独立改动，每处 commit。文件较长，每次改动前 Read 定位精确行。
P3-2：新建 bash 脚本，参照 `scripts/sync-workflow.sh` 风格，chmod +x 后执行验证所有检查为 ✅。

## 任务列表

### P0 核心任务（T001-T007 全部属于 TDD SKILL，T008 为脚本）

---

#### T001：更新 frontmatter description — 移除"React/Next.js 特化"标签 [skill]

- **描述**：SKILL frontmatter 的 `description` 字段仍写"针对 React/Next.js/Vitest 项目"，与项目框架无关定位矛盾
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] description 字段不再含"针对 React/Next.js/Vitest 项目"
  - [x] description 改为体现框架无关性（含"框架无关"或"参考实现"等表述）
- **具体改动**（1 处）：

  | old_string | new_string |
  |-----------|-----------|
  | `description: 测试驱动开发循环 - 针对 React/Next.js/Vitest 项目的完整 TDD 红绿重构规范，每个任务单元循环执行` | `description: 测试驱动开发循环 - 框架无关的完整 TDD 红绿重构规范，以 React/Next.js/Vitest 为参考实现，每个任务单元循环执行` |

- **依赖**：无

---

#### T002：重命名章节标题 — "React/Next.js 特化" → "框架无关" [skill]

- **描述**：`## TDD 分层规范（React/Next.js 特化）` 是最显眼的框架绑定声明，与项目定位直接矛盾
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] 章节标题不再含"React/Next.js 特化"
  - [x] 章节标题含"框架无关"
- **具体改动**（1 处）：

  | old_string | new_string |
  |-----------|-----------|
  | `## TDD 分层规范（React/Next.js 特化）` | `## TDD 分层规范（框架无关）` |

- **依赖**：无

---

#### T003：扩展"框架适配"说明块 — 新增框架/工具对照表 [skill]

- **描述**：现有"框架适配"块只有 3 行简短说明，缺少具体的框架→测试工具对照表，执行者仍需自行查找
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] "框架适配"块包含框架/测试工具对照表（至少含 React、Vue、Svelte 三行）
  - [x] 说明"以下示例以 React/Next.js + Vitest 为参考实现"
- **具体改动**（1 处）：

  将现有块：
  ```
  > **框架适配**：以下分层规范默认以 React/Next.js/Vitest 为示例。
  > 如 `docs/project-context.md` 显示其他框架（Vue / Svelte 等），参照相应框架测试实践，
  > 测试工具替换为对应生态（如 Vitest + Vue Test Utils），其余 TDD 循环原则不变。
  ```
  替换为：
  ```
  > **框架适配**：本 SKILL 适用于所有前端框架。在开始前，先读取
  > `docs/project-context.md` 确认当前项目的框架和测试工具：
  >
  > | 框架 | 推荐测试工具 | 组件测试库 |
  > |------|------------|-----------|
  > | React / Next.js | Vitest | React Testing Library (RTL) |
  > | Vue 3 | Vitest | Vue Test Utils |
  > | Svelte | Vitest | @testing-library/svelte |
  > | 其他框架 | 项目已有测试工具 | 对应生态测试库 |
  >
  > 以下示例代码以 **React/Next.js + Vitest** 为参考实现，其他框架按对应工具类比执行。
  ```

- **依赖**：T002（同章节内容，逻辑上先改标题再改内容）

---

#### T004：更新"强制 TDD"表格 — 移除 Next.js 专有行描述 [skill]

- **描述**：表格中"Server Actions"和"API 路由"两行的示例列和测试工具列使用了 Next.js 专有术语，Vue/Svelte 项目无法对应
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] "Server Actions"行改为框架无关描述，示例列不再特指 Next.js Server Action
  - [x] "API 路由"行改为框架无关描述，示例列不再特指"Next.js route handlers"
  - [x] 测试工具列说明"框架对应 mock 库"
- **具体改动**（2 处）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `\| Server Actions \| 表单提交处理、数据变更 \| Vitest + MSW \|` | `\| 服务端数据变更逻辑 \| Server Action / API handler 等服务端函数 \| Vitest + MSW（或框架对应 mock 库）\|` |
  | 2 | `\| API 路由 \| Next.js route handlers \| Vitest + MSW \|` | `\| API 路由 / 接口处理函数 \| Route handler、API endpoint \| Vitest + MSW（或框架对应 mock 库）\|` |

- **依赖**：无

---

#### T005：更新"适度 TDD"表格 — RTL 改为框架无关描述 [skill]

- **描述**：表格"测试工具"列全部为 RTL（React Testing Library）专有标注，Vue/Svelte 项目看到此表无法直接套用
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] "测试工具"列不再裸写"RTL"，改为"组件测试库"并注明 React 场景使用 RTL
- **具体改动**（4 处，replace_all 可一次处理相近内容）：

  | # | old_string | new_string |
  |---|-----------|-----------|
  | 1 | `\| 有状态组件 \| 用户交互行为（点击、输入、选择） \| RTL + userEvent \|` | `\| 有状态组件 \| 用户交互行为（点击、输入、选择） \| 组件测试库 + userEvent（React: RTL）\|` |
  | 2 | `\| 表单组件 \| 提交、验证触发、错误展示 \| RTL + userEvent \|` | `\| 表单组件 \| 提交、验证触发、错误展示 \| 组件测试库 + userEvent（React: RTL）\|` |
  | 3 | `\| 列表组件 \| 渲染、空状态、加载状态 \| RTL \|` | `\| 列表组件 \| 渲染、空状态、加载状态 \| 组件测试库（React: RTL）\|` |
  | 4 | `\| 模态框/弹窗 \| 打开/关闭、确认/取消回调 \| RTL + userEvent \|` | `\| 模态框/弹窗 \| 打开/关闭、确认/取消回调 \| 组件测试库 + userEvent（React: RTL）\|` |

- **依赖**：无

---

#### T006：更新 REFACTOR 步骤 — 规范检查改为条件性引用 [skill]

- **描述**：REFACTOR 步骤的"规范"检查项硬编码引用 `references/react-nextjs-conventions.md`，非 React 项目读到此处会困惑
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] 规范检查项不再直接写死 `references/react-nextjs-conventions.md`
  - [x] 改为条件性说明（React 项目参照该文件，其他框架参照自身规范）
- **具体改动**（1 处）：

  | old_string | new_string |
  |-----------|-----------|
  | `- **规范**：是否符合 \`references/react-nextjs-conventions.md\`？` | `- **规范**：是否符合项目约定的编码规范？（React/Next.js 项目参照 \`references/react-nextjs-conventions.md\`；其他框架参照 \`docs/project-context.md\` 中记录的规范）` |

- **依赖**：无

---

#### T007：在第 2 步代码示例前插入参考实现标注 [skill]

- **描述**：第 2 步（RED）的测试模板直接以 Vitest/RTL 代码开始，未说明这是 React/Next.js 专用示例。非 React 用户看到 `@testing-library/react` import 会困惑
- **文件路径**：`skills/03-tdd-cycle/SKILL.md`
- **验收标准**：
  - [x] "工具函数测试模板"之前有一行说明，标注"以下为 React/Next.js 参考实现"
- **具体改动**（1 处）：

  | old_string | new_string |
  |-----------|-----------|
  | `**工具函数测试模板**：` | `> 以下测试模板以 **React/Next.js + Vitest** 为参考实现，其他框架请按对应工具类比。\n\n**工具函数测试模板**：` |

- **依赖**：T003（框架适配块已在章节顶部说明，此处补充到执行步骤入口）

---

#### T008：新建 `scripts/validate-workflow.sh` [script]

- **描述**：目前三端一致性只能靠人工检查。新建 bash 脚本，检查 9 个 viktor:* 命令在三端的存在性 + 10 个 Skill 文件存在于磁盘，输出彩色 ✅/❌ 列表，全通过 exit 0，有失败 exit 1
- **文件路径**：`scripts/validate-workflow.sh`（新建）
- **验收标准**：
  - [x] 文件存在于 `scripts/` 目录
  - [x] 包含 9 个 viktor:* 命令的三端检查（共 27 项）
  - [x] 包含 10 个 Skill 文件存在性检查
  - [x] 在仓库根目录运行时所有检查均为 ✅（37/37 通过）
  - [x] exit code：全通过 0，有失败 1
  - [x] 文件说明中含 `bash scripts/validate-workflow.sh` 用法
- **依赖**：T001-T007（Skill 文件检查依赖 Skill 文件存在，逻辑上需 P3-1 先完成）

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T003 | ⚠️ 多行替换 | 框架适配块跨多行，需完整匹配 | Read 文件确认精确内容后再 Edit |
| T007 | ⚠️ 换行处理 | new_string 含 `\n`，需确认 Edit 工具正确处理 | 改完后 Read 目视核查 |
| T008 | ⚠️ 路径依赖 | 脚本从仓库根目录运行，文件路径均为相对路径 | 脚本开头校验 `.git` 目录存在 |

## 验收总结

- [x] 所有 8 个任务完成，改动已 committed
- [x] `grep "React/Next.js 特化" skills/03-tdd-cycle/SKILL.md` 无输出
- [x] `grep "框架无关" skills/03-tdd-cycle/SKILL.md` 有输出（2 处）
- [x] `grep "参考实现" skills/03-tdd-cycle/SKILL.md` 有输出（3 处）
- [x] `grep "Next.js route handlers" skills/03-tdd-cycle/SKILL.md` 无输出
- [x] `grep "组件测试库" skills/03-tdd-cycle/SKILL.md` 有输出（5 处）
- [x] `grep "react-nextjs-conventions" skills/03-tdd-cycle/SKILL.md` 存在且包含条件性说明
- [x] `[ -f scripts/validate-workflow.sh ]` 为真
- [x] `bash scripts/validate-workflow.sh` 在仓库根目录运行时 exit 0（37/37 通过）
