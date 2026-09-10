# Bắt đầu từ đây

Nếu đây là lần đầu bạn dùng AI-DEV-OS, **chỉ cần bắt đầu từ file này**.

Mục tiêu của onboarding là đưa một máy/project từ trạng thái chưa chuẩn bị gì tới trạng thái:

```text
Máy đủ công cụ
↓
Project có AI-DEV-OS core
↓
Claude đọc được project instructions
↓
Project knowledge được bootstrap/fill
↓
Bootstrap status: READY hoặc PARTIAL có scope rõ
↓
Có thể giao task thật
```

Không cần đọc toàn bộ repository trước khi bắt đầu. File này sẽ dẫn sang tài liệu chi tiết khi cần.

---

## 1. Bạn đang dùng Claude Code hay agent khác?

### Dùng Claude Code

Đi tiếp theo guide này. Khi cần chi tiết về Claude Code, xem:

```text
CLAUDE-CODE-GUIDE.md
```

### Dùng agent khác

AI-DEV-OS vẫn dùng được thông qua:

```text
AGENTS.md
.agents/skills/
docs/
```

Không copy `.claude/` nếu agent đó không dùng format của Claude Code.

---

## 2. Kiểm tra máy trước khi áp vào project

Với Windows + VS Code + Claude Code, kiểm tra theo thứ tự dưới đây.

### 2.1 Git

Mở PowerShell:

```powershell
git --version
```

Nếu có version:

```text
PASS → tiếp tục
```

Nếu báo không tìm thấy command, cài Git for Windows.

Có thể dùng WinGet:

```powershell
winget install --id Git.Git -e
```

Sau khi cài:

```text
đóng terminal
→ mở PowerShell mới
→ chạy lại git --version
```

Nếu vẫn lỗi, kiểm tra PATH hoặc restart Windows.

---

### 2.2 VS Code

Kiểm tra:

```powershell
code --version
```

Nếu command hoạt động, tiếp tục.

Nếu chưa cài VS Code:

```powershell
winget install --id Microsoft.VisualStudioCode -e
```

Hoặc cài từ trang chính thức của VS Code.

Nếu VS Code đã cài nhưng `code` chưa chạy trong terminal, vẫn có thể dùng giao diện VS Code bình thường; command này không phải blocker cho AI-DEV-OS.

---

### 2.3 Claude Code Extension

Trong VS Code:

```text
Ctrl + Shift + X
→ tìm "Claude Code"
→ chọn extension của Anthropic
→ Install
→ mở Claude panel
→ Sign in
```

Nếu chỉ dùng Claude Code qua VS Code Extension thì **đủ để bắt đầu**.

Tài khoản phải có Claude Code access phù hợp.

Chi tiết: `CLAUDE-CODE-GUIDE.md`.

---

### 2.4 Claude Code CLI — optional nhưng nên có khi dùng sâu

Kiểm tra:

```powershell
claude --version
```

Nếu có version:

```text
PASS
```

Nếu không có nhưng bạn chỉ dùng Extension:

```text
WARN → chưa phải blocker
```

Nếu muốn cài standalone CLI:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Hoặc stable channel:

```powershell
& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable
```

Kiểm tra lại:

```powershell
claude --version
claude doctor
```

---

### 2.5 GitHub CLI — optional

Kiểm tra:

```powershell
gh --version
```

Nếu chưa có, AI-DEV-OS vẫn hoạt động bình thường.

Nếu muốn Claude/Git workflow thao tác PR thuận tiện hơn:

```powershell
winget install --id GitHub.cli -e
```

Sau đó đăng nhập:

```powershell
gh auth login
```

---

## 3. Kiểm tra toolchain của chính project

AI-DEV-OS **không thay thế toolchain của project**.

Ví dụ repository có thể cần:

```text
.NET SDK
Node.js / npm / pnpm
Python
Java / Maven / Gradle
Docker
SQL tooling
```

Không cài "bản mới nhất" một cách ngẫu nhiên.

Trước tiên đọc evidence trong project:

```text
global.json
*.csproj / *.sln
package.json / lock file
.nvmrc
pyproject.toml / requirements.txt
pom.xml / build.gradle
Dockerfile / compose files
CI workflow
README hiện có
```

Rồi cài **đúng version project yêu cầu**.

Ví dụ:

```text
Project yêu cầu .NET 8
→ kiểm tra dotnet --version
→ thiếu thì cài .NET 8 SDK

Project có .nvmrc = 22
→ dùng Node 22
→ không tự cài Node latest khác version
```

Nếu chưa biết project cần tool nào, `bootstrap-project` phải phát hiện từ repository và báo `NOT VERIFIED`/`BLOCKED` thay vì đoán.

---

## 4. Xác định loại project

Chọn một trong hai nhánh.

### A. Project đã có code

Ví dụ:

```text
src/
tests/
*.sln
package.json
README.md
...
```

Đi theo bước 5 → 6 → 7 → 8.

### B. Project mới gần như trống

