from __future__ import annotations

import json
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]

    required = [
        root / ".ai-dev-os" / "VERSION",
        root / ".ai-dev-os" / "manifest.json",
        root / ".ai-dev-os" / "layouts.json",
        root / ".ai-dev-os" / "state.json",
        root / "UPGRADE.md",
        root / "tools" / "install-personal-updater.ps1",
        root / ".claude" / "skills" / "update-ai-dev-os" / "SKILL.md",
        root / ".agents" / "skills" / "update-ai-dev-os" / "SKILL.md",
    ]
    missing = [str(path.relative_to(root)) for path in required if not path.exists()]
    if missing:
        fail(f"missing required updater artifacts: {missing}")

    version = (root / ".ai-dev-os" / "VERSION").read_text(encoding="utf-8").strip()
    manifest = json.loads((root / ".ai-dev-os" / "manifest.json").read_text(encoding="utf-8"))

    if manifest.get("framework_version") != version:
        fail("manifest framework_version does not match VERSION")

    layouts = json.loads((root / ".ai-dev-os" / "layouts.json").read_text(encoding="utf-8"))
    state = json.loads((root / ".ai-dev-os" / "state.json").read_text(encoding="utf-8"))
    if layouts.get("default_layout") != "ordered-v2":
        fail("default layout must be ordered-v2")
    if state.get("docs_layout") != "ordered-v2" or state.get("docs_layout_version") != 2:
        fail("canonical source state must be ordered-v2 / 2")

    managed = manifest.get("managed_files")
    if not isinstance(managed, list) or not managed:
        fail("manifest managed_files must be a non-empty list")

    valid_ownership = {"framework", "mixed"}
    valid_scope = {"core", "claude", "generic"}
    seen: set[str] = set()

    for item in managed:
        path = item.get("path")
        if not path or path in seen:
            fail(f"invalid or duplicate managed path: {path!r}")
        seen.add(path)
        if item.get("ownership") not in valid_ownership:
            fail(f"invalid ownership for {path}")
        if item.get("scope") not in valid_scope:
            fail(f"invalid scope for {path}")
        if not (root / path).exists():
            fail(f"managed source path does not exist: {path}")

    protected_project_knowledge = {
        "docs/00-overview/project-context.md",
        "docs/00-overview/product.md",
        "docs/00-overview/architecture.md",
        "docs/00-overview/codebase-map.md",
        "docs/01-development/coding-standards.md",
        "docs/01-development/commands.md",
        "docs/01-development/testing.md",
        "docs/01-development/security.md",
        "docs/01-development/git-workflow.md",
        "docs/01-development/definition-of-ready.md",
        "docs/01-development/definition-of-done.md",
        "docs/03-knowledge/business-rules.md",
        "docs/03-knowledge/known-pitfalls.md",
    }
    accidentally_managed = sorted(protected_project_knowledge & seen)
    if accidentally_managed:
        fail(f"project-owned knowledge must not be manifest-managed: {accidentally_managed}")

    claude_skill = (root / ".claude" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    generic_skill = (root / ".agents" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    if claude_skill != generic_skill:
        fail("Claude and generic updater skills differ")

    installer = (root / "tools" / "install-personal-updater.ps1").read_text(encoding="utf-8")
    for needle in [
        ".claude\\skills\\update-ai-dev-os",
        "Canonical updater skill not found",
        "/update-ai-dev-os",
        "$HOME",
        "disable-model-invocation: true",
    ]:
        if needle not in installer:
            fail(f"installer missing expected contract: {needle}")

    upgrade = (root / "UPGRADE.md").read_text(encoding="utf-8")
    for needle in [
        "2.3.0",
        "2.6.0",
        "17-AI-USAGE-POLICY.md",
        "docs/team/AI-USAGE-POLICY.md",
        "install-personal-updater.ps1",
        "ordered-v2",
        "không bootstrap lại project",
    ]:
        if needle not in upgrade:
            fail(f"UPGRADE.md missing: {needle}")

    changelog = (root / "CHANGELOG.md").read_text(encoding="utf-8")
    if version not in changelog:
        fail(f"CHANGELOG.md does not mention current VERSION {version}")

    print("PASS: updater static verification")
    print(f"PASS: version={version}")
    print(f"PASS: managed_files={len(managed)}")
    print("PASS: canonical updater skill mirrors exact")


if __name__ == "__main__":
    main()
