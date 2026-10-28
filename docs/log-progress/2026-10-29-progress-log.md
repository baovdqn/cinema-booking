# Progress Log / Changelog — 2026-10-29

> Phase hiện tại: **Phase 0 — Nền tảng (tuần 1-2)**  
> Tiến độ Phase 0: **~90%** (Tăng mạnh từ ~40% ngày 25.10)  
> Tiến độ tổng MVP1: **~9% (1/11 tuần)**  

---

## 1. Tổng quan công việc hoàn thành trong đợt này

| Hạng mục | Trạng thái | Chi tiết |
|---|:---:|---|
| **Data Model (`03-data-model.md`)** | ✅ Hoàn thành | Thiết kế chi tiết 5 bảng catalog, chuẩn hóa quy ước naming constraint (`chk_`, `fk_`, `uq_`, `idx_`, `pk_`), phân tích tuple alignment |
| **Liquibase Changelog 001** | ✅ Hoàn thành | Tự viết `001-user-catalog-tables.sql` (formatted SQL), include vào `db.changelog-master.yaml` |
| **Fix Config DataSource** | ✅ Hoàn thành | Cập nhật `application.yaml` có fallback `POSTGRES_PORT:5433`, user `cinema`, password `cinema123` khớp với Docker |
| **Maven Build Verification** | ✅ Hoàn thành | `./mvnw compile` thành công (`BUILD SUCCESS`), kiểm tra dependencies hợp lệ |
| **Chạy Migration Liquibase** | ✅ Hoàn thành | Kích hoạt migration tự động, tạo thành công 5 bảng trong PostgreSQL thật |
| **Kiểm chứng CSDL (psql)** | ✅ Hoàn thành | Xác nhận cấu trúc bảng, PK, FK, CHECK constraint (`chk_seat_type`, `chk_movie_duration`...), Unique index |
| **Roadmap Checklist** | ✅ Hoàn thành | Đánh dấu tick `[x]` hoàn thành các mục changelog và kiểm tra DB trong `cinema-booking-roadmap.md` |

---

## 2. Chi tiết các thay đổi trong codebase

### 2.1. Tài liệu kiến trúc & CSDL
- **Tạo mới `docs/03-data-model.md`**:
  - Đặc tả chi tiết từng cột, kiểu dữ liệu, ràng buộc cho nhóm Catalog: `app_user`, `movie`, `cinema`, `room`, `seat`.
  - Bổ sung định nghĩa và ý nghĩa của tiền tố ràng buộc:
    - `chk_`: **CHECK constraint** (kiểm tra tính hợp lệ dữ liệu trực tiếp trong DB).
    - `pk_`: Khóa chính.
    - `fk_`: Khóa ngoại.
    - `uq_`: Ràng buộc duy nhất.
    - `idx_`: Chỉ mục tìm kiếm.
  - Phân tích tuple alignment (`INT` 4 bytes vs `BIGINT` 8 bytes cho `seat.id`).

### 2.2. Liquibase Migration
- **Tạo file `src/main/resources/db/changelog/001-user-catalog-tables.sql`**:
  - `001-01-create-app-user`: Bảng người dùng, index `uq_app_user_email` không phân biệt hoa thường (`LOWER(email)`), check role.
  - `001-02-create-movie`: Bảng phim, check thời lượng > 0, check trạng thái (`COMING_SOON`, `NOW_SHOWING`, `ENDED`).
  - `001-03-create-cinema`: Bảng cụm rạp, cờ `is_active` soft-delete.
  - `001-04-create-room`: Bảng phòng chiếu, FK `fk_room_cinema`, UNIQUE `(cinema_id, name)`.
  - `001-05-create-seat`: Bảng ghế, `seat.id` kiểu `SERIAL`, FK `fk_seat_room`, check `seat_type`, UNIQUE `(room_id, seat_row, seat_number)`.
  - Toàn bộ 5 changeset đều có `--rollback`.
- **Cập nhật `src/main/resources/db/changelog/db.changelog-master.yaml`**:
  - Khai báo include file `001-user-catalog-tables.sql`.

### 2.3. Cấu hình ứng dụng
- **Cập nhật `src/main/resources/application.yaml`**:
  - Thêm giá trị fallback cho datasource: `POSTGRES_PORT:5433`, `POSTGRES_USER:cinema`, `POSTGRES_PASSWORD:cinema123` để khi chạy ngoài Docker không bị lỗi port mismatch `5432` vs `5433`.

### 2.4. Kết quả kiểm chứng trên Database
Đã kết nối PostgreSQL container `cinema-postgres` và xác thực qua `psql`:
- Danh sách quan hệ (`\dt`):
  - `app_user`
  - `cinema`
  - `movie`
  - `room`
  - `seat`
  - `databasechangelog` & `databasechangeloglock` (Liquibase)
- Cấu trúc bảng `seat` (`\d seat`):
  - `seat_pkey` PRIMARY KEY
  - `uq_seat_room_row_number` UNIQUE
  - `chk_seat_type` CHECK
  - `fk_seat_room` FOREIGN KEY

---

## 3. Trạng thái Checklist Phase 0

- [x] Tạo repo, thư mục `docs/`, review và hoàn thiện `01-requirements.md`
- [x] Cài và kiểm tra: `java -version`, `docker --version`
- [x] Viết `docker-compose.yml` (Postgres, Redis), tách mật khẩu ra `.env`
- [x] Kiểm tra: `docker compose ps`, vào `psql`, `redis-cli ping`
- [x] Kiểm tra volume: `docker compose down` rồi `up`, `down -v`
- [x] Tạo project Spring Boot từ start.spring.io (Maven, Java 21, Spring Boot 4.1.2)
- [x] Đọc `pom.xml`, đối chiếu dependency (`./mvnw compile` BUILD SUCCESS)
- [x] Cấu hình `application.yaml` (datasource port 5433, `ddl-auto: validate`, liquibase, redis)
- [x] Hiểu lại ERD, viết tài liệu `03-data-model.md`
- [x] **Tự viết changelog `001`** cho nhóm catalog (`app_user`, `movie`, `cinema`, `room`, `seat`)
- [x] Chạy app/test, kiểm tra bảng bằng `\dt` và `\d seat`
- [ ] **Làm endpoint `GET /movies` (entity, repository, controller)** ← *Mục tiêu tiếp theo*

---

## 4. Kế hoạch tiếp theo (Hoàn thành Phase 0 và chuẩn bị Phase 1)

1. **Entity `Movie`**:
   - Tạo class entity `@Entity @Table(name = "movie")`.
   - Khai báo các field khớp với bảng `movie` để pass Hibernate `ddl-auto: validate`.
2. **Repository & Controller**:
   - `MovieRepository extends JpaRepository<Movie, Long>`.
   - `MovieController` với endpoint `GET /movies` trả về `List<Movie>` (JSON).
3. **Chạy ứng dụng & Test cURL**:
   - Chạy `./mvnw spring-boot:run`.
   - Gọi `curl http://localhost:8080/movies` nhận về `[]` (HTTP 200).
   - Đóng lại Phase 0 (100%) và chuyển sang **Phase 1: Catalog**.
