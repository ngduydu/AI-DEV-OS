# Generated Skills Mirror

Thư mục này là **bản mirror tự động** của `.claude/skills/`.

Không sửa trực tiếp các file:

```text
.agents/skills/<skill>/SKILL.md
```

Khi cần thêm, sửa hoặc xóa một skill:

1. Thay đổi nguồn tại `.claude/skills/<skill>/SKILL.md`.
2. Chạy một trong hai script từ repository root:

Bash:

```bash
bash scripts/sync-skills.sh
```

PowerShell:

```powershell
./scripts/sync-skills.ps1
```

3. Commit cả thay đổi nguồn và mirror được sinh lại.

CI sẽ kiểm tra `.agents/skills/` luôn khớp với `.claude/skills/`.
