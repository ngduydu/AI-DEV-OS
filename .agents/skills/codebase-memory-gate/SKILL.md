---
name: codebase-memory-gate
description: Mandatory structural codebase discovery before any code task. Use codebase-memory-mcp to check MCP connectivity/coverage and query symbols, architecture, relationships, or impact before source search/read. Let the configured auto-index/auto-watch prepare the graph in the normal workflow.
---

# Codebase Memory Gate

Áp dụng cho mọi task có đọc hoặc sửa code.

## Contract

1. Xác định absolute repository root.
2. Kiểm tra `codebase-memory-mcp` đã Connected.
3. Kiểm tra MCP đã Connected và cơ chế auto-index/auto-watch đang sẵn sàng; graph coverage sẽ được tự chuẩn bị trong workflow bình thường.
4. Nếu graph chưa sẵn sàng, chờ/kiểm tra auto-index; chỉ dùng `index_repository` thủ công khi troubleshooting, recovery hoặc force refresh.
5. Query graph phù hợp với task, tối thiểu một query trước khi dùng `rg`/`ast-grep` để lần theo code.
6. Dùng graph để định vị area/symbol/file/relationship/impact.
7. Đọc source và test thật để xác minh graph evidence.
8. Nếu MCP/index/coverage không usable: **BLOCKED**. Không âm thầm fallback để bỏ qua gate.

## Query routing

- symbol/class/function/module → `search_graph`
- caller/callee → `trace_path`
- architecture/area → `get_architecture`
- known file declarations → `get_file_outline`
- current diff impact → `detect_changes`
- multi-hop relationship → `query_graph`

Graph không phải source of truth. Không kết luận behavior chỉ từ graph.

## Completion evidence

Report phải có:

```text
Codebase Memory:
- Indexed: PASS
- Query: <tool/query>
- Discovered: <area/symbols/relationships>
```

Task chưa có evidence này thì chưa qua Codebase Memory Gate.
