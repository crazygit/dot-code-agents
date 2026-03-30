---
allowed-tools: Read, Glob, Grep, Bash(uv run *), Bash(pytest *), Bash(python -m pytest *), Bash(python -m compileall *)
argument-hint: [路径、测试筛选或项目目录]
description: 运行 Python 项目的测试和基础校验，兼容 uv 和 pytest 工作流
---

# Python 测试与校验

执行 Python 验证: $ARGUMENTS

## 工作流程

1. 先判断项目使用的是 `uv`、`pytest`、Poetry、pip 还是其它方式管理环境。
2. 优先执行项目现有的测试入口，不要擅自改造项目约定。
3. 如果可以，先跑变更相关的最小测试集，再决定是否扩大到全量测试。
4. 必要时补充导入检查或字节码编译检查，帮助发现基础语法问题。

## 默认行为

- 有 `pyproject.toml` 且使用 `uv` 的项目，优先考虑 `uv run pytest`
- 只有 `pytest` 可用时，使用 `pytest`
- 如果用户传入目录或筛选表达式，优先只跑该范围

## 关注点

- 测试是否通过
- 导入和语法是否正常
- 是否需要补充回归测试
- 是否存在因为环境差异导致的失败

