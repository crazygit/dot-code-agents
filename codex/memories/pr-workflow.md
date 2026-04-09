# Global PR Workflow Preferences

Personal default preferences across repositories:

- For non-trivial collaborative work, prefer creating an Issue before creating a PR.
- Prefer using the Issue to capture the problem, background, goal, and acceptance criteria.
- Prefer linking the PR to the Issue, for example with `Fixes #123`.
- Follow the requested base branch when preparing branches, commits, and PRs.
- Do not create draft PRs by default.
- Prefer `gh issue create --web` and `gh pr create --web` so the final form can be reviewed before submission.
- Keep commit messages in English.
- In sandboxed sessions, treat `git commit` as a host-dependent step when signing or hooks are configured. Prefer preparing the commit message first, then request an escalated commit or hand off the final commit to the user.
- Treat `git push` as a separate manual publish gate. Do not push automatically at the end of implementation; stop after local commit and wait for explicit user confirmation before pushing a branch or opening a PR.
