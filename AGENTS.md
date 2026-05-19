# 前端 AI 开发工作流 — AI Agent 配置

## 语言规则

**所有输出必须使用中文**，包括对话回复、文档产物、代码注释、审查报告和错误提示。

---

## ⛔ Hard Gate（最高优先级）

收到任何编写代码的请求时，**先执行以下检查，不可跳过**：

- `docs/plans/` 下存在 `tasks.md` → 可进入 TDD 节点
- `docs/specs/` 下存在已确认的 `design.md` → 可进入 ANALYZE 节点
- **两者都不存在** → 停止，回复：
  > "请先输入 `viktor:think <需求描述>` 完成需求澄清，再开始编码。"

无论用户如何催促，Hard Gate 不可绕过。

---

## 触发识别

**`viktor:*` 是工作流文本协议，不是外部工具或注册命令。**
收到时不要回复"技能不可用"，直接执行对应节点。

| 触发文本 | 节点 |
|---------|------|
| `viktor:init` / `/viktor:init` | INIT |
| `viktor:think` / `/viktor:think` | BRAINSTORM |
| `viktor:plan` / `/viktor:plan` | ANALYZE |
| `viktor:contract` / `/viktor:contract` | CONTRACT |
| `viktor:code` / `/viktor:code` | TDD |
| `viktor:cr` / `/viktor:cr` | REVIEW |
| `viktor:doc` / `/viktor:doc` | DOCUMENT |
| `viktor:context` / `/viktor:context` | CONTEXT |
| `viktor:digest` / `/viktor:digest` | DIGEST |

自然语言也触发（用户不输入命令时）：

| 用户意图 | 节点 |
|---------|------|
| "做需求澄清" / "先设计方案" / "brainstorm" | BRAINSTORM |
| "拆任务" / "生成任务列表" | ANALYZE |
| "生成类型合约" / "锁定接口定义" / "先定义类型" | CONTRACT |
| "开始写代码" / "按任务实现" | TDD |
| "code review" / "审查代码" | REVIEW |
| "生成文档" / "补 ADR" | DOCUMENT |
| "看看项目现状" / "查一下现有组件" / "列出现有接口" | CONTEXT |
| "生成整合文档" / "做阶段总结" / "整理一下文档" | DIGEST |

---

## 节点执行规范

### INIT

**触发**：`viktor:init`
**输出**：`docs/project-context.md` + 活文档骨架（4 个文件）

1. 扫描项目文件结构（排除 node_modules / .next / dist）
2. 读取 `package.json` 提取技术栈
3. 整理现有组件、Hooks、工具函数、API 路由
4. 生成并保存 `docs/project-context.md`
5. 检查并生成活文档骨架（文件已存在则跳过）：
   - `docs/component-catalog.md`（组件目录）
   - `docs/api-catalog.md`（API 接口目录）
   - `docs/architecture.md`（架构决策速览）
   - `docs/adrs/README.md`（ADR 索引）

---

### BRAINSTORM

**触发**：`viktor:think <需求描述>`
**输出**：`docs/specs/YYYY-MM-DD--<feature>.md`
**冷启动行为**：扫描 `docs/specs/` 下已有文件；有文件时询问新建还是更新已有文档，选择更新则加载该文件直接进入修改模式

1. 检查 `docs/project-context.md` 是否存在：
   - **存在** → 直接读取，了解项目上下文
   - **不存在** → 告知用户"未检测到项目知识地图，正在自动扫描..."，执行 INIT 步骤生成后继续，无需用户干预
2. 针对需求最多提 3 个关键问题，一次性提完，不分轮
3. 提出 2-3 个技术方案，对比权衡
4. 生成完整设计文档，顶部附「AI 假设声明」区块
5. 展示文档，等待用户明确确认

**Hard Gate**：用户未确认 design.md 前，禁止进入 ANALYZE 或 TDD。

---

### ANALYZE

