import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';
import '../utils/format.dart';

/// Thẻ đếm ngược đến kỳ thi. Chạm vào nút lịch để đổi ngày thi.
class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key});

  Future<void> _pickDate(BuildContext context, ProgressProvider p) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: p.examDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2028, 12, 31),
      helpText: 'Chọn ngày thi',
    );
    if (picked != null) p.setExamDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressProvider>();
    final scheme = Theme.of(context).colorScheme;
    final days = p.daysUntilExam;

    final String big;
    final String small;
    if (days > 0) {
      big = '$days';
      small = 'ngày nữa đến kỳ thi';
    } else if (days == 0) {
      big = 'Hôm nay';
      small = 'là ngày thi — chúc bạn làm bài tốt!';
    } else {
      big = '—';
      small = 'Ngày thi đã qua, hãy cập nhật ngày thi mới';
    }

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    big,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimaryContainer,
                        ),
                  ),
                  Text(
                    small,
                    style: TextStyle(color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ngày thi: ${formatDate(p.examDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Đổi ngày thi',
              icon: Icon(Icons.edit_calendar, color: scheme.onPrimaryContainer),
              onPressed: () => _pickDate(context, p),
            ),
          ],
        ),
      ),
    );
  }
}
