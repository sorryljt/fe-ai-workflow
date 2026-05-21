# P3 框架无关化与验证脚本 设计文档

**日期**：2026-05-21
**状态**：已确认
**关联 PRD**：内部优化（来自整体分析清单 P3 级别）

> **设计假设**（以下判断来自项目上下文推断，如有不符请在确认时指出具体条目）：
> 1. P3-1 保留所有 React/Next.js 代码示例，但显式标注为"以下以 React/Next.js + Vitest 为例"，不删除
> 2. P3-1 将三张分层规范表格（强制/适度/不适合 TDD）中的 Next.js 专有概念（Server Component、Server Action、App Router、`next/image`）替换为框架无关描述
> 3. P3-1 在 SKILL 顶部新增"框架适配"说明块，要求读取 `docs/project-context.md` 决定测试工具
> 4. P3-1 对 `references/react-nextjs-conventions.md` 的引用改为条件性说明（"如为 React/Next.js 项目则参照"）
> 5. P3-2 脚本语言为 bash（与现有 `scripts/sync-workflow.sh` 保持一致），输出带颜色的 PASS/FAIL，exit code 0/1
> 6. P3-2 检查范围：9 个 viktor:* 命令在三端入口中的存在性 + using-fe-workflow/SKILL.md 中引用的 Skill 文件实际存在

## 1. 背景

P3 批次解决两组影响工作流长期可维护性的深层问题：

1. **P3-1：TDD SKILL 与框架声明不符**。项目 README 和 CLAUDE.md 均声明"框架无关（React / Vue / Svelte 等均适用）"，但 `skills/03-tdd-cycle/SKILL.md` 标题就写着"React/Next.js 特化"，内容中大量使用 Next.js 专有概念（Server Component、Server Action、App Router、`next/image`、`npx vitest run` 硬编码等）。非 React 项目接入后执行 TDD SKILL 会遇到大量无法适用的指令，需要自行判断如何变通。

2. **P3-2：三端一致性无自动化验证**。工作流有三个平台入口（CLAUDE.md / AGENTS.md / workflow.mdc），修改时需手动对照确保命令名称一致。目前验证依赖人工检查，容易遗漏，且没有固定的检查清单。一个 bash 脚本可在每次修改后快速跑一遍基础一致性检查。

## 2. 目标

**要做的事**：
- [x] P3-1：将 `skills/03-tdd-cycle/SKILL.md` 的三张分层表格改为框架无关描述
- [x] P3-1：在 SKILL 顶部新增"框架适配"说明块
- [x] P3-1：将 SKILL 文件名/描述中的"React/Next.js 特化"改为"框架无关"
- [x] P3-1：将 `references/react-nextjs-conventions.md` 的引用改为条件性说明
- [x] P3-1：代码示例保留但显式标注"React/Next.js 参考实现"
- [x] P3-2：新建 `scripts/validate-workflow.sh`，检查三端命令一致性 + Skill 文件存在性
- [x] P3-2：脚本可执行（`chmod +x`），含简单 `--help` 说明

**不做的事（明确边界）**：
- 不删除任何 React/Next.js 代码示例（删除会降低现有用户价值）
- 不为每个框架分别写示例（范围过大，且项目目标是"原则"而非"多框架配置库"）
- 不自动修复三端不一致（脚本只做检测，修复需人工处理）
- 不修改 `references/react-nextjs-conventions.md` 本身（它的内容本就是 React 专用规范，保持原样）

## 3. 方案对比

### P3-1：框架适配机制

| 方案 | 描述 | 选择结果 |
|------|------|---------|
| 仅重命名标题 | 去掉"React/Next.js 特化"字样 | ❌ 治标不治本，表格内容仍 Next.js 专有 |
| 中度重构（选择） | 重写三张表格 + 顶部适配说明 + 条件引用，保留示例 | ✅ 一步到位，兼顾实用性与准确性 |
| 完全抽象 | 删除所有 React 示例 | ❌ 损失主流用户的参考价值 |

### P3-2：脚本检查策略

| 检查维度 | 是否包含 | 说明 |
|---------|---------|------|
| 9 个 viktor:* 命令在 CLAUDE.md 中存在 | ✅ | 主要入口 |
| 9 个 viktor:* 命令在 AGENTS.md 中存在 | ✅ | Codex 入口 |
| 9 个 viktor:* 命令在 workflow.mdc 中存在 | ✅ | Cursor 入口 |
| using-fe-workflow/SKILL.md 中引用的 Skill 文件存在于磁盘 | ✅ | 防止孤立引用 |
| Skill 内容语义一致性 | ❌ 不包含 | 需要 NLP，超出 bash 脚本能力范围 |

## 4. 选定方案

详见上方对比表 ✅ 项。

## 5. 技术细节

### 5.1 P3-1：TDD SKILL 改动点

**改动 1 — SKILL 元信息**：
- frontmatter description 中"React/Next.js 特化"→"框架无关，React/Next.js 参考实现"
- 文件内一级标题副标题同步

**改动 2 — 顶部新增"框架适配"说明块**（插入在"TDD 分层规范"章节之前）：

