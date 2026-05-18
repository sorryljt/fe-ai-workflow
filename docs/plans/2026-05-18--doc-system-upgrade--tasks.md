# 升级文档能力 任务列表

**日期**：2026-05-18
**关联设计**：[docs/specs/2026-05-18--doc-system-upgrade.md](../specs/2026-05-18--doc-system-upgrade.md)
**总任务数**：11（P0: 4, P1: 5, P2: 2）

## 功能概述

改造 DOCUMENT 和 INIT 节点，建立活文档体系（5 个持久化 Markdown 文件），
引入 ADR 自动编号、ADR 替代流程、工作流变更检测，并将活文档规范写入开发参考文档。

## 技术方案

本项目为 workflow meta 项目（无可运行代码），所有任务均为 Markdown 文档和 SKILL.md 修改。
"测试"等价于验证 checklist（格式正确、内容自洽、与三端入口一致）。

## 任务列表

### P0 核心任务（阻塞性，最先完成）

#### T001：DOCUMENT SKILL — 工作流变更检测 [docs]

- **描述**：在 `skills/05-documentation/SKILL.md` 第 1 步末尾新增工作流变更检测逻辑：汇总产物时执行 git diff，若检测到 `skills/` 或 `commands/` 路径变更，输出专项提示列出需同步的四个文件。
- **文件路径**：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [ ] 第 1 步末尾包含 git diff 命令和条件分支
  - [ ] 专项提示列出：using-fe-workflow/SKILL.md、CLAUDE.md、AGENTS.md、.cursor/rules/workflow.mdc
  - [ ] 非 git 项目场景有跳过说明（不报错）
- **依赖**：无

#### T002：DOCUMENT SKILL — ADR 自动编号 + 替代流程 + 模板状态字段 [docs]

- **描述**：在 `skills/05-documentation/SKILL.md` 第 3 步新增：（1）读取 docs/adrs/ 文件数自动计算编号；（2）询问用户是否替代历史 ADR，指定编号后自动更新旧文件状态字段；（3）更新 ADR 模板，将状态字段改为 4 选项格式。
- **文件路径**：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [ ] 第 3 步包含统计 docs/adrs/ 文件数的逻辑（排除 README.md）
  - [ ] 编号格式为三位数（ADR-001、ADR-002 等）
  - [ ] 包含替代流程交互提示（询问 → 定位旧文件 → 更新状态字段）
  - [ ] 输入不存在编号时有错误提示和重试引导
  - [ ] ADR 模板状态字段显示：`草稿 / 已接受 / 已废弃 / 已替代（见 ADR-XXX）  ← 四选一`
  - [ ] ADR 模板标题注释说明编号由 DOCUMENT 自动填入
- **依赖**：T001（同文件，顺序修改）

#### T003：DOCUMENT SKILL — 条件更新活文档 [docs]

- **描述**：在 `skills/05-documentation/SKILL.md` 第 4 步新增条件更新活文档逻辑：根据变更类型更新 component-catalog.md / api-catalog.md / architecture.md / adrs/README.md；若文件不存在则先创建骨架再追加；同步更新 project-context.md 的最后更新日期。
- **文件路径**：`skills/05-documentation/SKILL.md`
- **验收标准**：
  - [ ] 第 4 步包含 4 种变更类型 → 更新目标的对应规则表
  - [ ] 包含"文件不存在时先创建骨架"的边界处理
  - [ ] 包含 project-context.md 最后更新日期的同步说明
  - [ ] 骨架创建前不需要用户干预（自动处理）
- **依赖**：T002（同文件，顺序修改）

#### T004：INIT SKILL — 新增第 6 步生成活文档骨架 [docs]

- **描述**：在 `skills/06-project-init/SKILL.md` 新增第 6 步：在生成 project-context.md 后检查并生成其余 4 个活文档骨架，文件已存在则跳过。嵌入 4 个骨架模板内容（component-catalog、api-catalog、architecture、docs/adrs/README）。
- **文件路径**：`skills/06-project-init/SKILL.md`
- **验收标准**：
  - [ ] 第 6 步在第 5 步之后，触发条件为"生成 project-context.md 完成后"
  - [ ] 4 个骨架模板内容完整（表头、维护说明、示例行）
  - [ ] 文件已存在时跳过并给出提示
  - [ ] 验证标准 checklist 更新（新增 4 个活文档文件项）
  - [ ] 导航卡无需变更（已有）
- **依赖**：无

---

### P1 主要任务

#### T005：新建 references/living-docs-conventions.md [docs]

- **描述**：创建活文档体系规范文件，供后续所有迭代参照，共 5 个章节。
- **文件路径**：`references/living-docs-conventions.md`（新建）
- **验收标准**：
  - [ ] 第 1 节：文件清单与职责（5 个文件、各自的更新触发节点和时机）
  - [ ] 第 2 节：更新原则（追加不覆盖、Markdown 表格格式、每次 DOCUMENT 必须更新）
  - [ ] 第 3 节：ADR 状态机制（4 个状态定义、变更时机、替代流程说明）
  - [ ] 第 4 节：工作流自身变更同步规范（修改 skills/commands 时必须同步的文件清单）
  - [ ] 第 5 节：活文档退化的识别与修复（何时需要重跑 /viktor:init）