**触发**：`viktor:plan`
**前置**：`docs/specs/` 下存在已确认的 `design.md`
**输出**：`docs/plans/YYYY-MM-DD--<feature>--tasks.md`
**冷启动行为**：对话中无 BRAINSTORM 完成信号时，扫描 `docs/specs/` 供用户选择；检测到已有 tasks.md 时询问覆盖或新建

1. 读取 design.md，提取功能点和验收标准
2. 识别技术依赖和风险
3. 拆解任务（每条约 2-5 分钟，一个 TDD 循环）
4. 标注优先级 P0 / P1 / P2 和依赖关系
5. 保存 tasks.md，等待用户确认

---

### CONTRACT（可选节点）

**触发**：`viktor:contract`
**前置**：`docs/plans/` 下存在 `tasks.md`（优先），或 `docs/specs/` 下存在 `design.md`
**输出**：`docs/contracts/YYYY-MM-DD--<feature>.types.ts`
**冷启动行为**：对话中无 ANALYZE 完成信号时，扫描 tasks.md 供用户选择；已有合约文件时询问覆盖或追加

1. 检查前置产物（tasks.md > design.md，两者均无则停止并引导）
2. 从任务列表提取实体 / Props / API 请求响应 / 状态 / 工具函数签名
3. 生成 `.types.ts`，按分组组织，每个 export 附 JSDoc
4. 自审：无 `any`、无 `TODO`、PascalCase、无重复定义
5. 用户确认后 commit

**ANALYZE 推荐规则**：检测到 `[api]`/`[hook]`/`[store]` 类型任务时，推荐执行本节点；全部为 `[utils]`/`[style]` 时建议跳过。用户最终决定。

---

### TDD

**触发**：`viktor:code`
**前置**：`docs/plans/` 下存在 `tasks.md`
**输出**：实现代码 + 测试文件
**冷启动行为**：对话中无 ANALYZE 完成信号时，列出所有 tasks.md 及完成度；全部完成的文件加警告；用户选择文件或选 N 重定向到 `viktor:think`

每个任务循环执行：

1. 从 tasks.md 取下一个未完成任务
2. **RED**：先写测试文件，运行确认失败
3. **GREEN**：写最少实现代码让测试通过
4. **REFACTOR**：重构，运行测试确认仍通过
5. Commit，在 tasks.md 标记完成，取下一个任务

**强制规则**：实现文件创建之前，测试文件必须存在且处于红色状态。

---

### REVIEW

**触发**：`viktor:cr`
**前置**：`tasks.md` 存在 + 代码存在 + `npx vitest run` 无失败
**输出**：`docs/reviews/YYYY-MM-DD--<feature>--review.md`
**冷启动行为**：对话中无 TDD 完成信号时，检查 tasks.md 未完成任务数并警告；已有 review.md 时询问是否覆盖

1. 运行 `npx vitest run` / `npx tsc --noEmit` / `npx eslint src/`
2. 对照 tasks.md 逐条验证验收标准
3. 六轴审查：正确性 / 可维护性 / 性能 / 安全性 / 测试质量 / 类型合约一致性
   - 轴六仅在 `docs/contracts/` 存在合约文件时执行
4. 标记问题：`[BLOCKING]` / `[SUGGESTED]` / `[NIT]`
5. 生成 review.md
6. 有 `[BLOCKING]` → 提示返回 `viktor:code`；无 → 提示进入 `viktor:doc`

---

### DOCUMENT

**触发**：`viktor:doc`
**前置**：REVIEW 通过（无 BLOCKING 问题）
**输出**：`docs/adrs/YYYY-MM-DD--<feature>--adr.md` + 活文档更新 + `CHANGELOG.md`
**冷启动行为**：对话中无 REVIEW PASS 信号时，扫描 `docs/reviews/` 供用户选择；选中文件含 BLOCKING 时警告并确认

