---
name: research-codebase
description: Research an unfamiliar feature, bug, subsystem, or code path before implementation. Use when the relevant code flow is not already understood, when a change crosses modules, or when evidence is needed before planning.
---

# Research Codebase

1. Read `AGENTS.md` and only the relevant project docs.
2. **Pass the Codebase Memory Gate first:** verify Codebase Memory connectivity/coverage and query `codebase-memory-mcp`; rely on auto-index/auto-watch for normal indexing for the task's relevant symbols/architecture/relationships. Do not start with `rg`/`ast-grep`.
3. Locate entry points from graph results, then read the actual source/test files. Use targeted text/structural search only after the graph route is established.
4. Trace data/control flow end to end far enough to explain the behavior.
5. Separate verified facts from hypotheses.
6. Find existing patterns and canonical examples before proposing new abstractions.
7. Identify constraints, side effects, tests, integrations and risky boundaries.
8. Do not edit production code during research.
9. For substantial work, write findings using `docs/06-work/_template/RESEARCH.md`.
10. End with: findings, relevant paths, unknowns, risks, and what must be decided before planning.
