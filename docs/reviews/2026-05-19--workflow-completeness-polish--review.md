# Code Review — workflow-completeness-polish

**日期**：2026-05-19
**审查者**：Claude Code（自审）
**关联任务**：[docs/plans/2026-05-19--workflow-completeness-polish--tasks.md](../plans/2026-05-19--workflow-completeness-polish--tasks.md)
**结论**：✅ PASS

---

## 审查范围

| 变更文件 | 关联任务 |
|---------|---------|
| `skills/01-brainstorming/SKILL.md` | T001 / T004 / T005 |
| `skills/06-project-init/SKILL.md` | T006 |
| `skills/05-documentation/SKILL.md` | T008 / T010 |
| `skills/07-type-contract/SKILL.md` | T011 |
| `skills/04-code-review/SKILL.md` | T012 |
| `CLAUDE.md` | T002 / T007 / T009 |
| `AGENTS.md` | T003 / T007 / T009 |
| `.cursor/rules/workflow.mdc` | T003 / T007 / T009 |

---

## 轴 1：正确性（功能完整性）

### T001 — BRAINSTORM 冷启动检测

- ✅ 无文件时直接继续，路径正确
- ✅ 有文件时列出并询问 N / A / B / ...，覆盖所有分支
- ✅ 更新模式明确跳过第 1-3 步，进入第 4 步修改模式，步骤边界清晰
- ✅ 修改完成后继续第 5-7 步（自审/确认/commit），流程闭合

### T004 — PRD 输入路径

- ✅ 判断依据清晰（"含背景/目标/功能需求/验收标准等结构性章节"）
- ✅ PRD 路径明确跳过第 3 步（提问轮次），直接进第 4 步
- ✅ prd-input-template.md 已显式引用，不再是隐含规范

### T005 — init vs think 说明

- ✅ 仅在"情况 B（project-context.md 不存在）"时显示，触发时机准确
- ✅ 标注为非阻塞，不打断用户流程

### T006 — INIT 幂等保护

- ✅ A/B 两条路径边界清晰
- ✅ 强调"重复执行安全"，消除用户顾虑
- ✅ B 路径明确说明 project-context.md 保持不变

### T008 — DOCUMENT digest 触发

- ✅ 移除了 "5 的倍数" 条件判断，触发逻辑简化
- ✅ 导航卡内的 `💡` 选项与 `▶` 主流程选项视觉区分清晰，不会造成混淆

### T010 — references 变更检测

- ✅ 四个 references 文件与引用 Skill 的映射表准确（经逐一核实）：
  - `react-nextjs-conventions.md` → tdd-cycle（REFACTOR 规范检查）、code-review（正确性/可维护性）✅
  - `testing-patterns.md` → tdd-cycle（TDD 规范）、code-review（测试质量）✅
  - `living-docs-conventions.md` → documentation（ADR 状态机制）、project-init（活文档骨架）✅
  - `prd-input-template.md` → brainstorming（PRD 输入路径，T004 刚引入）✅

### T011/T012 — 单文件直接使用

- ✅ CONTRACT：只有一个文件时直接告知，不再静默处理
- ✅ REVIEW：同上，与 CONTRACT 风格一致

---

## 轴 2：跨文件一致性（三端同步）

| 行为 | SKILL.md | CLAUDE.md | AGENTS.md | workflow.mdc |
|------|----------|-----------|-----------|--------------|
| BRAINSTORM 冷启动 | ✅ 详细逻辑 | ✅ 一行摘要 | ✅ 一行摘要 | ✅ 一行摘要 |
| INIT 幂等行为 | ✅ A/B 对话 | ✅ 节点 0 + 幂等行为 | ✅ 幂等行为 | ✅ 幂等行为 |
| DOCUMENT digest 选项 | ✅ 固定输出 | ✅ 无条件触发描述 | ✅ 无条件触发描述 | ✅ 无条件触发描述 |

三端一致性核查通过。

---

## 轴 3：可维护性

- ✅ 所有新增的冷启动检测步骤格式与其他节点（ANALYZE / CONTRACT / TDD / REVIEW / DOCUMENT）保持统一风格
- ✅ references 检测表格可维护：新增 reference 文件时只需追加一行

---

## 问题清单

### [SUGGESTED] S001 — INIT Skill 概述措辞与幂等逻辑不一致

**位置**：`skills/06-project-init/SKILL.md`，概述第 1 行

**现状**：
> "在将工作流接入一个已有项目时，执行**一次性扫描**..."

**问题**：T006 已引入 A/B 幂等路径，`/viktor:init` 可以多次安全执行，但概述仍写"一次性扫描"，容易误导用户认为重复执行有风险。

**建议修改**：
> "在将工作流接入一个已有项目时，扫描项目结构并生成 `docs/project-context.md`。"

---

### [NIT] N001 — BRAINSTORM Step 1 中的 "查看 docs/specs/" 与冷启动步骤轻微重复

**位置**：`skills/01-brainstorming/SKILL.md`，第 1 步"额外执行"列表中

**现状**：
> "查看 `docs/specs/` 下已有的 design.md（避免重复）"

**问题**：冷启动前置步骤已经展示了所有 spec 文件并让用户做出选择，Step 1 再次提及"避免重复"略显冗余。两者职责有差异（冷启动是 gating 问题；Step 1 是背景了解），但注释措辞容易让 AI 产生二次扫描行为。

**建议**：调整 Step 1 的措辞为"了解已有 spec 的覆盖范围，作为上下文参考"，明确它是信息收集而非再次询问。

---

### [NIT] N002 — "检测输入类型"表格位置可更明显

**位置**：`skills/01-brainstorming/SKILL.md`，第 1 步末尾

**问题**：PRD vs 需求描述的分支逻辑影响第 3 步是否执行，但它嵌套在 Step 1 末尾，不如放在独立的前置说明中显眼。

**建议**：在第 1 步末尾加注释 `（本步结束后，根据此判断决定是否跳过第 3 步）`，增强可读性。

---

## 验收总结

| 任务 | 验收结论 |
|------|---------|
| T001 BRAINSTORM 冷启动 | ✅ |
| T002 CLAUDE.md 同步 | ✅ |
| T003 三端同步 | ✅ |
| T004 PRD 输入路径 | ✅ |
| T005 init vs think 说明 | ✅ |
| T006 INIT 幂等保护 | ✅ |
| T007 三端同步 | ✅ |
| T008 digest 触发优化 | ✅ |
| T009 三端同步 | ✅ |
| T010 references 变更检测 | ✅ |
| T011 CONTRACT NIT | ✅ |
| T012 REVIEW NIT | ✅ |

**结论**：✅ PASS

- 0 BLOCKING
- 1 SUGGESTED（INIT 概述措辞，不影响行为，可本轮修复）
- 2 NIT（BRAINSTORM 可读性，可后续迭代处理）
