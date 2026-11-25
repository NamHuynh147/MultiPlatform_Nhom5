# Ôn thi tốt nghiệp THPT

Ứng dụng Flutter hỗ trợ học sinh lớp 12 ôn thi tốt nghiệp THPT. Dữ liệu tiến độ được lưu ngay trên máy (shared_preferences), không cần tài khoản hay mạng.

## Tính năng

- **Đếm ngược kỳ thi**, đổi được ngày thi ngay trong ứng dụng. Ngày mặc định 11-06-2027 chỉ là ước lượng; hãy cập nhật theo lịch chính thức của Bộ GD&ĐT.
- **Chọn môn**: Toán và Ngữ văn bắt buộc, chọn thêm 2 môn tự chọn (nút ⚙ ở trang chủ).
- **10 môn**: Toán, Ngữ văn, Tiếng Anh, Vật lí, Hóa học, Sinh học, Lịch sử, Địa lí, GD Kinh tế & Pháp luật, Tin học.
- **Ba dạng câu hỏi** theo cấu trúc đề mới: trắc nghiệm nhiều lựa chọn, đúng/sai (chấm theo thang 0 / 0,1 / 0,25 / 0,5 / 1), trả lời ngắn.
- **Luyện tập** theo chuyên đề hoặc tổng hợp, có đáp án và lời giải ngay từng câu.
- **Thi thử** có tính giờ, nộp bài mới xem đáp án, quy đổi điểm thang 10.
- **Ôn lại câu sai**: tự gom các câu làm sai; làm đúng thì được gỡ khỏi danh sách.
- **Flashcard** công thức, mốc sự kiện, khái niệm; đánh dấu đã nhớ / chưa nhớ.
- **Tiến độ**: điểm trung bình từng môn, chuỗi ngày học liên tiếp, lịch sử làm bài.

## Chạy ứng dụng

Yêu cầu Flutter **3.27 trở lên** (Dart 3.6+).

Repo chưa có các thư mục nền tảng (`android/`, `ios/`, `web/`...). Tạo chúng một lần trong thư mục project, lệnh này giữ nguyên `lib/` và `pubspec.yaml`:

```bash
flutter create . --project-name on_thi_thpt --org vn.edu.onthi --platforms=android,ios,web
flutter pub get
flutter run
```

Chạy kiểm thử và phân tích mã:

```bash
flutter analyze
flutter test
```

## Cấu trúc

```
lib/
  main.dart                  Khởi tạo, theme, ngôn ngữ tiếng Việt
  models/                    Subject, Question, Flashcard, QuizResult
  data/                      Danh sách môn, ngân hàng câu hỏi, flashcard
  providers/progress_provider.dart   Lưu tiến độ, môn tự chọn, ngày thi
  screens/                   Trang chủ, môn học, làm bài, kết quả, flashcard, tiến độ
  widgets/                   Thẻ đếm ngược, hiển thị câu hỏi
  utils/                     Chuẩn hóa văn bản, định dạng
test/app_logic_test.dart     Chấm điểm và kiểm tra tính toàn vẹn dữ liệu
```

## Thêm câu hỏi và flashcard

Sửa `lib/data/questions_data.dart` và `lib/data/flashcards_data.dart`. Quy ước:

- `id` duy nhất, bắt đầu bằng `<mã môn>-` (ví dụ `toan-q10`).
- `topic` phải trùng đúng tên một chuyên đề trong `subjects_data.dart`.
- Câu trắc nghiệm có 4 phương án, `correct` là chỉ số 0–3. Câu đúng/sai có 4 ý và `correctTf` gồm 4 giá trị.
- Không dùng ký tự `$` trong nội dung (Dart hiểu là nội suy chuỗi); nếu cần, viết `\$`.

`flutter test` sẽ báo lỗi nếu id trùng, chuyên đề sai tên hoặc cấu trúc đáp án không hợp lệ.

## Lưu ý về nội dung

Ngân hàng câu hỏi hiện chỉ là **dữ liệu mẫu** (65 câu, mỗi môn 4–9 câu) để minh họa ứng dụng. Cần giáo viên bộ môn rà soát và bổ sung trước khi dùng để ôn tập thật.
