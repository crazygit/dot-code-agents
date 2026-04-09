---
name: pick-issue
description: >-
  接手已有 GitHub Issue：读取并解析 Issue 内容、创建隔离 worktree 和分支、
  生成 kickoff 草稿。为后续设计和实现做准备。
argument-hint: "<Issue 编号>（如 #123）"
disable-model-invocation: false
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(git remote -v)
  - Bash(git rev-parse --is-inside-work-tree)
  - Bash(gh auth status *)
  - Bash(gh repo view *)
  - Bash(gh issue view *)
  - Bash(git worktree add *)
  - Bash(git branch *)
---

# 接手 Issue

接手已有 GitHub Issue：`$ARGUMENTS`

## 执行步骤

### 1. 前置检查

1. 运行 `gh auth status`，失败则停止，提示 `gh auth login -h github.com`
2. 运行 `git remote -v` 确认仓库有 GitHub remote
3. 运行 `gh repo view --json nameWithOwner -q .nameWithOwner` 读取仓库标识

任何一步失败则停止，不继续后续步骤。

### 2. 读取 Issue

运行 `gh issue view <N> --comments`，提取以下要素：

- 目标（要达成什么结果）
- 验收标准（可验证条件列表）
- 约束（技术限制、依赖、排除项）
- 未知点（需要澄清的地方）

### 3. 信息充足性判断

- 如果目标、验收标准、约束清晰 → 继续下一步
- 如果信息不足（缺少验收标准、技术约束不明、目标模糊）→ 使用 AskUserQuestion 提示用户需要先走 brainstorming，**不替用户决定跳过**

### 4. 创建 worktree 和分支

1. 使用 `using-git-worktrees` skill 创建隔离工作区
2. 分支命名：`<type>/<N>-<slug>`
   - type 从 Issue label 推断：enhancement→feature, bug→fix, refactor→refactor, 其他→chore
   - N 为 Issue 编号
   - slug 从 Issue 标题生成简短英文标识
3. 如仓库已有强约束的分支命名规则，退回仓库既有格式

### 5. 生成 kickoff 草稿

使用 `references/issue-templates.md` 中的 kickoff 模板生成草稿。

草稿只保留在本地，**不发布**到 GitHub。

### 6. 输出

完成时输出：

- Issue 摘要（目标、验收标准、约束）
- 分支名和 worktree 路径
- kickoff 草稿内容
- 是否建议先走 brainstorming

## 规则

- 不直接实现代码，只做接手准备
- kickoff 草稿默认不发布到 GitHub
- 分支名中保留 Issue 编号，便于和 GitHub linked branch、PR 对应
- 不编造 Issue 中不存在的内容
