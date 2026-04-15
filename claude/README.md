# Claude 配置总览

这份 README 说明当前 `claude/` 目录下已经启用或提供的主要配置，并按日常使用场景给出推荐用法。

适用对象：

- 这套配置的日常使用者
- 在新机器初始化 Claude Code 的维护者
- 需要判断某个能力应该放在 agent、command、skill、plugin 还是 MCP 的配置维护者

## 目录概览

- `settings.json`：全局配置入口，包含权限、hooks、状态栏、插件开关、沙箱策略
- `CLAUDE.md`：全局规则，目前约束 git commit message 必须使用英文
- `agents/`：本地子 agent
- `commands/`：已弃用，自定义命令已迁移到 skills 体系
- `skills/`：本地 skills
- `hooks/`：hook 脚本
- `rules/`：共享规则
- `statusline.sh`：Claude Code 状态栏脚本

## 当前配置

### Agents

- `code-reviewer`
  适合在本地功能完成后，对当前改动做风险导向的代码审查。
  重点关注正确性、安全性、回归风险和可维护性。

### Skills

- `find-docs`
  用 `ctx7` 获取库、框架、SDK、CLI、云服务的最新文档。
  适合 API 用法、版本迁移、配置项、CLI 参数等问题。

- `config-curator`
  用于维护当前仓库的 Claude Code 配置基线。
  重点关注配置收敛、官方优先、安全默认、模板化管理。

