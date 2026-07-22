import 'package:cross_file/cross_file.dart';

abstract class ClipboardFileReader {
  /// Читает файлы/изображения из буфера обмена.
  /// Чистый текст → пустой список.
  Future<List<XFile>> readFiles();
}
