---
allowed-tools: Read, Glob, Grep, Bash(terraform fmt *), Bash(terraform validate *), Bash(terraform init *), Bash(find *), Bash(rg *)
argument-hint: [Terraform 目录]
description: 运行 Terraform 格式化与验证，优先检查当前变更目录
---

# Terraform 验证

执行 Terraform 校验: $ARGUMENTS

## 工作流程

1. 先确认目标目录下是否存在 Terraform 配置文件。
2. 运行 `terraform fmt -check -recursive` 检查格式。
3. 运行 `terraform init` 和 `terraform validate` 做基础校验。
4. 如果校验失败，先区分是语法、依赖还是 provider 配置问题。

## 默认行为

- 无参数时，优先在当前目录或最近的 Terraform 模块目录执行
- 如果模块依赖远程状态或 provider，先说明可能需要网络或凭据
- 如果仓库里有多个模块，优先只验证当前修改涉及的模块

## 关注点

- 格式是否统一
- 语法是否有效
- provider、module、variable、output 配置是否合理
- 是否存在明显的计划前阻断问题

