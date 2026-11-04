# Progress Log / Changelog — 2026-11-04

> Phase hiện tại: **Phase 0 — Nền tảng (tuần 1-2) ➔ ĐÃ HOÀN THÀNH 100% 🎉**  
> Tiến độ tổng MVP1: **~18% (2/11 tuần)**  
> Tiếp theo: **Phase 1 — Catalog (tuần 3-4)**  

---

## 1. Tổng quan công việc hoàn thành trong đợt này

| Hạng mục | Trạng thái | Chi tiết |
|---|:---:|---|
| **Movie Entity & Enum** | ✅ Hoàn thành | `Movie.java` map chuẩn xác với bảng `movie` trong PostgreSQL, pass Hibernate `ddl-auto: validate`. Enum `MovieStatus.java` chuẩn hóa trạng thái phim. |
| **MovieRepository** | ✅ Hoàn thành | `MovieRepository.java` interface kế thừa `JpaRepository<Movie, Long>`, sẵn sàng cho các thao tác CRUD. |
| **MovieController (API GET /movies)** | ✅ Hoàn thành | `MovieController.java` đón `GET /movies`, inject `MovieRepository` và trả về JSON danh sách phim. |
| **Spring Boot Context & DB Integration Test** | ✅ Hoàn thành | `./mvnw test` chạy thành công (`BUILD SUCCESS`), kiểm tra trọn vẹn luồng Entity ↔ JPA ↔ Postgres. |
| **Nghiệm thu Phase 0** | ✅ **100% Hoàn thành** | Đánh dấu hoàn thành toàn bộ checklist của Phase 0 trong `cinema-booking-roadmap.md`. |

---

## 2. Chi tiết các thay đổi trong codebase

### 2.1. Tầng Repository (`src/main/java/com/billy/cinema_booking/repository/`)
- Hoàn thiện `MovieRepository.java`:
  - Kế thừa `JpaRepository<Movie, Long>`, đánh dấu `@Repository`.
  - Tận dụng Dynamic Proxy của Spring Data JPA để có sẵn các method CRUD (`findAll`, `findById`, `save`, `delete`).

### 2.2. Tầng Controller (`src/main/java/com/billy/cinema_booking/controller/`)
- Hoàn thiện `MovieController.java`:
  - Đánh dấu `@RestController` và `@RequestMapping("/movies")`.
  - Sử dụng Constructor Injection với `@RequiredArgsConstructor` (Lombok) cho `MovieRepository`.
  - Endpoint `@GetMapping` trả về `List<Movie>` tự động serialize ra JSON.

### 2.3. Cập nhật Roadmap (`docs/cinema-booking-roadmap.md`)
- Đánh dấu hoàn thành hạng mục cuối cùng của Phase 0:
  - `[x] Làm endpoint GET /movies (entity, repository, controller)`

---

## 3. Trạng thái Checklist Phase 0 (Nền tảng)

- [x] Tạo repo, thư mục `docs/`, review và hoàn thiện `01-requirements.md`
- [x] Cài và kiểm tra: `java -version`, `docker --version`
- [x] Viết `docker-compose.yml` (Postgres, Redis), tách mật khẩu ra `.env`
- [x] Kiểm tra: `docker compose ps`, vào `psql`, `redis-cli ping`
- [x] Kiểm tra volume: `docker compose down` rồi `up`, `down -v`
- [x] Tạo project Spring Boot từ start.spring.io (Maven, Java 21, Spring Boot 4.1.2)
- [x] Đọc `pom.xml`, đối chiếu dependency (`./mvnw compile` BUILD SUCCESS)
- [x] Cấu hình `application.yaml` (datasource port 5433, `ddl-auto: validate`, liquibase, redis)
- [x] Hiểu lại ERD, viết tài liệu `03-data-model.md`
- [x] Tự viết changelog `001` cho nhóm catalog (`app_user`, `movie`, `cinema`, `room`, `seat`)
- [x] Chạy app/test, kiểm tra bảng bằng `\dt` và `\d seat`
- [x] **Làm endpoint `GET /movies` (entity, repository, controller)**

👉 **Phase 0 chính thức khép lại. Hệ thống nền tảng đã sẵn sàng cho Phase 1!**

---

## 4. Kế hoạch tiếp theo (Phase 1: Catalog - tuần 3-4)

1. **Viết Changelog `002` (showtime) và `003` (showtime_seat)**:
   - Suất chiếu và bảng ghế suất chiếu (bảng hotspot quan trọng nhất).
2. **Entity và quan hệ JPA**:
   - `Cinema`, `Room`, `Seat`, `Showtime`, `ShowtimeSeat`.
   - Quan hệ `@ManyToOne`, `@OneToMany`, thiết lập `FetchType.LAZY`.
3. **API Admin & Khách**:
   - CRUD danh mục rạp, phòng, phim, suất chiếu.
   - API xem lịch chiếu theo phim, rạp, ngày.
4. **Tách DTO & Validation**:
   - Tách Request/Response DTO khỏi Entity, thêm Bean Validation (`@NotBlank`, `@NotNull`, ...).

