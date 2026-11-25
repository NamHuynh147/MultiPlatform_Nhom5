/// Thẻ ghi nhớ: mặt trước là khái niệm / câu hỏi, mặt sau là nội dung cần nhớ.
class Flashcard {
  const Flashcard({
    required this.id,
    required this.subjectId,
    required this.front,
    required this.back,
  });

  final String id;
  final String subjectId;
  final String front;
  final String back;
}
