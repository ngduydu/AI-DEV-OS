# Hướng dẫn dùng Claude Code với AI-DEV-OS

Tài liệu này dành cho người chưa có nhiều kinh nghiệm với Claude Code nhưng muốn dùng theo cách làm bài bản ngay từ đầu.

Mục tiêu:

```text
Cài đúng
→ mở đúng project
→ để Claude đọc đúng context
→ bootstrap một lần
→ giao task bình thường
→ review evidence + diff
→ merge theo Git workflow
```

Guide này ưu tiên cách dùng thực tế trên Windows + VS Code, nhưng các nguyên tắc chính áp dụng cho mọi hệ điều hành.

## 1. Claude Code là gì?

Claude Code là coding agent của Anthropic. Nó không chỉ chat mà có thể đọc repository, search code, sửa file, chạy command, test/build/lint, dùng Git, tạo plan, dùng skills/subagents và làm nhiều bước liên tiếp trong một task.

Vì nó có khả năng thay đổi project thật, cách dùng nên dựa trên repository rules + verification + human review, không phải chỉ prompt dài trong chat.

AI-DEV-OS được thiết kế để cung cấp phần đó.

## 2. Setup khuyến nghị

Với developer làm việc chủ yếu bằng VS Code trên Windows:

```text
Windows native
│
├── Git for Windows
├── VS Code
├── Claude Code Extension      ← giao diện chính hằng ngày
├── Claude Code CLI            ← nên cài thêm khi bắt đầu dùng sâu
├── GitHub CLI (gh)            ← optional nhưng rất hữu ích
│
└── Project
    ├── CLAUDE.md
    ├── AGENTS.md
    ├── .claude/
    ├── docs/
    ├── src/
    └── tests/
```

Khuyến nghị thực tế:

- Extension: dùng chính để chat, xem diff, Plan mode và review trực quan.
- CLI: dùng cho terminal workflow, diagnostics, automation, worktree, nhiều session hoặc thao tác nhanh.
- Git + PR: luôn là lớp kiểm soát cuối.

Không cần WSL nếu project/tooling chạy native Windows như .NET, SQL Server, Visual Studio/VS Code. Chỉ ưu tiên WSL khi project dùng Linux toolchain hoặc cần sandboxing Linux.

## 3. Yêu cầu trước khi cài

Cần:

- VS Code bản đang được Claude Code hỗ trợ;
- tài khoản Claude trả phí có Claude Code access: Pro, Max, Team, Enterprise hoặc Console;
- Git nên được cài sẵn.

Kiểm tra Git:

```powershell
git --version
```

## 4. Cài Claude Code Extension trong VS Code

Trong VS Code:

```text
Extensions
→ tìm "Claude Code"
→ chọn extension của Anthropic
→ Install
```

Hoặc nhấn:

```text
Ctrl + Shift + X
```

Sau khi cài:

1. Mở một file trong project.
2. Bấm biểu tượng Claude/Spark.
3. Chọn `Sign in`.
4. Đăng nhập bằng tài khoản Claude của bạn.

Extension là cách dùng phù hợp khi làm việc trực tiếp trong VS Code vì có diff view, Plan mode, @file và nhiều conversation.

### Extension có đủ để bắt đầu không?

Có.

Bạn có thể bắt đầu dùng AI-DEV-OS chỉ với extension.

Nếu muốn tự gõ:

```powershell
claude
```

trong terminal thì cài standalone CLI riêng.

## 5. Cài standalone Claude Code CLI trên Windows

Mở PowerShell:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Nếu muốn ưu tiên release ổn định hơn:

```powershell
& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable
```

Hoặc dùng WinGet:

```powershell
winget install Anthropic.ClaudeCode
```

Kiểm tra sau cài:

```powershell
claude --version
claude doctor
```

Đăng nhập CLI:

```powershell
claude
```

và hoàn tất đăng nhập trên trình duyệt.

## 6. Extension hay CLI?

Không cần chọn một trong hai.