- `issue-flow`
  Issue 驱动开发的编排器。通过 `.issue-flow/` 状态机管理全流程，支持 manual/auto 两种模式。
  串联 brainstorm、create、pick、plan、implement、verify、commit、pr、finish 九个子 skill。
  适合所有功能开发和 bug 修复场景。详见 [按场景使用](#3-issue-驱动的开发)。

- `issue-brainstorm`
  将用户想法或需求通过调研和结构化讨论，整理成可用于创建 Issue 的 design spec。

- `issue-create`
  从上下文提取需求，按类型选择模板，创建 GitHub Issue。manual 模式用 `--web` 审核，auto 模式直接创建。

- `issue-pick`
  接手已有 GitHub Issue：读取解析内容、创建 worktree 和分支、初始化 `.issue-flow/` 上下文。

- `issue-plan`
  基于 Issue 生成实现计划，保存到 `.issue-flow/plan-path`。

- `issue-implement`
  读取 `.issue-flow/plan-path`，调用 subagent-driven-development 执行实现计划。

- `issue-verify`
  运行 test + lint，调用 code review，比对 Issue 验收标准，输出验证报告。失败时自动修复并重试。

- `issue-commit`
  智能 Git 提交。Conventional Commit + Emoji 格式，自动分析变更、建议拆分、关联 Issue。

- `issue-pr`
  创建 Pull Request。manual 模式用 `--web` 审核，auto 模式直接创建。

- `issue-finish`
  清理 worktree/分支，删除 `.issue-flow/` 状态目录。

- `db9`
  外部数据库相关 skill，属于特定场景能力，不作为通用开发基线。

### Plugins

当前 `settings.json` 中启用的 plugins：

- `gopls-lsp@claude-plugins-official` — Go 语言服务支持
- `superpowers@claude-plugins-official` — 核心工作流编排（brainstorming, TDD, debugging, plans 等）

已禁用的 plugins：

- `commit-commands@claude-plugins-official` — `/commit` 与 `issue-commit` 功能重叠，`/commit-push-pr` 跳过验证阶段与工作流原则冲突
- `code-review@claude-plugins-official` — 与本地 `code-review` agent 职责重叠
- `code-simplifier@claude-plugins-official` — 与 pr-review-toolkit 中的同名 agent 重叠，使用频率低
- `ralph-loop@claude-plugins-official` — 与内置 `/loop` skill 功能重叠
- `pr-review-toolkit@claude-plugins-official` — 包含 6 个子 agent，重量过大，按需手动调用更可控

使用原则：

- plugin 用于补充不可替代的结构化工作流能力
- 本地 review 优先使用 `code-review` agent
- 如果某项能力已经能由 command、agent 或 skill 清晰覆盖，不叠加更多 plugin

### Hooks

- `notify-macos.sh`
  在权限确认和 idle 提醒时触发 macOS 通知

- `guard-dangerous-bash.sh`
  拦截高风险 Bash 模式，例如 `rm -rf`、`git push --force`、`terraform destroy`、`terraform apply -auto-approve`、`curl | sh`

- `record-change-context.sh`
  记录本轮会话涉及的改动类型，目前包括 Go、Python、Terraform、Docs

- `cleanup-change-context.sh`
  在响应结束后清理会话缓存，避免跨轮污染

### Rules

- `rules/context7.md`
  约束在库、框架、SDK、CLI、云服务问题上优先用 `ctx7` 查最新文档，而不是凭记忆回答。

## 按场景使用

### 1. 功能开发完成后做一次本地 Review

推荐顺序：

1. 用 `code-review` 审查当前改动
2. 修掉阻塞问题
3. 跑对应语言的测试命令（`go test`, `pytest`, `terraform validate` 等已在权限白名单中）
4. 最后用 `/issue-commit` 做本地提交

适用入口：

- 想要一个专门审查角色时：`code-review`
- 想看 PR 相关增强能力时：相关 review plugin 作为补充，不替代本地 review 基线

### 2. 查官方文档或最新 API

优先使用 `find-docs`。

适合的问题：

- 某个框架的最新 API 怎么写
- 某个 CLI 现在支持哪些参数
- 某个 SDK 某版本的配置项或迁移方式

这里不建议让 agent 凭经验直接回答，`rules/context7.md` 已经要求这类问题优先走 `ctx7`。

### 4. 维护这套 Claude 配置

优先使用 `config-curator`。

适用情况：

- 想调整 `settings.json`
- 想增删 plugin、skill、MCP 模板
- 想审视当前配置是否过重、过散或不够安全

原则：

- 官方优先
- 小而可组合
- 模板优先于硬编码成品
- 安全默认，不提交凭据

### 3. Issue 驱动的开发

`issue-flow` 是编排器，通过 `.issue-flow/` 状态机串联以下子 skill：

- `/issue-flow <需求描述>` — 模式 A：brainstorm → create → pick → plan → implement → verify → commit → pr → finish
- `/issue-flow #N` — 模式 B：pick → plan → implement → verify → commit → pr → finish
- `/issue-flow --auto <需求描述>` — auto 模式，连续自动推进全流程
- `/issue-flow` — 模式 C：恢复已有会话，从 `.issue-flow/state` 继续

各 skill 也可单独使用：

- `/issue-brainstorm` — 需求头脑风暴
- `/issue-create` — 创建 Issue
- `/issue-pick #N` — 接手 Issue 并创建工作区
- `/issue-plan` — 生成实现计划
- `/issue-implement` — 执行计划
- `/issue-verify` — 验收验证
- `/issue-commit` — 提交代码
- `/issue-pr` — 创建 PR
- `/issue-finish` — 清理收尾

核心原则：

- 没有 Issue 不开工
- PR 必须关联 Issue（`Closes #N`）
- manual 模式下所有 GitHub 写操作和 git push 必须人工确认
- 状态由 `issue-flow` 编排器统一维护，子 skill 不写 state

前置条件：

- `gh` CLI 已认证（`gh auth status`）
- 在有 remote 的 git 仓库内

## 权限与安全边界

当前整体策略：

- 高频、本地、低风险开发动作尽量放行
- 外部副作用或不可逆动作保留确认
- 敏感信息读取默认拒绝
- 默认开启 sandbox，但把强依赖宿主机凭据、Keychain、SSH agent、Docker daemon 或云端本地登录态的命令排除出 sandbox

重点行为：

- 允许：本地读写、搜索、Git 本地操作、Go/Python/Terraform 的常规验证
- 询问：`git push`、`terraform apply`、删除类命令、安装类命令、远程连接
- 拒绝：读取 `.env`、密钥、云凭据、SSH 配置，以及明显的 secrets 读取模式

当前 sandbox 排除命令：

- `git`
- `gh`
- `docker`
- `ssh`
- `scp`
- `kubectl`
- `helm`
- `gcloud`
- `terraform`

这样处理的原因：

- 这些工具经常依赖宿主机上的认证材料或系统能力，例如 Keychain、`~/.ssh`、云厂商本地登录态、Docker socket
- 强行放进 sandbox 容易出现“命令能运行，但认证、证书或网络行为异常”的伪环境问题
- 真正的风险控制继续由 permissions 的 `ask`/`deny` 规则和 hooks 承担，而不是把所有外部工具都硬塞进 sandbox

macOS 额外兼容项：

- `sandbox.enableWeakerNetworkIsolation: true`
- 原因是 Claude Code 官方文档明确说明，macOS 下 Go 工具如 `gh`、`gcloud`、`terraform` 在 sandbox 中经由代理做 TLS 校验时，可能需要访问系统 TLS trust service（`com.apple.trustd.agent`）
- 这会略微放宽网络隔离，但能减少 `x509`/证书链校验异常，尤其是类似 `gh repo view` 这类 GitHub API 调用

已知取舍：

- 优先仍然是把 `gh` 等工具排除出 sandbox
- 但在实际使用里，某些调用路径可能仍以 `Bash(...)` 形式落入 sandbox；开启这个兼容项可以作为兜底，避免出现 `tls: failed to verify certificate` 这类伪环境问题

## 初始化建议

1. 把 `claude/` 软链到 `~/.claude`
2. 重启 Claude Code
3. 检查 agents、commands、skills、hooks 是否已加载
4. 确认本机已安装 `jq`
5. 如果要用 macOS 通知，确认系统支持 `osascript`

## 推荐的最小日常工作流

### 本地开发

1. 写代码
2. `code-review` 审查
3. 对应语言测试命令（`go test`、`pytest`、`terraform validate` 等）
4. `/issue-commit`
5. 需要推远端时再人工确认 `git push`

### 配置维护

1. 先看 `config-curator`
2. 再检查 `settings.json`、相关脚本和模板
3. 变更后同步更新文档

## 相关文件

- `settings.json`
- `CLAUDE.md`
- `agents/`
- `commands/`
- `skills/`
- `hooks/`
- `mcp-templates/`
- `rules/context7.md`
