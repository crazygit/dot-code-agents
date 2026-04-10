---
name: auto-dev
description: >-
  全自动 Issue 驱动开发编排器。除前期需求评审（brainstorming）需人工确认外，
  plan → implement → test → commit → push → create PR 全部 AI 自主完成，
  无需人工确认和授权。
argument-hint: "<需求描述> | <#Issue编号> | plan <plan-file>"
disable-model-invocation: false
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(git add *)
  - Bash(git branch *)
  - Bash(git checkout *)
  - Bash(git commit *)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git merge *)
  - Bash(git push *)
  - Bash(git remote *)
  - Bash(git reset *)
  - Bash(git rev-parse *)
  - Bash(git show *)
  - Bash(git status *)
  - Bash(git switch *)
  - Bash(git worktree *)
  - Bash(gh auth status *)
  - Bash(gh issue create *)
  - Bash(gh issue edit *)
  - Bash(gh issue comment *)
  - Bash(gh issue close *)
  - Bash(gh issue view *)
  - Bash(gh pr create *)
  - Bash(gh pr list *)
  - Bash(gh pr view *)
  - Bash(gh repo view *)
  - Bash(npm test *)
  - Bash(npm run *)
  - Bash(npx *)
  - Bash(pytest *)
  - Bash(python *)
  - Bash(python -m *)
  - Bash(uv run *)
  - Bash(uv pip install *)
  - Bash(ruff check *)
  - Bash(ruff format *)
  - Bash(go test *)
  - Bash(go build *)
  - Bash(go vet *)
  - Bash(cargo test *)
  - Bash(cargo clippy *)
  - Bash(mktemp *)
  - Bash(jq *)
  - Bash(find *)
  - Bash(ls *)
  - Agent
  - TaskCreate
  - TaskGet
  - TaskList
  - TaskUpdate
  - Skill(superpowers:brainstorming)
  - Skill(superpowers:writing-plans)
  - Skill(superpowers:subagent-driven-development)
---

# Auto-Dev: 全自动 Issue 驱动开发

全自动执行从需求到 PR 的完整开发流程：`$ARGUMENTS`

**唯一人工门控：模式 A 的 brainstorming 设计评审。其余全部自动。**

## 何时使用

- `/auto-dev <需求描述>` → 模式 A（需求评审 + 全自动执行）
- `/auto-dev #123` → 模式 B（Issue 直接全自动执行）
- `/auto-dev plan <file>` → 模式 C（Plan 直接全自动执行）

## 何时不要使用

- 不是 git 仓库或没有 GitHub remote
- 需要 CI/CD pipeline 变更（需额外审批）
- 不确定需求，想先讨论再决定

## 运行模式

### 模式 A：需求评审 → Issue → 全自动执行

```
需求描述
  → 1. brainstorming（人工评审设计）    ← 唯一人工门控
  → 2. create-issue（自动 gh issue create）
  → 3. pick-issue（自动 worktree + 分支）
  → 4. writing-plans（自动生成计划）
  → 5. subagent-driven-development（自动执行）
  → 6. commit + push（自动提交 + 推送）
  → 7. create-pr（自动创建 PR）
  → 8. 关联 Issue + 通知
```

### 模式 B：Issue → 全自动执行

```
Issue #N
  → 1. pick-issue（自动读取 + worktree + 分支）
  → 2. writing-plans（自动生成计划）
  → 3. subagent-driven-development（自动执行）
  → 4. commit + push + create-pr
  → 5. 关联 Issue + 通知
```

### 模式 C：Plan → 全自动执行

```
Plan file
  → 1. subagent-driven-development（自动执行）
  → 2. commit + push + create-pr
  → 3. 通知
```

## 前置检查（所有模式共用）

1. 运行 `gh auth status`，失败则停止并提示 `gh auth login -h github.com`
2. 运行 `git remote -v` 确认仓库有 GitHub remote
3. 运行 `gh repo view --json nameWithOwner -q .nameWithOwner` 读取仓库标识
4. 任一步骤失败则停止，不继续后续步骤

---

## 模式 A 详细流程

### 阶段 1：设计评审（人工门控）

1. 调用 `brainstorming` skill，传入需求描述进行设计评审
2. **等待人工批准设计** — 这是唯一的阻断点
3. 设计批准后继续

### 阶段 2：自动创建 Issue

1. 从 brainstorming 输出的 design spec 中提取需求信息
2. 根据类型选择 label（enhancement/bug/refactor/documentation/chore/performance）
3. 标题使用中文，简洁描述交付结果，不加 `feat:`/`fix:` 前缀
4. 按 `create-issue` skill 的 `references/templates.md` 中对应类型模板填充内容：
   - Feature/其他类型 → 使用「Feature / 其他类型」模板（概述、背景、验收标准、范围、测试计划）
   - Bug 类型 → 使用「Bug 类型」模板（问题描述、复现步骤、期望/实际行为、环境信息、验收标准）
5. **直接执行** `gh issue create --title "..." --label "..." --body "..."`（不使用 `--web`）
6. 记录返回的 Issue 编号和 URL

### 阶段 3：接手 Issue

1. 读取 Issue：`gh issue view <N> --comments`
2. 提取目标、验收标准、约束
3. 自动创建 worktree 和分支：
   - 分支命名：`<type>/<N>-<slug>`
   - type 映射：enhancement→feature, bug→fix, refactor→refactor, 其他→chore
