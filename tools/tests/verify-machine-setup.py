from __future__ import annotations

import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]
    setup = root / "tools" / "setup-ai-dev-machine.ps1"

    if not setup.exists():
        fail("missing tools/setup-ai-dev-machine.ps1")

    text = setup.read_text(encoding="utf-8")

    required = {
        "ripgrep": "BurntSushi.ripgrep.MSVC",
        "ast-grep": "ast-grep.ast-grep",
        "Repomix": "npm install -g repomix",
        "codebase-memory-mcp": "codebase-memory-mcp",
        "skip config": "--skip-config",
        "Claude MCP user scope": "--scope user",
        "personal updater": "install-personal-updater.ps1",
        "Vietnamese output": "TÓM TẮT THIẾT LẬP",
        "no project MCP mutation": "Không sửa .mcp.json của project",
        "optional SQL MCP flag": "[switch]$WithSqlServerMcp",
        "Microsoft SQL MCP": "Microsoft.DataApiBuilder --version 2.0.12",
        "SQL MCP remains project-specific": "Chưa cấu hình database/project",
    }

    for name, needle in required.items():
        if needle not in text:
            fail(f"missing contract: {name} ({needle})")

    if "CodeGraph" not in text:
        fail("setup script must explicitly state CodeGraph is not installed")

    print("PASS: machine setup static contract")


if __name__ == "__main__":
    main()
