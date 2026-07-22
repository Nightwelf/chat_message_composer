abstract class Utils {
  static const maxPreviewLines = 1;

  static String truncatePreview(String text) {
    if (text.isEmpty) return '';
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';
    final lines = trimmed.split('\n');
    if (lines.length <= maxPreviewLines) return trimmed;
    return lines.take(maxPreviewLines).join('\n');
  }
}
