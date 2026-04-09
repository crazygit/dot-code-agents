# Codex 配置总览

这份目录既是可版本化的 Codex 配置基线，也可以直接软链接到 `~/.codex` 使用。

与 `claude/` 相比，这里的结构更轻，主要保留 Codex 当前原生可承载的入口：

- `AGENTS.md`：全局行为规则、review/debug 默认方式、Issue 驱动工作流
- `config.toml`：模型、推理强度、web 搜索和 sandbox 的共享配置
- `memories/`：跨仓库稳定偏好，例如 PR / Issue / 分支工作流

## 使用原则

- 版本化基线，不版本化个人运行态
- 只同步可维护、可解释、跨机器通用的内容
- 不伪造 Claude 的 plugins / hooks / commands 等价层
- 文档查询继续使用 `ctx7`

## 推荐使用方式

像 `claude/` 一样，直接软链接整个目录：

```bash
mv ~/.codex ~/.codex.bak
ln -s "${PWD}/codex" ~/.codex
```

Codex 运行后会在该目录下生成运行态和敏感文件，例如：

- `auth.json`
- `history.jsonl`
- `logs_*.sqlite`
- `state_*.sqlite`
- `log/`
- `sqlite/`
- `archived_sessions/`

这些文件属于本地运行数据，仓库默认不纳入版本控制。日常维护时只需要关注你明确管理的配置文件。

## 目录职责

### `AGENTS.md`

承接以下高价值规则：

- 库 / 框架 / SDK / API / CLI / 云服务问题必须优先用 `ctx7`
- review 采用 findings-first、风险优先
- debug 采用最小复现、根因优先
- 非 trivial 任务优先走计划，再进入实现
- 非 trivial 协作优先以 GitHub Issue 作为事实来源

### `config.toml`

只放可复用的运行参数模板，例如：

- 默认模型
- reasoning effort
- `web_search`
- `sandbox_workspace_write`

这里不放本机项目路径，因为这类信息只适合保留在个人环境中。

### `memories/`

放长期偏好，不放仓库私密信息，也不放单次任务上下文。适合保存：

- PR 创建偏好
- Issue 驱动偏好
- 分支/提交流程
- 代码审查与验证习惯

## 维护边界

以下内容属于本地运行数据，不作为仓库配置的一部分：

- 登录态与 token
- 本地历史与会话索引
- sqlite 数据库
- shell 快照
- 临时导入缓存
- 私有 memory

如果 Codex 后续新增稳定且值得版本化的新入口，再扩展这个目录；默认保持小而稳。
