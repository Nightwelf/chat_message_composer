import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart' as theme;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

/// Утилита для получения виджета с иконкой типа файла.
///
/// Предоставляет статические методы для создания виджетов, отображающих
/// иконку файла с цветным тегом расширения. Иконка состоит из базовой SVG-иконки
/// и наложенного тега с расширением файла в верхнем регистре.
///
/// Пример использования:
/// ```dart
/// FileTypeIconUtil.getFileTypeIconWidget(
///   'document.pdf',
///   width: 24.0,
///   height: 24.0,
/// )
/// ```
class FileTypeIconUtil {
  FileTypeIconUtil._();

  /// Цвет по умолчанию для тега типа файла.
  ///
  /// Используется для типов файлов, которые не определены в [_fileTypeColors].
  /// Значение: `Color(0xFF0068FA)` (синий).
  static const Color _defaultFileTypeColor = Color(0xFF0068FA);

  /// Map с цветами для различных типов файлов.
  ///
  /// Ключ - расширение файла в нижнем регистре (например, 'pdf', 'jpg').
  /// Значение - цвет для тега расширения.
  ///
  /// Поддерживаемые типы файлов:
  /// - Медиа файлы (mp3, mp4, avi, mov и др.) - фиолетовый (#6E45F0)
  /// - Изображения (jpg, png, gif, svg и др.) - синий (#0068FA)
  /// - Документы (doc, docx, pdf, ppt и др.) - синий/красный
  /// - Архивы (zip, rar) - серый (#41454B)
  /// - И другие типы файлов
  static const Map<String, Color> _fileTypeColors = {
    'fig': Color(0xFF6E45F0),
    'aep': Color(0xFF6E45F0),
    'mp3': Color(0xFF6E45F0),
    'wav': Color(0xFF6E45F0),
    'mp4': Color(0xFF6E45F0),
    'avi': Color(0xFF6E45F0),
    'mov': Color(0xFF6E45F0),
    'mpg': Color(0xFF6E45F0),
    'psd': Color(0xFF0068FA),
    'jpg': Color(0xFF0068FA),
    'jpeg': Color(0xFF0068FA),
    'png': Color(0xFF0068FA),
    'gif': Color(0xFF0068FA),
    'webp': Color(0xFF0068FA),
    'tiff': Color(0xFF0068FA),
    'svg': Color(0xFF0068FA),
    'ico': Color(0xFF0068FA),
    'doc': Color(0xFF0068FA),
    'docx': Color(0xFF0068FA),
    'exe': Color(0xFF0068FA),
    'dmg': Color(0xFF0068FA),
    'ai': Color(0xFFFF5C00),
    'sketch': Color(0xFFFFBA35),
    'blend': Color(0xFFFF9033),
    'cdr': Color(0xFF2FB249),
    'csv': Color(0xFF2FB249),
    'xls': Color(0xFF2FB249),
    'xlsx': Color(0xFF2FB249),
    'html': Color(0xFF2FB249),
    'css': Color(0xFF2FB249),
    'js': Color(0xFF2FB249),
    'json': Color(0xFF2FB249),
    'java': Color(0xFF2FB249),
    'c4d': Color(0xFF41454B),
    'txt': Color(0xFF41454B),
    'zip': Color(0xFF41454B),
    'rar': Color(0xFF41454B),
    'ppt': Color(0xFFDB1F1F),
    'pdf': Color(0xFFDB1F1F),
  };

