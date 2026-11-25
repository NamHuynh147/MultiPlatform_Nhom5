import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/flashcards_data.dart';
import '../data/questions_data.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../providers/progress_provider.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

/// Trang của một môn: thi thử, luyện tập, ôn câu sai, flashcard, chuyên đề.
class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key, required this.subject});

  final Subject subject;

  static const int _examQuestionCount = 20;

  void _openQuiz(
    BuildContext context, {
    required List<Question> questions,
    required String mode,
    String? topic,
    Duration? timeLimit,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          subject: subject,
          questions: questions,
          mode: mode,
          topic: topic,
          timeLimit: timeLimit,
        ),
      ),
    );
  }

  List<Question> _shuffled(List<Question> list) => [...list]..shuffle();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressProvider>();
    final all = questionsFor(subject.id);
    final wrong = all.where((q) => p.wrongQuestions.contains(q.id)).toList();
    final cards = flashcardsFor(subject.id);
    final avg = p.averagePercentFor(subject.id);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: subject.color.withValues(alpha: 0.15),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: subject.color.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(subject.icon, color: subject.color, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${all.length} câu hỏi · ${cards.length} flashcard',
                          style: textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          avg == null
                              ? 'Bạn chưa làm bài nào của môn này.'
                              : 'Điểm trung bình: ${avg.round()}% '
                                  '(${p.resultsFor(subject.id).length} lượt làm bài)',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Luyện tập', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.timer_outlined,
            color: subject.color,
            title: 'Thi thử có tính giờ',
            subtitle: all.isEmpty
                ? 'Chưa có câu hỏi'
                : 'Tối đa $_examQuestionCount câu ngẫu nhiên, nộp bài mới xem đáp án',
            onTap: all.isEmpty
                ? null
                : () {
                    final list =
                        _shuffled(all).take(_examQuestionCount).toList();
                    final minutes = max(5, (list.length * 1.5).ceil());
                    _openQuiz(
                      context,
                      questions: list,
                      mode: kModeExam,
                      timeLimit: Duration(minutes: minutes),
                    );
                  },
          ),
          _ActionTile(
            icon: Icons.shuffle,
            color: subject.color,
            title: 'Luyện tập tổng hợp',
            subtitle: 'Làm tất cả câu hỏi, kiểm tra đáp án ngay từng câu',
            onTap: all.isEmpty
                ? null
                : () => _openQuiz(
                      context,
                      questions: _shuffled(all),
                      mode: kModePractice,
                    ),
          ),
          _ActionTile(
            icon: Icons.replay_circle_filled_outlined,
            color: subject.color,
            title: 'Ôn lại câu làm sai',
            subtitle: wrong.isEmpty
                ? 'Chưa có câu sai nào cần ôn'
                : '${wrong.length} câu cần ôn lại',
            onTap: wrong.isEmpty
                ? null
                : () => _openQuiz(
                      context,
                      questions: _shuffled(wrong),
                      mode: kModePractice,
                      topic: 'Ôn câu sai',
                    ),
          ),
          _ActionTile(
            icon: Icons.style_outlined,
            color: subject.color,
            title: 'Flashcard công thức & kiến thức',
            subtitle: cards.isEmpty
                ? 'Chưa có flashcard'
                : 'Đã nhớ ${p.knownCountFor(subject.id)}/${cards.length} thẻ',
            onTap: cards.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FlashcardScreen(subject: subject),
                      ),
                    ),
          ),
          const SizedBox(height: 16),
          Text('Luyện theo chuyên đề', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final topic in subject.topics)
            Builder(builder: (context) {
              final list = questionsFor(subject.id, topic: topic);
              return _ActionTile(
                icon: Icons.bookmark_outline,
                color: subject.color,
                title: topic,
                subtitle:
                    list.isEmpty ? 'Sắp có câu hỏi' : '${list.length} câu hỏi',
                onTap: list.isEmpty
                    ? null
                    : () => _openQuiz(
                          context,
                          questions: _shuffled(list),
                          mode: kModePractice,
                          topic: topic,
                        ),
              );
            }),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: onTap != null,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
