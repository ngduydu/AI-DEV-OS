---
name: verify-change
description: Verify that a code change actually works before claiming completion. Use after implementation, before merge, when asked whether work is done, or when test/build evidence is missing.
---

# Verify Change

1. Read the diff and Acceptance Criteria.
2. Read `docs/ai/07-COMMANDS.md` and `docs/ai/08-TESTING.md`.
3. Select the smallest checks that directly exercise changed behavior.
4. Run focused checks first, then broader checks appropriate to the risk.
5. Inspect failures; do not rerun flaky checks until green and call that success.
6. Check the final diff for unrelated changes, debug artifacts and secrets.
7. Classify every required check as PASS, FAIL or NOT VERIFIED.
8. Never claim passing evidence for a command that was not actually run.
9. For substantial work, record evidence in `docs/work/.../VERIFICATION.md`.
