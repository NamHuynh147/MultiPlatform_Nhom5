import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/flashcards_data.dart';
import '../models/flashcard.dart';
import '../models/subject.dart';
import '../providers/progress_provider.dart';

/// Học flashcard: chạm vào thẻ để lật, rồi đánh dấu "Đã nhớ" / "Chưa nhớ".
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.subject});

  final Subject subject;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late List<Flashcard> _deck;
  int _index = 0;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _deck = flashcardsFor(widget.subject.id);
  }

  void _restart({required bool onlyUnknown}) {
    final p = context.read<ProgressProvider>();
    final all = flashcardsFor(widget.subject.id);
    setState(() {
      _deck = onlyUnknown ? all.where((c) => !p.isKnown(c.id)).toList() : all;
      _index = 0;
      _flipped = false;
    });
  }

  void _answer(bool known) {
    context.read<ProgressProvider>().setKnown(_deck[_index].id, known);
    setState(() {
      _index++;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final p = context.watch<ProgressProvider>();
    final total = flashcardsFor(subject.id).length;
    final done = _index >= _deck.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard · ${subject.name}'),
        actions: [
          IconButton(
            tooltip: 'Xóa tiến độ ghi nhớ',
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              p.resetKnown(subject.id);
              _restart(onlyUnknown: false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: done ? _buildDone(context, p, total) : _buildCard(context, p, total),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ProgressProvider p, int total) {
    final subject = widget.subject;
    final card = _deck[_index];
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Thẻ ${_index + 1}/${_deck.length} · Đã nhớ ${p.knownCountFor(subject.id)}/$total',
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _index / _deck.length,
          color: subject.color,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _flipped = !_flipped),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey('${card.id}-$_flipped'),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _flipped
                      ? subject.color.withValues(alpha: 0.15)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: subject.color, width: 2),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _flipped ? 'NỘI DUNG' : 'CÂU HỎI / KHÁI NIỆM',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: subject.color,
                                letterSpacing: 1,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _flipped ? card.back : card.front,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (!_flipped) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Chạm để lật thẻ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Chưa nhớ'),
                onPressed: _flipped ? () => _answer(false) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Đã nhớ'),
                onPressed: _flipped ? () => _answer(true) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context, ProgressProvider p, int total) {
    final known = p.knownCountFor(widget.subject.id);
    final unknown = total - known;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration_outlined,
              size: 64, color: widget.subject.color),
          const SizedBox(height: 16),
          Text(
            _deck.isEmpty ? 'Bạn đã nhớ hết các thẻ!' : 'Hoàn thành lượt học!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Đã nhớ $known/$total thẻ'),
          const SizedBox(height: 24),
          if (unknown > 0)
            FilledButton(
              onPressed: () => _restart(onlyUnknown: true),
              child: Text('Ôn $unknown thẻ chưa nhớ'),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _restart(onlyUnknown: false),
            child: const Text('Học lại từ đầu'),
          ),
        ],
      ),
    );
  }
}
