# Git Workflow

## Nguyên tắc

- Một task/feature độc lập nên có branch riêng.
- Một PR tập trung vào một mục tiêu chính.
- Không trộn refactor không liên quan vào feature/bug fix.
- Commit phải mô tả ý nghĩa thay đổi.
- Không rewrite lịch sử chung nếu không có lý do rõ ràng.

## Branch naming

```text
<member>/<task-name>
```

Hoặc convention thật của dự án: ...

## Commit

Khuyến nghị:

```text
feat: ...
fix: ...
refactor: ...
test: ...
docs: ...
```

## Pull Request phải nêu

- vấn đề;
- giải pháp;
- phạm vi;
- cách test;
- migration/risk nếu có;
- screenshot khi UI thay đổi đáng kể.

## Không merge khi

- test cần thiết chưa pass;
- chưa review;
- còn thay đổi ngoài scope chưa giải thích;
- migration/rollback chưa rõ với thay đổi rủi ro cao.
