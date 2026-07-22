import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:cross_file/cross_file.dart';

///
/// Файл с уникальным идентификатором и кешированным размером.
///
final class AttachedFile {
  AttachedFile({
    required this.id,
    required this.cachedSize,
    required this.data,
    this.imageSize,
    this.thumbnailBytes,
    this.contentHash,
  });

  factory AttachedFile.fromXFile({
    required XFile file,
    required String id,
    required int cachedSize,
    Size? imageSize,
    Uint8List? thumbnailBytes,
    int? contentHash,
  }) =>
      AttachedFile(
        id: id,
        data: file,
        cachedSize: cachedSize,
        imageSize: imageSize,
        thumbnailBytes: thumbnailBytes,
        contentHash: contentHash,
      );

  final String id;
  final int cachedSize;
  final XFile data;

  /// Размеры изображения в пикселях (null для не-изображений).
  final Size? imageSize;

  /// Уменьшенная миниатюра изображения (PNG), сгенерированная один раз при
  /// добавлении файла. null для не-изображений и при ошибке декодирования.
  ///
  /// Хранится вместо полных байтов файла, чтобы не удерживать в памяти весь
  /// оригинал (до 50 МБ) на всё время жизни вложения.
  final Uint8List? thumbnailBytes;

  /// Хэш содержимого файла (FNV-1a), используется для дедупликации
  /// clipboard-изображений, у которых [data]`.path` пуст, поэтому дедуп по
  /// пути для них не работает. null для файлов с непустым путём (дедуп по
  /// пути уже покрывает этот случай).
  final int? contentHash;
}
