# Roadmap dự án bán vé xem phim (2 MVP)

> Dành cho người có nền tảng Senior FE, mới bắt đầu với Java và backend.
> Thời gian ước tính cho **8-10 giờ mỗi tuần**. Nếu chạy nhanh hơn thì tốt, đừng cố ép cho kịp.
> Tick `[x]` khi hoàn thành để theo dõi tiến độ.

## Nguyên tắc xuyên suốt

- **Trigger trước, công nghệ sau.** Chỉ thêm một thành phần (cache, queue, replica...) khi đo được vấn đề mà nó giải quyết.
- **Không nhảy cóc phase.** Mỗi phase dựa trên số đo của phase trước. Không có baseline ở Phase 3 thì không biết cache ở Phase 5 hiệu quả đến đâu.
- **Cuối mỗi phase:** commit, ghi số đo (vấn đề, đo được gì, quyết định, đánh đổi), viết ADR nếu có quyết định lớn, rồi mới sang phase sau.
- **Kẹt quá 2 giờ** ở một chỗ thì dán code hoặc log để hỏi.
- **Bạn viết, người hướng dẫn review.** Bản tham khảo chỉ để so sánh sau khi bạn tự làm.
- **Cắt phạm vi nếu bị chậm** (bỏ check-in, bỏ Kafka, bỏ SSE), nhưng đừng bỏ các thí nghiệm.

## Tổng quan

| Phase | Nội dung | Thời gian |
|---|---|---|
| **MVP1: Modular monolith đúng đắn** | | **~11 tuần** |
| 0 | Nền tảng: Java, Docker Compose, Spring Boot, Liquibase đầu tiên | 2 tuần |
| 1 | Changelog: phim, rạp, suất chiếu | 2 tuần |
| 2 | Identity: đăng ký, đăng nhập, JWT | 1 tuần |
| 3 | Dữ liệu lớn và đo lường | 1 tuần |
| 4 | Booking core: giữ ghế, thanh toán, vé | 3 tuần |
| 5 | Tối ưu, nghiệm thu, tổng kết MVP1 | 2 tuần |
| **MVP2: Chịu tải và phân tán** | | **~14 tuần** |
| 6 | Scale ngang monolith: load balancer, observability | 2 tuần |
| 7 | Database: read replica, partition | 2 tuần |
| 8 | Hàng chờ ảo, rate limit, realtime sơ đồ ghế | 2 tuần |
| 9 | Message queue và outbox | 2 tuần |
| 10 | Tách microservice | 3 tuần |
| 11 | Saga, resilience, chaos test, tổng kết | 3 tuần |

## Tài liệu cần có trong `docs/`

| File | Khi nào hoàn thiện |
|---|---|
| `01-requirements.md` | Phase 0 |
| `03-data-model.md` | Phase 0-1 (cập nhật dần) |
| `04-api.md` | Phase 5 |
| `05-failure-modes.md` | Viết các dòng liên quan **trước** khi code mỗi tính năng ở Phase 4, hoàn thiện ở Phase 5 |
| `adr/` | Viết ngay khi đưa ra quyết định (5-8 dòng: bối cảnh, lựa chọn, đánh đổi) |

---

# MVP1: Modular monolith đúng đắn

**Mục tiêu:** hệ thống chạy đúng, không bán trùng ghế, hiểu sâu database và Redis.

## Phase 0: Nền tảng (tuần 1-2) ← bạn đang ở đây

**Mục tiêu:** app Spring Boot chạy được, nói chuyện được với Postgres, tạo bảng bằng Liquibase, trả về JSON.

**Việc cần làm**

