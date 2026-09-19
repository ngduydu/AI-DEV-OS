from __future__ import annotations

import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        fail(f"{label}: missing {needle!r}")


def forbid(text: str, needle: str, label: str) -> None:
    if needle.lower() in text.lower():
        fail(f"{label}: forbidden {needle!r}")


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[2]

    workflow = (root / ".github" / "workflows" / "verify-powershell.yml").read_text(encoding="utf-8")
    require(workflow, "permissions:\n  contents: read", "workflow permissions")
    require(
        workflow,
        "actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1",
        "pinned checkout",
    )
    require(workflow, "persist-credentials: false", "checkout credentials")
    require(workflow, "Verify security hardening contract", "security CI")

    setup = (root / "tools" / "setup-ai-dev-machine.ps1").read_text(encoding="utf-8-sig")
    require(
        setup,
        '$CodebaseMemoryInstallerCommit = "aacf96a20e3b9c450ba968c8aae663da25598992"',
        "third-party installer pin",
    )
    require(
        setup,
        "raw.githubusercontent.com/DeusData/codebase-memory-mcp/$CodebaseMemoryInstallerCommit/install.ps1",
        "third-party installer URL",
    )
    require(setup, '$CodebaseMemoryVersion = "v0.11.0"', "pinned codebase-memory release")
    require(
        setup,
        "releases/download/$CodebaseMemoryVersion",
        "pinned codebase-memory release URL",
    )
    require(setup, "npm install -g repomix@1.18.0", "pinned Repomix package")
    forbid(
        setup,
        "raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1",
        "floating third-party installer",
    )

    migrator = (root / "tools" / "migrate-docs-layout.ps1").read_text(encoding="utf-8")
    for needle in [
        "function Get-SafeFiles",
        "Refusing reparse-point entry during docs migration",
        "function Resolve-SafeDestinationFullPath",
        "Destination escapes target repository",
        "Refusing reparse-point destination during docs migration",
        "[string[]]$GitArgs",
        "Target working tree must be clean before migration",
        "reset --hard HEAD",
        "$stateExistedBefore",
        'foreach ($folder in @("docs", ".claude", ".agents", ".github", "prompts"))',
        'Get-ChildItem -LiteralPath $Root -File -Filter *.md -Force',
    ]:
        require(migrator, needle, "migration hardening")

    forbid(migrator, "[string[]]$Args", "PowerShell automatic Args collision")
    forbid(migrator, "clean -fd", "repository-wide destructive rollback cleanup")

    updater = (root / ".claude" / "skills" / "update-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "ít nhất 2",
        "AGENTS.md` hoặc `CLAUDE.md` **không đủ**",
        "Không được chạy framework migration trực tiếp trên branch task",
        "STOP trước mutation",
        "git symbolic-ref --short refs/remotes/origin/HEAD",
        "không hard-code repository phải dùng `main`/`master`",
    ]:
        require(updater, needle, "updater safety")

    apply_skill = (root / ".claude" / "skills" / "apply-ai-dev-os" / "SKILL.md").read_text(encoding="utf-8")
    for needle in [
        "Apply phải chạy trên branch riêng",
        "feature/task branch khác",
        "STOP trước mutation",
        "git symbolic-ref --short refs/remotes/origin/HEAD",
        "target base branch",
    ]:
        require(apply_skill, needle, "apply branch safety")

    tools_dir = root / "tools"
    for script in tools_dir.rglob("*.ps1"):
        text = script.read_text(encoding="utf-8-sig")
        forbid(text, "Invoke-Expression", str(script))

    for doc in root.rglob("*.md"):
        text = doc.read_text(encoding="utf-8-sig")
        forbid(text, "| iex", str(doc))
        forbid(text, "ScriptBlock]::Create((irm ", str(doc))

    for legacy in [        root / "docs" / "ai",
        root / "docs" / "modules",
        root / "docs" / "knowledge",
        root / "docs" / "operations",
        root / "docs" / "decisions",
        root / "docs" / "work",
    ]:
        if legacy.exists():
            fail(f"legacy docs root still exists: {legacy.relative_to(root)}")

    print("PASS: security hardening contract")


if __name__ == "__main__":
    main()
