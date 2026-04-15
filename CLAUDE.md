# dotCodeAgents - 个人 AI Code Agent 配置库

本仓库用于管理个人 AI Code Agent 使用习惯、配置和扩展，包括 skills、MCP servers、hooks、sub-agents 等。

## 目录结构

```
dot-code-agents/                  # 开发项目根目录
├── CLAUDE.md                     # 本文件 - 项目自身的开发指南
├── claude/                       # claude code 配置
│   ├── README.md                 # 当前配置说明与使用方式
│   ├── CLAUDE.md                 # 全局指令
│   ├── settings.json             # 全局 settings（hooks, MCP, 权限等）
│   ├── agents/                   # 自定义 sub-agents (*.md)
│   ├── skills/                   # 自定义 skills (<name>/SKILL.md，第三方由插件管理)
│   ├── commands/                 # 自定义 slash commands (*.md)
│   ├── rules/                    # 全局规则 (*.md)
│   └── hooks/                    # hook 脚本 (*.sh)
├── codex/                        # codex 配置
│   ├── README.md                 # 当前配置说明与同步方式
│   ├── AGENTS.md                 # 全局行为规则
│   ├── config.toml               # 运行参数模板
│   └── memories/                 # 长期偏好模板
```

**使用方式：**

```bash
mv ~/.claude ~/.claude.bak
ln -s "${PWD}/claude" ~/.claude
```

Codex 使用方式：

```bash
mv ~/.codex ~/.codex.bak
ln -s "${PWD}/codex" ~/.codex
```

## 核心规则

### 必须使用 context7 获取最新文档

创建或修改 skills、MCP servers、hooks、sub-agents 配置时，**必须**先通过 context7 CLI 获取最新的官方文档：

```bash
npx ctx7@latest docs /websites/code_claude "<查询内容>"
```

当前配置说明和使用入口见 [claude/README.md](claude/README.md)。
Codex 配置说明和同步入口见 [codex/README.md](codex/README.md)。

## Git 规范

- commit message 必须使用英文
- 遵循 Conventional Commits 格式（如 `feat:`, `fix:`, `chore:` 等）

## 工作流

1. **查询文档**：使用 context7 获取最新官方文档
2. **验证结构**：参照 `claude/` 或 `codex/` 下现有同类文件和对应 README 保持结构一致
3. **编写配置**：按最佳实践编写 skill/agent/hook/MCP 配置
4. **测试验证**：确保配置可被 Claude Code 正确识别和加载
