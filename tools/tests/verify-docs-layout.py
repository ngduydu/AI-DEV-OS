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
        "docs/ai/03-ARCHITECTURE.md": "docs/00-overview/architecture.md",
        "docs/ai/16-TASK-EXECUTION.md": "docs/01-development/ai-development.md",
        "docs/modules/README.md": "docs/02-modules/README.md",
        "docs/knowledge/README.md": "docs/03-knowledge/README.md",
        "docs/operations/README.md": "docs/04-operations/README.md",
        "docs/decisions/README.md": "docs/05-decisions/README.md",
        "docs/work/README.md": "docs/06-work/README.md",
    }
    for source, target in required_map.items():
        if path_map.get(source) != target:
            fail(f"bad ordered-v2 mapping: {source} -> {path_map.get(source)!r}")

    apply_skill = (root / ".claude" / "skills" / "apply-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "ordered-v2",
        "00-overview",
        "01-development",
        ".ai-dev-os/state.json",
        "không để target vừa có ordered path vừa có bản duplicate ở legacy path",
    ]:
        require(apply_skill, needle, "apply skill")

    updater = (root / ".claude" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    generic_updater = (root / ".agents" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "coi là \`legacy-v1\`",
        "/update-ai-dev-os\` không tự đổi docs layout",
        "resolved target path",
        "preserve nguyên \`docs_layout\`",
        "không đồng thời có duplicate scaffold ở legacy path và ordered path",
    ]:
        require(updater, needle, "claude updater")
        require(generic_updater, needle, "generic updater")

    if updater != generic_updater:
        fail("claude/generic updater skills are not mirrored")

    manifest = json.loads((root / ".ai-dev-os" / "manifest.json").read_text(encoding="utf-8"))
    managed = {item["path"] for item in manifest.get("managed_files", [])}
    if ".ai-dev-os/layouts.json" not in managed:
        fail("manifest does not manage .ai-dev-os/layouts.json")

    upgrade = (root / "UPGRADE.md").read_text(encoding="utf-8")
    for needle in [
        "Docs layout versioning",
        "tự migrate sang \`ordered-v2\`",
        "không bootstrap lại project",
        "content hash",
    ]:
        require(upgrade, needle, "upgrade docs")

    print("PASS: ordered docs layout + backward compatibility contract")


if __name__ == "__main__":
    main()
