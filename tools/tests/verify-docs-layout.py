from __future__ import annotations

import json
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def require(text: str, needle: str, label: str) -> None:
    if needle.lower() not in text.lower():
        fail(f"{label}: missing {needle!r}")


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]

    layouts_path = root / ".ai-dev-os" / "layouts.json"
    if not layouts_path.exists():
        fail("missing .ai-dev-os/layouts.json")

    layouts = json.loads(layouts_path.read_text(encoding="utf-8"))
    if layouts.get("default_layout") != "ordered-v2":
        fail("default docs layout must be ordered-v2")

    all_layouts = layouts.get("layouts", {})
    for name in ["legacy-v1", "ordered-v2"]:
        if name not in all_layouts:
            fail(f"missing layout: {name}")

    ordered = all_layouts["ordered-v2"]
    expected_roots = [
        "docs/00-overview",
        "docs/01-development",
        "docs/02-modules",
        "docs/03-knowledge",
        "docs/04-operations",
        "docs/05-decisions",
        "docs/06-work",
    ]
    if ordered.get("roots") != expected_roots:
        fail("ordered-v2 roots are not stable/ordered as expected")

    path_map = ordered.get("path_map", {})
    required_map = {
        "docs/ai/00-SETUP-CHECKLIST.md": "docs/01-development/setup-checklist.md",
        "docs/ai/01-PROJECT-CONTEXT.md": "docs/00-overview/project-context.md",
        "docs/ai/02-PRODUCT.md": "docs/00-overview/product.md",
        "docs/ai/03-ARCHITECTURE.md": "docs/00-overview/architecture.md",
        "docs/ai/04-CODEBASE-MAP.md": "docs/00-overview/codebase-map.md",
        "docs/ai/05-BUSINESS-RULES.md": "docs/03-knowledge/business-rules.md",
        "docs/ai/06-CODING-STANDARDS.md": "docs/01-development/coding-standards.md",
        "docs/ai/07-COMMANDS.md": "docs/01-development/commands.md",
        "docs/ai/08-TESTING.md": "docs/01-development/testing.md",
        "docs/ai/09-SECURITY.md": "docs/01-development/security.md",
        "docs/ai/10-GIT-WORKFLOW.md": "docs/01-development/git-workflow.md",
        "docs/ai/11-DEFINITION-OF-READY.md": "docs/01-development/definition-of-ready.md",
        "docs/ai/12-DEFINITION-OF-DONE.md": "docs/01-development/definition-of-done.md",
        "docs/ai/13-KNOWN-PITFALLS.md": "docs/03-knowledge/known-pitfalls.md",
        "docs/ai/14-AI-SYSTEM-MAINTENANCE.md": "docs/01-development/documentation-governance.md",
        "docs/ai/15-GLOSSARY.md": "docs/00-overview/glossary.md",
        "docs/ai/16-TASK-EXECUTION.md": "docs/01-development/ai-development.md",
        "docs/ai/17-CONTEXT-RETRIEVAL.md": "docs/01-development/context-retrieval.md",
        "docs/ai/18-TOOL-ADOPTION.md": "docs/01-development/tool-adoption.md",
        "docs/modules/README.md": "docs/02-modules/README.md",
        "docs/knowledge/README.md": "docs/03-knowledge/README.md",
        "docs/operations/README.md": "docs/04-operations/README.md",
        "docs/decisions/README.md": "docs/05-decisions/README.md",
        "docs/decisions/ADR-TEMPLATE.md": "docs/05-decisions/ADR-TEMPLATE.md",
        "docs/work/README.md": "docs/06-work/README.md",
        "docs/work/_template/PLAN.md": "docs/06-work/_template/PLAN.md",
        "docs/work/_template/RESEARCH.md": "docs/06-work/_template/RESEARCH.md",
        "docs/work/_template/SPEC.md": "docs/06-work/_template/SPEC.md",
        "docs/work/_template/TASKS.md": "docs/06-work/_template/TASKS.md",
        "docs/work/_template/VERIFICATION.md": "docs/06-work/_template/VERIFICATION.md",
    }
    if path_map != required_map:
        missing = sorted(set(required_map) - set(path_map))
        extra = sorted(set(path_map) - set(required_map))
        wrong = sorted(
            source for source in set(required_map) & set(path_map)
            if required_map[source] != path_map[source]
        )
        fail(f"ordered-v2 path_map mismatch; missing={missing}, extra={extra}, wrong={wrong}")

    required_prefix_map = {
        "docs/modules/": "docs/02-modules/",
        "docs/knowledge/": "docs/03-knowledge/",
        "docs/operations/": "docs/04-operations/",
        "docs/decisions/": "docs/05-decisions/",
        "docs/work/": "docs/06-work/",
        "docs/ai/": "docs/01-development/project/",
        "docs/team/": "docs/01-development/team/",
    }
    if ordered.get("prefix_map") != required_prefix_map:
        fail("ordered-v2 prefix_map is incomplete or changed unexpectedly")

    # Canonical source itself must already use ordered-v2.
    for relative in [
        "docs/00-overview/architecture.md",
        "docs/01-development/ai-development.md",
        "docs/02-modules/README.md",
        "docs/03-knowledge/README.md",
        "docs/04-operations/README.md",
        "docs/05-decisions/README.md",
        "docs/06-work/README.md",
    ]:
        if not (root / relative).exists():
            fail(f"canonical ordered path missing: {relative}")

    for legacy in [
        "docs/ai",
        "docs/modules",
        "docs/knowledge",
        "docs/operations",
        "docs/decisions",
        "docs/work",
    ]:
        if (root / legacy).exists():
            fail(f"legacy canonical folder still exists: {legacy}")

    apply_skill = (root / ".claude" / "skills" / "apply-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "ordered-v2",
        "Canonical source **đã dùng trực tiếp `ordered-v2`**",
        ".ai-dev-os/state.json",
        "Không tạo lại legacy folders",
    ]:
        require(apply_skill, needle, "apply skill")

    updater = (root / ".claude" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    generic_updater = (root / ".agents" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "coi là `legacy-v1`",
        "lập migration plan sang ordered-v2",
        "deterministic migrator",
        "Collision preflight",
        "git mv",
        "không bootstrap",
        "canonical ordered paths",
        "không còn duplicate scaffold ở legacy path và ordered path",
    ]:
        require(updater, needle, "claude updater")
        require(generic_updater, needle, "generic updater")

    if updater != generic_updater:
        fail("claude/generic updater skills are not mirrored")

    manifest = json.loads((root / ".ai-dev-os" / "manifest.json").read_text(encoding="utf-8"))
    managed = {item["path"] for item in manifest.get("managed_files", [])}
    if ".ai-dev-os/layouts.json" not in managed:
        fail("manifest does not manage .ai-dev-os/layouts.json")

    migrator = root / "tools" / "migrate-docs-layout.ps1"
    if not migrator.exists():
        fail("missing deterministic docs layout migrator")
    migrator_text = migrator.read_text(encoding="utf-8")
    for needle in [
        "Legacy docs inventory",
        "Collision preflight failed",
        "Get-FileHash",
        '$gitExe -C',
        "docs_layout = \"ordered-v2\"",
        "reset --hard HEAD",
    ]:
        require(migrator_text, needle, "layout migrator")

    upgrade = (root / "UPGRADE.md").read_text(encoding="utf-8")
    for needle in [
        "Docs layout versioning",
        "tự migrate sang `ordered-v2`",
        "không bootstrap lại project",
        "content hash",
    ]:
        require(upgrade, needle, "upgrade docs")

    print("PASS: ordered docs layout + backward compatibility contract")


if __name__ == "__main__":
    main()
