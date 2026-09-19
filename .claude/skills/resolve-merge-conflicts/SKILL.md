---
name: resolve-merge-conflicts
description: Resolve an in-progress Git merge or rebase conflict by intent, hunk by hunk, without discarding either side blindly. Use when the user explicitly asks to resolve merge/rebase conflicts.
disable-model-invocation: true
---

# Resolve Merge Conflicts

Mục tiêu: giải conflict theo **intent của hai phía**, không chọn `ours` / `theirs` hàng loạt.

## Preflight

1. Xác nhận đang ở merge/rebase conflict thật.
2. Đọc `git status`.
3. Liệt kê file conflict.
4. Không chạy reset/abort/checkout wholesale trừ khi user yêu cầu rõ.

## Mỗi conflict

Với từng hunk:

1. xác định base/ours/theirs;
2. truy nguồn intent từ task/spec/docs/test/source;
3. phân loại:
   - hai thay đổi độc lập → giữ cả hai;
   - cùng canonical truth → reconcile semantics;
   - một phía stale → giữ phía còn đúng và nêu evidence;
   - không đủ evidence → dừng hunk đó và hỏi.
4. xóa marker conflict;
5. không format/refactor ngoài scope chỉ vì đang sửa conflict.

Không dùng `--ours` / `--theirs` cho cả file nếu chưa chứng minh toàn file thuộc một phía.

## AI-DEV-OS knowledge conflict

Task-generated knowledge mới nên nằm ở entry-per-file nên thường không conflict.

Nếu conflict xảy ra ở shared canonical docs, coi đó là conflict có ý nghĩa:

- architecture;
- project-wide rule;
- canonical workflow;
- shared configuration.

Không né bằng cách duplicate hai phiên bản truth.

## Verify

```text
git diff --check
→ search conflict markers
→ focused tests
→ broader tests nếu impact đáng kể
→ git status
```

Không báo xong nếu vẫn còn unmerged path hoặc marker.

## Report

Nêu ngắn:

- file đã resolve;
- intent nào được giữ/kết hợp;
- verification;
- conflict nào còn cần human decision.
