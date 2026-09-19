---
name: plan-change
description: Create a concrete implementation plan for a non-trivial feature, bug fix, refactor, migration, or cross-file change after the current behavior and desired behavior are sufficiently understood.
---

# Plan Change

1. Read the accepted requirement/spec and any research artifact.
2. Confirm scope and non-scope from available sources; do not invent new product requirements.
3. Prefer existing repository patterns and dependencies.
4. Define test/verification seams before implementation when behavior is testable.
5. Run Simplicity Gate: no-code/config → reuse → stdlib/platform → existing dependency → minimum new code.
6. Break implementation into phases that can each be verified.
7. Name the files/modules likely to change and why.
8. Define verification commands or checks for each phase.
9. Include data migration, compatibility, rollback, security and observability where relevant.
10. Explicitly list assumptions and risks.
11. Avoid unrelated cleanup.
12. For substantial work, use `docs/06-work/_template/PLAN.md`.
