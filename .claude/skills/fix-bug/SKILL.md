---
name: fix-bug
description: Diagnose and fix unintended software behavior using evidence and root-cause analysis. Use for bugs, regressions, failing tests, production errors, incorrect data flows, or intermittent failures.
---

# Fix Bug

1. Capture the symptom and expected behavior.
2. Reproduce the failure or gather concrete evidence.
3. Trace backward from the failure to find the first incorrect assumption/state transition.
4. Check business rules and existing tests before labeling behavior a bug.
5. When feasible, add a test that fails for the bug before the fix.
6. Apply the smallest fix that addresses the root cause.
7. Run focused and regression verification.
8. Check similar code paths only when evidence suggests the same defect pattern.
9. Preserve a non-obvious recurring lesson in `docs/ai/13-KNOWN-PITFALLS.md` when valuable.
