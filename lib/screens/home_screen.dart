import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/subjects_data.dart';
import '../models/subject.dart';
import '../providers/progress_provider.dart';
import '../widgets/countdown_card.dart';
import 'subject_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickElectives(BuildContext context) async {
    final p = context.read<ProgressProvider>();
    final selected = {...p.electives};
    final electives = kSubjects.where((s) => !s.compulsory).toList();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Chọn 2 môn tự chọn'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final s in electives)
                  CheckboxListTile(
                    value: selected.contains(s.id),
                    title: Text(s.name),
                    secondary: Icon(s.icon, color: s.color),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          if (selected.length < 2) selected.add(s.id);
                        } else {
                          selected.remove(s.id);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: selected.length == 2
                  ? () {
                      p.setElectives(selected);
                      Navigator.pop(ctx);
                    }
                  : null,
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressProvider>();
    final subjects = p.mySubjects;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ôn thi tốt nghiệp THPT'),
        actions: [
          IconButton(
            tooltip: 'Chọn môn tự chọn',
            icon: const Icon(Icons.tune),
            onPressed: () => _pickElectives(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CountdownCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrange,
                  value: '${p.streak}',
                  label: 'ngày học liên tiếp',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.emoji_events_outlined,
                  color: Colors.amber.shade800,
                  value: p.overallAveragePercent == null
                      ? '—'
                      : '${p.overallAveragePercent!.round()}%',
                  label: 'điểm trung bình',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Môn thi của bạn', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              for (final s in subjects) _SubjectCard(subject: s),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressProvider>();
    final avg = p.averagePercentFor(subject.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: subject.color.withValues(alpha: 0.12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SubjectScreen(subject: subject),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(subject.icon, color: subject.color, size: 32),
              const Spacer(),
              Text(
                subject.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                avg == null ? 'Chưa làm bài' : 'TB ${avg.round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: avg == null ? 0 : avg / 100,
                color: subject.color,
                backgroundColor: subject.color.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
