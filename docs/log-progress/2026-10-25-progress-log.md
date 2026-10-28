# Progress Log — 2026-10-25

> Phase hiện tại: **Phase 0 — Nền tảng (tuần 1-2)**
> Tiến độ Phase 0: **~40%**
> Tiến độ tổng MVP1: **~4% (1/11 tuần)**

---

## Tổng quan

| Hạng mục | Trạng thái |
|---|---|
| Tài liệu yêu cầu & thiết kế | ✅ Hoàn thành |
| Docker Compose | ⚠️ Một phần (thiếu MinIO) |
| Spring Boot project | ✅ Có, cần verify build |
| Liquibase changelog | ❌ Chưa bắt đầu |
| Entity / API code | ❌ Chưa bắt đầu |

---

## Phase 0: Nền tảng — Chi tiết

### ✅ Đã hoàn thành

- [x] Tạo repo, thư mục `docs/`
- [x] Viết và review `docs/01-requirements.md` (9 UC, ràng buộc cứng, quy mô, SLO, tiêu chí nghiệm thu)
- [x] Viết `docs/cinema-booking-progress.md` (tổng hợp brainstorm: ERD, state machine, luồng đặt vé, thiết kế Redis key, quy ước Liquibase)
- [x] Viết `docs/cinema-booking-roadmap.md` (lộ trình 11 phase, MVP1 + MVP2)
- [x] Viết `docker-compose.yml` — Postgres 17-alpine, Redis 7-alpine, ghim version, healthcheck, volume, mật khẩu tách `.env`
- [x] Có `.env` và `.env.example`, `.gitignore` bao gồm `.env`
- [x] Tạo project Spring Boot (Maven, Java 21, Spring Boot 4.1.2)
- [x] Cấu hình `application.yaml`: datasource, `ddl-auto: validate`, Liquibase, Redis, HikariCP
- [x] File `db.changelog-master.yaml` tồn tại (chưa có changeset)

### ⚠️ Cần sửa / kiểm tra

- [ ] **Dependencies trong `pom.xml`**: `spring-boot-starter-liquibase` và các `*-test` starter có thể không đúng tên artifact. Cần chạy `./mvnw compile` để xác nhận
- [ ] **Port mismatch**: `.env` đặt `POSTGRES_PORT=5433`, nhưng `application.yaml` default là `5432`. App chạy ngoài Docker có thể không kết nối được nếu thiếu env var
- [ ] **Thiếu MinIO** trong `docker-compose.yml` (roadmap yêu cầu Postgres + Redis + MinIO)

### ❌ Chưa làm

- [ ] Cài và kiểm tra: `java -version`, `docker --version`
- [ ] Kiểm tra: `docker compose ps`, vào `psql`, `redis-cli ping`, mở giao diện web MinIO
- [ ] Kiểm tra volume: `docker compose down` rồi `up` (dữ liệu còn), `down -v` (dữ liệu mất)
- [ ] Đọc `pom.xml`, đối chiếu với các dependency đã chọn
- [ ] Hiểu lại ERD: với mỗi bảng, tự giải thích khóa chính, ràng buộc, index cần có
- [ ] **Tự viết changelog `001`** cho nhóm catalog (`app_user`, `movie`, `cinema`, `room`, `seat`)
- [ ] Chạy app, kiểm tra bảng bằng `\dt` và `\d tên_bảng`
- [ ] Làm endpoint `GET /movies` (entity, repository, controller)

---

## Phase 1–11: Chưa bắt đầu

| Phase | Tên | Trạng thái |
|---|---|---|
| 1 | Catalog: phim, rạp, suất chiếu | ❌ |
| 2 | Identity: đăng ký, đăng nhập, JWT | ❌ |
| 3 | Dữ liệu lớn và đo lường | ❌ |
| 4 | Booking core: giữ ghế, thanh toán, vé | ❌ |
| 5 | Tối ưu, nghiệm thu, tổng kết MVP1 | ❌ |
| 6–11 | MVP2 (scale, microservice, saga…) | ❌ |

---

## Tài liệu trong `docs/`

| File | Trạng thái | Ghi chú |
|---|---|---|
| `01-requirements.md` | ✅ Có | Đầy đủ, chất lượng tốt |
| `03-data-model.md` | ❌ Chưa có | Cần tự vẽ ERD và viết changelog |
| `04-api.md` | ❌ Chưa có | Phase 5 |
| `05-failure-modes.md` | ❌ Chưa có | Viết trước khi code Phase 4 |
| `adr/` | ❌ Chưa có | 3 ADR đầu tiên cần viết |
| `cinema-booking-progress.md` | ✅ Có | Tổng hợp brainstorm |
| `cinema-booking-roadmap.md` | ✅ Có | Lộ trình chi tiết |

---

## Cây thư mục hiện tại

```
cinema-booking/
├── .env / .env.example / .gitignore
├── docker-compose.yml          ← Postgres + Redis (thiếu MinIO)
├── pom.xml                     ← Spring Boot 4.1.2, Java 21
├── docs/
│   ├── 01-requirements.md      ← ✅
│   ├── cinema-booking-progress.md ← ✅
│   ├── cinema-booking-roadmap.md  ← ✅
│   └── log-progress/           ← 📝 file này
├── src/main/
│   ├── java/com/billy/cinema_booking/
│   │   └── CinemaBookingApplication.java  ← chỉ có main class
│   └── resources/
│       ├── application.yaml
│       └── db/changelog/
│           └── db.changelog-master.yaml   ← rỗng []
└── src/test/                   ← chưa có test nào
```

---

## Việc tiếp theo (ưu tiên)

1. Chạy `./mvnw compile` — xác nhận dependencies
2. `docker compose up -d` — kiểm tra Postgres, Redis
3. **Viết changelog `001`** — 5 bảng đầu tiên
4. Chạy app → kiểm tra bảng
5. Viết entity + `GET /movies`
6. Thêm MinIO vào docker-compose

---

*Ghi chú: Log này được tạo bằng review so sánh codebase thực tế với roadmap. Cập nhật log mới khi hoàn thành các milestone.*