| Tình huống | Dùng |
|---|---|
| Code/review hằng ngày | VS Code Extension |
| Xem diff trực quan | VS Code Extension |
| Plan mode | VS Code Extension |
| Chạy command nhanh | CLI hoặc terminal VS Code |
| Diagnostics | CLI (`claude doctor`) |
| Automation | CLI |
| Git worktree / parallel workflow | CLI + Git |
| Nhiều session | Extension tabs hoặc CLI/worktrees |

Với người mới, bắt đầu bằng extension. Khi đã quen workflow, cài thêm CLI.

## 7. Cách mở một project đúng

Mở root repository, không chỉ mở một thư mục con.

Ví dụ:

```text
D:\Projects\PhotocopyRental
```

Root nên chứa:

```text
CLAUDE.md
AGENTS.md
docs/
.claude/
.git/
```

CLI tương đương:

```powershell
cd D:\Projects\PhotocopyRental
claude
```

## 8. Claude đọc AI-DEV-OS như thế nào?

```text
CLAUDE.md
↓
@AGENTS.md
↓
docs/README.md
↓
Task Execution Contract
↓
relevant docs/code/tests
```

`CLAUDE.md` cố tình cực ngắn để không làm đầy context. Knowledge chi tiết nằm trong `docs/`, và Claude chỉ load phần liên quan đến task.

Kiểm tra context trong Claude Code:

```text
/context
```

Kiểm tra `CLAUDE.md` xuất hiện trong memory/context files. Nếu Claude không thấy project instructions, dừng task và sửa setup trước.

## 9. Lần đầu áp AI-DEV-OS vào project đã có code

Sau khi copy core vào repository:

```text
CLAUDE.md
AGENTS.md
docs/
.claude/skills/
.claude/agents/
```

mở Claude Code và chạy:

```text
/bootstrap-project
```

Nếu command chưa hiện, nói trực tiếp:

```text
Bootstrap project này theo skill bootstrap-project.
Tự scan code, tests, config, CI và conventions.
Chỉ hỏi tôi những UNKNOWN quan trọng không thể xác định an toàn từ repository.
```

Claude phải:

```text
scan repository
→ detect architecture/stack
→ detect conventions
→ detect commands/tests
→ find canonical examples
→ find reusable building blocks
→ fill project docs
→ report UNKNOWN/conflict
→ READY / PARTIAL / BLOCKED
```

Không chạy bootstrap mỗi task.

## 10. Khi nào project được coi là sẵn sàng?

Mục tiêu là:

```text
Bootstrap status: READY
```

Không phải vì mọi file docs đã đầy, mà vì Claude xác định được đáng tin cậy project purpose, architecture/stack, code/module location, convention, canonical implementation, reusable building blocks, build/test/lint commands và material UNKNOWN còn lại.

Nếu là `PARTIAL`, chỉ làm task trong area đã đủ knowledge. Nếu `BLOCKED`, giải quyết blocker trước khi giao feature lớn.

## 11. Từ task thứ hai trở đi giao như thế nào?

Sau khi bootstrap tốt, không cần prompt nghi lễ.

Ví dụ:

```text
Sửa lỗi khi hủy hợp đồng nhưng máy chưa chuyển về Available.
```

Claude phải tự:

```text
Load context
→ inspect code/tests
→ Understanding Gate
→ Reuse Gate
→ Dependency Gate
→ plan nếu cần
→ implement
→ verify
→ cleanup
→ review
→ Knowledge Sync
→ Production Gate
→ report
```

## 12. Khi nào dùng Plan mode?

Nên dùng Plan mode khi:

- task chạm nhiều file/module;
- behavior chưa rõ hoàn toàn;
- bạn chưa quen area code đó;
- có database migration;
- auth/security/payment;
- thay đổi public API;
- refactor lớn;
- feature có nhiều bước.

Flow:

```text
Explore
↓
Plan
↓
Bạn review/chỉnh plan
↓
Approve
↓
Implement
↓
Verify
```

Không cần Plan mode cho typo, đổi text nhỏ, validation rất rõ hoặc task cực cục bộ.

## 13. Permission mode nên dùng thế nào?

Khi mới dùng, ưu tiên `Manual` hoặc `Plan`.

### Manual

Claude hỏi trước khi sửa file hoặc chạy nhiều command. Dùng khi mới làm quen, codebase quan trọng, task risky hoặc chưa tin setup.

