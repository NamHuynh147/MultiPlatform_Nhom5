import 'package:flutter_test/flutter_test.dart';
import 'package:on_thi_thpt/data/flashcards_data.dart';
import 'package:on_thi_thpt/data/questions_data.dart';
import 'package:on_thi_thpt/data/subjects_data.dart';
import 'package:on_thi_thpt/models/question.dart';
import 'package:on_thi_thpt/utils/text_utils.dart';

void main() {
  group('Chấm điểm câu hỏi', () {
    test('trắc nghiệm nhiều lựa chọn', () {
      const q = Question.mc(
        id: 'x-q1',
        subjectId: 'x',
        topic: 't',
        text: '?',
        options: ['a', 'b', 'c', 'd'],
        correct: 2,
        explanation: '',
      );
      final right = UserAnswer()..choice = 2;
      final wrong = UserAnswer()..choice = 1;
      expect(q.score(right), 1.0);
      expect(q.score(wrong), 0.0);
      expect(q.score(UserAnswer()), 0.0);
    });

    test('đúng/sai tính theo số ý đúng: 0 / 0,1 / 0,25 / 0,5 / 1', () {
      const q = Question.tf(
        id: 'x-q2',
        subjectId: 'x',
        topic: 't',
        text: '?',
        options: ['a', 'b', 'c', 'd'],
        correctTf: [true, false, true, true],
        explanation: '',
      );
      UserAnswer answer(List<bool> v) {
        final a = UserAnswer();
        for (var i = 0; i < 4; i++) {
          a.tf[i] = v[i];
        }
        return a;
      }

      expect(q.score(answer([true, false, true, true])), 1.0);
      expect(q.score(answer([true, false, true, false])), 0.5);
      expect(q.score(answer([true, false, false, false])), 0.25);
      expect(q.score(answer([true, true, false, false])), 0.1);
      expect(q.score(answer([false, true, false, false])), 0.0);
    });

    test('trả lời ngắn bỏ qua khoảng trắng, dấu phẩy thập phân', () {
      const q = Question.sa(
        id: 'x-q3',
        subjectId: 'x',
        topic: 't',
        text: '?',
        answer: '2.5',
        explanation: '',
      );
      expect(q.score(UserAnswer()..text = ' 2,5 '), 1.0);
      expect(q.score(UserAnswer()..text = '2.50'), 1.0);
      expect(q.score(UserAnswer()..text = '3'), 0.0);
      expect(q.score(UserAnswer()), 0.0);
    });
  });

  group('Xử lý văn bản', () {
    test('bỏ dấu tiếng Việt', () {
      expect(foldVietnamese('Đường Hồ Chí Minh'), 'duong ho chi minh');
    });

    test('so sánh đáp án', () {
      expect(answersMatch('Etyl  axetat', 'etyl axetat'), isTrue);
      expect(answersMatch('', '1'), isFalse);
    });
  });

  group('Tính toàn vẹn dữ liệu mẫu', () {
    test('id câu hỏi duy nhất và đúng tiền tố môn', () {
      final ids = <String>{};
      for (final q in kQuestions) {
        expect(ids.add(q.id), isTrue, reason: 'trùng id ${q.id}');
        expect(q.id.startsWith('${q.subjectId}-'), isTrue, reason: q.id);
      }
    });

    test('môn và chuyên đề của câu hỏi tồn tại', () {
      for (final q in kQuestions) {
        final subject = subjectById(q.subjectId);
        expect(subject.topics, contains(q.topic), reason: q.id);
      }
    });

    test('cấu trúc đáp án hợp lệ', () {
      for (final q in kQuestions) {
        switch (q.type) {
          case QuestionType.multipleChoice:
            expect(q.options.length, 4, reason: q.id);
            expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
          case QuestionType.trueFalse:
            expect(q.options.length, 4, reason: q.id);
            expect(q.correctTf.length, 4, reason: q.id);
          case QuestionType.shortAnswer:
            expect(q.correctText, isNotEmpty, reason: q.id);
        }
        expect(q.explanation, isNotEmpty, reason: q.id);
      }
    });

    test('mỗi môn đều có câu hỏi và flashcard', () {
      for (final s in kSubjects) {
        expect(questionsFor(s.id), isNotEmpty, reason: s.id);
        expect(flashcardsFor(s.id), isNotEmpty, reason: s.id);
      }
    });

    test('id flashcard duy nhất và đúng tiền tố môn', () {
      final ids = <String>{};
      for (final c in kFlashcards) {
        expect(ids.add(c.id), isTrue, reason: 'trùng id ${c.id}');
        expect(c.id.startsWith('${c.subjectId}-'), isTrue, reason: c.id);
      }
    });
  });
}
