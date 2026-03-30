---
allowed-tools: Read, Glob, Grep, Bash(terraform fmt *), Bash(terraform validate *), Bash(terraform init *), Bash(terraform plan *), Bash(find *), Bash(rg *)
argument-hint: [Terraform 目录]
description: 运行 Terraform 计划，先完成格式与验证，再生成 plan 供审阅
---

# Terraform 计划

执行 Terraform 计划: $ARGUMENTS

## 工作流程

1. 先确认目标目录和工作区。
2. 运行 `terraform fmt -check -recursive` 和 `terraform validate`。
3. 在必要时执行 `terraform init`，再生成 `terraform plan`。
4. 解释 plan 的主要变更，标出可能有风险的资源改动。

## 默认行为

- 无参数时，优先在当前目录或最近的 Terraform 模块目录执行
- 如果 plan 涉及敏感资源或大规模替换，明确提醒需要人工确认
- 如果命令失败，先给出失败原因分类，再决定是否重试

## 关注点

- 是否存在破坏性资源变更
- 是否有意外的替换、销毁或大规模扩散
- 变量、输出、状态后端是否符合预期
- plan 结果是否足够清晰，可供后续 review

