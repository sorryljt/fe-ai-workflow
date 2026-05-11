---
name: 05-documentation
description: 架构决策记录与文档沉淀 - CR 通过后汇总所有产物，生成 ADR 和更新 CHANGELOG，关闭本次需求的完整工作流
---

# DOCUMENT — 文档沉淀

## 触发条件

以下情况触发本 Skill：
- 用户输入 `/viktor:doc` 命令
- REVIEW 节点完成且无 BLOCKING 问题

**前置条件检查**（缺少时停止并提示）：
- `docs/reviews/` 下必须存在 review.md 且结论为 PASS
- 如果 review.md 不存在：提示 "请先运行 `/viktor:cr` 完成代码审查"
- 如果 review.md 结论为 BLOCK：提示 "Review 尚有 BLOCKING 问题未解决，请先返回 `/viktor:code` 修复"

## 执行步骤

### 第 1 步：汇总本次需求的所有产物

收集并列举以下文件：
- `docs/specs/YYYY-MM-DD--design.md`（设计文档）
- `docs/plans/YYYY-MM-DD--tasks.md`（任务列表）
- `docs/reviews/YYYY-MM-DD--review.md`（Review 报告）
- 所有实现文件路径
- 所有测试文件路径

记录关键数据：
- 任务总数 / 完成数
- 最终测试覆盖率（来自 review.md 中的自动化检查结果）
- Review 中发现的 [SUGGESTED] 问题列表（记入 ADR 的"已知问题"）

### 第 2 步：提取关键技术决策

从以上文档中识别以下内容，为 ADR 做准备：

**架构决策**（必须记录）：
- 选择了哪种技术方案？（来自 design.md 的"选定方案"）
- 为什么选这个而不是其他方案？（决策理由）
- 这个决策有哪些前提假设？

**重要权衡**（若有记录）：
- 在什么约束下做了什么取舍？
- 为了获得 X 好处，接受了 Y 代价

**已知问题**（诚实记录）：
- Review 中发现的 [SUGGESTED] 问题（未立即修复）
- 实现过程中发现的技术债务
- 未覆盖的边缘场景

**未来工作**（若有）：
- 后续可优化的方向
- 暂时 workaround 的部分，未来需要正式解决

### 第 3 步：生成 ADR 文档

按下方「ADR 模板」生成文档，保存到：
`docs/adrs/YYYY-MM-DD--<feature-name>--adr.md`

**质量标准（生成后自检）**：
6 个月后，新加入的团队成员读到这篇 ADR，能回答以下问题：
- 当时面临什么具体问题？（背景要足够具体）
- 为什么选 A 而不选 B？（方案对比要清晰）
- 这个决策带来了什么后果？（结果要诚实，包括负面影响）

如果以上任何一个问题答不上来，说明 ADR 需要补充。

### 第 4 步：更新 CHANGELOG.md

在 `CHANGELOG.md` 中的 `[Unreleased]` 部分添加本次变更：

```markdown
## [Unreleased]

### Added
- [功能名称]：[一句话描述] ([ADR](docs/adrs/YYYY-MM-DD--adr.md))

### Changed
- [如有修改已有功能]

### Fixed
- [如有 Bug 修复]
```

**CHANGELOG 写作原则**：
- 面向使用者，不是面向开发者
- 说明变化对用户的影响，而不是"修改了 X 文件"
- 每条变更附 ADR 链接，方便追溯决策背景

### 第 5 步：最终 Commit

```bash
git add docs/adrs/ CHANGELOG.md
git commit -m "docs: add ADR and update changelog for <feature-name>"
```

### 第 6 步：完成提示

提示用户：
> "🎉 文档沉淀完成！本次需求已走完完整工作流。
>
> 产物汇总：
> - 设计文档：docs/specs/YYYY-MM-DD--<feature>.md
> - 任务列表：docs/plans/YYYY-MM-DD--<feature>--tasks.md
> - Review 报告：docs/reviews/YYYY-MM-DD--<feature>--review.md
> - 架构决策：docs/adrs/YYYY-MM-DD--<feature>--adr.md
> - CHANGELOG 已更新
>
> 可以开始下一个需求了。输入 `/viktor:think` 继续。"

