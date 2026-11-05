--liquibase formatted sql

--changeset billy:003-01-create-showtime-seat
--comment: Tạo bảng showtime_seat lưu trạng thái ghế theo suất (bảng nóng nhất, ~32 triệu dòng sau 90 ngày)
-- Cố ý KHÔNG có khóa ngoại tới showtime và seat để insert/seed nhanh. App tự bảo đảm toàn vẹn
-- và tự xóa các dòng của một suất trong cùng transaction khi xóa suất đó.
-- Không có created_at/updated_at để giữ mỗi dòng nhỏ nhất có thể.
-- Thứ tự cột: BIGINT, INT, SMALLINT, BIGINT (xem 03-data-model.md mục 4.2 về căn lề).
CREATE TABLE showtime_seat (
    showtime_id BIGINT NOT NULL,
    seat_id INT NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0,
    price BIGINT NOT NULL,
    -- Truy vấn sơ đồ ghế WHERE showtime_id = ? dùng cột đầu của PK, không cần index khác.
    CONSTRAINT pk_showtime_seat PRIMARY KEY (showtime_id, seat_id),
    -- 0 = AVAILABLE, 1 = SOLD. Trạng thái "đang giữ" nằm ở Redis.
    CONSTRAINT chk_showtime_seat_status CHECK (status IN (0, 1)),
    CONSTRAINT chk_showtime_seat_price CHECK (price > 0)
);
--rollback DROP TABLE IF EXISTS showtime_seat;

