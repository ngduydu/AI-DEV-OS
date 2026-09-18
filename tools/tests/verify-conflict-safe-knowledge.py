from __future__ import annotations

import json
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        fail(f"{label}: missing {needle!r}")


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]

    version = (root / ".ai-dev-os" / "VERSION").read_text(encoding="utf-8").strip()
    manifest = json.loads((root / ".ai-dev-os" / "manifest.json").read_text(encoding="utf-8"))

    if version != "2.6.0":
        fail(f"expected VERSION 2.6.0, got {version!r}")
    if manifest.get("framework_version") != version:
        fail("manifest version mismatch")

    knowledge = root / "docs" / "knowledge" / "README.md"
    if not knowledge.exists():
        fail("missing docs/knowledge/README.md")
    knowledge_text = knowledge.read_text(encoding="utf-8")
    for needle in [
        "mỗi knowledge item = một file riêng",
        "không có central index",
        "shared canonical docs",
        "docs/knowledge/pitfalls/",
        "docs/knowledge/business-rules/",
    ]:
        require(knowledge_text, needle, "knowledge policy")

    task_contract = (root / "docs" / "ai" / "16-TASK-EXECUTION.md").read_text(encoding="utf-8")
    for needle in [
        "Conflict-safe Knowledge Sync",
        "mặc định tạo file riêng",
        "không append vào shared canonical file",
    ]:
        require(task_contract, needle, "task contract")

    pitfalls = (root / "docs" / "ai" / "13-KNOWN-PITFALLS.md").read_text(encoding="utf-8")
    for needle in [
        "Legacy / canonical router",
        "Không thêm pitfall mới trực tiếp vào file này",
        "docs/knowledge/pitfalls/",
    ]:
        require(pitfalls, needle, "pitfalls router")

    claude_skill = (root / ".claude" / "skills" / "update-project-knowledge" / "SKILL.md").read_text(encoding="utf-8")
    generic_skill = (root / ".agents" / "skills" / "update-project-knowledge" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "mặc định tạo file riêng",
        "không sửa shared canonical docs",
        "docs/knowledge/",
    ]:
        require(claude_skill, needle, "claude knowledge skill")
        require(generic_skill, needle, "generic knowledge skill")

    updater = (root / ".claude" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    upgrade = (root / "UPGRADE.md").read_text(encoding="utf-8")
    for text, label in [(updater, "updater"), (upgrade, "upgrade")]:
        require(text, "2.6.0", label)
        require(text, "không di chuyển hoặc tách knowledge cũ tự động", label)

    managed = {item["path"]: item for item in manifest["managed_files"]}
    for path in [
        "docs/knowledge/README.md",
        "docs/ai/13-KNOWN-PITFALLS.md",
        ".claude/skills/update-project-knowledge/SKILL.md",
        ".agents/skills/update-project-knowledge/SKILL.md",
    ]:
        if path not in managed:
            fail(f"manifest missing managed path: {path}")

    print("PASS: conflict-safe knowledge sync contract")


if __name__ == "__main__":
    main()
