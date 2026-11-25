import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';
import '../utils/format.dart';
import 'quiz_screen.dart';

/// Kết quả sau khi nộp bài, kèm phần xem lại từng câu.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.subject,
    required this.questions,
    required this.answers,
    required this.result,
    this.timeLimit,
  });

  final Subject subject;
  final List<Question> questions;
  final List<UserAnswer> answers;
  final QuizResult result;
  final Duration? timeLimit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scale10 = result.total == 0 ? 0.0 : result.score / result.total * 10;
    final percent = result.percent;
    final message = percent >= 80
        ? 'Xuất sắc! Hãy giữ phong độ này.'
        : percent >= 50
            ? 'Khá tốt! Xem lại các câu sai để tiến bộ hơn.'
            : 'Cố lên! Ôn lại kiến thức và thử lần nữa nhé.';

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả · ${subject.name}'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: subject.color.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    formatScore(double.parse(scale10.toStringAsFixed(2))),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: subject.color,
                        ),
                  ),
                  const Text('điểm (thang 10)'),
                  const SizedBox(height: 8),
                  Text(
                    '${formatScore(result.score)}/${result.total} điểm câu hỏi · ${percent.round()}%',
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Trang chủ'),
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Làm lại'),
                  onPressed: () => _retry(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Xem lại bài làm',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < questions.length; i++)
            _buildReviewItem(context, i, scheme),
        ],
      ),
    );
  }

  void _retry(BuildContext context) {
    final list = [...questions]..shuffle();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          subject: subject,
          questions: list,
          mode: result.mode,
          topic: result.topic,
          timeLimit: timeLimit,
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, int i, ColorScheme scheme) {
    final q = questions[i];
    final a = answers[i];
    final s = q.score(a);
    final Color color;
    final IconData icon;
    if (s >= 1.0) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (s > 0) {
      color = Colors.orange;
      icon = Icons.timelapse;
    } else {
      color = scheme.error;
      icon = Icons.cancel;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          'Câu ${i + 1}: ${q.text}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(q.topic),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.text),
          const SizedBox(height: 10),
          Text('Bạn trả lời: ${q.describeAnswer(a)}'),
          const SizedBox(height: 4),
          Text(
            'Đáp án đúng: ${q.correctLabel}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text('Giải thích: ${q.explanation}'),
        ],
      ),
    );
  }
}