### Plan

Claude research và lập plan trước khi sửa. Dùng cho task vừa/lớn.

### Auto/Edit automatically

Chỉ nên dùng khi task rõ, branch riêng, verification tốt, project rules đã bootstrap và bạn sẵn sàng review diff sau đó.

Không dùng chế độ tự động để bỏ qua review/CI.

## 14. Workflow khuyến nghị cho một task

Task nhỏ:

```text
Tạo branch
↓
Giao task
↓
Claude inspect + sửa
↓
Claude chạy verification
↓
Review diff
↓
Commit / PR
```

Task vừa/lớn:

```text
Tạo branch
↓
Plan mode
↓
Claude explore
↓
Review plan
↓
Approve
↓
Implement
↓
Tests/build/lint
↓
change-reviewer
↓
production-reviewer nếu liên quan
↓
Review diff
↓
PR
↓
CI
↓
Human review
↓
Merge
```

## 15. Git workflow

Khuyến nghị:

```text
1 task = 1 branch
1 PR = 1 task
không push trực tiếp main
không merge khi chưa review
```

Claude có thể hỗ trợ commit và mở PR, nhưng human vẫn kiểm tra diff và quyết định merge.

GitHub CLI là optional nhưng hữu ích:

```powershell
gh --version
```

## 16. Nhiều Claude session có nên dùng không?

Có, nhưng chỉ khi các task độc lập.

Ví dụ:

```text
Session A → implement feature Customer
Session B → research Billing
Session C → review một change đã xong
```

Không cho hai session cùng sửa cùng một working tree nếu có khả năng đụng file.

Khi chạy song song thật sự, dùng Git worktree để mỗi session có branch và working directory riêng.

## 17. Skills dùng như nào?

AI-DEV-OS có skills trong:

```text
.claude/skills/
```

Ví dụ:

```text
bootstrap-project
fix-bug
plan-change
implement-plan
review-change
verify-change
update-project-knowledge
```

Claude có thể tự chọn skill khi description phù hợp. Bạn cũng có thể gọi trực tiếp skill nếu muốn ép workflow cụ thể.

Không tạo skill cho mọi việc nhỏ. Skill dành cho workflow/domain knowledge có khả năng lặp lại.

## 18. Subagents dùng khi nào?

AI-DEV-OS hiện có:

```text
.claude/agents/change-reviewer.md
.claude/agents/production-reviewer.md
```

Dùng khi feature vừa/lớn, code risky, migration, auth/security hoặc cần reviewer độc lập. Không spawn reviewer cho typo/chỉnh text nhỏ.

## 19. Quản lý context

Khuyến nghị:

- một task độc lập → ưu tiên một session riêng;
- không kéo chat cũ sang task không liên quan;
- dùng `/context` để xem context;
- dùng `/compact` khi session dài nhưng vẫn cần tiếp tục;
- mở session mới nếu task mới không cần history cũ;
- dùng subagent cho investigation lớn để không làm bẩn main context.

Không yêu cầu Claude đọc toàn bộ `docs/` cho mọi task.

## 20. Verification là bắt buộc

Claude phải có cách kiểm tra kết quả của chính nó: unit test, integration test, build, lint, static analysis, migration validation hoặc UI check tùy task.

Rule:

```text
Không chạy → không nói pass.
```

Nếu không chạy được:

```text
NOT VERIFIED: <check>
Reason: <reason>
Impact: <risk>
```

## 21. Hooks nên dùng khi nào?

Không cần setup hooks ngay ngày đầu.

Sau khi dùng project thật và thấy một rule cần luôn luôn xảy ra, chuyển rule đó thành hook/tool enforcement.

Ví dụ:

```text
Sau edit → chạy formatter
Trước stop → chạy test bắt buộc
Block sửa generated folder
Block command production nguy hiểm
```

Nguyên tắc:

```text
CLAUDE.md/docs → hướng dẫn
Hooks/tools/CI → enforce
```

## 22. Những việc không nên để Claude tự quyết hoàn toàn

