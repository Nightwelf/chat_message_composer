part of 'message_files_bloc.dart';

/// Базовый класс для событий управления файлами.
sealed class MessageFilesEvent extends Equatable {
  const MessageFilesEvent();

  @override
  List<Object?> get props => [];
}

/// Событие добавления файлов.
final class MessageFiles$Add extends MessageFilesEvent {
  const MessageFiles$Add(this.files);

  final List<XFile> files;

  @override
  List<Object?> get props => [files];
}

/// Событие удаления одного файла.
final class MessageFiles$Remove extends MessageFilesEvent {
  const MessageFiles$Remove(this.fileId);

  final String fileId;

  @override
  List<Object?> get props => [fileId];
}

/// Событие удаления нескольких файлов.
final class MessageFiles$RemoveMultiple extends MessageFilesEvent {
  const MessageFiles$RemoveMultiple(this.fileIds);

  final List<String> fileIds;

  @override
  List<Object?> get props => [fileIds];
}

/// Событие удаления всех файлов.
final class MessageFiles$Clear extends MessageFilesEvent {
  const MessageFiles$Clear();
}
