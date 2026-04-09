---
name: commit
description: >-
  使用 Conventional Commit 格式和 Emoji 创建格式良好的提交。
  自动分析变更、建议拆分、运行 pre-commit 检查。
argument-hint: "[message] | --no-verify | --amend"
disable-model-invocation: false
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(git add *)
  - Bash(git status *)
  - Bash(git commit *)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git branch *)
  - Bash(pre-commit *)
---

# 智能 Git 提交

创建格式良好的提交: $ARGUMENTS

## 当前仓库状态

- Git status: !`git status --porcelain`
- 当前分支: !`git branch --show-current`
- 已暂存变更: !`git diff --cached --stat`
- 未暂存变更: !`git diff --stat`
- 最近提交: !`git log --oneline -5`

## 工作流程

1. **自动运行检查**（除非指定 `--no-verify`）:
   - 如果项目配置了 `pre-commit`，尝试运行
   - 检查常见的代码问题（如格式错误、尾随空格等）
2. **检查暂存文件**: 使用 `git status` 查看哪些文件已暂存
3. **智能添加**: 如果没有文件被暂存，自动 `git add` 添加所有修改和新增的文件；有暂存文件时，只提交被暂存的文件
4. **分析变更**: 执行 `git diff` 理解提交的内容
5. **拆分建议**: 如果检测到多个逻辑上不相关的变更，建议拆分为多个原子提交
6. **生成消息**: 为每个提交生成符合 Conventional Commit 格式且带有 Emoji 的提交信息

## Conventional Commit 类型与 Emoji

| Emoji | Type       | 用途                   |
| ----- | ---------- | ---------------------- |
| ✨    | `feat`     | 新功能                 |
| 🐛    | `fix`      | Bug 修复               |
| 📝    | `docs`     | 文档变更               |
| 💄    | `style`    | 格式/样式              |
| ♻️    | `refactor` | 重构                   |
| ⚡️    | `perf`     | 性能优化               |
| ✅    | `test`     | 测试                   |
| 🔧    | `chore`    | 工具/配置              |
| 🚀    | `ci`       | CI/CD                  |
| 🗑️    | `revert`   | 回滚                   |
| 🚨    | `fix`      | 修复编译器/Linter 警告 |
| 🔒️    | `fix`      | 修复安全问题           |
| 🏗️    | `refactor` | 架构变更               |
| 📦️    | `chore`    | 编译文件/包            |
| ➕    | `chore`    | 添加依赖               |
| ➖    | `chore`    | 移除依赖               |
| 🏷️    | `feat`     | 类型定义               |
| 💥    | `feat`     | 破坏性变更             |
| 🚧    | `wip`      | 进行中                 |
| 🚑️    | `fix`      | 关键热修复             |

## 拆分提交指南

分析 diff 时，根据以下标准考虑拆分：

1. **不同关注点**: 不同模块（如 `frontend` vs `backend`）
2. **不同变更类型**: 混合了功能添加、Bug 修复和重构
3. **文件类型**: 源代码 vs 文档
4. **逻辑分组**: 分开提交以便于理解和审查

## 提交规范

- **时态**: 祈使句（`add feature` 而非 `added feature`）
- **简洁**: 第一行保持在 72 字符以内
- **commit message 使用英文**

## 命令选项

- `--no-verify`: 跳过 pre-commit 检查
- `--amend`: 修改上一次提交。仅对尚未推送的本地提交使用

## 规则

- 只提交到本地，不自动 push
- 如果没有暂存文件，自动暂存所有修改和新增的文件
- 检测到多个逻辑变更时，建议拆分提交
- 始终检查 diff 和 commit message 是否匹配
