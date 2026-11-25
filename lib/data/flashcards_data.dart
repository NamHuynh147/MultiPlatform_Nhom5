import '../models/flashcard.dart';

List<Flashcard> _cards(String subjectId, List<List<String>> rows) {
  final result = <Flashcard>[];
  for (var i = 0; i < rows.length; i++) {
    result.add(Flashcard(
      id: '$subjectId-f${i + 1}',
      subjectId: subjectId,
      front: rows[i][0],
      back: rows[i][1],
    ));
  }
  return result;
}

/// Thẻ ghi nhớ mẫu (công thức, mốc sự kiện, khái niệm). Hãy bổ sung thêm.
final List<Flashcard> kFlashcards = [
  ..._cards('toan', [
    ['Đạo hàm của sin x', '(sin x)′ = cos x'],
    ['Đạo hàm của eˣ và aˣ', '(eˣ)′ = eˣ;  (aˣ)′ = aˣ · ln a'],
    ['Nguyên hàm của 1/x', '∫ (1/x) dx = ln|x| + C'],
    ['Thể tích khối chóp', 'V = ⅓ · S_đáy · h'],
    ['Thể tích khối lăng trụ', 'V = S_đáy · h'],
    [
      'Tích vô hướng của a = (x₁; y₁; z₁) và b = (x₂; y₂; z₂)',
      'a · b = x₁x₂ + y₁y₂ + z₁z₂'
    ],
    [
      'Logarit của một tích',
      'logₐ(bc) = logₐ b + logₐ c  (0 < a ≠ 1; b, c > 0)'
    ],
  ]),
  ..._cards('van', [
    [
      'Tây Tiến (Quang Dũng): nét nổi bật',
      'Cảm hứng lãng mạn, bi tráng; hình tượng người lính Tây Tiến hào hùng, hào hoa giữa thiên nhiên miền Tây hùng vĩ.'
    ],
    [
      'Vợ nhặt (Kim Lân): tình huống truyện',
      'Tràng nhặt được vợ giữa nạn đói năm 1945. Giá trị nhân đạo: khát vọng sống, hạnh phúc và niềm tin vào tương lai.'
    ],
    [
      'Việt Bắc (Tố Hữu): hoàn cảnh sáng tác',
      'Tháng 10-1954, sau chiến thắng Điện Biên Phủ, khi Trung ương Đảng và Chính phủ rời Việt Bắc về Hà Nội.'
    ],
    [
      'Bố cục bài nghị luận xã hội',
      'Mở bài (dẫn dắt, nêu vấn đề) → Thân bài (giải thích, phân tích, bàn luận, bài học) → Kết bài.'
    ],
  ]),
  ..._cards('anh', [
    [
      'Câu điều kiện loại 2',
      'If + S + V-ed/were, S + would + V. Giả định không có thật ở hiện tại.'
    ],
    [
      'Câu điều kiện loại 3',
      'If + S + had + V3, S + would have + V3. Giả định không có thật ở quá khứ.'
    ],
    [
      'Thì hiện tại hoàn thành',
      'S + have/has + V3. Hành động bắt đầu trong quá khứ và còn liên quan đến hiện tại.'
    ],
    ['Cấu trúc bị động', 'S + be + V3 (+ by O)'],
    ['look forward to', 'Mong đợi — theo sau là V-ing: I look forward to seeing you.'],
  ]),
  ..._cards('ly', [
    ['Chu kì con lắc lò xo', 'T = 2π√(m/k)'],
    ['Chu kì con lắc đơn', 'T = 2π√(l/g)'],
    ['Cảm kháng và dung kháng', 'Z_L = ωL;  Z_C = 1/(ωC)'],
    ['Định luật Bôi-lơ – Ma-ri-ốt', 'Nhiệt độ không đổi: pV = hằng số'],
    ['Hệ thức Anh-xtanh', 'E = mc²'],
    ['Độ hụt khối của hạt nhân', 'Δm = Z·mₚ + (A − Z)·mₙ − m_hạt nhân'],
  ]),
  ..._cards('hoa', [
    ['Glucozơ', 'C₆H₁₂O₆ — monosaccarit, có phản ứng tráng bạc.'],
    ['Saccarozơ', 'C₁₂H₂₂O₁₁ — đisaccarit, không có phản ứng tráng bạc.'],
    ['Tinh bột và xenlulozơ', '(C₆H₁₀O₅)ₙ — polisaccarit.'],
    [
      'Phản ứng xà phòng hóa este',
      'Este + NaOH → muối của axit cacboxylic + ancol (đun nóng, phản ứng một chiều).'
    ],
    [
      'Dãy hoạt động hóa học của kim loại',
      'K, Na, Ca, Mg, Al, Zn, Fe, Ni, Sn, Pb, H, Cu, Hg, Ag, Pt, Au'
    ],
    ['Amino axit', 'Hợp chất tạp chức có cả nhóm –NH₂ và nhóm –COOH.'],
  ]),
  ..._cards('sinh', [
    [
      'Mã di truyền',
      'Là bộ ba nuclêôtit: có 64 bộ ba, 61 bộ ba mã hóa axit amin và 3 bộ ba kết thúc (UAA, UAG, UGA); AUG là mã mở đầu.'
    ],
    [
      'Nguyên tắc bổ sung',
      'A–T (2 liên kết hiđrô), G–X (3 liên kết hiđrô); trên ARN: A–U, G–X.'
    ],
    [
      'Định luật Hacđi – Vanbec',
      'Quần thể ngẫu phối ở trạng thái cân bằng: p²AA + 2pqAa + q²aa = 1.'
    ],
    [
      'Quy luật phân li (Menđen)',
      'Mỗi tính trạng do một cặp alen quy định; khi giảm phân mỗi giao tử chỉ chứa một alen của cặp.'
    ],
  ]),
  ..._cards('su', [
    [
      '2-9-1945',
      'Hồ Chí Minh đọc Tuyên ngôn Độc lập tại Quảng trường Ba Đình, khai sinh nước Việt Nam Dân chủ Cộng hòa.'
    ],
    [
      '7-5-1954',
      'Chiến thắng Điện Biên Phủ. Ngày 21-7-1954 Hiệp định Giơ-ne-vơ được kí.'
    ],
    ['27-1-1973', 'Kí Hiệp định Pa-ri về chấm dứt chiến tranh, lập lại hòa bình ở Việt Nam.'],
    ['30-4-1975', 'Chiến dịch Hồ Chí Minh toàn thắng, giải phóng hoàn toàn miền Nam.'],
    ['Tháng 12-1986', 'Đại hội VI của Đảng đề ra đường lối Đổi mới.'],
    [
      'Liên hợp quốc',
      'Thành lập năm 1945 (Hiến chương có hiệu lực ngày 24-10-1945) nhằm duy trì hòa bình và an ninh thế giới.'
    ],
  ]),
  ..._cards('dia', [
    [
      'Các vùng biển của Việt Nam',
      'Nội thủy, lãnh hải (12 hải lí), vùng tiếp giáp lãnh hải, vùng đặc quyền kinh tế (200 hải lí tính từ đường cơ sở), thềm lục địa.'
    ],
    ['Dân tộc ở Việt Nam', '54 dân tộc; dân tộc Kinh có số dân đông nhất.'],
    ['Hai quần đảo xa bờ của Việt Nam', 'Hoàng Sa và Trường Sa.'],
    ['Đặc điểm khí hậu nước ta', 'Nhiệt đới ẩm gió mùa: nóng, ẩm, mưa nhiều.'],
  ]),
  ..._cards('gdktpl', [
    [
      'Thuế trực thu và thuế gián thu',
      'Trực thu: đánh vào thu nhập, tài sản (thuế thu nhập cá nhân, thuế thu nhập doanh nghiệp). Gián thu: tính vào giá hàng hóa, dịch vụ (VAT, thuế tiêu thụ đặc biệt).'
    ],
    ['Quan hệ cung – cầu và giá cả', 'Cung > cầu → giá giảm; cung < cầu → giá tăng.'],
    [
      'Các hình thức thực hiện pháp luật',
      'Sử dụng pháp luật, thi hành pháp luật, tuân thủ pháp luật, áp dụng pháp luật.'
    ],
  ]),
  ..._cards('tin', [
    ['SQL cơ bản', 'SELECT các cột FROM tên bảng WHERE điều kiện;'],
    ['Khóa chính', 'Xác định duy nhất mỗi bản ghi của bảng, không trùng lặp và không để trống.'],
    ['HTTP và HTTPS', 'Giao thức truyền trang web; HTTPS là HTTP có mã hóa (TLS) để bảo mật.'],
    ['Học máy', 'Lĩnh vực của trí tuệ nhân tạo, cho phép máy học quy luật từ dữ liệu.'],
  ]),
];

List<Flashcard> flashcardsFor(String subjectId) =>
    kFlashcards.where((c) => c.subjectId == subjectId).toList();