Luôn có human gate với production deploy, destructive database operation, xóa dữ liệu, secret rotation, permission/auth thay đổi quan trọng, breaking API change, migration khó rollback, merge vào protected main và quyết định business chưa rõ.

Claude có thể chuẩn bị, phân tích và đề xuất. Human quyết định hành động irreversible/risky.

## 23. Setup khuyến nghị cho team chuyên nghiệp

Mức tối thiểu:

```text
VS Code + Claude Code Extension
Git
AI-DEV-OS
Branch + PR
Tests/build/lint
Human review
```

Mức nên hướng tới:

```text
VS Code Extension
+ Claude Code CLI
+ GitHub CLI
+ AI-DEV-OS
+ project conventions
+ canonical examples
+ skills/subagents
+ formatter/linter/analyzers
+ test suite
+ hooks cho deterministic rules
+ CI
+ branch protection
+ human review
```

Model mạnh chỉ là một thành phần; workflow và enforcement mới quyết định độ tin cậy.

## 24. Workflow sử dụng hằng ngày đề xuất

```text
Mở VS Code tại repo root
↓
Tạo/chuyển branch task
↓
Mở Claude Code
↓
Task nhỏ?
├── Có → giao trực tiếp
└── Không → Plan mode
↓
Claude tự load AI-DEV-OS context
↓
Implement + verify
↓
Review final report
↓
Review diff
↓
Commit / PR
↓
CI
↓
Human review
↓
Merge
```

## 25. Troubleshooting nhanh

### Không thấy Claude Code extension

- update VS Code;
- reload window;
- kiểm tra extension đúng của Anthropic.

### Gõ `claude` nhưng báo không tìm thấy command

Extension không đồng nghĩa standalone CLI đã được cài. Cài CLI rồi mở terminal mới.

### CLI có vấn đề

```powershell
claude doctor
```

### Claude không tuân project docs

Chạy:

```text
/context
```

Kiểm tra:

```text
CLAUDE.md
→ AGENTS.md
→ docs/README.md
→ relevant project knowledge
```

### Claude liên tục hỏi cùng một câu

Không tiếp tục trả lời bằng chat mãi. Đưa câu trả lời bền vững vào đúng project docs/module docs.

## 26. Checklist cài đặt cho project đầu tiên

```text
[ ] Git hoạt động
[ ] VS Code hoạt động
[ ] Claude Code Extension đã cài
[ ] Đã Sign in
[ ] Repo được mở tại root
[ ] AI-DEV-OS đã copy vào repo
[ ] CLAUDE.md import AGENTS.md
[ ] /context thấy CLAUDE.md
[ ] bootstrap-project đã chạy
[ ] Bootstrap status READY hoặc PARTIAL có scope rõ
[ ] Build/test commands đã xác định
[ ] Branch/PR workflow đã sẵn sàng
```

CLI có thể cài ngay hoặc sau:

```text
[ ] Claude Code standalone CLI
[ ] claude --version
[ ] claude doctor
[ ] GitHub CLI nếu cần
```

## 27. Cách dùng ngắn nhất

Lần đầu:

```text
Cài Claude Code Extension
↓
Mở repo
↓
Copy AI-DEV-OS
↓
/context
↓
/bootstrap-project
↓
resolve material UNKNOWN
↓
READY
```

Mỗi ngày:

```text
Tạo branch
↓
Giao task
↓
Plan nếu cần
↓
Claude làm + verify
↓
Review diff/evidence
↓
PR
↓
CI + human review
↓
Merge
```

## Tài liệu tham khảo chính thức

- VS Code integration: https://code.claude.com/docs/en/ide-integrations
- Setup / CLI / Windows: https://code.claude.com/docs/en/setup
- Best practices: https://code.claude.com/docs/en/best-practices
- Project memory / CLAUDE.md: https://code.claude.com/docs/en/memory
- Permission modes: https://code.claude.com/docs/en/permission-modes
- Skills: https://code.claude.com/docs/en/skills
- Subagents: https://code.claude.com/docs/en/sub-agents
- Hooks: https://code.claude.com/docs/en/hooks

Nếu Claude Code thay đổi UI/command theo phiên bản mới, ưu tiên tài liệu Anthropic ở trên làm nguồn cập nhật.
