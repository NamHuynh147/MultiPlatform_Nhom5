import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/subject.dart';
import '../providers/progress_provider.dart';
import '../utils/format.dart';
import '../widgets/question_view.dart';
import 'result_screen.dart';

const String kModePractice = 'Luyện tập';
const String kModeExam = 'Thi thử';

/// Màn hình làm bài. Chế độ luyện tập: kiểm tra đáp án ngay từng câu.
/// Chế độ thi thử: tính giờ, chỉ xem kết quả sau khi nộp bài.
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.subject,
    required this.questions,
    required this.mode,
    this.topic,
    this.timeLimit,
  });

  final Subject subject;
  final List<Question> questions;
  final String mode;
  final String? topic;
  final Duration? timeLimit;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<UserAnswer> _answers =
      List.generate(widget.questions.length, (_) => UserAnswer());
  late final List<bool> _revealed =
      List<bool>.filled(widget.questions.length, false);

  int _index = 0;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _finished = false;

  bool get _isExam => widget.mode == kModeExam;
  bool get _isLast => _index == widget.questions.length - 1;

  @override
  void initState() {
    super.initState();
    final limit = widget.timeLimit;
    if (limit != null) {
      _remaining = limit;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _remaining -= const Duration(seconds: 1));
        if (_remaining <= Duration.zero) {
          t.cancel();
          _finish(auto: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thoát khỏi bài làm?'),
        content: const Text('Kết quả của lượt làm này sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      _finished = true;
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  Future<void> _finish({bool auto = false}) async {
    if (_finished) return;

    if (!auto) {
      var unanswered = 0;
      for (var i = 0; i < widget.questions.length; i++) {
        if (!widget.questions[i].isAnswered(_answers[i])) unanswered++;
      }
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nộp bài?'),
          content: Text(
            unanswered == 0
                ? 'Bạn đã trả lời tất cả các câu hỏi.'
                : 'Bạn còn $unanswered câu chưa trả lời.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Làm tiếp'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    if (_finished) return;
    _finished = true;
    _timer?.cancel();

    var total = 0.0;
    final wrong = <String>[];
    final right = <String>[];
    for (var i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final s = q.score(_answers[i]);
      total += s;
      if (s >= 1.0) {
        right.add(q.id);
      } else {
        wrong.add(q.id);
      }
    }
    final result = QuizResult(
      subjectId: widget.subject.id,
      mode: widget.mode,
      topic: widget.topic,
      date: DateTime.now(),
      score: total,
      total: widget.questions.length,
    );
    context
        .read<ProgressProvider>()
        .addResult(result, wrongIds: wrong, rightIds: right);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          subject: widget.subject,
          questions: widget.questions,
          answers: _answers,
          result: result,
          timeLimit: widget.timeLimit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_index];
    final total = widget.questions.length;
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.subject.name} · ${widget.topic ?? widget.mode}'),
          actions: [
            if (widget.timeLimit != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  avatar: Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: _remaining.inSeconds <= 60 ? scheme.error : null,
                  ),
                  label: Text(
                    formatDuration(_remaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _remaining.inSeconds <= 60 ? scheme.error : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: (_index + 1) / total),
            if (_isExam) _buildNavigator(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Câu ${_index + 1}/$total · ${q.typeLabel}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: widget.subject.color,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.text,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    QuestionView(
                      key: ValueKey(q.id),
                      question: q,
                      answer: _answers[_index],
                      revealed: _revealed[_index],
                      onChanged: () => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(q),
          ],
        ),
      ),
    );
  }

  /// Dải số câu để nhảy nhanh (chỉ ở chế độ thi thử).
  Widget _buildNavigator(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: widget.questions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final answered = widget.questions[i].isAnswered(_answers[i]);
          final current = i == _index;
          return GestureDetector(
            onTap: () => setState(() => _index = i),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: current
                  ? scheme.primary
                  : (answered
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 13,
                  color: current
                      ? scheme.onPrimary
                      : (answered
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(Question q) {
    final canCheck = !_isExam &&
        !_revealed[_index] &&
        q.isAnswered(_answers[_index]);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _index > 0 ? () => setState(() => _index--) : null,
                child: const Text('Câu trước'),
              ),
            ),
            if (!_isExam) ...[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: canCheck
                      ? () => setState(() => _revealed[_index] = true)
                      : null,
                  child: const Text('Kiểm tra'),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _isLast ? _finish : () => setState(() => _index++),
                child: Text(_isLast ? 'Nộp bài' : 'Câu sau'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
