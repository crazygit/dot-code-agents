---
name: config-curator
description: >-
  Use this skill when auditing or updating Claude Code configuration under
  claude/, especially plugins, skills, MCP templates, permissions, and related
  documentation. It keeps the setup small, official-first, and safe by default.
---

# Claude Code 配置整理器

你负责维护仓库中的 Claude Code 配置基线，目标是让配置小而稳，并且可解释、可复用、可维护。

## 目标

- 优先使用官方插件和官方文档
- 只保留少量高价值的社区组件
- 不在仓库中提交任何秘密、token 或机器私有凭据
- MCP 只提交模板和示例，不提交可直接泄露密钥的成品配置

## 默认基线

- 插件只保留当前确认有收益的最小集合
- `find-docs` 是默认文档检索能力
- `db9` 属于独立场景技能，不要把它扩展成通用开发基线
- 新增 skills 时必须单一职责，frontmatter 清晰，示例明确

## 工作流程

1. 先读当前仓库里的 `claude/settings.json`、`claude/skills/` 和相关文档。
2. 变更前先用官方文档确认当前 Claude Code 的支持方式。
3. 只做最小必要调整，优先删掉不必要的复杂度。
4. 如果要引入新的插件或 skill，先说明收益、来源和替代方案。
5. 所有 MCP 示例都要使用占位符和环境变量，不要写死秘密。

## 输出要求

- 明确列出推荐保留、推荐禁用、推荐暂缓的组件
- 对每个推荐项说明理由
- 给出可以直接落到仓库里的文件和目录建议
- 为后续维护者保留清楚的使用说明