- [ ] Tạo repo, thư mục `docs/`, review và hoàn thiện `01-requirements.md`
- [ ] Cài và kiểm tra: `java -version`, `docker --version`
- [ ] Viết `docker-compose.yml` (Postgres, Redis, MinIO), ghim version image, tách mật khẩu ra `.env`
- [ ] Kiểm tra: `docker compose ps`, vào `psql`, `redis-cli ping`, mở giao diện web MinIO
- [ ] Kiểm tra volume: `docker compose down` rồi `up` (dữ liệu còn), sau đó `down -v` (dữ liệu mất)
- [ ] Tạo project Spring Boot từ start.spring.io (Maven, Java, Jar; dependencies: Web, Data JPA, PostgreSQL Driver, Liquibase, Data Redis, Validation, Actuator, DevTools)
- [ ] Đọc `pom.xml`, đối chiếu với các dependency đã chọn
- [ ] Cấu hình `application.properties` hoặc `.yml` (datasource, `ddl-auto: validate`, liquibase, redis)
- [ ] Hiểu lại ERD: với mỗi bảng, tự giải thích khóa chính, ràng buộc, index cần có
- [ ] **Tự viết** changelog `001` cho nhóm catalog (`app_user`, `movie`, `cinema`, `room`, `seat`) rồi mới so với bản tham khảo
- [ ] Chạy app, kiểm tra bảng bằng `\dt` và `\d tên_bảng`
- [ ] Làm endpoint `GET /movies` (entity, repository, controller)

**Kiến thức cần học (học đến đâu dùng đến đó)**

- Java: kiểu dữ liệu, class/interface, generics, `List/Map/Optional`, Stream API, record, exception, `null`
- Spring: IoC và dependency injection, bean, annotation, kiến trúc controller → service → repository, `application.yml`, profile
- Maven cơ bản: `pom.xml`, `./mvnw clean`, `test`, `package`

**Nguồn:** dev.java/learn, spring.io/guides (làm 2-3 guide đầu), Spring Boot Reference, Baeldung khi cần tra.

**Hoàn thành khi:** `docker compose up` rồi chạy app thì thấy bảng được Liquibase tạo, `GET /movies` trả JSON (dù rỗng).

## Phase 1: Catalog (tuần 3-4)

**Mục tiêu:** quản lý phim, rạp, phòng, ghế, suất chiếu; khách xem được danh sách.

**Việc cần làm**

- [ ] Tự viết changelog `002` (showtime) và `003` (showtime_seat)
- [ ] Entity và quan hệ JPA cho `cinema`, `room`, `seat`, `movie`, `showtime`
- [ ] API admin: CRUD phim, rạp, phòng, suất chiếu
- [ ] Khi tạo suất chiếu, sinh sẵn dòng `showtime_seat` cho mọi ghế của phòng
- [ ] API khách: danh sách phim, chi tiết phim, suất chiếu theo phim, rạp, ngày (có phân trang)
- [ ] Tách DTO khỏi entity, validation đầu vào
- [ ] Xử lý lỗi tập trung (`@RestControllerAdvice`)
- [ ] Tài liệu API bằng springdoc (Swagger UI)
- [ ] Test đầu tiên: JUnit 5, Mockito, test repository với Testcontainers (Postgres thật)

**Kiến thức cần học:** JPA/Hibernate (quan hệ, lazy vs eager, `@Transactional`), bài toán N+1, DTO, đọc stack trace, test pyramid trong Java.

**Thí nghiệm**

- [ ] Cố tình gây N+1, log SQL, đếm số câu, rồi sửa bằng fetch join hoặc entity graph

**Hoàn thành khi:** UC2, UC3, UC9 (chưa có poster) chạy qua Swagger, có test cho các service chính.

## Phase 2: Identity (tuần 5)

**Mục tiêu:** đăng ký, đăng nhập, phân quyền khách và admin.

**Việc cần làm**

- [ ] Thêm Spring Security
- [ ] Băm mật khẩu bằng BCrypt
- [ ] Đăng nhập trả JWT, filter xác thực JWT, phân quyền theo role
- [ ] Cấu hình CORS
- [ ] Bảo vệ API admin
- [ ] ADR: có làm refresh token hay không

**Kiến thức cần học:** security filter chain, `SecurityContext`, cấu trúc JWT (hạn dùng, ký), vì sao không lưu mật khẩu thô.

**Hoàn thành khi:** UC1 chạy; API admin trả 403 với khách, 401 khi không có token.

