---
name: issue-dev
description: >-
  以 GitHub Issue 为交付事实来源的编排器。串联 create-issue、pick-issue、
  issue-status、commit、create-pr 等独立 skill，配合 Superpowers 工作流
  完成从需求到 PR 的全流程。
version: 2.0.0
---

# Issue-Driven Development（编排器）

用 GitHub Issue 作为需求入口和进度追踪中心，编排独立 skill 和 Superpowers 工作流完成交付。

## 何时使用

- 用户要从需求出发创建 Issue 并进入执行
- 用户要基于已有 Issue 开始开发
- 用户要查看仓库 Issue/PR 状态

## 何时不要使用

- 只是讨论想法，还没准备落到 Issue
- 不是 git 仓库或没有 GitHub remote
- 纯文档/答疑/临时实验，不需要可追踪交付

## 快速示例

- `/issue-dev <需求描述>` → 模式 A
- `/issue-dev #123` → 模式 B
- `/issue-dev status` → 模式 C

## 运行模式

### 模式 A：需求到 Issue

1. 调用 `brainstorming` skill，把需求变成清晰设计和验收标准
2. 设计批准后，调用 `create-issue` skill 创建 Issue
3. Issue 创建完成后，提示用户转入模式 B

### 模式 B：执行已有 Issue

1. 调用 `pick-issue` skill 接手 Issue、创建 worktree 和分支
2. 如果 pick-issue 返回"信息不足"，先调用 `brainstorming` skill 补充设计
3. 调用 `writing-plans` skill 写出可执行计划
4. 调用 `executing-plans` 或 `subagent-driven-development` 执行计划
5. 实现完成后，调用 `commit` skill 提交代码
6. 调用 `create-pr` skill 创建 PR
7. 调用 `finishing-a-development-branch` skill 收尾

多 Issue 并行时，先用 `pick-issue` 逐个接手，再用 `dispatching-parallel-agents` 分发。

### 模式 C：状态汇总

1. 调用 `issue-status` skill 拉取并展示状态
2. 如用户要求，生成评论草稿供审核

## 核心治理规则

- Issue 是任务入口，没有明确 Issue 不直接实现
- PR 必须关联 Issue（Fixes #N 或 Closes #N）
- 所有 GitHub 写操作（create、comment、edit、close）必须人工审核
- git push 不自动执行，必须人工确认
- 创建 Issue 和 PR 使用 `--web`，由人工最终提交
- commit message 使用英文，遵循 Conventional Commits

## 前置检查

1. `gh auth status` — 失败则停止，提示 `gh auth login -h github.com`
2. 确认 git 仓库且有 GitHub remote
3. `gh repo view --json nameWithOwner -q .nameWithOwner` — 确认仓库标识

## 错误处理

- `gh` 未安装或未认证 → 停止，提示修复
- Issue 不存在或无权限 → 停止，让用户确认
- Issue 描述不清 → 通过 pick-issue 或 brainstorming 澄清，不猜测
- 准备直接调用 GitHub 写命令 → 停止，改为生成草稿供人工审核
- 准备自动 git push → 停止，等待人工确认