---

## ADR 模板

```markdown
# ADR-XXX: [决策标题，动词开头，例：使用 httpOnly Cookie 存储 JWT Token]

**日期**：YYYY-MM-DD
**状态**：已接受
**提出者**：[姓名/团队]
**关联需求**：[功能名称]

## 背景

[描述做出此决策时面临的具体情况、约束条件和待解决的问题。要足够具体，让 6 个月后的读者能重建当时的决策环境。]

示例：
> 在实现用户认证功能时，需要选择 JWT Token 的客户端存储方式。当时的约束：
> 1. 必须支持 Next.js SSR（服务端渲染时需要能读取 Token）
> 2. 需要防范 XSS 攻击（用户输入内容可能被注入页面）
> 3. 需要支持 refresh token 机制（token 过期自动刷新）
> 4. 不引入 Redis 等服务端 session 存储（减少运维复杂度）

## 决策

**我们决定：[具体决策内容]**

[一句话明确说明做了什么决定。]

示例：
> **我们决定使用 httpOnly Cookie 存储 JWT Token**，服务端在登录成功后通过 Set-Cookie 响应头设置，
> 客户端 JavaScript 无法读取，通过 Next.js middleware 在服务端验证。

## 方案对比

| 方案 | 优势 | 劣势 | 选择结果 |
|------|------|------|---------|
| httpOnly Cookie | 防 XSS，SSR 可读，符合安全规范 | 需 CSRF 防护，跨域受限 | ✅ 选择 |
| localStorage | 实现简单，跨域无限制 | XSS 风险高，SSR 不可读 | ❌ 排除 |
| sessionStorage | 比 localStorage 稍安全 | 页面关闭丢失，SSR 不可读 | ❌ 排除 |
| 内存存储（React State） | 最安全（内存），SSR 可配合 | 页面刷新丢失，跨 tab 不共享 | ❌ 不满足持久化需求 |

## 结果

**正面影响**：
- Token 无法被 XSS 脚本窃取，安全性符合要求
- Next.js middleware 可直接读取 Cookie，SSR 认证流程顺畅
- 利用 httpOnly + SameSite=Strict 双重防护，基本满足 CSRF 防护

**负面影响 / 已知问题**：
- 需要在所有 API 路由中验证 CSRF token（增加少量开发量）
- 移动端 WebView 的 Cookie 行为需要额外测试
- [来自 Review 的 SUGGESTED 问题，如有]

**实际效果**：[如已上线，记录观察到的实际效果]

## 后续行动

- [ ] 添加 CSRF token 验证中间件（下次迭代）
- [ ] 补充移动端 WebView 的 Cookie 兼容性测试

## 相关文档

- 设计文档：[docs/specs/YYYY-MM-DD--design.md](../specs/...)
- 任务列表：[docs/plans/YYYY-MM-DD--tasks.md](../plans/...)
- Review 报告：[docs/reviews/YYYY-MM-DD--review.md](../reviews/...)
```

---

## 验证标准

文档沉淀成功完成的标志：
- [ ] ADR 的"背景"部分足够具体，6 个月后能重建决策环境（避免"需要认证功能"这种空泛描述）
- [ ] ADR 的"方案对比"清晰说明了为什么没选其他方案（不只是说选了什么）
- [ ] ADR 的"结果"包含了已知问题（诚实记录，不回避负面）
- [ ] CHANGELOG 面向使用者描述变化，不是"改了 X 文件"
- [ ] 所有文档已 committed
- [ ] 新成员读 ADR 能理解决策的「为什么」而不只是「是什么」

---

## 导航卡

节点完成后**必须**输出：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 DOCUMENT 已完成，本次需求全部收尾
📄 产物：docs/adrs/YYYY-MM-DD--<feature>--adr.md
──────────────────────────────
▶ 下一个需求：输入 /viktor:think
  开始新一轮需求澄清
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