## Phase 3: Dữ liệu lớn và đo lường (tuần 6)

**Mục tiêu:** có 32 triệu dòng để thấy vấn đề thật, và có công cụ đo từ giờ trở đi.

**Việc cần làm**

- [ ] Chạy script seed trên schema thật (script tham khảo có lỗi với schema hiện tại, tự tìm nguyên nhân và sửa)
- [ ] Chạy `ANALYZE`
- [ ] Đọc `EXPLAIN ANALYZE` cho 3-4 truy vấn chính (sơ đồ ghế một suất, các suất của phim X trong 3 ngày tới)
- [ ] Thêm index cần thiết, dùng `CREATE INDEX CONCURRENTLY` với `runInTransaction:false`
- [ ] Dựng k6, viết kịch bản đầu tiên cho endpoint sơ đồ ghế, ghi **baseline**
- [ ] Bật Actuator và Micrometer metrics (xem latency từng endpoint)

**Kiến thức cần học:** cách Postgres chọn plan (seq scan, index scan, bitmap), index composite và partial, độ chọn lọc, bloat và autovacuum (`pg_stat_user_tables`), cú pháp k6 cơ bản.

**Thí nghiệm**

- [ ] So sánh truy vấn trước và sau khi có index
- [ ] Xem hiệu ứng của `fillfactor`

**Hoàn thành khi:** có bảng số đo (truy vấn, trước, sau, vì sao) trong `docs/`.

## Phase 4: Booking core (tuần 7-9)

Phase quan trọng nhất của cả dự án. Làm xong và test từng phần rồi mới sang phần sau.

### 4a. Sơ đồ ghế

- [ ] API trả ghế theo suất, ghép "đã bán" (Postgres) với "đang giữ" (Redis)

### 4b. Giữ ghế

- [ ] Viết các dòng failure mode liên quan (hold, Redis chết) **trước khi code**
- [ ] Lua script all-or-nothing, tối đa 4 ghế, TTL 8 phút
- [ ] Trả `holdId` và hạn giữ; tạo booking `HELD`
- [ ] API hủy giữ ghế

### 4c. Thanh toán

- [ ] Payment giả lập (độ trễ và lỗi ngẫu nhiên, kể cả mất response)
- [ ] Idempotency key
- [ ] Luồng: kiểm tra hold, charge, TX ghi `SOLD`, xóa hold (đúng thứ tự)
- [ ] Void thanh toán khi ghi `SOLD` thất bại

### 4d. Hết hạn

- [ ] Job `@Scheduled` chuyển booking `HELD` quá hạn sang `EXPIRED`
- [ ] Phát hiện lười khi người dùng quay lại

### 4e. Vé

- [ ] Sinh vé và mã QR cho từng ghế
- [ ] API xem lịch sử đặt vé

**Kiến thức cần học:** kiểu dữ liệu và TTL của Redis, Lua trong Redis, `StringRedisTemplate` / `DefaultRedisScript`, transaction isolation level, idempotency, `@Scheduled`, state machine (cài bằng enum và câu `UPDATE` có điều kiện).

**Thí nghiệm bắt buộc**

- [ ] 500 request song song tranh 10 ghế: **0 vé trùng**, đúng 10 người thắng
- [ ] Gửi lặp cùng một request thanh toán: chỉ một vé
- [ ] `docker stop redis` giữa luồng đặt vé: không bán trùng
- [ ] Hold hết hạn đúng lúc đang thanh toán
- [ ] So với phương án "chỉ Postgres" (`SELECT ... FOR UPDATE` hoặc optimistic lock) về throughput và tỷ lệ lỗi

**Hoàn thành khi:** UC4-UC8 chạy; cả 5 thí nghiệm có test tự động hoặc script tái hiện; `05-failure-modes.md` có đủ dòng và đều được kiểm chứng.

## Phase 5: Tối ưu, nghiệm thu, tổng kết (tuần 10-11)

**Việc cần làm**

