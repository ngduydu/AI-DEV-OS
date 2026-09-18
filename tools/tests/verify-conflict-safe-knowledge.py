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

    version = (root / ".ai-dev-os" / "VERSION").read_text(encoding="utf-8").strip()
    manifest = json.loads((root / ".ai-dev-os" / "manifest.json").read_text(encoding="utf-8"))

    if version != "2.6.0":
        fail(f"expected VERSION 2.6.0, got {version!r}")
    if manifest.get("framework_version") != version:
        fail("manifest version mismatch")

    knowledge = root / "docs" / "03-knowledge" / "README.md"
    if not knowledge.exists():
        fail("missing docs/03-knowledge/README.md")
    knowledge_text = knowledge.read_text(encoding="utf-8")
    for needle in [
        "mỗi discovery bền vững của task = một file entry riêng",
        "không có central index",
        "shared canonical docs",
        "docs/03-knowledge/pitfalls/entries/",
        "docs/03-knowledge/business-rules/entries/",
    ]:
        require(knowledge_text, needle, "knowledge policy")

    task_contract = (root / "docs" / "01-development" / "ai-development.md").read_text(encoding="utf-8")
    for needle in [
        "Conflict-safe Knowledge Sync",
        "mặc định tạo file riêng",
        "không append vào shared canonical file",
        "Conflict Surface Gate",
    ]:
        require(task_contract, needle, "task contract")

    pitfalls = (root / "docs" / "03-knowledge" / "known-pitfalls.md").read_text(encoding="utf-8")
    for needle in [
        "Legacy / canonical router",
        "Không thêm pitfall mới trực tiếp vào file này",
        "docs/03-knowledge/pitfalls/",
    ]:
        require(pitfalls, needle, "pitfalls router")

    claude_skill = (root / ".claude" / "skills" / "update-project-knowledge" / "SKILL.md").read_text(encoding="utf-8")
    generic_skill = (root / ".agents" / "skills" / "update-project-knowledge" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "mặc định tạo file riêng",
        "không sửa shared canonical docs",
        "docs/03-knowledge/",
        "Conflict Surface Gate",
    ]:
        require(claude_skill, needle, "claude knowledge skill")
        require(generic_skill, needle, "generic knowledge skill")

    updater = (root / ".claude" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    upgrade = (root / "UPGRADE.md").read_text(encoding="utf-8")
    require(updater, "2.6.0", "updater")
    require(updater, "không split nội dung", "updater")
    require(updater, "không bootstrap lại project", "updater")
    require(upgrade, "2.6.0", "upgrade")
    require(upgrade, "không split/rewrite semantics", "upgrade")
    require(upgrade, "không bootstrap lại project", "upgrade")

    managed = {item["path"]: item for item in manifest["managed_files"]}
    for path in [
        "docs/03-knowledge/README.md",
        "docs/03-knowledge/known-pitfalls.md",
        ".claude/skills/update-project-knowledge/SKILL.md",
        ".agents/skills/update-project-knowledge/SKILL.md",
        "docs/01-development/setup-checklist.md",
        "docs/05-decisions/README.md",
        "docs/02-modules/README.md",
        "docs/04-operations/README.md",
        "docs/06-work/README.md",
        ".claude/skills/fix-bug/SKILL.md",
        ".agents/skills/fix-bug/SKILL.md",
    ]:
        if path not in managed:
            fail(f"manifest missing managed path: {path}")

    decisions = (root / "docs" / "05-decisions" / "README.md").read_text(encoding="utf-8")
    require(decisions, "docs/05-decisions/entries/", "decisions routing")
    require(decisions, "không dùng sequence toàn cục", "decisions routing")

    for path in [
        root / ".claude" / "skills" / "fix-bug" / "SKILL.md",
        root / ".agents" / "skills" / "fix-bug" / "SKILL.md",
    ]:
        text = path.read_text(encoding="utf-8")
        require(text, "docs/03-knowledge/pitfalls/entries/", str(path))
        if "Preserve a non-obvious recurring lesson in `docs/ai/13-KNOWN-PITFALLS.md`" in text:
            fail(f"{path}: stale shared-pitfall append guidance")

    print("PASS: conflict-safe knowledge sync contract")


if __name__ == "__main__":
    main()
