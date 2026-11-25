import 'package:flutter/material.dart';

/// Một môn thi tốt nghiệp THPT.
class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.topics,
    this.compulsory = false,
  });

  /// Mã môn, không chứa dấu '-' (dùng làm tiền tố cho id câu hỏi / flashcard).
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  /// Danh sách chuyên đề. Tên chuyên đề phải khớp với trường `topic` của câu hỏi.
  final List<String> topics;

  /// Môn bắt buộc (Toán, Ngữ văn).
  final bool compulsory;
}
