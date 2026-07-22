import 'package:cross_file/cross_file.dart';

/// Расширения для [XFile] с дополнительными утилитами.
extension XFileExtensions on XFile {
  /// Проверяет, является ли файл изображением.
  bool isImage() {
    return mimeType != null && mimeType!.startsWith('image/');
  }

  /// Форматирует размер файла в читаемый вид (Б, КБ, МБ).
  Future<String> formatFileSize() async {
    final size = await length();
    if (size < 1024) {
      return '${size.toStringAsFixed(0)} Б';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} КБ';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
  }
}
