# dotAgents

个人 AI Code Agent 配置管理库，集中管理和版本控制各种 code agent 的使用习惯、扩展配置。

## 当前支持

| Agent       | 配置目录      | 软链接目标      | 同步方式           |
| ----------- | ------------- | --------------- | ------------------ |
| Claude Code | `claude/`     | `~/.claude`     | 软链接             |
| Codex       | `codex/`      | `~/.codex`      | 软链接             |
| Codex Agents| `agents/`     | `~/.agents/*`   | `agents/setup.sh`  |

## 快速开始

### 一键安装（推荐）

一条命令完成下载和所有配置：

```bash
curl -fsSL https://raw.githubusercontent.com/crazygit/dot-code-agents/main/install.sh | bash
```

或使用 wget：

```bash
wget -qO- https://raw.githubusercontent.com/crazygit/dot-code-agents/main/install.sh | bash
```

安装脚本会自动：
- 克隆仓库到 `~/dot-code-agents`
- 备份现有配置
- 创建软链接配置 Claude Code 和 Codex
- 同步 Codex Agents 配置

### 手动配置

#### Claude Code

```bash
# 1. 备份现有配置
mv ~/.claude ~/.claude.bak

# 2. 软链接
ln -s "${PWD}/claude" ~/.claude

# 3. 重启 Claude Code 会话，配置自动生效
```

#### Codex

```bash
# 1. 备份现有配置
mv ~/.codex ~/.codex.bak

# 2. 软链接
ln -s "${PWD}/codex" ~/.codex

# 3. 同步 agents 配置
cd agents/
./setup.sh

# 4. 克隆本地插件（如 issue-flow）
git clone https://github.com/obra/issue-flow.git ~/.codex/local-plugins/issue-flow

# 5. 在 Codex 中打开插件目录，从 "Local Plugins" 源安装插件
```

## 更新配置

```bash
cd ~/dot-code-agents
git pull
cd agents && ./setup.sh sync
```

## 卸载

```bash
# 删除软链接
rm ~/.claude ~/.codex

# 删除仓库
rm -rf ~/dot-code-agents

# 备份文件会保留在 *.bak.* 目录中
```

仓库已排除 Codex 运行过程中生成的本地文件，例如 `auth.json`、history、sqlite、
日志、快照和缓存；日常维护时只需要关注明确管理的配置文件。

## 目录结构

```
dot-code-agents/
├── claude/                       # Claude Code 全局配置 → ~/.claude
│   ├── README.md                 #   当前配置说明与使用方式
│   ├── CLAUDE.md                 #   全局指令
│   ├── settings.json             #   hooks, MCP, 权限等
│   ├── agents/                   #   自定义 sub-agents
│   ├── skills/                   #   自定义 skills
│   ├── commands/                 #   自定义 slash commands
│   ├── rules/                    #   全局规则
│   └── hooks/                    #   hook 脚本
├── codex/                        # Codex 全局配置 → ~/.codex
│   ├── README.md                 #   当前配置说明与同步方式
│   ├── AGENTS.md                 #   全局行为规则
│   ├── config.toml               #   共享运行参数
│   ├── memories/                 #   长期偏好模板
│   └── local-plugins/            # 本地插件说明
├── agents/                       # Codex agents 配置同步
│   ├── README.md                 #   配置同步说明
│   ├── setup.sh                  #   一键同步脚本
│   └── plugins/
│       └── marketplace.json      # 插件源配置
├── CLAUDE.md                     # 本项目自身的开发指南
└── README.md                     # 本文件
```
