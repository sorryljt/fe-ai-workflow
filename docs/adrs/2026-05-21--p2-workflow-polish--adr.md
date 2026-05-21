# ADR-008: P2 工作流打磨批次（frontmatter 规范、Workflow-Meta Lane 正式化、TDD commit 粒度建议）

**日期**：2026-05-21
**状态**：已接受
**提出者**：Dawson
**关联需求**：P2 工作流打磨批次

## 背景

P0/P1 批次完成了一致性和稳定性修复。P2 批次解决三组长期使用中的摩擦点：

1. **产物文档状态字段不可机器读取**：specs/plans/reviews 的状态（已确认/完成/PASS）只存在于 Markdown 正文，DIGEST 只能扫描正文文字来识别状态，脆弱且难以扩展。未来若需构建自动化脚本或验证工具，无结构化入口。

2. **Workflow-Meta Lane 未正式化**：在 P0/P1 两个批次中，修改 skills/ 文件时实际走的是一条不同于业务功能的通道（无 TDD、grep 验收、每文件 commit），但这条通道在任何文档中都没有正式描述。每次执行时需要临时判断"这次要不要跑 vitest"，缺乏一致性参考。

3. **TDD commit 粒度无指导**：TDD SKILL 规定了红→绿→重构循环，但没有说明何时提交。实践中两种模式（每任务 vs. 里程碑）均合理，缺少建议导致执行时决策混乱。

## 决策

**我们决定通过 7 项精确文本改动解决上述三组问题：**

**frontmatter 规范化（T001-T004）**：
- 在 BRAINSTORM / ANALYZE / REVIEW 的输出模板中各自添加 YAML frontmatter 块
- 字段设计：specs → `status/confirmed_at`，plans → `status/spec`，reviews → `result/reviewed_at/plan`
- DIGEST step 2 优先读取 frontmatter，无 frontmatter 时降级正文扫描（向后兼容）

**Workflow-Meta Lane 正式化（T005-T006）**：
- 在 `skills/using-fe-workflow/SKILL.md` 新增独立章节，定义触发条件、Feature vs. Meta 对比表（6 维度）、三端同步粒度规则
- 在 `CLAUDE.md` 流程图注释区添加一行说明，指向 SKILL 详情

**TDD commit 粒度建议（T007）**：
- 在 TDD SKILL 的 commit 步骤之后追加建议块
- 推荐：每任务提交（原子粒度，便于回滚）
- 可选：里程碑提交（tasks.md 中 `# --- commit here ---` 标记）
- 不推荐：全部完成后一次性提交

## 方案对比

### frontmatter 存储位置

| 方案 | 优势 | 劣势 | 选择结果 |
|------|------|------|---------|
| YAML frontmatter（选择） | 结构化、可机器解析、Markdown 生态标准 | 与正文字段轻微冗余 | ✅ 选择 |
| 正文字段（现状） | 人类可读 | 不可机器解析，DIGEST 扫描脆弱 | ❌ 保留为降级 |
| JSON sidecar 文件 | 完全结构化 | 文件数翻倍，维护负担高 | ❌ 排除 |

### Workflow-Meta Lane 文档位置

| 方案 | 选择结果 |
|------|---------|
| 新建独立 SKILL 文件 `skills/10-workflow-meta/SKILL.md` | ❌ 过重，与 using-fe-workflow 职责重叠 |
| 写入 `skills/using-fe-workflow/SKILL.md`（选择） | ✅ 元调度器本职，位置最合理 |
| 仅写入 CLAUDE.md | ❌ 太精简，无执行细节 |

### commit 粒度机制

| 方案 | 选择结果 |
|------|---------|
| TDD 开始时选择模式（交互） | ❌ 过度设计，增加不必要摩擦 |
| tasks.md 里程碑标记（选择） | ✅ 可选机制，不影响默认行为 |
| 仅文档建议（选择） | ✅ 足够，无需引入新交互 |

## 结果

**正面影响**：
- specs/plans/reviews 文件获得机器可读状态字段，为未来验证脚本/自动化工具提供入口
- Workflow-Meta Lane 有了正式参考，后续修改 skills/ 时执行者知道跳过 TDD 是有据可查的决策而非临时判断
- TDD commit 建议降低执行时的决策负担，推荐模式（每任务）与 P1 实践保持一致

**负面影响 / 已知问题**：
- DIGEST step 2 三行因追加说明变得较长（>200 字符），纯文本阅读体验略降（已在 Review 中记录为 NIT，可后续换行优化）
- frontmatter 与正文的 `**状态**` 字段存在轻微冗余，但两者服务不同读者（机器 vs. 人类），可接受

**实际效果**：所有 7 项验收 grep 检查通过，改动已 committed。

## 后续行动

- [ ] P3-1：TDD SKILL 框架无关全面重构（脱离 React/Next.js 硬编码描述）
- [ ] P3-2：`scripts/validate-workflow.sh` 三端一致性验证脚本（可利用 frontmatter 解析 spec 状态）
- [ ] 可选：DIGEST step 2 三行换行缩进优化（NIT 级别，随时可处理）

## 相关文档

- 设计文档：[docs/specs/2026-05-21--p2-workflow-polish.md](../specs/2026-05-21--p2-workflow-polish.md)
- 任务列表：[docs/plans/2026-05-21--p2-workflow-polish--tasks.md](../plans/2026-05-21--p2-workflow-polish--tasks.md)
- Review 报告：[docs/reviews/2026-05-21--p2-workflow-polish--review.md](../reviews/2026-05-21--p2-workflow-polish--review.md)
- 前序决策：[ADR-007](2026-05-21--p1-stability-fixes--adr.md)（P1 稳定性修复）
