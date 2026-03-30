---
allowed-tools: Bash(git add *), Bash(git status *), Bash(git commit *), Bash(git diff *), Bash(git log *), Bash(git branch *), Bash(pre-commit *)
argument-hint: [message] | --no-verify | --amend
description: 使用 Conventional Commit 格式和 Emoji 创建格式良好的提交
---

# 智能 Git 提交 (Smart Git Commit)

创建格式良好的提交: $ARGUMENTS

## 当前仓库状态 (Current Repository State)

- Git status: !`git status --porcelain`
- 当前分支: !`git branch --show-current`
- 已暂存变更: !`git diff --cached --stat`
- 未暂存变更: !`git diff --stat`
- 最近提交: !`git log --oneline -5`

## 此命令的作用 (What This Command Does)

1. **自动运行检查** (除非指定 `--no-verify`):
   - 如果项目配置了 `pre-commit` 或其他 Lint/Test 脚本，尝试运行它们以确保代码质量。
   - 检查常见的代码问题（如格式错误、尾随空格等）。
2. **检查暂存文件**: 使用 `git status` 查看哪些文件已暂存。
3. **智能添加**: 如果没有文件被暂存，自动运行 `git add` 添加所有修改和新增的文件。有暂存文件时，只提交被暂存的文件。
4. **分析变更**: 执行 `git diff` 理解提交的内容。
5. **拆分建议**: 如果检测到多个逻辑上不相关的变更，建议拆分为多个小的原子提交。
6. **生成消息**: 为每个提交（或单个提交）生成符合 Conventional Commit 格式且带有 Emoji 的提交信息。

## 提交最佳实践 (Best Practices)

- **提交前验证**: 确保代码已格式化，通过了 Lint 检查，并且没有编译/运行错误。
- **原子提交 (Atomic commits)**: 每个提交应包含单一目的的相关变更。
- **拆分大变更**: 如果变更涉及多个关注点（例如同时修改了前端 UI 和后端 API），请拆分为单独的提交。
- **Conventional Commit 格式**: 使用 `<type>: <description>` 格式，其中 type 是：
  - `feat`: 新功能 (A new feature)
  - `fix`: Bug 修复 (A bug fix)
  - `docs`: 文档变更 (Documentation changes)
  - `style`: 代码样式变更 (格式化, 标点等)
  - `refactor`: 代码重构 (既不修复 bug 也不添加功能)
  - `perf`: 性能优化 (Performance improvements)
  - `test`: 添加或修复测试 (Adding or fixing tests)
  - `chore`: 构建过程或工具变更 (Changes to the build process, tools, etc.)
- **时态**: 使用祈使句 (例如 "add feature" 而不是 "added feature")。
- **简洁**: 第一行保持在 72 个字符以内。
- **Emoji**: 每个提交类型搭配适当的表情符号:
  - ✨ `feat`: 新功能 (New feature)
  - 🐛 `fix`: Bug 修复 (Bug fix)
  - 📝 `docs`: 文档 (Documentation)
  - 💄 `style`: 格式/样式 (Formatting/style)
  - ♻️ `refactor`: 重构 (Code refactoring)
  - ⚡️ `perf`: 性能 (Performance improvements)
  - ✅ `test`: 测试 (Tests)
  - 🔧 `chore`: 工具/配置 (Tooling, configuration)
  - 🚀 `ci`: CI/CD 改进
  - 🗑️ `revert`: 回滚变更 (Reverting changes)
  - 🚨 `fix`: 修复编译器/Linter 警告
  - 🔒️ `fix`: 修复安全问题 (Security)
  - 🏗️ `refactor`: 架构变更 (Architectural changes)
  - 📦️ `chore`: 添加或更新编译文件/包
  - ➕ `chore`: 添加依赖 (Add a dependency)
  - ➖ `chore`: 移除依赖 (Remove a dependency)
  - 🏷️ `feat`: 添加或更新类型 (Add or update types)
  - 👽️ `fix`: 由于外部 API 变更而更新代码
  - 🔥 `fix`: 移除代码或文件
  - 🎨 `style`: 改进代码结构/格式
  - 🚑️ `fix`: 关键热修复 (Critical hotfix)
  - 🚧 `wip`: 进行中的工作 (Work in progress)
  - 💚 `fix`: 修复 CI 构建
  - 📌 `chore`: 固定依赖版本
  - 👷 `ci`: 添加 or 更新 CI 构建系统
  - 📄 `chore`: 添加或更新许可证 (License)
  - 💥 `feat`: 引入破坏性变更 (Breaking changes)
  - 🙈 `chore`: 添加或更新 .gitignore 文件

## 拆分提交指南 (Splitting Commits)

分析 diff 时，请根据以下标准考虑拆分提交：

1. **不同的关注点**: 修改了系统的不同模块 (例如 `frontend` vs `backend`，或者 `auth` vs `payment`)。
2. **不同的变更类型**: 混合了功能添加、Bug 修复和重构。
3. **文件类型**: 源代码 vs 文档说明 (Source code vs documentation)。
4. **逻辑分组**: 分开提交以便于理解和审查的变更。

## 示例 (Examples)

良好的提交信息:

- ✨ feat: 添加用户登录功能
- 🐛 fix: 修复页面加载时的空指针异常
- 📝 docs: 更新 API 接口文档
- ♻️ refactor: 重构数据处理逻辑以提高可读性
- 🔧 chore: 更新依赖包版本
- 🔒️ fix: 修复潜在的 XSS 安全漏洞

拆分提交示例:

- 提交 1: 🔧 chore: 升级 React 版本
- 提交 2: ✨ feat: 使用新 Hooks 重写组件
- 提交 3: 📝 docs: 更新组件使用说明

## 命令选项 (Command Options)

- `--no-verify`: 跳过代码质量检查 (pre-commit, lint 等)。
- `--amend`: 修改上一次提交。**警告：仅对尚未推送到远程的本地提交使用，已推送的提交 amend 后需要 force push，可能导致他人工作丢失。**

## 重要提示 (Important Notes)

- 默认情况下，会尝试运行项目配置的质量检查脚本。
- 如果没有暂存文件，此命令会自动暂存所有修改和新增的文件。
- 提交信息将根据检测到的变更自动构建。
- 如果检测到多个逻辑变更，助手会建议并帮助你拆分提交。
- 始终检查生成的 diff 和提交信息是否匹配。
- 只需要把代码提交到本地，千万不要直接 push 到远程仓库
