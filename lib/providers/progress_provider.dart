import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/subjects_data.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';

/// Ngày thi mặc định (chỉ là ước lượng). Học sinh tự cập nhật theo lịch chính
/// thức của Bộ Giáo dục và Đào tạo ngay trong ứng dụng.
final DateTime kDefaultExamDate = DateTime(2027, 6, 11);

const List<String> _defaultElectives = ['anh', 'ly'];

/// Lưu cấu hình và tiến độ học tập của học sinh trên thiết bị.
class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._prefs) {
    _load();
  }

  static Future<ProgressProvider> create() async {
    return ProgressProvider(await SharedPreferences.getInstance());
  }

  static const _kResults = 'results';
  static const _kExam = 'examDate';
  static const _kElectives = 'electives';
  static const _kKnown = 'knownCards';
  static const _kWrong = 'wrongQuestions';
  static const _maxResults = 200;

  final SharedPreferences _prefs;

  List<QuizResult> _results = [];
  DateTime _examDate = kDefaultExamDate;
  Set<String> _electives = _defaultElectives.toSet();
  Set<String> _knownCards = {};
  Set<String> _wrongQuestions = {};

  // ───────────── Truy xuất ─────────────

  List<QuizResult> get results => List.unmodifiable(_results);
  DateTime get examDate => _examDate;
  Set<String> get electives => Set.unmodifiable(_electives);
  Set<String> get wrongQuestions => Set.unmodifiable(_wrongQuestions);

  /// Các môn học sinh đăng ký thi: Toán, Ngữ văn + môn tự chọn.
  List<Subject> get mySubjects => kSubjects
      .where((s) => s.compulsory || _electives.contains(s.id))
      .toList();

  int get daysUntilExam {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _examDate.difference(today).inDays;
  }

  List<QuizResult> resultsFor(String subjectId) =>
      _results.where((r) => r.subjectId == subjectId).toList();

  /// Điểm trung bình (%) của một môn, `null` nếu chưa làm bài nào.
  double? averagePercentFor(String subjectId) {
    final list = resultsFor(subjectId);
    if (list.isEmpty) return null;
    final sum = list.fold<double>(0, (a, r) => a + r.percent);
    return sum / list.length;
  }

  double? get overallAveragePercent {
    if (_results.isEmpty) return null;
    final sum = _results.fold<double>(0, (a, r) => a + r.percent);
    return sum / _results.length;
  }

  /// Số ngày học liên tiếp (tính cả hôm nay, hoặc đến hôm qua nếu hôm nay
  /// chưa làm bài).
  int get streak {
    final days = _results
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();
    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }

  int wrongCountFor(String subjectId) =>
      _wrongQuestions.where((id) => id.startsWith('$subjectId-')).length;

  bool isKnown(String cardId) => _knownCards.contains(cardId);

  int knownCountFor(String subjectId) =>
      _knownCards.where((id) => id.startsWith('$subjectId-')).length;

  // ───────────── Thay đổi ─────────────

  void setExamDate(DateTime date) {
    _examDate = DateTime(date.year, date.month, date.day);
    _prefs.setString(_kExam, _examDate.toIso8601String());
    notifyListeners();
  }

  void setElectives(Set<String> ids) {
    _electives = {...ids};
    _prefs.setStringList(_kElectives, _electives.toList());
    notifyListeners();
  }

  /// Lưu một lượt làm bài và cập nhật danh sách câu cần ôn lại.
  void addResult(
    QuizResult result, {
    Iterable<String> wrongIds = const [],
    Iterable<String> rightIds = const [],
  }) {
    _results.add(result);
    if (_results.length > _maxResults) {
      _results = _results.sublist(_results.length - _maxResults);
    }
    _wrongQuestions
      ..addAll(wrongIds)
      ..removeAll(rightIds);
    _prefs.setString(
      _kResults,
      jsonEncode(_results.map((r) => r.toJson()).toList()),
    );
    _prefs.setStringList(_kWrong, _wrongQuestions.toList());
    notifyListeners();
  }

  void setKnown(String cardId, bool known) {
    if (known) {
      _knownCards.add(cardId);
    } else {
      _knownCards.remove(cardId);
    }
    _prefs.setStringList(_kKnown, _knownCards.toList());
    notifyListeners();
  }

  void resetKnown(String subjectId) {
    _knownCards.removeWhere((id) => id.startsWith('$subjectId-'));
    _prefs.setStringList(_kKnown, _knownCards.toList());
    notifyListeners();
  }

  // ───────────── Nạp dữ liệu ─────────────

  void _load() {
    final raw = _prefs.getString(_kResults);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _results = list
            .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _results = [];
      }
    }
    final exam = _prefs.getString(_kExam);
    if (exam != null) {
      _examDate = DateTime.tryParse(exam) ?? kDefaultExamDate;
    }
    _electives =
        (_prefs.getStringList(_kElectives) ?? _defaultElectives).toSet();
    _knownCards = (_prefs.getStringList(_kKnown) ?? const <String>[]).toSet();
    _wrongQuestions =
        (_prefs.getStringList(_kWrong) ?? const <String>[]).toSet();
  }
}
