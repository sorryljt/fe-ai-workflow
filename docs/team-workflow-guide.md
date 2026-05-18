# fe-ai-workflow 团队试点指南

**版本**：v0.4.0
**日期**：2026-05-18
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
cd .workflow/fe-ai-workflow && git checkout v0.4.0 && cd ../..

# 同步入口文件到项目根目录
.workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow .

# 写入 postinstall（之后 npm install 自动同步）
npm pkg set scripts.postinstall=".workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow . || true"

# 提交
git add .gitmodules .workflow/fe-ai-workflow package.json
git commit -m "chore: add fe-ai-workflow v0.4.0"
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
.workflow/fe-ai-workflow/scripts/upgrade-workflow.sh v0.4.0
```

完成后确认变更，按需提交。

---

### Windows 说明

> **前提**：需要安装 [Git for Windows](https://git-scm.com/download/win)，安装完成后重新打开终端使 PATH 生效。

上方命令均为 bash 语法，Windows 用户有两种方式：

**推荐：Git Bash**（Git for Windows 自带）  
在项目根目录右键 → **Git Bash Here**，执行与 macOS/Linux 完全相同的命令。  
唯一差异：`postinstall` 步骤改为：

```bash
npm pkg set scripts.postinstall="bash .workflow/fe-ai-workflow/scripts/sync-workflow.sh .workflow/fe-ai-workflow . || true"
```

**备选：PowerShell**  
`&&` 需改为分行执行，`.sh` 脚本加 `bash` 前缀，其余命令相同。详见 [README - Windows 安装](../README.md#windows-安装)。

**`bash` 无法识别？**
- Git for Windows 未安装 → 先安装，安装后重新打开 PowerShell
- 已安装但命令找不到 → 在 PowerShell 运行 `$env:PATH += ";C:\Program Files\Git\bin"` 后重试

---

### 安装 / 升级后第一步

直接用 `/viktor:think <需求描述>` 开始第一个需求即可。

如果项目知识地图（`docs/project-context.md`）不存在，工作流会在 BRAINSTORM 开始前自动扫描项目并生成，无需手动执行 `/viktor:init`。

> 也可以提前手动执行 `/viktor:init`，适合想先了解项目结构再开始需求的场景。

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

初始化项目知识地图，扫描当前项目并生成 `docs/project-context.md`，同时创建活文档骨架（`component-catalog.md`、`api-catalog.md`、`architecture.md`、`docs/adrs/README.md`），为后续每次需求完成后的活文档更新做好准备。

### 4.2 `/viktor:think` / `viktor:think`

需求澄清，生成设计文档 `docs/specs/YYYY-MM-DD--design.md`。

### 4.3 `/viktor:plan` / `viktor:plan`

将设计文档拆解为任务列表 `docs/plans/YYYY-MM-DD--tasks.md`。
完成后根据任务构成自动推荐是否执行 `/viktor:contract`。

### 4.3.5 `/viktor:contract` / `viktor:contract`（可选）

从任务列表提取 TypeScript 类型定义，生成 `docs/contracts/YYYY-MM-DD--<feature>.types.ts`。

- ANALYZE 完成后若检测到 `[api]`/`[hook]`/`[store]` 类型任务，会主动推荐
- 用户可选择执行或跳过，直接进入 `/viktor:code`
- TDD 实现时会自动感知合约文件，将其作为类型锚点
- REVIEW 时若合约存在，会增加第六检查轴（类型一致性）

### 4.4 `/viktor:code` / `viktor:code`

按 TDD 实现任务，输出代码与测试。

### 4.5 `/viktor:cr` / `viktor:cr`

审查实现，生成 `docs/reviews/YYYY-MM-DD--review.md`。

### 4.6 `/viktor:doc` / `viktor:doc`

生成 ADR（自动编号，支持标记历史 ADR 为"已替代"），有条件地更新活文档（组件目录 / 接口目录 / 架构速览 / ADR 索引），更新 `CHANGELOG.md`。若本次修改了工作流自身文件，会提示同步三端入口。

## 5. 各节点说明

### INIT

先扫描项目结构，生成 `docs/project-context.md`，同时创建活文档骨架（4 个文件），让后续需求分析不必重复摸索项目上下文，也为每次 DOCUMENT 的活文档更新准备好落脚点。

### BRAINSTORM

把模糊需求转成可确认的设计文档，重点是方案对比、假设声明和可测试验收标准。

### ANALYZE

把设计文档拆成小任务，每个任务都应该能在一个短 TDD 循环里完成。
完成后根据任务构成给出推荐：含接口/Hook/Store 类型 → 推荐先执行 CONTRACT。

### CONTRACT（可选）

从任务列表提取结构化 TypeScript 类型，生成合约文件。
消除节点间的"类型漂移"，让 TDD 和 REVIEW 都有明确的类型锚点。

### TDD

先写测试，再写实现，再重构，确保每一步都可验证。

### REVIEW

按正确性、可维护性、性能、安全性、测试质量、类型合约一致性六轴审查。
若无合约文件，第六轴自动跳过，不影响原有审查流程。

### DOCUMENT

生成 ADR（自动三位数编号，支持替代历史决策），有条件地更新活文档（组件目录 / 接口目录 / 架构决策速览 / ADR 索引），并更新 CHANGELOG。若本次变更涉及工作流自身规则文件，自动提示同步三端入口，防止平台间不一致。

## 6. 试点建议与反馈入口

- 先让 1-3 名成员试用，不要一开始全员铺开
- 先选一个小而完整的需求，走完全流程
- 试点时重点观察三件事：
  - 命令是否好触发
  - 门禁是否好理解
  - 文档是否真的帮助团队协作

## 7. 版本更新方式

当 workflow 仓库发布新版本后，在业务项目根目录执行一条命令即可：

```bash
.workflow/fe-ai-workflow/scripts/upgrade-workflow.sh <新版本 tag>
```

脚本会自动完成：切换版本 → 同步入口文件 → 提交。建议先在非关键项目上验证新版本后再推广。

建议反馈记录在 workflow 仓库的 issue 或团队约定的试点群里。
