/// Kết quả một lượt làm bài (luyện tập hoặc thi thử).
class QuizResult {
  const QuizResult({
    required this.subjectId,
    required this.mode,
    required this.date,
    required this.score,
    required this.total,
    this.topic,
  });

  final String subjectId;

  /// 'Luyện tập' hoặc 'Thi thử'.
  final String mode;
  final String? topic;
  final DateTime date;

  /// Tổng điểm đạt được (mỗi câu tối đa 1 điểm).
  final double score;

  /// Số câu hỏi.
  final int total;

  double get percent => total == 0 ? 0 : score / total * 100;

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'mode': mode,
        'topic': topic,
        'date': date.toIso8601String(),
        'score': score,
        'total': total,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        subjectId: json['subjectId'] as String,
        mode: json['mode'] as String,
        topic: json['topic'] as String?,
        date: DateTime.parse(json['date'] as String),
        score: (json['score'] as num).toDouble(),
        total: json['total'] as int,
      );
}
