import 'package:flutter/material.dart';

import '../models/subject.dart';

/// Các môn có thể thi tốt nghiệp THPT. Toán và Ngữ văn là bắt buộc,
/// thí sinh chọn thêm 2 môn tự chọn.
const List<Subject> kSubjects = [
  Subject(
    id: 'toan',
    name: 'Toán',
    icon: Icons.functions,
    color: Color(0xFF3F51B5),
    compulsory: true,
    topics: [
      'Hàm số và đạo hàm',
      'Mũ – Logarit',
      'Nguyên hàm – Tích phân',
      'Hình học không gian',
      'Tọa độ Oxyz',
      'Xác suất',
    ],
  ),
  Subject(
    id: 'van',
    name: 'Ngữ văn',
    icon: Icons.menu_book,
    color: Color(0xFFC2185B),
    compulsory: true,
    topics: ['Thơ', 'Truyện – Kí', 'Văn bản nghị luận'],
  ),
  Subject(
    id: 'anh',
    name: 'Tiếng Anh',
    icon: Icons.translate,
    color: Color(0xFF00897B),
    topics: ['Ngữ pháp', 'Từ vựng', 'Cấu trúc câu'],
  ),
  Subject(
    id: 'ly',
    name: 'Vật lí',
    icon: Icons.bolt,
    color: Color(0xFFF57C00),
    topics: [
      'Dao động cơ',
      'Sóng cơ',
      'Điện xoay chiều',
      'Khí lí tưởng',
      'Từ trường',
      'Hạt nhân',
    ],
  ),
  Subject(
    id: 'hoa',
    name: 'Hóa học',
    icon: Icons.science,
    color: Color(0xFF7B1FA2),
    topics: [
      'Este – Lipit',
      'Cacbohiđrat',
      'Amin – Amino axit',
      'Polime',
      'Đại cương kim loại',
    ],
  ),
  Subject(
    id: 'sinh',
    name: 'Sinh học',
    icon: Icons.biotech,
    color: Color(0xFF388E3C),
    topics: [
      'Di truyền phân tử',
      'Quy luật di truyền',
      'Di truyền quần thể',
      'Đột biến',
      'Sinh thái học',
    ],
  ),
  Subject(
    id: 'su',
    name: 'Lịch sử',
    icon: Icons.account_balance,
    color: Color(0xFF6D4C41),
    topics: [
      'Thế giới sau 1945',
      'Cách mạng tháng Tám',
      'Kháng chiến chống Pháp',
      'Kháng chiến chống Mĩ',
      'Đổi mới',
    ],
  ),
  Subject(
    id: 'dia',
    name: 'Địa lí',
    icon: Icons.public,
    color: Color(0xFF0288D1),
    topics: ['Địa lí tự nhiên', 'Địa lí dân cư', 'Địa lí kinh tế', 'Biển đảo'],
  ),
  Subject(
    id: 'gdktpl',
    name: 'GD Kinh tế & Pháp luật',
    icon: Icons.gavel,
    color: Color(0xFFD84315),
    topics: ['Kinh tế thị trường', 'Thuế và bảo hiểm', 'Pháp luật và công dân'],
  ),
  Subject(
    id: 'tin',
    name: 'Tin học',
    icon: Icons.computer,
    color: Color(0xFF455A64),
    topics: [
      'Mạng máy tính',
      'Cơ sở dữ liệu',
      'Trí tuệ nhân tạo',
      'HTML & CSS',
    ],
  ),
];

Subject subjectById(String id) => kSubjects.firstWhere((s) => s.id == id);
