part of 'message_files_bloc.dart';

/// Базовый класс для состояний управления файлами.
sealed class MessageFilesState extends Equatable {
  const MessageFilesState();

  @override
  List<Object?> get props => [];
}

/// Состояние с загруженными файлами.
/// Начальное состояние - это пустой список файлов.
final class MessageFilesState$Data extends MessageFilesState {
  const MessageFilesState$Data({this.files = const [], this.isProcessing = false});

  /// Список файлов в порядке их добавления.
  final List<AttachedFile> files;

  /// true, пока идёт асинхронное добавление файла(ов) (чтение размера,
  /// декодирование превью). Пока флаг true, отправку сообщения следует
  /// блокировать — иначе файл, добавление которого ещё не завершилось,
  /// не попадёт в отправляемое сообщение.
  final bool isProcessing;

  MessageFilesState$Data copyWith({List<AttachedFile>? files, bool? isProcessing}) =>
      MessageFilesState$Data(
        files: files ?? this.files,
        isProcessing: isProcessing ?? this.isProcessing,
      );

  @override
  List<Object?> get props => [files, isProcessing];
}
