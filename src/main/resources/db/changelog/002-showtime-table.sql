--liquibase formatted sql

--changeset billy:002-01-enable-btree-gist
--comment: Kích hoạt extension btree_gist để hỗ trợ exclusion constraint trên room_id và thời gian
CREATE EXTENSION IF NOT EXISTS btree_gist;
--rollback DROP EXTENSION IF EXISTS btree_gist;

--changeset billy:002-02-create-showtime
--comment: Tạo bảng showtime lưu suất chiếu (end_time = start_time + duration_minutes, không cộng thời gian dọn phòng)
CREATE TABLE showtime (
    id BIGSERIAL PRIMARY KEY,
    movie_id BIGINT NOT NULL,
    room_id BIGINT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_showtime_movie FOREIGN KEY (movie_id) REFERENCES movie (id) ON DELETE RESTRICT,
    CONSTRAINT fk_showtime_room FOREIGN KEY (room_id) REFERENCES room (id) ON DELETE RESTRICT,
    CONSTRAINT chk_showtime_time CHECK (end_time > start_time),
    -- Không cho 2 suất cùng phòng có khoảng [start_time, end_time) chồng nhau.
    -- tstzrange mặc định là [a, b) nên suất 19:00-21:00 và 21:00-23:00 vẫn hợp lệ.
    CONSTRAINT ex_showtime_room_overlap EXCLUDE USING gist (
        room_id WITH =,
        tstzrange(start_time, end_time) WITH &&
    )
);

-- UC3: các suất của một phim trong một ngày. Cũng là index cho FK movie_id.
CREATE INDEX idx_showtime_movie_time ON showtime (movie_id, start_time);

-- Lịch chiếu của một phòng (admin). Cũng là index cho FK room_id.
CREATE INDEX idx_showtime_room_time ON showtime (room_id, start_time);
--rollback DROP TABLE IF EXISTS showtime;