Không để AI tự bịa product/architecture chỉ để lấp template.

Trước khi code, cần chốt tối thiểu:

```text
Project này làm gì?
Ai sử dụng?
MVP cần behavior nào?
Stack nào đã được quyết định?
Architecture/boundary nào đã quyết định?
Convention nào đã chốt?
```

Điền những gì đã biết chắc vào:

```text
docs/ai/01-PROJECT-CONTEXT.md
docs/ai/02-PRODUCT.md
docs/ai/03-ARCHITECTURE.md
docs/ai/06-CODING-STANDARDS.md
```

Phần chưa biết quan trọng thì Claude phải hỏi; phần chưa cần thì để thiếu.

Sau khi project skeleton hình thành, `bootstrap-project` sẽ tiếp tục fill codebase map, commands, testing và canonical examples.

---

## 5. Copy AI-DEV-OS vào project

### Nếu dùng Claude Code

Copy **core bắt buộc** sau vào root repository sản phẩm:

```text
AGENTS.md
CLAUDE.md
docs/
.claude/skills/
.claude/agents/
```

Nếu muốn giữ compatibility với agent khác, copy thêm:

```text
.agents/skills/
```

### Ví dụ cấu trúc sau khi copy

```text
MyProduct/
├── .git/
├── AGENTS.md
├── CLAUDE.md
├── .claude/
│   ├── skills/
│   └── agents/
├── .agents/                  # optional nếu cần generic agents
├── docs/
├── src/
└── tests/
```

### Không copy các file quản trị của chính AI-DEV-OS vào product repo

Thông thường **không cần**:

```text
LICENSE
CONTRIBUTING.md
CHANGELOG.md của AI-DEV-OS
SECURITY.md của public template
FILE-INDEX.md
.github/ISSUE_TEMPLATE/
prompts/
templates/
START-HERE.md
CLAUDE-CODE-GUIDE.md
```

Các file trên phục vụ repository AI-DEV-OS hoặc người vận hành framework, không phải project runtime knowledge.

`APPLY-TO-PROJECT.md` có giải thích chi tiết hơn về phần copy/bootstrap.

---

## 6. Verify cấu trúc trước khi giao Claude làm việc

Mở **root repository**, không mở riêng `src/` hay một thư mục con.

Ví dụ:

```text
D:\Projects\MyProduct
```

Tại root phải nhìn thấy tối thiểu:

```text
.git/
AGENTS.md
CLAUDE.md
docs/
.claude/
```

Nếu `.git/` không tồn tại vì đây là project mới:

```powershell
git init
```

Sau đó mở root bằng VS Code.

---

## 7. Kiểm tra Claude có nhận project instructions không

Mở Claude Code trong VS Code và chạy:

```text
/context
```

Kiểm tra `CLAUDE.md` có xuất hiện trong project memory/context hay không.

### Có

```text
PASS → tiếp tục bootstrap
```

### Không

```text
STOP
```

Kiểm tra lại:

```text
1. VS Code có đang mở đúng repo root không?
2. CLAUDE.md có nằm ở repo root không?
3. CLAUDE.md có import AGENTS.md đúng không?
4. Reload VS Code / Claude session nếu cần.
```

Không giao task thật nếu project instructions chưa được load.

---

## 8. Chạy bootstrap-project

### Project đã có code

Trong Claude Code:

```text
/bootstrap-project
```

Nếu skill chưa hiện thành slash command, giao trực tiếp:

```text
Bootstrap project này theo skill bootstrap-project.
Tự scan docs, code, tests, config, tooling và CI.
Fill project knowledge từ evidence thật.
Tìm canonical examples và reusable building blocks.
Chỉ hỏi tôi những UNKNOWN quan trọng không thể xác định an toàn từ repository.
Kết thúc bằng READY / PARTIAL / BLOCKED và nêu evidence.
```

Claude phải tự tìm:

```text
project purpose
stack
architecture
module boundaries
coding conventions
build/run/test/lint commands
canonical examples
reusable building blocks
business rules đã có evidence
security/operations artifacts
material UNKNOWN/conflict
```

Không bắt người dùng tự chép lại những gì repository đã chứng minh được.

---

## 9. Xử lý kết quả bootstrap

### READY

```text
Project đủ context để bắt đầu giao task.
```

Đi tiếp bước 10.

### PARTIAL

Claude phải nói rõ:

```text
Area nào làm được an toàn
Area nào còn thiếu knowledge/tooling
Cần cài/thêm/trả lời gì
```

Ví dụ:

```text
Bootstrap status: PARTIAL

PASS:
- project structure
- coding convention
- build command

WARN:
- integration tests chưa chạy vì Docker chưa được cài

Safe scope:
- application logic

Blocked scope:
- integration changes phụ thuộc Docker
```

Không coi `PARTIAL` là thất bại; chỉ không làm task vượt ra ngoài safe scope.

### BLOCKED

Không code tiếp.

Claude phải báo blocker cụ thể và cách giải quyết nếu xác định được.

