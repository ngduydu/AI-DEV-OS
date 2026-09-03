# Release Checklist — <Version>

## Before release

- [ ] CI xanh.
- [ ] Acceptance Criteria của release đã đạt.
- [ ] Migration được review.
- [ ] Backup/restore requirement đã xem xét.
- [ ] Config/secret production đã sẵn sàng.
- [ ] Security-sensitive changes đã review.
- [ ] Monitoring/logging đủ để phát hiện lỗi.
- [ ] Rollback plan rõ.

## Deploy

- [ ] Deploy theo runbook.
- [ ] Migration thành công.
- [ ] Health check pass.

## Smoke test

- [ ] Critical flow 1.
- [ ] Critical flow 2.

## Observe

- [ ] Error rate.
- [ ] Latency.
- [ ] Background jobs.
- [ ] Business-critical metric.

## Close

- [ ] Changelog/version.
- [ ] Incident/issue nếu phát sinh.
