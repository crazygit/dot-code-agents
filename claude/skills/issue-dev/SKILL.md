---
name: issue-dev
description: >-
  当用户希望以 GitHub Issue 作为软件交付的事实来源，用于创建、接手、
  执行或汇总任务时使用本 skill。它把 GitHub Issue 追踪与 Superpowers
  工作流结合起来，让需求、计划、实现进度、验证结果和 PR 关联都可追溯。
version: 1.0.0
---

# Issue-Driven Development

用 GitHub Issue 作为需求入口、执行记录和进度追踪中心，并强制接入 Superpowers 的标准开发工作流。

## 何时使用

- 用户要从一个需求出发，先整理再落到 GitHub Issue
- 用户要基于一个或多个已有 Issue 开始开发
- 用户要查看某个仓库当前 Issue 和 PR 的推进状态
- 用户明确希望把设计、计划、阻塞、验证结果记录回 GitHub Issue

## 何时不要使用

- 用户只是想讨论想法，还没有准备把工作落到 Issue
- 当前目录不是 git 仓库，或仓库没有 GitHub remote
- 当前任务只是纯文档润色、答疑或临时实验，且不需要可追踪交付

## 快速示例

- `/issue-dev <需求描述>`
  从需求出发，先澄清和拆分，再生成 Issue 草稿并进入执行流程。
- `/issue-dev #123`
  读取现有 Issue，补足澄清后直接进入执行流程。
- `/issue-dev status`
  汇总当前仓库的 Issue、PR 和阶段状态，必要时回写状态评论。

## 核心规则

- Issue 是任务入口，没有明确 Issue 就不要直接开始实现
- 1 个可交付变更对应 1 个主 Issue；过大需求要先拆分
- PR 必须关联对应 Issue，优先使用 `Fixes #N` 或 `Closes #N`
- Superpowers 工作流是强制流程，不是建议
- 进度必须写回 GitHub，而不是只保留在对话上下文里
- 创建 Issue 和 PR 时必须使用 `--web`，由人工最终审核并提交
- 未经用户确认，不要直接修改生产配置、合并 PR、关闭 Issue

## 必经流程

按下面顺序工作，除非用户明确要求跳过某一步且风险可接受：

1. `brainstorming`
   用于把模糊需求变成清晰设计和验收标准。
2. `using-git-worktrees`
   设计获批后启用。为每个 Issue 建独立分支和工作区。
3. `writing-plans`
   基于已批准设计写出可执行计划。任务要小，通常 2-5 分钟。
4. `subagent-driven-development` 或 `executing-plans`
   按计划执行。多任务长流程优先 `subagent-driven-development`。
5. `test-driven-development`
   在每个实现任务中强制执行 RED-GREEN-REFACTOR。
6. `requesting-code-review`
   在任务批次之间和提交前执行。严重问题阻塞继续推进。
7. `verification-before-completion`
   确认功能、测试和验收标准真的成立。
8. `finishing-a-development-branch`
   收尾阶段决定开 PR、继续保留分支、合并还是丢弃。

只有在多个 Issue 之间彼此独立时，才额外调用 `dispatching-parallel-agents`。

## 运行模式

### 模式 A：需求到 Issue

当用户给的是需求而不是 Issue 编号时：

1. 先运行 `brainstorming`，把目标、边界、验收标准、技术约束讲清楚。
2. 产出设计摘要，并让用户明确批准。
3. 把需求拆成一个或多个 Issue。
4. 先展示 Issue 草稿，不要直接创建。
5. 用户确认后，只能用 `gh issue create --web` 打开预填页面，由人工最终审核并提交。
6. 创建完成后，转入对应的执行模式。

### 模式 B：执行已有 Issue

当用户给的是 `#123` 这类 Issue 编号时：

1. 读取 Issue 内容、评论、标签、Milestone、关联 PR。
2. 提炼目标、验收标准、约束、未知点。
3. 如果信息不足，先澄清，再开始实现。
4. 设计未明确时，先补走 `brainstorming`。
5. 设计获批后，按上面的必经流程执行。

### 模式 C：状态汇总与回写

当用户要看进度或做周报时：

1. 拉取 open Issues、open PRs、Milestones。
2. 识别 Issue 当前状态：待澄清、待计划、开发中、阻塞中、待评审、待验证、已完成。
3. 输出简洁状态表。
4. 如果用户要求，把状态摘要写回对应 Issue 评论。

## Agent 职责

这个 skill 默认采用主 agent 编排、subagent 执行的模式。

### 主 agent 负责全局编排

主 agent 负责全局控制，不能把这些职责下放：

