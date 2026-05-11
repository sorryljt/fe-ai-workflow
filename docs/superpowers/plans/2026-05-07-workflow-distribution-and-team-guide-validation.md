# fe-ai-workflow 分发与团队试点本地验证记录

**日期**：2026-05-07
**目的**：验证 workflow 仓库可作为 git 分发包，并能通过同步脚本在项目根目录物化入口文件

## 验证范围

- `scripts/sync-workflow.sh`
- `README.md` 的安装说明
- `docs/team-workflow-guide.md`

## 验证结果

### 1. 同步脚本可用

`scripts/sync-workflow.sh` 已通过本地最小测试验证：

- 首次同步成功
- 重复执行成功
- 缺少源目录时会失败并输出错误

### 2. 安装说明可执行

README 已补充 git submodule + 同步脚本的安装说明，业务项目可以按以下步骤使用：

1. 拉取 workflow 仓库作为 submodule
2. 运行同步脚本将入口文件复制到项目根目录
3. 让 Claude Code / Codex / Cursor 直接读取根目录文件

### 3. 团队试点文档已落地

已新增 `docs/team-workflow-guide.md`，内容覆盖：

- 背景
- 安装方式
- 平台差异说明
- 命令总览
- 各节点说明
- 试点建议与反馈入口

## 残余风险

- 目前仅验证了 workflow 仓库自身的同步能力，还未在额外业务仓库中做第二次独立试点
- submodule 方式需要团队成员理解“拉取后再同步一次”的步骤，后续可能需要进一步简化
- Codex CLI 的输入前缀规则已经明确，但团队成员初次使用时仍可能误输入 `/viktor:*`，需要在试点阶段提醒

## 结论

workflow 目前已经具备“可作为 git 工程分发给团队小范围试点”的最小条件。
