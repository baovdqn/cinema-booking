# Requirements – MVP1

Đây là bản requirements cho MVP1.

## 1. Mục tiêu

Xây hệ thống đặt vé xem phim cho một chuỗi rạp. Điều quan trọng nhất là không bao giờ bán trùng một ghế, kể cả khi nhiều người tranh cùng ghế và khi có thành phần bị lỗi. Đây là dự án học tập, nên hệ thống cũng phải đo được và tái hiện được các tình huống tải cao trên máy cá nhân.

## 2. Người dùng

- **Khách hàng**: xem phim và suất chiếu, chọn ghế, thanh toán, nhận vé.
- **Quản trị viên**: quản lý phim, rạp, phòng, suất chiếu và giá vé.

## 3. Yêu cầu chức năng (MVP1)

| Mã | Yêu cầu |
|----|----------|
| UC1 | Đăng ký, đăng nhập (JWT). |
| UC2 | Xem danh sách phim đang chiếu và sắp chiếu, xem chi tiết phim kèm poster. |
| UC3 | Xem các suất chiếu của một phim theo rạp và theo ngày. |
| UC4 | Xem sơ đồ ghế của một suất: ghế trống, ghế đang được giữ, ghế đã bán. |
| UC5 | Chọn từ 1 đến 4 ghế và giữ chỗ trong 8 phút. Giữ chỗ theo kiểu tất cả hoặc không ghế nào. |
| UC6 | Thanh toán cho phần ghế đã giữ (cổng thanh toán giả lập). |
| UC7 | Nhận vé có mã QR sau khi thanh toán thành công, xem lại lịch sử đặt vé. |
| UC8 | Hủy giữ ghế khi chưa thanh toán. |
| UC9 (admin) | CRUD phim, rạp, phòng, suất chiếu; upload poster. Khi tạo suất chiếu, hệ thống tạo sẵn trạng thái ghế cho suất đó. |

## 4. Quy tắc nghiệp vụ

- Mỗi lần đặt tối đa 4 ghế, trong một suất chiếu.
- Giữ ghế 8 phút. Hết hạn thì ghế được nhả và người khác đặt được ngay; không gia hạn.
- Không hoàn vé sau khi thanh toán thành công.
- Đóng bán vé trước giờ chiếu 15 phút.
- Một ghế trong một suất chiếu có tối đa một vé.
- Thời gian lưu UTC, hiển thị theo giờ của rạp. Tiền tệ là VND, số nguyên.
- Thanh toán và đặt vé phải idempotent: gửi lặp cùng một yêu cầu không được tính tiền hoặc tạo vé hai lần.

## 5. Ràng buộc cứng (không được đánh đổi)

- Không bao giờ có hai vé cho cùng một ghế trong cùng một suất.
- Không phát hành vé khi thanh toán chưa thành công.
- Thanh toán thành công nhưng không thể cấp ghế thì phải hủy giao dịch thanh toán (void), không để người dùng mất tiền mà không có vé.

## 6. Yêu cầu phi chức năng và mục tiêu đo được

| Chỉ tiêu | Mục tiêu đề xuất | Điều kiện đo |
|-----------|-------------------|--------------|
| Chống bán trùng | 0 vé trùng | 500 request song song tranh 10 ghế, lặp nhiều lần |
| Xem sơ đồ ghế | p95 < 300 ms | 1.000 RPS, bảng showtime_seat chứa ~32 triệu dòng |
| Giữ ghế | p95 < 200 ms | ~300 yêu cầu giữ ghế/giây, dồn vào 20 suất |
| Danh sách phim, suất chiếu | p95 < 200 ms | 200 RPS |
| Hold hết hạn | Ghế nhả đúng hạn (TTL), booking chuyển EXPIRED trong vòng 1 phút | Kiểm tra thủ công và test tự động |
| Khi Redis mất | Không bán trùng; người dùng có thể phải thử lại | docker stop redis giữa luồng đặt vé |
| Khởi tạo môi trường | Một lệnh docker compose up | Dựng từ máy trống |

## 7. Quy mô giả định

- 50 rạp × 8 phòng = 400 phòng, 6 suất/ngày, 150 ghế/phòng.
- Khoảng 2.400 suất/ngày, tương ứng 360.000 dòng ghế theo suất mỗi ngày.
- Lịch sử 90 ngày: khoảng 32 triệu dòng.
- Tải bình thường: khoảng 50 RPS.
- Kịch bản mở bán bom tấn: 20.000 người trong 60 giây, dồn vào 20 suất (3.000 ghế, tức khoảng 7 người tranh mỗi ghế). Nếu mỗi người xem sơ đồ khoảng 3 lần và thử giữ ghế 1 lần thì tải là khoảng 1.000 RPS đọc và 333 yêu cầu giữ ghế/giây.

## 8. Ngoài phạm vi MVP1

Hoàn vé, combo bắp nước, mã giảm giá, điểm thành viên, nhiều thành phố hoặc đối tác rạp, thanh toán thật, check-in tại rạp (thiết kế sau khi xong luồng đặt vé), hàng chờ ảo, realtime sơ đồ ghế (MVP2).

## 9. Tiêu chí nghiệm thu MVP1

- Tất cả UC1-UC9 chạy được qua API.
- Đạt các mục tiêu ở mục 6, hoặc ghi lại số đo thật kèm lý do chưa đạt.
- Có bộ test tái hiện: tranh chấp ghế, hold hết hạn, thanh toán lặp, Redis chết, payment timeout.
- Ghi chép số đo trước và sau cho mỗi lần tối ưu (index, cache).

---

> **Ghi chú**: Hãy đọc kỹ các con số ở mục 6 và 7, rồi tự hỏi "mình có sẵn sàng đo bằng k6 không?" Chỗ nào thấy mục tiêu quá cao hoặc quá thấp so với máy của mình thì sửa luôn.