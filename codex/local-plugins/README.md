# Local Plugins

此目录用于存放本地插件源码。

## 插件安装

### issue-flow

Issue 驱动开发编排器，支持 GitHub Issue 的完整开发流程。

**安装方式：**

```bash
# 克隆插件源码
git clone https://github.com/crazygit/issue-flow.git ~/.codex/local-plugins/issue-flow
```

**配置 Marketplace:**

确保 `~/.agents/plugins/marketplace.json` 包含以下配置：

```json
{
  "name": "codex-local-plugins",
  "plugins": [
    {
      "name": "issue-flow",
      "source": {
        "source": "local",
        "path": "./.codex/local-plugins/issue-flow"
      }
    }
  ]
}
```

**在 Codex 中安装：**

1. 打开插件目录 (Ctrl/Cmd + Shift + P → Plugins)
2. 从 "Local Plugins" 源安装 issue-flow

## 插件管理

添加新的本地插件：
1. 将插件源码克隆到 `~/.codex/local-plugins/<plugin-name>/`
2. 在 `~/.agents/plugins/marketplace.json` 中添加配置
3. 在 Codex 中从 "Local Plugins" 源安装

**注意：** 此目录在仓库中仅保留 README 说明，实际的插件源码需要单独克隆。
