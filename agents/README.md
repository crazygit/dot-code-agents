# Codex Agents 配置

本目录管理 Codex (`~/.agents`) 中值得版本化的配置文件。

## 目录结构

```
agents/
├── README.md                    # 本文件
├── setup.sh                     # 配置同步脚本
└── plugins/
    └── marketplace.json         # 插件源配置
```

## 使用方式

### 首次配置

```bash
# 1. 进入本目录
cd agents/

# 2. 运行同步脚本
./setup.sh

# 3. 在 Codex 中安装插件
#    - 打开插件目录（Ctrl/Cmd + Shift + P → Plugins）
#    - 从 "Local Plugins" 源安装 issue-flow
```

### 检查配置状态

```bash
./setup.sh check
```

### 同步配置更新

```bash
./setup.sh sync
```

## 为什么只版本化部分配置

`~/.agents` 目录包含大量运行时数据，不应该版本化：

**值得版本化：**
- `plugins/marketplace.json` - 插件源配置

**不应该版本化：**
- `plugins/cache/` - 插件缓存
- `skills/` - 实际安装的技能（从 marketplace 安装）
- `sessions/` - 会话数据
- `sqlite/` - 数据库
- `log/` - 日志
- `cache/` - 缓存
- `archived_sessions/` - 归档会话

## 工作原理

1. **插件源码**：存储在 `~/.codex/local-plugins/`（软链接到仓库的 `codex/local-plugins/`）
2. **插件索引**：`marketplace.json` 声明本地插件源
3. **同步脚本**：`setup.sh` 负责复制配置和创建软链接
4. **实际安装**：Codex 从插件源安装到 `~/.agents/skills/`

## 多机器配置

在新机器上：

```bash
# 1. 克隆仓库
git clone <repo-url> ~/dot-code-agents
cd ~/dot-code-agents

# 2. 软链接 codex 配置
ln -s "${PWD}/codex" ~/.codex

# 3. 同步 agents 配置
cd agents/
./setup.sh

# 4. 在 Codex 中安装插件
```
