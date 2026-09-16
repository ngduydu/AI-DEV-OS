# Upgrade AI-DEV-OS

Tài liệu này dùng khi một product repository đã copy AI-DEV-OS trước đó và cần nhận framework changes mới mà không làm mất project knowledge.

## Nguyên tắc

Không upgrade bằng cách copy đè toàn bộ `docs/`.

Project repository chứa hai loại tài sản:

- **Framework-owned**: execution contract, context policy, generic skills/agents, adapter files và framework templates.
- **Project-owned**: project context, product, architecture decision, CODEBASE-MAP đã bootstrap, business rules, coding convention thực tế, commands, testing, module/operations docs, ADR và custom skills.
- **Mixed**: file vừa chứa framework rule vừa có project customization; phải merge bằng diff/evidence.

Source code, tests và config hiện tại vẫn là ground truth.

## Version

Project đã áp dụng framework từ 2.2.0 trở đi có:

```text
.ai-dev-os/VERSION
```

Project chưa có file này được coi là **legacy / unversioned install**.

## Upgrade legacy / unversioned → 2.2.0

1. Không chạy bootstrap full lại nếu project knowledge hiện tại vẫn đáng tin cậy.
2. Giữ nguyên project-owned knowledge.
3. Cập nhật framework-owned files từ AI-DEV-OS 2.2.0.
4. Merge cẩn thận mixed files, đặc biệt coding standards hoặc custom skill.
5. Thêm:
   - `docs/ai/17-CONTEXT-RETRIEVAL.md`
   - `docs/ai/18-TOOL-ADOPTION.md`
   - skill `update-ai-dev-os`
6. Optional tool như codebase-memory-mcp, ast-grep hoặc Repomix **không tự cài/bật**.
7. Verify path/rule quan trọng.
8. Chỉ sau khi migration thành công mới tạo/cập nhật:
   ```text
   .ai-dev-os/VERSION = 2.2.0
   ```

## Ownership quick reference

| Nhóm | Ví dụ | Upgrade |
|---|---|---|
| Framework-owned | `CLAUDE.md`, task execution, context retrieval, generic skills/agents | Update có kiểm soát |
| Project-owned | project context, CODEBASE-MAP, business rules, commands/testing, module docs | Không overwrite |
| Mixed | `AGENTS.md`, coding standards, skill team đã customize | Merge + review |

## 2.2.0

### Framework changes

- Context Budget / retrieval escalation.
- Session hygiene: `/clear`, `/compact`, subagent isolation.
- Tool Adoption Gate.
- Optional mature-tool profiles: ripgrep, ast-grep, Repomix, codebase-memory-mcp.
- Framework version marker.
- Safe upgrade workflow.

### Existing projects cần làm gì?

Recommended:

- update Task Execution Contract;
- update bootstrap skill;
- add Context Retrieval + Tool Adoption docs;
- add `update-ai-dev-os` skill;
- add version marker sau khi verify.

Optional:

- pilot codebase-memory-mcp cho codebase lớn;
- dùng ast-grep khi structural search có lợi;
- dùng Repomix cho bootstrap/snapshot.

Không bắt buộc:

- cài MCP;
- bootstrap lại toàn repo;
- thay project knowledge bằng template mới.