- 判断当前模式：需求建 Issue、执行已有 Issue、状态汇总
- 执行前置检查，确认仓库、GitHub、Issue、分支策略都成立
- 决定是否先走 `brainstorming`
- 决定是否拆分 Issue、是否并行、是否停止并行回到串行
- 调用 Superpowers 工作流的正确阶段
- 为每个 subagent 分派明确边界的单个 Issue 或单个 plan task
- 收集 subagent 的结果、风险、阻塞、验证信息、文档更新
- 统一把开发状态回写到 GitHub Issue
- 准备 Issue / PR 草稿，并通过 `--web` 交给人工最终审核
- 在结束时整合交付结果、文档结果、剩余风险和下一步建议

主 agent 不应直接把“自己不想处理的不明确工作”丢给 subagent。

### subagent 负责局部执行

每个 subagent 只负责自己被分派的范围，不能越界接管全局流程：

- 只处理一个明确边界的 Issue，或一个明确 plan task
- 在自己的 worktree 或隔离上下文中执行
- 遵守 `writing-plans`、`test-driven-development`、`requesting-code-review`、`verification-before-completion`
- 只修改自己任务需要的文件和文档
- 输出结构化执行结果，交回主 agent 汇总
- 遇到阻塞时立即上报，不自行改写目标或扩大范围

subagent 不负责：

- 自主决定新建额外 Issue 或 PR
- 直接推进跨 Issue 的集成决策
- 直接关闭 Issue、提交 PR、或对 GitHub 做最终发布动作

## 交接契约

主 agent 给 subagent 的输入必须完整，避免 subagent 自行猜测：

- Issue 编号和标题
- 目标与验收标准
- 约束和非目标
- 当前计划中本次任务的边界
- 明确允许修改的文件或目录
- 必须补充或更新的局部文档
- 验证要求
- 需要上报给主 agent 的风险类型

subagent 回传给主 agent 的结果至少要包含：

- 完成了什么
- 修改了哪些文件
- 更新了哪些文档
- 测试和验证结果
- 发现的风险、限制、后续建议
- 是否可进入 review / verify / PR 阶段

如果 subagent 的结果不完整，主 agent 不应直接继续下一阶段。

## 前置检查

开始前先检查：

1. `gh auth status`
   失败则停止，并提示用户运行 `gh auth login -h github.com`
2. 确认当前目录在 git 仓库内，并且存在 GitHub remote
3. `gh repo view --json nameWithOwner -q .nameWithOwner`
   读取仓库标识，后续所有 Issue 和 PR 都以当前仓库为准

如果任何一步失败，不要假设，不要继续执行后续开发流程。

## Issue 设计规则

- Issue 标题必须能表达一个可交付结果
- 一个 Issue 必须能映射到一个明确 PR
- 验收标准必须是可验证的，不写模糊目标
- 技术约束只写会影响实现决策的内容
- 大型需求优先拆成父级跟踪 Issue 加若干子 Issue，或用 Milestone 聚合

推荐模板见 `references/issue-templates.md`。

## 进度回写规则

这个 skill 的核心不是“基于 Issue 开发”，而是“把开发进度持续记录回 Issue”。

默认记录节奏如下：

1. 进入执行时写 kickoff 评论
2. 计划完成后写 plan 评论
3. 关键检查点写 progress 评论
4. 出现阻塞时写 blocker 评论
5. 提交 PR 后写 handoff 评论
6. 完成后写 completion 评论

具体模板见 `references/comment-templates.md`。

如果用户没有明确授权自动发评论，先生成评论草稿并展示给用户确认。
如果用户明确要求全自动执行，才直接用 `gh issue comment` 写入。

GitHub Issue 的状态回写由主 agent 统一负责。subagent 只负责提供素材，不直接发布全局状态结论。

## 文档职责

文档也是交付物的一部分，不是事后补充。

### 每个 subagent 负责局部文档

每个 subagent 必须负责自己任务范围内的文档更新，至少覆盖以下之一：

- 改动说明
- 接口或行为变化
- 配置变化
- 测试方法
- 使用方式
- 迁移或兼容性影响

如果代码改动需要文档但 subagent 没有更新文档，该任务不能算完成。

### 主 agent 负责整合文档

主 agent 负责整合跨 Issue 和跨任务的信息，形成统一视图：

- 当前阶段总结
- 各 subagent 的完成情况
- 跨模块影响
- 对外可见变化
- 集成验证结果
- 剩余风险和后续建议

主 agent 负责决定哪些内容写回：

- GitHub Issue comment
- PR 描述草稿
- 最终交付摘要
- 需要用户审核的设计或实施结论

Issue 评论用于追踪状态，不能替代最终文档。

## 执行流程

### 单个 Issue