4. 切换到 worktree 目录

### 阶段 4：生成实现计划

1. 调用 `writing-plans` skill，基于 design spec 生成实现计划
2. 计划保存到 `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
3. **不询问执行方式**，直接选择 subagent-driven-development

### 阶段 5：执行实现计划

1. 调用 `subagent-driven-development` skill 执行计划
2. 每个任务由独立 subagent 实现 + 双阶段 review（spec compliance → code quality）
3. 发现问题时自动修复并重试（最多 3 次，见下方重试策略）

### 阶段 6：测试 → 提交 → 推送 → PR

1. **运行 test + lint**（按质量检查章节的自动检测表选择命令），失败时按重试策略处理
2. **自动提交**所有未提交的变更：
   - 分析变更内容，按逻辑拆分
   - 使用英文 Conventional Commits + Emoji
   - 不询问确认，直接 `git add` + `git commit`
3. **自动推送** `git push -u origin <branch>`（不询问确认）
4. **自动创建 PR**：
   - 模板复用 `create-pr` skill 的 `references/templates.md`（概述、关联 Issue、变更内容、验收标准覆盖、测试、注意事项）
   - 标题使用中文
   - Body 包含 `Closes #N`（自动关联 Issue，merge 时自动关闭）
   - **直接执行** `gh pr create --title "..." --body "..."`（不使用 `--web`）
5. 记录 PR URL

### 阶段 7：通知

输出完成报告（见下方通知格式）。

---

## 模式 B 详细流程

跳过阶段 1-2，直接从阶段 3（接手 Issue）开始。

如果 Issue 信息不足（缺少验收标准、目标模糊）：
- **不询问用户**，基于 Issue 描述和代码仓库自行补充设计
- 在 worktree 中创建 design spec，然后进入阶段 4

其余流程与模式 A 的阶段 4-7 完全一致。

---

## 模式 C 详细流程

跳过阶段 1-4，直接从阶段 5（执行计划）开始。

读取指定的 plan 文件，确认格式正确（包含任务列表和 checkbox），然后进入阶段 5-7。

---

## 自动重试策略

以下操作失败时自动修复并重试，**最多 3 次**：

### 测试失败

1. 分析测试失败输出，定位根因
2. Dispatch fix subagent 修复代码
3. 重新运行测试
4. 重复最多 3 次

### Lint 失败

1. 尝试自动修复：`<lint-cmd> --fix`（如 `ruff check --fix`、`npm run lint -- --fix`）
2. 重新运行 lint 检查
3. 重复最多 3 次

### Code Review 发现问题

1. 收集所有 findings
2. 按 Critical > Warning > Suggestion 排序
3. 逐条修复，每次修复后重新 commit
4. 修复范围较大（3+ 文件）时重新跑 code review
5. 重复最多 3 次

### 3 次重试后仍失败

**立即停止执行**，输出失败报告：

```
### ❌ 执行失败

- **阶段**: <失败阶段>
- **Issue**: #N - <标题>
- **Branch**: <branch-name>
- **失败原因**: <详细描述>
- **已尝试**: <尝试过的修复措施>
- **下一步**: <建议的人工介入方式>

Worktree 和分支已保留，可手动检查后继续。
```

---

## 质量检查

### 自动检测项目类型并运行对应命令

| 文件 | 测试 | Lint |
|------|------|------|
| `package.json` | `npm test` | `npm run lint` |
| `go.mod` | `go test ./...` | `go vet ./...` |
| `pyproject.toml` / `setup.cfg` | `pytest` | `ruff check` |
| `Cargo.toml` | `cargo test` | `cargo clippy` |

### Code Review

自动调用 `code-review` agent 审查当前分支相对 base branch 的所有变更。
不询问用户确认，review 发现的问题直接按重试策略自动修复。

### Issue 验收标准对比

1. 从 Issue 正文提取验收标准
2. 运行 `git diff <base>...HEAD` 获取变更
3. 逐条对比，标记 ✅/❌/⚠️
4. 有 ❌ 项时自动补全代码，不停止也不询问

---

## 完成通知

流程结束后输出结构化报告：

```
### ✅ 执行完成

- **Issue**: #N - <标题>
- **Branch**: <branch-name>
- **Commits**: <N> commits
- **PR**: <PR URL>
- **Test**: ✅ All passed
- **Review**: ✅ Approved (Critical: 0, Warning: 0, Suggestion: 0)
- **验收标准**: ✅ 全部覆盖 (X/Y)
```

---

## 核心规则

1. **Issue 是任务入口** — 没有明确 Issue 不直接实现（模式 C 除外）
2. **PR 必须关联 Issue** — Body 包含 `Closes #N` 或 `Fixes #N`
3. **commit message 使用英文** — 遵循 Conventional Commits + Emoji
4. **不使用 --web** — 所有 GitHub 操作直接执行
5. **不使用 AskUserQuestion** — 全部自动决策
6. **不自动 merge PR** — PR 创建后等待人工 code review（GitHub 侧）
7. **不自动删除分支** — worktree 在 PR 流程结束后清理，分支保留直到 merge
8. **失败保留现场** — 出错时保留 worktree 和分支供人工排查
