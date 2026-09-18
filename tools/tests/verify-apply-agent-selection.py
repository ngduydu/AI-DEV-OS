from __future__ import annotations

import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]
    skill = root / ".claude" / "skills" / "apply-ai-dev-os" / "SKILL.md"

    if not skill.exists():
        fail("missing apply-ai-dev-os skill")

    text = skill.read_text(encoding="utf-8")

    required = {
        "mandatory selection": "Không được mặc định agent",
        "claude option": "claude",
        "generic option": "generic",
        "both option": "both",
        "claude adapter": ".claude/skills/",
        "claude agents": ".claude/agents/",
        "generic adapter": ".agents/skills/",
        "claude marker": "CLAUDE.md",
        "core marker": "AGENTS.md",
        "selection report": "Agent profile:",
    }

    for name, needle in required.items():
        if needle not in text:
            fail(f"missing contract: {name} ({needle})")

    forbidden = [
        "## Apply cho Claude Code\n",
        "target chỉ dùng Claude Code",
    ]
    for needle in forbidden:
        if needle in text:
            fail(f"stale Claude-only behavior remains: {needle!r}")

    print("PASS: apply agent-selection contract")


if __name__ == "__main__":
    main()
