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
    if version != "2.8.2":
        fail(f"expected 2.8.2, got {version!r}")
    if manifest.get("framework_version") != version:
        fail("manifest version mismatch")

    agents = (root / "AGENTS.md").read_text(encoding="utf-8")
    for needle in [
        "Mọi phản hồi, báo cáo, plan/spec",
        "Comment mới hoặc comment được sửa",
        "tiếng Việt",
    ]:
        require(agents, needle, "language policy")

    task = (root / "docs" / "01-development" / "ai-development.md").read_text(encoding="utf-8")
    for needle in [
        "Simplicity Gate",
        "Có thể không viết gì / chỉ cấu hình?",
        "standard library/platform",
        "dependency project đang có",
        "shape-task",
        "decision-tree interview",
    ]:
        require(task, needle, "task execution")

    tool_adoption = (root / "docs" / "01-development" / "tool-adoption.md").read_text(encoding="utf-8")
    for needle in [
        "Headroom",
        "SQL MCP Server",
        "Ponytail",
        "mattpocock/skills",
        "Upstream-first adoption 2.8.0",
        "cài upstream thật",
        "mattpocock-skills",
    ]:
        require(tool_adoption, needle, "tool adoption")

    compression = (root / "docs" / "01-development" / "context-compression.md").read_text(encoding="utf-8")
    for needle in [
        "headroom_compress",
        "headroom_retrieve",
        "MCP on-demand",
        "transparent proxy/wrap",
        "start-claude-headroom.ps1",
        "/stats",
    ]:
        require(compression, needle, "context compression")

    codebase = (root / "docs" / "01-development" / "codebase-intelligence.md").read_text(encoding="utf-8")
    for needle in [
        "Graph UI",
        "localhost:9749",
        "auto_index = false",
        "auto_watch",
        "watcher_enabled",
        "Profile ít tài nguyên",
    ]:
        require(codebase, needle, "codebase intelligence")

    sql = (root / "docs" / "01-development" / "sql-server-mcp.md").read_text(encoding="utf-8")
    for needle in [
        "Microsoft SQL MCP Server",
        "Data API builder",
        "MSSQL_CONNECTION_STRING",
        "least privilege",
        "create-record",
        "read-records",
        "delete-record",
        "-SkipSqlServerMcp",
    ]:
        require(sql, needle, "SQL MCP")

    setup = (root / "tools" / "setup-ai-dev-machine.ps1").read_text(encoding="utf-8")
    for needle in [
        "[switch]$SkipSqlServerMcp",
        "[switch]$SkipExternalAiStack",
        "Microsoft.DataApiBuilder --version 2.0.12",
        "headroom-ai[proxy,mcp]",
        "ponytail@ponytail",
        "mattpocock-skills",
        "Ensure-UserPathEntry",
        "Chưa cấu hình database/project",
    ]:
        require(setup, needle, "machine setup")

    manifest_paths = {item["path"] for item in manifest.get("managed_files", [])}
    required_managed = {
        "docs/01-development/context-compression.md",
        "docs/01-development/sql-server-mcp.md",
        ".claude/skills/tdd/SKILL.md",
        ".agents/skills/tdd/SKILL.md",
        ".claude/skills/resolve-merge-conflicts/SKILL.md",
        ".agents/skills/resolve-merge-conflicts/SKILL.md",
        ".claude/skills/domain-modeling/SKILL.md",
        ".agents/skills/domain-modeling/SKILL.md",
        "templates/mcp/claude-headroom.json",
        "templates/mcp/claude-sql-server-dab.json",
        "docs/01-development/codebase-intelligence.md",
        ".claude/skills/shape-task/SKILL.md",
        ".agents/skills/shape-task/SKILL.md",
    }
    missing = sorted(required_managed - manifest_paths)
    if missing:
        fail(f"manifest missing managed files: {missing}")

    for name in ["shape-task", "tdd", "resolve-merge-conflicts", "domain-modeling"]:
        claude = (root / ".claude" / "skills" / name / "SKILL.md").read_text(encoding="utf-8")
        generic = (root / ".agents" / "skills" / name / "SKILL.md").read_text(encoding="utf-8")
        if claude != generic:
            fail(f"Claude/generic skill differs: {name}")

    launcher = (root / "tools" / "start-claude-headroom.ps1").read_text(encoding="utf-8")
    for needle in ["headroom wrap claude", "--code-memory none", "--port", "/stats", "claude"]:
        require(launcher, needle, "Headroom launcher")

    headroom_template = json.loads((root / "templates" / "mcp" / "claude-headroom.json").read_text(encoding="utf-8"))
    if "headroom" not in headroom_template.get("mcpServers", {}):
        fail("Headroom MCP template missing server")

    sql_template = json.loads((root / "templates" / "mcp" / "claude-sql-server-dab.json").read_text(encoding="utf-8"))
    args = sql_template.get("mcpServers", {}).get("sql-server", {}).get("args", [])
    expected = ["start", "--mcp-stdio", "role:ai-readonly", "--config", "dab-config.json"]
    if args != expected:
        fail(f"SQL MCP template args differ: {args!r}")

    print("PASS: AI engineering stack 2.8.2 contract")


if __name__ == "__main__":
    main()
