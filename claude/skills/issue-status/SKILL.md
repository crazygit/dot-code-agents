---
name: issue-status
description: >-
  汇总当前仓库的 Issue 和 PR 状态，按统一状态模型分类输出，
  并按需生成 progress、blocker、review-ready 等评论草稿。
argument-hint: "[Issue 编号]（可选，默认汇总全部）"
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
  - Bash(gh issue list *)
  - Bash(gh issue view *)
  - Bash(gh pr list *)
  - Bash(gh pr view *)
  - Bash(gh issue develop *)
---

# Issue 状态汇总

汇总当前仓库 Issue 和 PR 状态。`$ARGUMENTS` 为可选 Issue 编号，不指定则汇总全部。

## 执行步骤

### 1. 前置检查

1. 运行 `gh auth status`，失败则停止，提示 `gh auth login -h github.com`
2. 运行 `git remote -v` 确认仓库

### 2. 拉取数据

- `gh issue list --state open`
- `gh pr list --state open`
- 如指定了 Issue 编号：`gh issue view <N> --comments`

### 3. 状态分类

按以下统一状态模型归类每个 Issue：

| 状态 | 判断依据 |
|------|---------|
| `draft` | 有 draft 标签或 issue type 为 Draft |
| `planned` | 有计划/设计，但无 linked branch |
| `in_progress` | 有 linked branch 或 in-progress 标签 |
| `blocked` | 有 blocker 标签或评论中提到阻塞 |
| `in_review` | 有 linked open PR |
| `verifying` | PR 已 review 通过，验证中 |
| `done` | 已关闭 |

### 4. 输出状态表

按状态分组，每个 Issue 一行：

- 编号、标题、状态、关联 PR
- 简洁可读，不输出原始命令结果

### 5. 生成评论草稿（按需）

使用 `references/comment-templates.md` 中的模板。

- 默认不生成，只有用户要求或出现 blocker 时才生成
- 草稿不直接发布，需人工审核
- 可用模板：kickoff、plan、progress、blocker、review-ready、handoff、completion

## 规则

- 不修改任何 GitHub 状态（不创建、不编辑、不关闭 Issue/PR）
- 评论草稿默认不发布
- 状态判断基于 GitHub 原生数据（label、linked branch、PR 状态）
- 不编造 Issue 或 PR 中不存在的信息
