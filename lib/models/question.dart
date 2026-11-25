import '../utils/text_utils.dart';

const String _upperLetters = 'ABCD';
const String _lowerLetters = 'abcd';

/// Ba dạng câu hỏi theo cấu trúc đề thi tốt nghiệp THPT mới.
enum QuestionType {
  /// Phần I: trắc nghiệm nhiều lựa chọn (4 phương án, 1 đáp án đúng).
  multipleChoice,

  /// Phần II: trắc nghiệm đúng/sai (4 ý a, b, c, d).
  trueFalse,

  /// Phần III: trả lời ngắn.
  shortAnswer,
}

/// Câu trả lời của học sinh cho một câu hỏi.
class UserAnswer {
  int? choice;
  final List<bool?> tf = List<bool?>.filled(4, null);
  String text = '';
}

class Question {
  /// Câu trắc nghiệm nhiều lựa chọn. [correct] là chỉ số (0–3) của đáp án đúng.
  const Question.mc({
    required this.id,
    required this.subjectId,
    required this.topic,
    required this.text,
    required this.options,
    required int correct,
    required this.explanation,
  })  : type = QuestionType.multipleChoice,
        correctIndex = correct,
        correctTf = const [],
        correctText = null;

  /// Câu đúng/sai gồm 4 ý trong [options]; [correctTf] là đáp án của từng ý.
  const Question.tf({
    required this.id,
    required this.subjectId,
    required this.topic,
    required this.text,
    required this.options,
    required this.correctTf,
    required this.explanation,
  })  : type = QuestionType.trueFalse,
        correctIndex = null,
        correctText = null;

  /// Câu trả lời ngắn.
  const Question.sa({
    required this.id,
    required this.subjectId,
    required this.topic,
    required this.text,
    required String answer,
    required this.explanation,
  })  : type = QuestionType.shortAnswer,
        options = const [],
        correctIndex = null,
        correctTf = const [],
        correctText = answer;

  /// Quy ước: '<mã môn>-q<số>', ví dụ 'toan-q1'.
  final String id;
  final String subjectId;
  final String topic;
  final QuestionType type;
  final String text;
  final List<String> options;
  final int? correctIndex;
  final List<bool> correctTf;
  final String? correctText;
  final String explanation;

  String get typeLabel {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Trắc nghiệm';
      case QuestionType.trueFalse:
        return 'Đúng / Sai';
      case QuestionType.shortAnswer:
        return 'Trả lời ngắn';
    }
  }

  /// Học sinh đã trả lời đủ chưa.
  bool isAnswered(UserAnswer a) {
    switch (type) {
      case QuestionType.multipleChoice:
        return a.choice != null;
      case QuestionType.trueFalse:
        return a.tf.every((e) => e != null);
      case QuestionType.shortAnswer:
        return a.text.trim().isNotEmpty;
    }
  }

  /// Điểm của câu hỏi trong khoảng 0..1.
  ///
  /// Câu đúng/sai tính theo thang của đề thi: đúng 1 ý = 0,1; 2 ý = 0,25;
  /// 3 ý = 0,5; 4 ý = 1 (quy về thang 1 điểm).
  double score(UserAnswer a) {
    switch (type) {
      case QuestionType.multipleChoice:
        return a.choice == correctIndex ? 1.0 : 0.0;
      case QuestionType.trueFalse:
        var correct = 0;
        for (var i = 0; i < correctTf.length; i++) {
          if (a.tf[i] == correctTf[i]) correct++;
        }
        const table = <double>[0.0, 0.1, 0.25, 0.5, 1.0];
        return table[correct];
      case QuestionType.shortAnswer:
        return answersMatch(a.text, correctText ?? '') ? 1.0 : 0.0;
    }
  }

  /// Đáp án đúng ở dạng chuỗi để hiển thị.
  String get correctLabel {
    switch (type) {
      case QuestionType.multipleChoice:
        final i = correctIndex ?? 0;
        return '${_upperLetters[i]}. ${options[i]}';
      case QuestionType.trueFalse:
        final parts = <String>[];
        for (var i = 0; i < correctTf.length; i++) {
          parts.add('${_lowerLetters[i]}) ${correctTf[i] ? 'Đúng' : 'Sai'}');
        }
        return parts.join('   ');
      case QuestionType.shortAnswer:
        return correctText ?? '';
    }
  }

  /// Câu trả lời của học sinh ở dạng chuỗi để hiển thị khi xem lại bài.
  String describeAnswer(UserAnswer a) {
    switch (type) {
      case QuestionType.multipleChoice:
        final c = a.choice;
        if (c == null) return 'Chưa trả lời';
        return '${_upperLetters[c]}. ${options[c]}';
      case QuestionType.trueFalse:
        final parts = <String>[];
        for (var i = 0; i < correctTf.length; i++) {
          final v = a.tf[i];
          final label = v == null ? '—' : (v ? 'Đúng' : 'Sai');
          parts.add('${_lowerLetters[i]}) $label');
        }
        return parts.join('   ');
      case QuestionType.shortAnswer:
        return a.text.trim().isEmpty ? 'Chưa trả lời' : a.text.trim();
    }
  }
}
