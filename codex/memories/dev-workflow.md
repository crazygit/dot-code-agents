# Global Development Workflow Preferences

Personal default preferences across repositories:

- For non-trivial work, prefer planning before implementation.
- Prefer the smallest verification step that can prove a change is correct.
- When debugging, reproduce first and separate code problems from environment or dependency issues.
- When reviewing, prioritize correctness, security, compatibility, regression risk, and missing tests.
- Prefer one focused change set per issue or pull request.
- If a task becomes large or mixes concerns, split it before continuing.
- Treat local `git commit` as environment-sensitive when sandboxing is enabled. If the repo uses GPG signing, keychain-backed credentials, or local git hooks, do not assume a sandboxed commit will work.
- Before committing, distinguish code problems from host-environment failures such as inaccessible `~/.gnupg`, signing-agent issues, ignored hooks, or blocked writes outside writable roots.
- If a sandboxed commit fails for environment reasons, do not keep retrying inside the sandbox. Either request an escalated commit command or leave the final commit to the user after preparing the exact commit message and staged diff summary.
