---
description: 初始化项目知识地图 扫描代码库生成 project-context.md
---

# /viktor:init

当用户输入此命令时：

## 1. 加载 Skill

读取并严格遵循 `skills/06-project-init/SKILL.md`。

## 2. 使用场景

- 首次在已有项目中接入工作流
- `docs/project-context.md` 不存在
- 项目经过较大重构后需要更新知识地图

## 3. 执行过程

按照 `skills/06-project-init/SKILL.md` 的步骤执行：

1. 扫描项目文件结构（排除 node_modules / .next / dist）
2. 读取 package.json 提取技术选型
3. 分类整理现有组件、Hooks、工具函数、API 路由
4. 识别项目命名和目录约定
5. 生成并保存 `docs/project-context.md`

## 4. 完成后提示

输出导航卡：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ INIT 已完成
📄 产物：docs/project-context.md
──────────────────────────────
▶ 下一步：输入 /viktor:think <需求描述> 开始第一个需求
  后续每次 BRAINSTORM 会自动读取此知识地图
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
