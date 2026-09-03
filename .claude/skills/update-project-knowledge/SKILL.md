---
name: update-project-knowledge
description: Preserve durable knowledge discovered during implementation, review, debugging, or incidents. Use when project behavior, architecture, business rules, recurring workflows, or non-obvious pitfalls have changed or become clearer.
---

# Update Project Knowledge

Classify each new learning before writing it:

- always-on repository invariant → `AGENTS.md`;
- stable project knowledge → matching file in `docs/ai/`;
- architecture decision with trade-offs → `docs/decisions/` ADR;
- recurring multi-step procedure → create/update a Skill;
- non-obvious recurring failure → `docs/ai/13-KNOWN-PITFALLS.md`;
- task-only context → `docs/work/`.

Keep the system concise. Remove stale or contradictory guidance when discovered. Do not copy the same rule into several files unless a tool adapter truly requires a short duplicate.