```
> **框架适配**：本 SKILL 适用于所有前端框架。在开始前，先读取
> `docs/project-context.md` 确认当前项目的框架和测试工具：
>
> | 框架 | 推荐测试工具 | 组件测试库 |
> |------|------------|-----------|
> | React / Next.js | Vitest | React Testing Library |
> | Vue 3 | Vitest | Vue Test Utils |
> | Svelte | Vitest | @testing-library/svelte |
> | 其他 | 项目已有测试工具 | 对应生态测试库 |
>
> 以下示例代码以 **React/Next.js + Vitest** 为参考实现，
> 其他框架按对应工具类比执行。
```

**改动 3 — "强制 TDD"表格**（移除 Next.js 专有行）：

| 原内容 | 改为 |
|--------|------|
| `Server Actions 表单提交处理、数据变更` | `服务端数据变更逻辑（如 Server Action、API handler）` |
| `API 路由 Next.js route handlers` | `API 路由 / 接口处理函数` |

**改动 4 — "适度 TDD"表格**：保持现有行（通用概念），无需改动。

**改动 5 — "不适合 TDD"表格**：

| 原内容 | 改为 |
|--------|------|
| `图片是否使用 next/image？` | 移出此表（这是 Review 轴 3 的检查项，不属于 TDD 分层） |
| `第三方库集成层` | 保持原样（通用） |

**改动 6 — `references/react-nextjs-conventions.md` 的引用**：

将 REFACTOR 步骤中：
```
- **规范**：是否符合 `references/react-nextjs-conventions.md`？
```
改为：
```
- **规范**：是否符合项目约定的编码规范？
  （React/Next.js 项目参照 `references/react-nextjs-conventions.md`；
   其他框架参照项目自身 `docs/project-context.md` 中记录的规范）
```

**改动 7 — 代码示例标注**：在第一个代码块前插入说明行：
```
> 以下示例以 React/Next.js + Vitest 为参考实现：
```

### 5.2 P3-2：validate-workflow.sh 结构

```bash
#!/usr/bin/env bash
# validate-workflow.sh — 验证三端工作流入口与 Skill 文件一致性
# 用法：bash scripts/validate-workflow.sh
# 退出码：0=全部通过，1=有失败项

COMMANDS=(think plan code cr doc contract context digest init)
PASS=0; FAIL=0

check() { ... }   # 输出 ✅/❌ 并计数

# 检查组 1：三端命令存在性
for cmd in "${COMMANDS[@]}"; do
  check "CLAUDE.md 含 viktor:$cmd"      "grep -q 'viktor:$cmd' CLAUDE.md"
  check "AGENTS.md 含 viktor:$cmd"      "grep -q 'viktor:$cmd' AGENTS.md"
  check "workflow.mdc 含 viktor:$cmd"   "grep -q 'viktor:$cmd' .cursor/rules/workflow.mdc"
done

# 检查组 2：Skill 文件存在性（从 using-fe-workflow/SKILL.md 映射表提取路径）
SKILLS=(
  "skills/01-brainstorming/SKILL.md"
  "skills/02-requirements-analysis/SKILL.md"
  "skills/03-tdd-cycle/SKILL.md"
  "skills/04-code-review/SKILL.md"
  "skills/05-documentation/SKILL.md"
  "skills/06-project-init/SKILL.md"
  "skills/07-type-contract/SKILL.md"
  "skills/08-context/SKILL.md"
  "skills/09-digest/SKILL.md"
  "skills/using-fe-workflow/SKILL.md"
)
for skill in "${SKILLS[@]}"; do
  check "Skill 文件存在: $skill" "[ -f '$skill' ]"
done

# 汇总
echo "结果：$PASS 通过 / $FAIL 失败"
[ $FAIL -eq 0 ] && exit 0 || exit 1
```

## 6. 边界条件与错误处理

| 场景 | 处理方式 |
|------|---------|
| 脚本在非仓库根目录运行 | 检测 `.git` 目录，不存在时打印提示后 exit 1 |
| AGENTS.md 不存在 | 对应检查显示 ❌，不中断其他检查 |
| workflow.mdc 不存在 | 对应检查显示 ❌，不中断其他检查 |
| TDD SKILL 改动破坏已有表格结构 | 改动后 Read 文件目视核查 |

## 7. 验收标准

**P3-1**：
- [ ] `skills/03-tdd-cycle/SKILL.md` 中不再出现裸露的"React/Next.js 特化"（frontmatter description 和章节标题均已更新）
- [ ] SKILL 顶部存在"框架适配"说明块，含框架-测试工具对照表
- [ ] "强制 TDD"表格中不再出现"Next.js route handlers"（已改为通用描述）
- [ ] REFACTOR 步骤的规范检查改为条件性说明
- [ ] 文件中至少一处代码块前有"React/Next.js 参考实现"标注

**P3-2**：
- [ ] `scripts/validate-workflow.sh` 文件存在
- [ ] 脚本包含 `chmod +x` 权限（或文件模式为可执行）
- [ ] 脚本在仓库根目录运行时输出 ✅/❌ 列表
- [ ] 所有当前检查项均为 ✅（三端命令存在 + Skill 文件存在）
- [ ] exit code：全通过为 0，有失败为 1