1. 读取 Issue，并确认是否需要先补 `brainstorming`
2. 设计批准后，运行 `using-git-worktrees`
3. 创建工作分支，建议命名：`issue-<N>-<slug>`
4. 写 kickoff comment
5. 运行 `writing-plans`
6. 写 plan comment
7. 主 agent 决定是自己执行，还是分派给一个 subagent
8. 执行者必须遵守 `test-driven-development`
9. subagent 完成后，把代码结果、文档结果、测试结果、风险回传给主 agent
10. 主 agent 汇总后运行 `requesting-code-review`
11. 主 agent 运行 `verification-before-completion`
12. 主 agent 准备 PR，PR body 第一行使用 `Fixes #N`，并用 `gh pr create --web` 打开预填页面，由人工最终审核并提交
13. 主 agent 写 handoff comment，把 PR、测试、风险、文档结果记回 Issue
14. 主 agent 运行 `finishing-a-development-branch`
15. 用户确认后，再决定是否关闭 Issue 或继续跟进

### 多个独立 Issue

只在多个 Issue 能独立推进时并行：

1. 逐个读取 Issue，确认没有强耦合或共享大改动
2. 每个 Issue 都走自己的 `using-git-worktrees`
3. 主 agent 用 `dispatching-parallel-agents` 分发，但每个 subagent 只负责一个 Issue
4. 每个 subagent 都必须执行：
   `writing-plans` -> `test-driven-development` -> 局部文档更新 -> 结果回传
5. 主 agent 统一收集所有 subagent 的代码结果、文档结果、风险和阻塞
6. 主 agent 对每个 Issue 或集成结果运行 `requesting-code-review` 和 `verification-before-completion`
7. 主 agent 准备各自的 PR 草稿，并通过 `gh pr create --web` 交给人工最终审核
8. 主 agent 统一把状态、PR、阻塞、文档摘要回写到对应 GitHub Issue
9. 如有交叉影响，停止并行，回到串行集成

不要把多个无关 Issue 塞进同一个分支或同一个 PR。

## 状态模型

使用统一状态词，避免 Issue 评论风格漂移：

- `draft`
  需求已收集，但还没定稿
- `planned`
  设计和计划已确认，等待开始实现
- `in_progress`
  正在开发
- `blocked`
  有阻塞，等待外部输入
- `in_review`
  实现完成，正在 review 或等 review 处理
- `verifying`
  review 通过，正在做最终验证
- `done`
  已完成并具备关闭条件

输出状态时，优先按这个模型归类。

## 推荐 GitHub 命令

优先使用这些命令，避免手工拼接不稳定流程：

- `gh issue view <N> --comments`
- `gh issue list --state open`
- `gh issue comment <N> --body-file <file>`
- `gh pr list --state open`
- `gh issue create --web`
- `gh pr create --web`
- `gh pr view <N>`

如果需要创建 Issue，遵循这条默认策略：

- 默认先展示标题、body、labels、milestone 草稿
- 用户确认后，只能用 `gh issue create --web` 让用户在浏览器最终确认
- 不要使用非 `--web` 方式直接创建 Issue
- 创建 PR 时同理，只能用 `gh pr create --web`

更完整的评论模板和交付模板见 `references/comment-templates.md`。

## 自检清单

执行过程中始终自检：

- 是否真的有明确 Issue，还是只是口头需求
- 是否先做了设计澄清，而不是直接写代码
- 是否在设计批准后才进入 worktree 和计划阶段
- 计划是否足够细，可以直接执行
- 主 agent 和 subagent 的职责是否清晰，没有漂移
- 是否把进度写回 GitHub，而不是只留在本地上下文
- subagent 是否提交了局部文档更新
- 主 agent 是否整合了跨任务文档和状态摘要
- 是否每个实现任务都执行了 TDD
- 是否在提交前做了 code review 和最终验证
- PR 是否正确链接了 Issue

## 错误处理

- `gh` 未安装或未认证
  停止，并提示修复认证
- Issue 不存在、仓库不对、没有权限
  停止，并让用户确认仓库和编号
- Issue 描述不清
  先澄清，不要猜测实现
- 多个 Issue 实际强耦合
  停止并行，改成单计划串行推进
- 测试基线不干净
  在 `using-git-worktrees` 阶段先修复基线，再继续
- review 发现严重问题
  阻塞后续步骤，先修复
- PR 存在冲突或验证失败
  不要宣称完成，回到执行阶段

## 安全约束

- 不在 Issue、PR、commit、评论中写入密钥、token 或内部凭据
- commit message 使用英文，并尽量遵循 Conventional Commits
- 创建 Issue 和 PR 时必须经过人工网页审核，不允许 agent 直接提交
- 未经用户同意，不自动关闭 Issue、合并 PR 或删除分支
- 未经用户确认，不直接给仓库批量创建 labels、milestones、projects

## 预期输出

这个 skill 的输出至少要包含：

- 当前模式判断
- Issue 编号或待创建的 Issue 草稿
- 当前所处的 Superpowers 阶段
- 下一步动作
- 需要写回 GitHub 的评论草稿或已写入记录

如果用户问的是状态，输出必须包含可读的状态概览，而不是原始命令结果。
