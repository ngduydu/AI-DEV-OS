---
name: review-change
description: Perform an independent code review of a diff, branch, pull request, or implementation before merge. Use when the user asks for review, risk assessment, correctness checking, or a final quality pass.
---

# Review Change

Review for defects rather than style preferences.

Prioritize:

1. correctness and business-rule violations;
2. regressions and compatibility;
3. authorization, data isolation and security;
4. data consistency, transactions and concurrency;
5. error handling and failure states;
6. migration and rollback risk;
7. missing tests for new behavior;
8. unnecessary complexity and scope creep;
9. stale docs or misleading comments.

For each finding include severity, exact path/location, impact, evidence/reasoning, and a concrete remediation. Do not invent issues merely to fill a checklist.