- **依赖**：T002（状态机制内容参照）

#### T006：三端同步 — CLAUDE.md [docs]

- **描述**：更新 CLAUDE.md 中 INIT 节点说明（新增活文档骨架生成）、DOCUMENT 节点说明（新增自动编号/替代/活文档更新/变更检测）、产物目录（新增 component-catalog.md / api-catalog.md / architecture.md / docs/adrs/README.md）。
- **文件路径**：`CLAUDE.md`
- **验收标准**：
  - [ ] INIT 节点说明包含"生成活文档骨架"
  - [ ] DOCUMENT 节点说明包含 ADR 自动编号、替代流程、活文档更新、变更检测
  - [ ] 产物目录 `docs/` 章节包含 4 个新文件
- **依赖**：T001、T002、T003、T004

#### T007：三端同步 — AGENTS.md [docs]

- **描述**：同 T006，更新 AGENTS.md 对应章节。
- **文件路径**：`AGENTS.md`
- **验收标准**：
  - [ ] INIT 节点说明更新
  - [ ] DOCUMENT 节点说明更新（含 4 项新能力）
  - [ ] 产物目录更新
  - [ ] 与 CLAUDE.md 的节点说明逻辑一致（可简化，但不能矛盾）
- **依赖**：T006（参照 CLAUDE.md 作为对照基准）

#### T008：三端同步 — .cursor/rules/workflow.mdc [docs]

- **描述**：同 T006，更新 workflow.mdc 对应章节。
- **文件路径**：`.cursor/rules/workflow.mdc`
- **验收标准**：
  - [ ] INIT 节点说明更新
  - [ ] DOCUMENT 节点说明更新
  - [ ] 产物目录更新
  - [ ] 与 CLAUDE.md / AGENTS.md 逻辑一致
- **依赖**：T007（完成 AGENTS.md 后一并交叉检查）

#### T009：skills/using-fe-workflow/SKILL.md 更新 [docs]

- **描述**：更新元调度器中 INIT 和 DOCUMENT 的功能描述，反映活文档骨架生成和新增 DOCUMENT 能力。
- **文件路径**：`skills/using-fe-workflow/SKILL.md`
- **验收标准**：
  - [ ] INIT 描述包含"生成活文档骨架"
  - [ ] DOCUMENT 描述包含 ADR 编号、替代流程、活文档更新
  - [ ] 命令速查表和 Skill 对照无错误
- **依赖**：T006

---

### P2 优化任务（可选）

#### T010：命令文件描述更新 [docs]

- **描述**：更新 `commands/viktor/doc.md`、`commands/viktor/init.md` 及对应 `.claude/commands/viktor/` 文件的 description frontmatter，反映新能力。
- **文件路径**：
  - `commands/viktor/doc.md`
  - `commands/viktor/init.md`
  - `.claude/commands/viktor/doc.md`
  - `.claude/commands/viktor/init.md`
- **验收标准**：
  - [ ] doc.md description 包含"活文档更新"和"ADR 自动编号"
  - [ ] init.md description 包含"活文档骨架"
- **依赖**：T009

#### T011：版本号 v0.4.0 + README/团队指南更新 [docs]

- **描述**：更新 `README.md` 和 `docs/team-workflow-guide.md` 版本号至 v0.4.0，在 CHANGELOG.md [Unreleased] 中记录本次变更。
- **文件路径**：
  - `README.md`
  - `docs/team-workflow-guide.md`
  - `CHANGELOG.md`
- **验收标准**：
  - [ ] README.md 版本号 v0.4.0
  - [ ] team-workflow-guide.md 版本号 v0.4.0
  - [ ] CHANGELOG.md [Unreleased] 包含活文档体系、ADR 编号、替代流程、变更检测 4 条说明
- **依赖**：T010

---

## 风险标注

| 任务 | 风险类型 | 说明 | 应对策略 |
|------|---------|------|---------|
| T001-T003 | ⚠️ 同文件连续修改 | 三次改同一 SKILL.md，每次需确认没有破坏已有内容 | 每个任务改完后通读受影响的步骤区间 |
| T006-T008 | ⚠️ 三端一致性 | 三个入口文件描述需保持逻辑一致，但可详略有别 | 以 CLAUDE.md 为基准，其他两端对照交叉检查 |

## 验收总结

- [ ] 所有 P0 任务完成：DOCUMENT + INIT 两个 SKILL.md 改造完毕
- [ ] `skills/05-documentation/SKILL.md` 包含 4 项新能力（变更检测/自动编号/替代/活文档更新）
- [ ] `skills/06-project-init/SKILL.md` 包含第 6 步和 4 个骨架模板
- [ ] `references/living-docs-conventions.md` 存在且包含 5 个章节
- [ ] CLAUDE.md / AGENTS.md / workflow.mdc 三端描述一致
- [ ] `skills/using-fe-workflow/SKILL.md` 已同步