  /// Получает виджет с иконкой типа файла на основе пути к файлу.
  ///
  /// Создает виджет, состоящий из базовой SVG-иконки файла и цветного тега
  /// с расширением файла в верхнем регистре, расположенного в нижнем левом углу.
  ///
  /// Параметры:
  /// - [filePath] - путь к файлу или имя файла (например, 'document.pdf' или '/path/to/image.jpg').
  /// - [width] - ширина иконки в пикселях (опционально). Если не указано, используется размер по умолчанию SVG.
  /// - [height] - высота иконки в пикселях (опционально). Если не указано, используется размер по умолчанию SVG.
  /// - [color] - цвет иконки (опционально). Если не указано, используется цвет по умолчанию SVG.
  ///
  /// Возвращает [Widget] типа [Stack], содержащий:
  /// - Базовую SVG-иконку из `assets/file_type/file_default.svg`
  /// - Цветной тег с расширением файла (если расширение успешно извлечено)
  ///
  /// Цвет тега определяется на основе расширения файла из [_fileTypeColors].
  /// Если расширение не найдено в карте цветов, используется [_defaultFileTypeColor].
  ///
  /// Примеры:
  /// ```dart
  /// // Базовое использование
  /// FileTypeIconUtil.getFileTypeIconWidget('document.pdf')
  ///
  /// // С указанием размеров
  /// FileTypeIconUtil.getFileTypeIconWidget(
  ///   'image.jpg',
  ///   width: 32.0,
  ///   height: 32.0,
  /// )
  ///
  /// // С указанием цвета иконки
  /// FileTypeIconUtil.getFileTypeIconWidget(
  ///   'video.mp4',
  ///   color: Colors.grey,
  /// )
  /// ```
  static Widget getFileTypeIconWidget(
    String filePath, {
    double? width,
    double? height,
    Color? color,
  }) {
    const iconPath = 'assets/file_default.png';
    final extension = _extractExtension(filePath);
    final fileTypeColor = _getFileTypeColor(extension);

    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Image.asset(
          iconPath,
          width: width,
          height: height,
          color: color,
          package: 'chat_message_composer',
        ),
        if (extension.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.5),
            child: IntrinsicWidth(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fileTypeColor,
                  borderRadius: theme.ChatEditorRadii.br4,
                ),
                child: SizedBox(
                  height: 14.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.25),
                    child: Center(
                      child: Text(
                        extension.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          height: 1,
                          letterSpacing: -0.18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Извлекает расширение файла из пути.
  ///
  /// Анализирует путь к файлу и извлекает расширение, обрабатывая различные форматы путей.
  /// Сначала пытается извлечь расширение из пути файла. Если расширение не найдено,
  /// использует пакет `mime` для определения MIME-типа и получения расширения из него.
  ///
  /// Параметры:
  /// - [filePath] - путь к файлу или имя файла (например, 'document.pdf', '/path/to/file.jpg', 'file.name.txt').
  ///
  /// Возвращает:
  /// - Расширение файла в нижнем регистре (например, 'pdf', 'jpg', 'txt').
  /// - Пустую строку, если расширение не найдено или путь пустой.
  /// - Если расширение больше 4 символов, возвращает только последние 4 символа.
  ///
  /// Примеры:
  /// - `'document.pdf'` → `'pdf'`
  /// - `'image.JPG'` → `'jpg'`
  /// - `'/path/to/file.txt'` → `'txt'`
  /// - `'file'` → попытка определить через MIME-тип
  /// - `'file.verylongextension'` → `'sion'` (последние 4 символа)
  static String _extractExtension(String filePath) {
    if (filePath.isEmpty) {
      return '';
    }

    final parts = filePath.split('.');
    if (parts.length >= 2) {
      final extension = parts.last.toLowerCase();
      if (extension.isNotEmpty) {
        if (extension.length > 4) {
          return extension.substring(extension.length - 4);
        }
        return extension;
      }
    }

    final mimeType = lookupMimeType(filePath);
    if (mimeType != null) {
      final mimeExtension = extensionFromMime(mimeType);
      if (mimeExtension != null && mimeExtension.isNotEmpty) {
        final extension = mimeExtension.toLowerCase();
        if (extension.length > 4) {
          return extension.substring(extension.length - 4);
        }
        return extension;
      }
    }

    return '';
  }

  /// Получает цвет для типа файла на основе расширения.
  ///
  /// Определяет цвет тега расширения файла на основе его типа.
  /// Использует предопределенную карту цветов для различных типов файлов.
  ///
  /// Параметры:
  /// - [extension] - расширение файла в нижнем регистре (например, 'pdf', 'jpg', 'mp4').
  ///
  /// Возвращает:
  /// - Цвет из [_fileTypeColors], если расширение найдено в карте.
  /// - [_defaultFileTypeColor] (синий #0068FA), если расширение не найдено или пустое.
  ///
  /// Примеры:
  /// - `'pdf'` → `Color(0xFFDB1F1F)` (красный)
  /// - `'jpg'` → `Color(0xFF0068FA)` (синий)
  /// - `'mp4'` → `Color(0xFF6E45F0)` (фиолетовый)
  /// - `'unknown'` → `Color(0xFF0068FA)` (синий по умолчанию)
  /// - `''` → `Color(0xFF0068FA)` (синий по умолчанию)
  static Color _getFileTypeColor(String extension) {
    if (extension.isEmpty) {
      return _defaultFileTypeColor;
    }

    return _fileTypeColors[extension] ?? _defaultFileTypeColor;
  }
}
