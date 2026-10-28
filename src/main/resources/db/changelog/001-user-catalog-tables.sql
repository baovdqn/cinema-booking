--liquibase formatted sql

--changeset billy:001-01-create-app-user
--comment: Tạo bảng app_user lưu thông tin khách hàng và admin
CREATE TABLE app_user (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_app_user_role CHECK (role IN ('CUSTOMER', 'ADMIN'))
);

-- Email không phân biệt hoa thường (Case-insensitive unique)
CREATE UNIQUE INDEX uq_app_user_email ON app_user (LOWER(email));
--rollback DROP TABLE IF EXISTS app_user;

--changeset billy:001-02-create-movie
--comment: Tạo bảng movie lưu thông tin phim
CREATE TABLE movie (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    duration_minutes INT NOT NULL,
    release_date DATE NOT NULL,
    poster_key VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'COMING_SOON',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_movie_duration CHECK (duration_minutes > 0),
    CONSTRAINT chk_movie_status CHECK (status IN ('COMING_SOON', 'NOW_SHOWING', 'ENDED'))
);
--rollback DROP TABLE IF EXISTS movie;

--changeset billy:001-03-create-cinema
--comment: Tạo bảng cinema lưu thông tin các cụm rạp
CREATE TABLE cinema (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500) NOT NULL,
    city VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
--rollback DROP TABLE IF EXISTS cinema;

--changeset billy:001-04-create-room
--comment: Tạo bảng room lưu thông tin phòng chiếu trong rạp (bỏ total_seats để tránh trùng lặp dữ liệu)
CREATE TABLE room (
    id BIGSERIAL PRIMARY KEY,
    cinema_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_cinema FOREIGN KEY (cinema_id) REFERENCES cinema (id) ON DELETE RESTRICT,
    CONSTRAINT uq_room_cinema_name UNIQUE (cinema_id, name)
);
--rollback DROP TABLE IF EXISTS room;

--changeset billy:001-05-create-seat
--comment: Tạo bảng seat lưu ghế trong phòng chiếu (seat.id dùng SERIAL/INTEGER 4 bytes)
CREATE TABLE seat (
    id SERIAL PRIMARY KEY,
    room_id BIGINT NOT NULL,
    seat_row VARCHAR(10) NOT NULL,
    seat_number INT NOT NULL,
    seat_type VARCHAR(20) NOT NULL DEFAULT 'STANDARD',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_seat_room FOREIGN KEY (room_id) REFERENCES room (id) ON DELETE RESTRICT,
    CONSTRAINT uq_seat_room_row_number UNIQUE (room_id, seat_row, seat_number),
    CONSTRAINT chk_seat_type CHECK (seat_type IN ('STANDARD', 'VIP', 'COUPLE'))
);
--rollback DROP TABLE IF EXISTS seat;
