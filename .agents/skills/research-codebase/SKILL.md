---
name: research-codebase
description: Research an unfamiliar feature, bug, subsystem, or code path before implementation. Use when the relevant code flow is not already understood, when a change crosses modules, or when evidence is needed before planning.
---

# Research Codebase

1. Read `AGENTS.md` and only the relevant project docs.
2. Locate entry points using targeted search; do not bulk-read the repository.
3. Trace data/control flow end to end far enough to explain the behavior.
4. Separate verified facts from hypotheses.
5. Find existing patterns and canonical examples before proposing new abstractions.
6. Identify constraints, side effects, tests, integrations and risky boundaries.
7. Do not edit production code during research.
8. For substantial work, write findings using `docs/work/_template/RESEARCH.md`.
9. End with: findings, relevant paths, unknowns, risks, and what must be decided before planning.
