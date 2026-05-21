# fe-ai-workflow 团队试点指南

**版本**：v0.8.0
**日期**：2026-05-19
**适用范围**：团队内部小范围试点

## 1. 背景

这套工作流用于统一前端团队在 Claude Code、OpenAI Codex 和 Cursor 中的需求澄清、任务拆解、测试驱动实现、代码审查和文档沉淀方式。

试点的目的不是一次性替换所有现有做法，而是先让少量成员在真实项目里试用，验证两个问题：

1. 工作流是否能稳定跑通
2. 团队是否愿意按同一套门禁和文档节奏协作

## 2. 使用方式

根据你的情况选择对应场景。

> **安全说明**：同步脚本对 `CLAUDE.md` 和 `AGENTS.md` 采用**标记注入**方式，不会覆盖项目中已有的内容。工作流配置会被写入 `<!-- fe-ai-workflow-start -->` 和 `<!-- fe-ai-workflow-end -->` 标记之间，用户自己的内容完整保留。`skills/`、`references/`、`.claude/commands/` 等目录会直接覆盖（这些目录不应包含用户自定义内容）。

---

### 场景一：首次在新项目中接入

> **重要：必须在业务项目根目录下执行**（即你会用 Claude Code / Cursor 打开的那个目录）。
> 如果你的文件结构是 `mywork/business-project/`，应该先 `cd mywork/business-project`，再执行下面的命令。
> 在上层目录安装会导致 `/viktor:*` 命令不可用，`skills/` 路径也无法解析。

在业务项目根目录，**整体复制执行**：

```bash
# 引入 workflow 并锁定版本
git submodule add https://github.com/sorryljt/fe-ai-workflow.git .workflow/fe-ai-workflow
cd .workflow/fe-ai-workflow && git checkout v0.8.0 && cd ../..

# 同步入口文件到项目根目录
.workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow .

# 写入 postinstall（之后 npm install 自动同步）
npm pkg set scripts.postinstall=".workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow . || true"

# 提交
git add .gitmodules .workflow/fe-ai-workflow package.json
git commit -m "chore: add fe-ai-workflow v0.8.0"
```

---

### 场景二：克隆已接入 workflow 的项目（新成员）

```bash
git clone --recurse-submodules <项目地址>
cd <项目目录>
npm install
```

`--recurse-submodules` 会自动拉取 workflow 子模块，`npm install` 触发 `postinstall` 完成同步。无需额外操作。

---

### 场景三：升级 workflow 版本

```bash
.workflow/fe-ai-workflow/scripts/upgrade-workflow.sh <新版本tag>
```

完成后确认变更，按需提交。

---

### 场景四：验证三端一致性

每次修改 workflow 文件（CLAUDE.md / AGENTS.md / workflow.mdc）后，建议运行：

```bash
bash scripts/validate-workflow.sh
```

脚本检查 9 个 `viktor:*` 命令在三端入口的存在性 + 10 个 Skill 文件是否存在，共 37 项，输出彩色 PASS/FAIL 报告，exit 0/1，支持 CI 集成。

> **运行环境**：需在 **Git Bash 或 WSL** 下执行，不支持 PowerShell。
> Windows 用户：右键项目目录 → "Git Bash Here"，再运行上述命令。

---

### 安装 / 升级后第一步

直接用 `/viktor:think <需求描述>` 开始第一个需求即可。

如果项目知识地图（`docs/project-context.md`）不存在，工作流会在 BRAINSTORM 开始前自动扫描项目并生成，无需手动执行 `/viktor:init`。

> 也可以提前手动执行 `/viktor:init`，适合想先了解项目结构再开始需求的场景。新成员接入时，也可以先执行 `/viktor:context` 快速获取项目全貌。

## 3. 平台差异说明

### 3.1 Claude Code

- 继续使用 `/viktor:*` 命令式体验
- 启动时读取根目录 `CLAUDE.md`
- 命令和门禁规则与现有流程一致

### 3.2 OpenAI Codex

- 使用无前导 `/` 的 `viktor:*` 文本协议
- 启动时读取根目录 `AGENTS.md`
- 即使命令面板不显示，也要按文本协议或自然语言意图路由

### 3.3 Cursor

- 读取 `.cursor/rules/workflow.mdc`
- 保持与工作流一致的节点顺序和门禁

## 4. 命令总览