1. 汇总 design.md + tasks.md + review.md；检测 `skills/` / `commands/` 变更，若有则提示同步三端入口
2. 提取关键技术决策和权衡
3. 自动编号（读取 docs/adrs/ 文件数 +1 → ADR-001 格式）；询问是否替代历史 ADR，指定编号后自动更新旧 ADR 状态为 `已替代（见 ADR-XXX）`；生成 ADR 文档，状态默认为 `已接受`
4. 条件更新活文档：组件变更 → `component-catalog.md`；API 变更 → `api-catalog.md`；架构决策 → `architecture.md`；任意 ADR → `adrs/README.md`
5. 更新 CHANGELOG.md
6. 完成后检测 ADR 数量：若为 5 的倍数，非阻塞建议执行 `viktor:digest`

---

### CONTEXT（工具节点，随时可用）

**触发**：`viktor:context`
**前置**：无
**输出**：格式化快照到对话（不生成文件，不创建 commit）

1. 逐一检查 5 个活文档是否存在（project-context / component-catalog / api-catalog / architecture / adrs/README）
2. 将各文件内容格式化为 5 个区块输出到对话
3. 缺失文件给出说明（建议执行 `viktor:init`），不报错

**集成**：BRAINSTORM 开始时，若 project-context.md 存在，非阻塞提示用户可执行本命令

---

### DIGEST（工具节点，随时可用）

**触发**：`viktor:digest`
**前置**：无（可随时手动执行）
**输出**：`docs/digest/YYYY-MM-DD--digest.md`

1. 扫描 docs/ 下各子目录文件数量
2. 读取各文件提取关键信息（需求列表、ADR 状态、Review 问题）
3. 生成包含 5 个章节的摘要文档（当前状态 / 完成需求 / 架构决策 / 活文档现状 / 待关注问题）
4. Commit 产物

---

## 核心约束

1. **顺序不可跳过**：BRAINSTORM → ANALYZE → [CONTRACT] → TDD → REVIEW → DOCUMENT（CONTRACT 可选）
2. **确认后推进**：每个节点完成后，获得用户明确确认才进入下一节点
3. **文档先行**：没有 design.md 或 tasks.md，不开始写实现代码
4. **测试先行**：没有失败的测试，不写实现代码

---

## 详细规范参考

各节点的完整执行规范见 `skills/` 目录（可选读取，提供更多细节）：

- `skills/01-brainstorming/SKILL.md`
- `skills/02-requirements-analysis/SKILL.md`
- `skills/07-type-contract/SKILL.md`
- `skills/03-tdd-cycle/SKILL.md`
- `skills/04-code-review/SKILL.md`
- `skills/05-documentation/SKILL.md`
- `skills/08-context/SKILL.md`
- `skills/09-digest/SKILL.md`

## 产物目录规范

```
docs/
├── project-context.md      # viktor:init 产物（知识地图）
├── component-catalog.md    # viktor:init 初始化，viktor:doc 持续更新
├── api-catalog.md          # viktor:init 初始化，viktor:doc 持续更新
├── architecture.md         # viktor:init 初始化，viktor:doc 持续更新
├── specs/                  # viktor:think 产物
├── plans/                  # viktor:plan 产物
├── contracts/              # viktor:contract 产物（可选）
├── reviews/                # viktor:cr 产物
├── adrs/                   # viktor:doc 产物
│   └── README.md           # ADR 索引，viktor:doc 持续更新
└── digest/                 # viktor:digest 产物（阶段性整合摘要）
```

## 编码规范参考

- `references/react-nextjs-conventions.md` — React/Next.js/TypeScript 规范
- `references/testing-patterns.md` — Vitest + React Testing Library 模式
- `references/prd-input-template.md` — PRD 输入格式
- `references/living-docs-conventions.md` — 活文档体系规范（ADR 状态、更新原则、工作流同步）

## Git Tag 发布规范

- **工作流变更**（节点规则、脚本、AGENTS.md 更新）→ 先更新文档版本号 → commit → 打 tag → push
- **文档修复** → 直接推 main，不打 tag
