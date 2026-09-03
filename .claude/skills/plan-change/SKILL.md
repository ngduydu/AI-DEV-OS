---
name: plan-change
description: Create a concrete implementation plan for a non-trivial feature, bug fix, refactor, migration, or cross-file change after the current behavior and desired behavior are sufficiently understood.
---

# Plan Change

1. Read the accepted requirement/spec and any research artifact.
2. Confirm scope and non-scope from available sources; do not invent new product requirements.
3. Prefer existing repository patterns and dependencies.
4. Break implementation into phases that can each be verified.
5. Name the files/modules likely to change and why.
6. Define verification commands or checks for each phase.
7. Include data migration, compatibility, rollback, security and observability where relevant.
8. Explicitly list assumptions and risks.
9. Avoid unrelated cleanup.
10. For substantial work, use `docs/work/_template/PLAN.md`.