- [ ] Cache catalog bằng Redis (cache-aside): đo trước và sau; học cache invalidation, TTL, cache stampede, cache penetration
- [ ] Poster: MinIO và presigned URL, FE upload thẳng lên S3
- [ ] Kịch bản k6 "mở bán bom tấn" theo requirements; so với bảng mục tiêu, ghi số đo thật
- [ ] FE tối giản (React): danh sách phim, sơ đồ ghế có đồng hồ đếm ngược, thanh toán, xem vé
- [ ] Tùy chọn: check-in bằng QR (token ký chữ ký, vé dùng một lần)
- [ ] Hoàn thiện ADR, `04-api.md`, `05-failure-modes.md`
- [ ] Chạy lại toàn bộ môi trường từ trạng thái trống bằng `docker compose up`

**Tổng kết MVP1 (cổng sang MVP2)**

- [ ] Viết một trang trả lời: *giới hạn của hệ thống nằm ở đâu* (CPU app, Postgres, Redis hay lock) và *thành phần nào vượt mục tiêu*.
- Kết quả này quyết định thứ tự làm ở MVP2. Nếu số đo chưa chạm giới hạn thì phase tương ứng chỉ làm để học, và ghi rõ như vậy.

**Tiêu chí nghiệm thu MVP1**

- [ ] UC1-UC9 chạy được qua API
- [ ] Đạt mục tiêu trong requirements, hoặc ghi lại số đo thật kèm lý do chưa đạt
- [ ] Có bộ test: tranh chấp ghế, hold hết hạn, thanh toán lặp, Redis chết, payment timeout
- [ ] Có số đo trước và sau cho mỗi lần tối ưu

---

# MVP2: Chịu tải và phân tán

**Mục tiêu:** hệ thống chạy nhanh, chịu lỗi, và được tách thành microservice. Chỉ bắt đầu khi đã đo được giới hạn thật của MVP1.

## Phase 6: Scale ngang monolith (tuần 12-13)

**Việc cần làm**

- [ ] Viết `Dockerfile` cho app, thêm vào compose
- [ ] Nginx làm load balancer cho 3 instance (round-robin, rồi `least_conn`)
- [ ] Tìm và sửa các thứ "có trạng thái" bị vỡ: job `@Scheduled` chạy 3 lần (ShedLock hoặc lock bằng Redis), cache local, session
- [ ] Log có cấu trúc kèm correlation ID
- [ ] Prometheus và Grafana, dashboard cơ bản

**Kiến thức cần học:** stateless, health check và readiness, các thuật toán cân bằng tải, distributed lock và cạm bẫy của nó.

**Thí nghiệm**

- [ ] `docker stop` một instance giữa tải: đo lỗi và thời gian phục hồi
- [ ] Giới hạn CPU của container app: xem RPS tối đa

## Phase 7: Database scale (tuần 14-15)

**Việc cần làm**

- [ ] Dựng Postgres primary và read replica trong compose (streaming replication)
- [ ] Định tuyến: ghi vào primary, đọc catalog từ replica
- [ ] Quan sát replication lag: ghi xong đọc ngay mà chưa thấy
- [ ] Partition `showtime_seat` theo tháng, viết migration Liquibase chuyển từ bảng thường (tạo bảng mới, copy theo lô, đổi tên, đo thời gian và lock)
- [ ] Thử `DETACH PARTITION` thay cho `DELETE` dữ liệu cũ
- [ ] Tìm hiểu connection pool (HikariCP) và giới hạn kết nối

**Kiến thức cần học:** WAL và replication, eventual consistency, partition pruning, hot và cold data, PgBouncer (đọc để biết).

**Hoàn thành khi:** đo được độ trễ truy vấn trước và sau partition; có ví dụ cụ thể về replication lag gây lỗi hiển thị.

## Phase 8: Hàng chờ ảo, rate limit, realtime (tuần 16-17)

**Việc cần làm**

- [ ] Rate limit theo user và IP bằng Redis (token bucket hoặc sliding window)
- [ ] Hàng chờ ảo cho phim bom tấn: số thứ tự, cho vào theo đợt
- [ ] Realtime sơ đồ ghế bằng SSE (Redis pub/sub làm kênh nội bộ)

