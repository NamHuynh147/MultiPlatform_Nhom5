import 'package:flutter/material.dart';

import '../models/question.dart';

enum _Mark { none, correct, wrong }

/// Hiển thị một câu hỏi và nhận câu trả lời của học sinh.
///
/// Khi [revealed] = true, câu trả lời bị khóa và hiện đáp án + lời giải.
class QuestionView extends StatefulWidget {
  const QuestionView({
    super.key,
    required this.question,
    required this.answer,
    required this.revealed,
    required this.onChanged,
  });

  final Question question;
  final UserAnswer answer;
  final bool revealed;
  final VoidCallback onChanged;

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.answer.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        switch (q.type) {
          QuestionType.multipleChoice => _buildChoices(),
          QuestionType.trueFalse => _buildTrueFalse(context),
          QuestionType.shortAnswer => _buildShortAnswer(),
        },
        if (widget.revealed) ...[
          const SizedBox(height: 16),
          _buildFeedback(context),
        ],
      ],
    );
  }

  Widget _buildChoices() {
    final q = widget.question;
    return Column(
      children: [
        for (var i = 0; i < q.options.length; i++)
          _OptionTile(
            letter: 'ABCD'[i],
            text: q.options[i],
            selected: widget.answer.choice == i,
            mark: !widget.revealed
                ? _Mark.none
                : (i == q.correctIndex
                    ? _Mark.correct
                    : (widget.answer.choice == i ? _Mark.wrong : _Mark.none)),
            onTap: widget.revealed
                ? null
                : () {
                    widget.answer.choice = i;
                    widget.onChanged();
                  },
          ),
      ],
    );
  }

  Widget _buildTrueFalse(BuildContext context) {
    final q = widget.question;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var i = 0; i < q.options.length; i++)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !widget.revealed
                    ? scheme.outlineVariant
                    : (widget.answer.tf[i] == q.correctTf[i]
                        ? Colors.green
                        : scheme.error),
                width: widget.revealed ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'abcd'[i]}) ${q.options[i]}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: true, label: Text('Đúng')),
                    ButtonSegment(value: false, label: Text('Sai')),
                  ],
                  selected:
                      widget.answer.tf[i] == null ? <bool>{} : {widget.answer.tf[i]!},
                  onSelectionChanged: widget.revealed
                      ? null
                      : (s) {
                          widget.answer.tf[i] = s.isEmpty ? null : s.first;
                          widget.onChanged();
                        },
                ),
                if (widget.revealed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Đáp án: ${q.correctTf[i] ? 'Đúng' : 'Sai'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.answer.tf[i] == q.correctTf[i]
                            ? Colors.green
                            : scheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildShortAnswer() {
    return TextField(
      controller: _controller,
      enabled: !widget.revealed,
      decoration: const InputDecoration(
        labelText: 'Nhập đáp án',
        border: OutlineInputBorder(),
      ),
      onChanged: (v) {
        widget.answer.text = v;
        widget.onChanged();
      },
    );
  }

  Widget _buildFeedback(BuildContext context) {
    final q = widget.question;
    final score = q.score(widget.answer);
    late final Color color;
    late final String title;
    late final IconData icon;
    if (score >= 1.0) {
      color = Colors.green;
      title = 'Chính xác!';
      icon = Icons.check_circle;
    } else if (score > 0) {
      color = Colors.orange;
      title = 'Đúng một phần';
      icon = Icons.timelapse;
    } else {
      color = Theme.of(context).colorScheme.error;
      title = 'Chưa chính xác';
      icon = Icons.cancel;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Đáp án đúng: ${q.correctLabel}'),
          const SizedBox(height: 6),
          Text('Giải thích: ${q.explanation}'),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.mark,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final _Mark mark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = selected ? scheme.primary : scheme.outlineVariant;
    Color fill = selected
        ? scheme.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    IconData? icon;
    if (mark == _Mark.correct) {
      border = Colors.green;
      fill = Colors.green.withValues(alpha: 0.12);
      icon = Icons.check_circle;
    } else if (mark == _Mark.wrong) {
      border = scheme.error;
      fill = scheme.error.withValues(alpha: 0.12);
      icon = Icons.cancel;
    }
    final highlighted = selected || mark != _Mark.none;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: highlighted ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: highlighted ? border : scheme.surfaceContainerHighest,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: highlighted ? Colors.white : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(text)),
                if (icon != null) Icon(icon, color: border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
