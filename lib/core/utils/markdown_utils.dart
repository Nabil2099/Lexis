class MarkdownUtils {
  const MarkdownUtils._();

  static String toPlainText(String markdown) {
    return markdown
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        .replaceAll(RegExp(r'`([^`]*)`'), r'$1')
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]+\)'), ' ')
        .replaceAllMapped(
            RegExp(r'\[([^\]]+)\]\([^)]+\)'), (match) => match.group(1) ?? '')
        .replaceAll(RegExp(r'^[#>\-\*\+]+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'[*_~>#\[\]()]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static int wordCount(String value) {
    final text = toPlainText(value);
    if (text.isEmpty) return 0;
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
  }
}
