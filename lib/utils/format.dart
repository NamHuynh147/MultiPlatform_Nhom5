String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

String formatDateTime(DateTime d) =>
    '${formatDate(d)} ${_two(d.hour)}:${_two(d.minute)}';

String formatDuration(Duration d) {
  final seconds = d.inSeconds < 0 ? 0 : d.inSeconds;
  return '${_two(seconds ~/ 60)}:${_two(seconds % 60)}';
}

/// Hiển thị điểm: số nguyên thì không có phần thập phân.
String formatScore(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(2);
}
