---
name: codebase-memory-gate
description: Mandatory structural codebase discovery before any code task. Use codebase-memory-mcp to index/check coverage and query symbols, architecture, relationships, or impact before source search/read.
---

# Codebase Memory Gate

Áp dụng cho mọi task có đọc hoặc sửa code.

## Contract

1. Xác định absolute repository root.
2. Kiểm tra `codebase-memory-mcp` đã Connected.
3. Kiểm tra project đã được index và graph có coverage.
4. Nếu chưa index, gọi `index_repository` rồi kiểm tra trạng thái.
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