Ví dụ:

```text
BLOCKED: .NET SDK 8 không tồn tại trên máy
Evidence: global.json yêu cầu 8.0.x; dotnet --list-sdks không có 8.0
Next: cài .NET 8 SDK rồi chạy bootstrap verification lại
```

Sau khi xử lý blocker, chạy lại phần bootstrap/verification liên quan.

---

## 10. Commit bootstrap knowledge trước task đầu tiên

Sau khi docs đã được fill/review:

```text
review diff
↓
resolve material UNKNOWN
↓
commit bootstrap knowledge
```

Không để bootstrap changes lẫn với feature đầu tiên nếu có thể tránh.

Ví dụ commit:

```text
docs: bootstrap project knowledge
```

---

## 11. Giao task đầu tiên

Từ đây không cần prompt dài.

Ví dụ:

```text
Sửa lỗi khi hủy hợp đồng nhưng máy chưa chuyển về Available.
```

Hoặc:

```text
Thêm chức năng nhập chỉ số máy hàng tháng.
```

Claude phải tự đi theo:

```text
CLAUDE.md
↓
AGENTS.md
↓
docs/README.md
↓
relevant docs/code/tests
↓
Understand
↓
Reuse
↓
Implement
↓
Verify
↓
Review
↓
Knowledge Sync
↓
Production Gate
↓
Report
```

Cách dùng hằng ngày chi tiết: `USAGE.md`.

---

## 12. Workflow Git khuyến nghị ngay từ task đầu tiên

Không làm trực tiếp trên `main`.

```text
main
↓
tạo branch task
↓
Claude làm việc
↓
verify
↓
review diff
↓
commit
↓
PR
↓
CI
↓
human review
↓
merge
```

Nguyên tắc:

```text
1 task = 1 branch
1 PR = 1 task
```

Task vừa/lớn: dùng Plan mode trước khi implement.

Chi tiết Claude workflow: `CLAUDE-CODE-GUIDE.md`.

---

## 13. Nếu thiếu thứ gì trong lúc làm thì xử lý thế nào?

Không cài package/tool ngẫu nhiên chỉ vì Claude đề xuất.

Flow chuẩn:

```text
Task cần tool/dependency
↓
Search project config/docs/CI trước
↓
Project đã định version/tool chưa?
├── Có → dùng đúng cái đó
└── Không → đánh giá đây là dependency/project decision hay chỉ local tool
↓
Có thể thay bằng building block hiện tại không?
├── Có → reuse
└── Không → mới xem xét cài/thêm
```

Claude phải nêu:

```text
Thiếu gì
Evidence nào chứng minh cần
Version nào phù hợp
Cài ở máy hay thêm vào project
Ảnh hưởng CI/team/deploy không
Cách verify sau khi cài
```

Ví dụ tốt:

```text
Thiếu: .NET 8 SDK
Evidence: global.json yêu cầu 8.0.4xx
Scope: local development tool
Install: .NET 8 SDK
Verify: dotnet --list-sdks + dotnet build
```

Ví dụ không tốt:

```text
Thiếu tool → cài latest luôn
```

---

## 14. Checklist hoàn tất onboarding

Trước khi gọi setup đủ dùng:

```text
[ ] Git hoạt động
[ ] VS Code mở đúng repo root
[ ] Claude Code Extension đã cài và sign in
[ ] Claude CLI nếu cần đã hoạt động
[ ] Project-specific toolchain đúng version đã có hoặc blocker đã được ghi rõ
[ ] AGENTS.md ở repo root
[ ] CLAUDE.md ở repo root
[ ] docs/ tồn tại
[ ] .claude/skills/ tồn tại
[ ] .claude/agents/ tồn tại nếu dùng independent review
[ ] /context thấy CLAUDE.md
[ ] bootstrap-project đã chạy
[ ] Material UNKNOWN đã resolve hoặc scope còn lại được ghi rõ
[ ] Build/test/verification commands có evidence
[ ] Bootstrap status READY hoặc PARTIAL với safe scope rõ
[ ] Bootstrap knowledge đã được review/commit
[ ] Git branch/PR workflow đã sẵn sàng
```

Nếu một mục bắt buộc fail, không bỏ qua chỉ để bắt đầu code nhanh hơn.

---

## 15. Sau khi onboarding xong đọc gì?

Không cần đọc tất cả.

```text
START-HERE.md
    ↓ onboarding xong
USAGE.md
    ↓ cần dùng Claude sâu hơn
CLAUDE-CODE-GUIDE.md
```

Các tài liệu còn lại chủ yếu dành cho agent và tra cứu khi cần:

```text
APPLY-TO-PROJECT.md
→ chi tiết cách bê framework vào project

docs/README.md
→ router project knowledge

docs/ai/16-TASK-EXECUTION.md
→ execution contract
```

Từ đây, mỗi task bình thường chỉ cần mô tả yêu cầu. Không cần nhắc Claude đọc từng file.