> **注意：** 新需求必须从 `/viktor:think` 开始，不能直接跳到 `/viktor:code` 或 `/viktor:cr`。每个节点依赖前一节点生成的文档（`design.md` → `tasks.md` → 代码），缺少对应文件会被拦截。

### 4.1 `/viktor:init` / `viktor:init`

扫描当前项目并生成 `docs/project-context.md`（项目知识地图），同时创建活文档骨架（`component-catalog.md`、`api-catalog.md`、`architecture.md`、`docs/adrs/README.md`），为后续每次需求完成后的活文档更新做好准备。

### 4.2 `/viktor:think` / `viktor:think`

需求澄清，生成设计文档 `docs/specs/YYYY-MM-DD--design.md`。把模糊需求转成结构化方案，明确验收标准，是整个流程的起点。

### 4.3 `/viktor:plan` / `viktor:plan`

将设计文档拆解为任务列表 `docs/plans/YYYY-MM-DD--tasks.md`。完成后根据任务构成自动推荐是否执行 `/viktor:contract`。

### 4.3.5 `/viktor:contract` / `viktor:contract`（可选）

从任务列表提取 TypeScript 类型定义，生成 `docs/contracts/YYYY-MM-DD--<feature>.types.ts`。

- ANALYZE 完成后若检测到 `[api]`/`[hook]`/`[store]` 类型任务，会主动推荐
- 用户可选择执行或跳过，直接进入 `/viktor:code`
- TDD 实现时会自动感知合约文件，将其作为类型锚点
- REVIEW 时若合约存在，会增加第六检查轴（类型一致性）

### 4.4 `/viktor:code` / `viktor:code`

按 TDD 循环实现任务：先写测试（RED）→ 写实现（GREEN）→ 重构（REFACTOR），每个任务 commit 一次。

### 4.5 `/viktor:cr` / `viktor:cr`

六轴代码审查（正确性 / 可维护性 / 性能 / 安全性 / 测试质量 / 类型合约一致性），生成 `docs/reviews/YYYY-MM-DD--review.md`。有 `[BLOCKING]` 问题必须修复后才能继续。

### 4.6 `/viktor:doc` / `viktor:doc`

生成 ADR（自动编号，支持标记历史 ADR 为"已替代"），有条件地更新活文档（组件目录 / 接口目录 / 架构速览 / ADR 索引），更新 `CHANGELOG.md`。若本次修改了工作流自身文件，会提示同步三端入口。若 ADR 累积到 5 的倍数，会非阻塞建议执行 `/viktor:digest`。

### 4.7 `/viktor:context` / `viktor:context`（工具节点，随时可用）

读取 5 个活文档（项目知识地图 / 组件目录 / 接口目录 / 架构速览 / ADR 索引），格式化输出到当前对话。

- **随时可用**，无需任何前置条件，不影响主流程
- **只读无副作用**：不生成文件，不创建 commit
- **最佳使用时机**：开始新需求前回顾项目现状；新成员快速了解项目；不想翻多个文件时
- BRAINSTORM 开始时，若项目知识地图存在，会自动非阻塞提示可执行本命令
- 文件缺失时给出说明（建议先执行 `/viktor:init`），不报错

### 4.8 `/viktor:digest` / `viktor:digest`（工具节点，随时可用）

读取 `docs/` 下所有文档，生成阶段性整合摘要 `docs/digest/YYYY-MM-DD--digest.md`。

- **随时可手动执行**，适合一批需求完成后做阶段性回顾
- 摘要包含 5 个章节：项目当前状态 / 本阶段完成需求 / 关键架构决策 / 活文档现状 / 待关注问题
- DOCUMENT 节点完成后，若 ADR 数量达到 5 的倍数（如 ADR-005、ADR-010），会非阻塞建议执行本命令
- 产物自动 commit

## 5. 试点建议与反馈入口

- 先让 1-3 名成员试用，不要一开始全员铺开
- 先选一个小而完整的需求，走完全流程
- 试点时重点观察三件事：
  - 命令是否好触发
  - 门禁是否好理解
  - 文档是否真的帮助团队协作

## 6. 版本更新方式

当 workflow 仓库发布新版本后，在业务项目根目录执行一条命令即可：

```bash
.workflow/fe-ai-workflow/scripts/upgrade-workflow.sh <新版本tag>
```

脚本会自动完成：切换版本 → 同步入口文件 → 提交。建议先在非关键项目上验证新版本后再推广。

建议反馈记录在 workflow 仓库的 issue 或团队约定的试点群里。
