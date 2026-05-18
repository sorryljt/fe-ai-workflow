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

自然语言也触发（用户不输入命令时）：

| 用户意图 | 节点 |
|---------|------|
| "做需求澄清" / "先设计方案" / "brainstorm" | BRAINSTORM |
| "拆任务" / "生成任务列表" | ANALYZE |
| "生成类型合约" / "锁定接口定义" / "先定义类型" | CONTRACT |
| "开始写代码" / "按任务实现" | TDD |
| "code review" / "审查代码" | REVIEW |
| "生成文档" / "补 ADR" | DOCUMENT |

---

## 节点执行规范

### INIT

**触发**：`viktor:init`
**输出**：`docs/project-context.md`

1. 扫描项目文件结构（排除 node_modules / .next / dist）
2. 读取 `package.json` 提取技术栈
3. 整理现有组件、Hooks、工具函数、API 路由
4. 生成并保存 `docs/project-context.md`

---

### BRAINSTORM

**触发**：`viktor:think <需求描述>`
**输出**：`docs/specs/YYYY-MM-DD--<feature>.md`

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
**输出**：`docs/adrs/YYYY-MM-DD--<feature>--adr.md` + 更新 `CHANGELOG.md`

1. 汇总 design.md + tasks.md + review.md
2. 提取关键技术决策和权衡
3. 生成 ADR 文档
4. 更新 CHANGELOG.md

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

## 产物目录规范

```
docs/
├── specs/      # viktor:think 产物
├── plans/      # viktor:plan 产物
├── contracts/  # viktor:contract 产物（可选）
├── reviews/    # viktor:cr 产物
└── adrs/       # viktor:doc 产物
```

## 编码规范参考

- `references/react-nextjs-conventions.md` — React/Next.js/TypeScript 规范
- `references/testing-patterns.md` — Vitest + React Testing Library 模式
- `references/prd-input-template.md` — PRD 输入格式

## Git Tag 发布规范

- **工作流变更**（节点规则、脚本、AGENTS.md 更新）→ 先更新文档版本号 → commit → 打 tag → push
- **文档修复** → 直接推 main，不打 tag
