---
name: implement-plan
description: Implement an already-defined and accepted change plan phase by phase, keeping scope controlled and verifying each meaningful step. Use when a plan/spec exists and implementation should begin.
---

# Implement Plan

1. Read the plan, spec, relevant docs and current code before editing.
2. Execute one cohesive phase at a time.
3. Keep the diff within stated scope.
4. Follow existing repository patterns unless the plan explicitly changes them.
5. If the plan marks a test-first seam, use the `tdd` skill and work in small red-green slices.
6. During implementation, run the smallest relevant test/typecheck frequently; do not wait until the very end for all feedback.
7. After each meaningful phase, run the planned focused verification when feasible.
8. If the plan's assumptions are disproved, update or flag the plan instead of silently improvising a different architecture.
9. Do not hide failures by weakening tests or deleting assertions without a justified behavior change.
10. Finish with broad-enough verification, diff review and documentation updates.
11. For non-trivial changes, run `review-change` or an independent reviewer before reporting Done.
12. Report only checks actually executed.
