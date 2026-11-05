package com.billy.cinema_booking.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "showtime_seat")
@IdClass(ShowtimeSeatId.class)
@Getter
@Setter
@NoArgsConstructor
public class ShowtimeSeat {

    public static final short STATUS_AVAILABLE = 0;
    public static final short STATUS_SOLD = 1;

    @Id
    @Column(name = "showtime_id", nullable = false)
    private Long showtimeId;

    @Id
    @Column(name = "seat_id", nullable = false)
    private Integer seatId;

    @Column(name = "status", nullable = false)
    private Short status = STATUS_AVAILABLE;

    @Column(name = "price", nullable = false)
    private Long price;
}

