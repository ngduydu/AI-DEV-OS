from __future__ import annotations

import sys
from pathlib import Path


LEGACY_PREFIXES = (
    "docs/ai/",
    "docs/modules/",
    "docs/knowledge/",
    "docs/operations/",
    "docs/decisions/",
    "docs/work/",
)

# These files intentionally describe migration FROM the legacy layout.
ALLOW_LEGACY_REFERENCES = {
    ".claude/skills/update-ai-dev-os/SKILL.md",
    ".agents/skills/update-ai-dev-os/SKILL.md",
    ".ai-dev-os/layouts.json",
    "UPGRADE.md",
    "CHANGELOG.md",
    "tools/migrate-docs-layout.ps1",
    "tools/tests/test-migrate-docs-layout.ps1",
    "tools/tests/verify-docs-layout.py",
    "tools/tests/verify-security-hardening.py",
}


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]

    active_roots = [
        root / "AGENTS.md",
        root / ".github" / "copilot-instructions.md",
        root / "docs" / "README.md",
        root / "docs" / "00-overview",
        root / "docs" / "01-development",
        root / "docs" / "02-modules",
        root / "docs" / "03-knowledge",
        root / "docs" / "04-operations",
        root / "docs" / "05-decisions",
        root / "docs" / "06-work",
        root / ".claude" / "skills",
        root / ".claude" / "agents",
        root / ".agents" / "skills",
        root / "prompts",
    ]

    files: list[Path] = []
    for item in active_roots:
        if item.is_file():
            files.append(item)
        elif item.is_dir():
            files.extend(path for path in item.rglob("*") if path.is_file() and path.suffix in {".md", ".json"})

    for path in files:
        relative = path.relative_to(root).as_posix()
        if relative in ALLOW_LEGACY_REFERENCES:
            continue
        text = path.read_text(encoding="utf-8-sig")
        for legacy in LEGACY_PREFIXES:
            if legacy in text:
                fail(f"stale legacy docs reference in active instruction: {relative}: {legacy}")

    print("PASS: active docs and skills use ordered paths")


if __name__ == "__main__":
    main()
