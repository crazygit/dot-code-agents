# dotAgents

个人 AI Code Agent 配置管理库，集中管理和版本控制各种 code agent 的使用习惯、扩展配置。

## 当前支持

| Agent       | 配置目录  | 软链接目标  |
| ----------- | --------- | ----------- |
| Claude Code | `claude/` | `~/.claude` |
| ...         |           |             |

## 快速开始

```bash
# 1. 备份现有配置
mv ~/.claude ~/.claude.bak

# 2. 软链接（以 Claude Code 为例）
ln -s "${PWD}/claude" ~/.claude

# 3. 重启 Claude Code 会话，配置自动生效
```

## 目录结构

```
dotAgents/
├── claude/                       # Claude Code 全局配置 → ~/.claude
│   ├── README.md                 #   当前配置说明与使用方式
│   ├── CLAUDE.md                 #   全局指令
│   ├── settings.json             #   hooks, MCP, 权限等
│   ├── agents/                   #   自定义 sub-agents
│   ├── skills/                   #   自定义 skills
│   ├── commands/                 #   自定义 slash commands
│   ├── rules/                    #   全局规则
│   └── hooks/                    #   hook 脚本
├── CLAUDE.md                     # 本项目自身的开发指南
└── README.md                     # 本文件
```
