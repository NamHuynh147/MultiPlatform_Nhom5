import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/flashcards_data.dart';
import '../data/subjects_data.dart';
import '../models/quiz_result.dart';
import '../providers/progress_provider.dart';
import '../utils/format.dart';

/// Thống kê tiến độ học tập theo môn và lịch sử làm bài.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressProvider>();
    final textTheme = Theme.of(context).textTheme;
    final recent = p.results.reversed.take(15).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tiến độ học tập')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _Figure(
                  value: '${p.results.length}',
                  label: 'lượt làm bài',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Figure(
                  value: p.overallAveragePercent == null
                      ? '—'
                      : '${p.overallAveragePercent!.round()}%',
                  label: 'điểm trung bình',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Figure(value: '${p.streak}', label: 'ngày liên tiếp'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Theo môn', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final s in p.mySubjects)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(s.icon, color: s.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.name,
                            style: textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          p.averagePercentFor(s.id) == null
                              ? 'Chưa làm bài'
                              : '${p.averagePercentFor(s.id)!.round()}%',
                          style: textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (p.averagePercentFor(s.id) ?? 0) / 100,
                      color: s.color,
                      backgroundColor: s.color.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${p.resultsFor(s.id).length} lượt làm · '
                      '${p.wrongCountFor(s.id)} câu cần ôn · '
                      'flashcard ${p.knownCountFor(s.id)}/${flashcardsFor(s.id).length}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text('Lịch sử gần đây', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Chưa có lượt làm bài nào.')),
            )
          else
            for (final r in recent) _HistoryTile(result: r),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final matches = kSubjects.where((s) => s.id == result.subjectId);
    final subject = matches.isEmpty ? null : matches.first;
    final color = subject?.color ?? Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(subject?.icon ?? Icons.quiz_outlined, color: color),
        ),
        title: Text('${subject?.name ?? result.subjectId} · ${result.topic ?? result.mode}'),
        subtitle: Text('${result.mode} · ${formatDateTime(result.date)}'),
        trailing: Text(
          '${formatScore(result.score)}/${result.total}\n${result.percent.round()}%',
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}
