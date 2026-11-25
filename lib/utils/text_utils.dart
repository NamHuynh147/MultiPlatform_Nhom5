/// Bỏ dấu tiếng Việt để so sánh đáp án linh hoạt hơn.
final Map<String, String> _foldMap = _buildFoldMap();

Map<String, String> _buildFoldMap() {
  const groups = <String, String>{
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  final map = <String, String>{};
  groups.forEach((base, chars) {
    for (final ch in chars.split('')) {
      map[ch] = base;
    }
  });
  return map;
}

/// Chuyển về chữ thường và bỏ dấu tiếng Việt.
String foldVietnamese(String input) {
  final buffer = StringBuffer();
  for (final ch in input.toLowerCase().split('')) {
    buffer.write(_foldMap[ch] ?? ch);
  }
  return buffer.toString();
}

/// Chuẩn hóa đáp án nhập tay: bỏ dấu, bỏ khoảng trắng, đổi ',' thành '.'.
String normalizeAnswer(String input) {
  return foldVietnamese(input).replaceAll(',', '.').replaceAll(RegExp(r'\s+'), '');
}

/// So sánh hai đáp án (hỗ trợ so sánh số với sai số nhỏ).
bool answersMatch(String userInput, String expected) {
  final x = normalizeAnswer(userInput);
  final y = normalizeAnswer(expected);
  if (x.isEmpty) return false;
  if (x == y) return true;
  final nx = double.tryParse(x);
  final ny = double.tryParse(y);
  if (nx != null && ny != null) {
    return (nx - ny).abs() < 1e-6;
  }
  return false;
}
