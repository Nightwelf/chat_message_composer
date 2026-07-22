import 'package:equatable/equatable.dart';

/// Информация о файле для отображения в превью цитируемого сообщения.
class QuotedFileInfo extends Equatable {
  const QuotedFileInfo({
    required this.url,
    required this.name,
    this.mimeType,
  });

  final String url;
  final String name;

  /// MIME-тип файла (например `image/jpeg`, `application/pdf`).
  final String? mimeType;

  bool get isImage => mimeType?.startsWith('image/') ?? false;

  @override
  List<Object?> get props => [url, name, mimeType];
}
