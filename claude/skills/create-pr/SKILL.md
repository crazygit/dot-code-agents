---
name: create-pr
description: >-
  创建 PR。从当前 feature 分支出发，经过测试/lint、code review、
  Issue 合规检查后，用 gh pr create --web 创建 PR 供人工审核提交。
argument-hint: "[Issue 编号]（可选，默认自动推断）"
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
  - Bash(git show *)
  - Bash(git remote -v)
  - Bash(git rev-parse *)
  - Bash(gh auth status *)
  - Bash(gh pr create --web *)
  - Bash(gh pr list --head *)
  - Bash(gh issue view --comments *)
  - Bash(npm run test *)
  - Bash(npm run lint *)
  - Bash(go test *)
  - Bash(go vet *)
  - Bash(pytest *)
  - Bash(ruff check *)
  - Bash(cargo test *)
  - Bash(cargo clippy *)
---

创建 PR。从当前 feature 分支出发，经过测试/lint、code review、Issue 合规检查后，用 `gh pr create --web` 创建 PR 供人工审核提交。

## 执行步骤

### 1. 前置检查

1. 运行 `gh auth status`，失败则停止，提示运行 `gh auth login -h github.com`
2. 运行 `git remote -v` 确认仓库
3. 确认当前分支不是 main/master，否则停止

### 2. 关联 Issue

按以下优先级尝试提取 Issue 编号：

1. 分支名中的数字（如 `feature/123-xxx` → `#123`）
2. `git log` 中 `Fixes/Closes/Resolves #N` 引用
3. 当前分支已有的 PR（`gh pr list --head <branch>`）
4. `$ARGUMENTS` 中的 Issue 编号

提取到编号后，运行 `gh issue view <N> --comments` 读取 Issue 内容。如果所有来源都无法提取，提示用户手动提供 Issue 编号。如果用户明确表示没有关联 Issue，跳过后续的 Issue 合规检查（步骤 6）。

### 3. 运行测试 & Lint

根据项目文件自动检测类型并运行对应命令：

| 文件                           | 测试命令        | Lint 命令      |
| ------------------------------ | --------------- | -------------- |
| `package.json`                 | `npm run test`  | `npm run lint` |
| `go.mod`                       | `go test ./...` | `go vet ./...` |
| `pyproject.toml` / `setup.cfg` | `pytest`        | `ruff check`   |
| `Cargo.toml`                   | `cargo test`    | `cargo clippy` |

并行运行测试和 lint。如果失败：

1. 自动尝试修复（lint 修复命令加 `--fix`，测试失败尝试修复代码）
2. 修复后自动 `git add` + `git commit`（commit message 使用英文 Conventional Commits）
3. 重新运行测试和 lint
4. 仍然失败 → **Checkpoint A**：展示失败摘要，让用户决定继续还是退出

### 4. Code Review

调用 `code-review` agent（使用 Agent 工具，subagent_type: "code-review"），让它审查当前分支相对于 main 的所有变更。

### 5. 根据 Review 修复

1. 收集 code-review agent 的所有 findings
2. 展示摘要：几条 Critical / Warning / Suggestion
3. 如果有 findings → **Checkpoint B**：使用 AskUserQuestion 展示摘要，让用户确认是否全部自动修复
4. 用户确认后，全部自动修复
5. 修复后自动 `git add` + `git commit`（commit message 使用英文 Conventional Commits）
6. 如果修复范围较大（涉及 3 个以上文件），重新跑一次 code review 确认修复到位

### 6. Issue 验收标准对比

仅当步骤 2 成功关联到 Issue 时执行：

1. 从 Issue 正文中提取验收标准（`- [ ]` 开头的条目）
2. 运行 `git diff main...HEAD` 获取当前分支所有变更
3. 逐条对比验收标准与变更内容，标记：
   - ✅ 已覆盖
   - ❌ 未覆盖
   - ⚠️ 部分覆盖
4. 输出覆盖报告 → **Checkpoint C**：如果有未覆盖项，使用 AskUserQuestion 让用户决定继续创建 PR 还是回去补代码

### 7. 创建 PR

1. 根据 `references/templates.md` 中的 PR 模板起草内容，写入临时文件
2. 运行以下命令：
   ```bash
   TMPFILE=$(mktemp /tmp/pr-draft.XXXXXX.md)
   trap 'rm -f "$TMPFILE"' EXIT
   # 将 PR body 写入 $TMPFILE
   gh pr create --web --title "..." --body-file "$TMPFILE"
   ```
3. 使用 `--web` 让用户在浏览器中审核后手动提交
4. 临时文件在 shell 退出时自动清理

## 规则

- PR 标题和正文使用中文
- PR 必须关联 Issue（`Closes #N`），除非用户明确跳过
- 不自动 `git push`，不自动提交 PR
- 所有 GitHub 写操作使用 `--web` 由人工审核
- commit message 使用英文，遵循 Conventional Commits
- 未找到关联 Issue 时提示用户，不编造关联关系
- 不要编造变更内容 — 严格从 `git diff` 和 Issue 中提取