**Kiến thức cần học:** các thuật toán rate limit, back-pressure, SSE vs WebSocket, giới hạn kết nối dài của proxy.

**Thí nghiệm**

- [ ] Chạy lại kịch bản bom tấn của MVP1: so số lỗi, độ trễ, tải lên Postgres khi có và không có hàng chờ

## Phase 9: Message queue và outbox (tuần 18-19)

**Việc cần làm**

- [ ] Thêm RabbitMQ (hoặc Kafka) vào compose
- [ ] Phát event `BookingConfirmed` qua outbox pattern (ghi event cùng transaction với `SOLD`, relay đẩy lên broker)
- [ ] Consumer gửi email vé: ack, retry có backoff, dead letter queue
- [ ] Consumer idempotent (nhận trùng thì sao?)
- [ ] Tùy chọn: làm lại một luồng nhỏ bằng Kafka (partition, consumer group, offset)

**Kiến thức cần học:** at-least-once vs at-most-once vs exactly-once (thường là xử lý trùng cộng idempotency), thứ tự message, poison message.

**Thí nghiệm**

- [ ] Tắt consumer giữa chừng rồi bật lại
- [ ] Phát cùng một event 2 lần
- [ ] Làm consumer lỗi liên tục, xem DLQ

## Phase 10: Tách microservice (tuần 20-22)

Mỗi lần tách là một vòng lặp đầy đủ: trước, sau, đo độ trễ, ghi lỗi mới phát sinh.

**Thứ tự (dễ đến khó)**

- [ ] 1. **Notification**: gần như thuần async; có DB và changelog riêng
- [ ] 2. **Catalog**: kèm read replica, cache, MinIO
- [ ] 3. **Payment**: giao tiếp đồng bộ qua REST có timeout, retry, circuit breaker (Resilience4j)
- [ ] 4. **Booking**: phần còn lại của monolith (giữ ghế, đơn đặt vé, vé)
- [ ] 5. **API Gateway** (Spring Cloud Gateway hoặc Nginx): JWT, routing, rate limit chuyển về đây

**Quy tắc:** mỗi service một database và một changelog Liquibase riêng; không join chéo; không chạy migration lên DB của service khác. Dữ liệu cần chia sẻ thì gọi API hoặc nghe event.

**Kiến thức cần học:** API contract giữa service, distributed data (không còn JOIN), service discovery bằng DNS trong Compose, versioning event và API.

## Phase 11: Saga, resilience, chaos, tổng kết (tuần 23-25)

**Việc cần làm**

- [ ] Saga orchestrator trong Booking: giữ ghế, thanh toán, xác nhận, có nhánh bù trừ khi lỗi
- [ ] Lưu trạng thái saga bền vững trong DB
- [ ] Distributed tracing xuyên service (OpenTelemetry, Jaeger hoặc Tempo)
- [ ] Chaos test: tắt Payment giữa chừng
- [ ] Chaos test: làm chậm broker
- [ ] Chaos test: tắt Redis
- [ ] Chaos test: ngắt mạng bằng Toxiproxy
- [ ] Chạy lại kịch bản bom tấn với kiến trúc đầy đủ

**Hoàn thành khi:** mọi lần tắt một thành phần đều có hành vi suy giảm mong đợi, vẫn **0 bán trùng**, và bạn viết được báo cáo cuối.

**Báo cáo cuối:** kiến trúc, số đo trước và sau từng phase, những quyết định bạn sẽ làm khác đi.

---

## Sách và nguồn đọc song song

- *Designing Data-Intensive Applications* (Martin Kleppmann): Chương 7 (transaction) cho Phase 4, Chương 5 (replication) cho Phase 7, Chương 11 (stream processing) cho Phase 9
- Spring Boot Reference và spring.io/guides
- Tài liệu chính thức của Postgres (EXPLAIN, index, partition, replication)
- Tài liệu Redis (Lua scripting, persistence, expire)
- Baeldung để tra cứu nhanh các chủ đề Spring
