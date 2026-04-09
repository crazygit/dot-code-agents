# Commands（已弃用）

> 自定义命令（Custom Commands）已被 Claude Code 官方合并到 Skills 体系中。
> 请在 `claude/skills/` 下创建新的功能扩展，不要在本目录下新增文件。
>
> 详见：https://code.claude.com/docs/en/skills

## Skills vs Commands

| 特性        | Skills                                                | Commands（已弃用）                  |
| ----------- | ----------------------------------------------------- | ----------------------------------- |
| 目录结构    | `skills/<name>/SKILL.md` + 支持文件                   | `commands/<name>.md` 单文件         |
| 自动加载    | 可通过 `description` 让 Claude 自动判断何时调用       | 仅用户手动触发                      |
| frontmatter | `name`、`description`、`context`、`agent`、`hooks` 等 | 仅 `argument-hint`、`allowed-tools` |
| 工具权限    | 更精细的 `allowed-tools` 控制                         | 同左                                |
