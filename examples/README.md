# 工作流产物示例

此目录用于存放完整的工作流产物示例，帮助新成员直观理解每个节点的产物格式和质量标准。

## 目录结构（预期）

```
examples/
├── project-context.md          # /viktor:init 产物示例
├── 密码重置功能/              # 完整示例（待填充）
│   ├── design.md             # /viktor:think 产物示例
│   ├── tasks.md              # /viktor:plan 产物示例
│   ├── review.md             # /viktor:cr 产物示例
│   └── adr.md                # /viktor:doc 产物示例
└── README.md                 # 本文件
```

## 当前状态

**示例产物暂时为空。**

等第一次用此工作流完成真实需求后，将该需求的完整产物复制到对应子目录。

理想的示例功能特点：
- 涉及 2-4 个组件和 1-2 个 API 接口（不太简单也不太复杂）
- 经历了至少一轮 Review BLOCK → 修复 → 重新 Review 的流程
- 包含有意义的技术决策（方案对比有实际取舍）

## 如何填充示例

完成一个真实功能的完整工作流后：

```bash
# 复制项目知识地图（建议始终保留一份）
cp docs/project-context.md examples/project-context.md

# 创建示例目录
mkdir -p examples/<功能名称>

# 复制产物
cp docs/specs/YYYY-MM-DD--<feature>.md examples/<功能名称>/design.md
cp docs/plans/YYYY-MM-DD--<feature>--tasks.md examples/<功能名称>/tasks.md
cp docs/reviews/YYYY-MM-DD--<feature>--review.md examples/<功能名称>/review.md
cp docs/adrs/YYYY-MM-DD--<feature>--adr.md examples/<功能名称>/adr.md
```

然后在此 README 中添加对该示例的简短说明：
- 功能背景（一句话）
- 工作流中遇到的关键决策点
- 对新成员最有参考价值的内容

## 如何使用示例

新成员建议在开始第一个任务前，先阅读 `examples/` 中的示例产物，了解：

| 节点 | 示例产物 | 重点关注 |
|------|---------|---------|
| /viktor:init | project-context.md | 技术栈探测是否准确、现有组件/Hook/API 盘点是否完整 |
| /viktor:think | design.md | 方案对比的深度、验收标准的可测试性 |
| /viktor:plan | tasks.md | 任务粒度（2-5 分钟？），测试要点的完整性 |
| /viktor:cr | review.md | BLOCKING/SUGGESTED/NIT 的判断标准，修复建议的具体程度 |
| /viktor:doc | adr.md | "背景"和"方案对比"的信息密度，"已知问题"的诚实程度 |

> 说明：旧命令 `/brainstorm`、`/analyze`、`/review`、`/document` 已废弃，示例目录统一使用 `/viktor:*` 命名体系理解。
