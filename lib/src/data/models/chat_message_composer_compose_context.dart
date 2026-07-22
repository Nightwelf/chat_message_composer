import 'package:chat_message_composer/src/data/models/chat_message_composer_message_data.dart';
import 'package:chat_message_composer/src/data/models/quoted_file_info.dart';
import 'package:cross_file/cross_file.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Контекст compose редактора: обычный ввод, редактирование или цитирование.
sealed class ChatMessageComposerComposeContext extends Equatable {
  const ChatMessageComposerComposeContext();

  @override
  List<Object?> get props => [];
}

/// Обычный режим ввода (без edit/quote/reply).
class ChatMessageComposerComposeContextIdle extends ChatMessageComposerComposeContext {
  const ChatMessageComposerComposeContextIdle({
    this.initialDocument,
    this.initialFiles = const [],
  });

  final Document? initialDocument;
  final List<XFile> initialFiles;

  @override
  List<Object?> get props => [initialDocument, initialFiles];
}

/// Режим редактирования существующего сообщения.
class ChatMessageComposerComposeContextEditing
    extends ChatMessageComposerComposeContext {
  const ChatMessageComposerComposeContextEditing({
    required this.messageId,
    required this.originalDocument,
    this.originalFiles = const [],
  });

  /// Создаёт контекст редактирования по данным сообщения (клонирует document и files).
  factory ChatMessageComposerComposeContextEditing.fromMessage(
    String messageId,
    ChatMessageComposerMessageData message,
  ) =>
      ChatMessageComposerComposeContextEditing(
        messageId: messageId,
        originalDocument: Document.fromDelta(message.document.toDelta()),
        originalFiles: List<XFile>.from(message.files),
      );

  final String messageId;
  final Document originalDocument;
  final List<XFile> originalFiles;

  @override
  List<Object?> get props => [messageId, originalDocument, originalFiles];
}

sealed class ChatMessageComposerComposeContextRQ
    extends ChatMessageComposerComposeContext {
  const ChatMessageComposerComposeContextRQ({
    required this.id,
    required this.delta,
    required this.author,
    this.files = const [],
  });

  final String id;
  final Delta delta;
  final QuotedAuthor author;
  final List<QuotedFileInfo> files;

  bool get isQuoting => this is ChatMessageComposerComposeContextQuoting;
  bool get isReplying => this is ChatMessageComposerComposeContextReplying;

  @override
  List<Object?> get props => [id, delta, author, files];
}

/// Режим цитирования сообщения
class ChatMessageComposerComposeContextQuoting
    extends ChatMessageComposerComposeContextRQ {
  const ChatMessageComposerComposeContextQuoting({
    required super.id,
    required super.delta,
    required super.author,
    super.files = const [],
  });

  factory ChatMessageComposerComposeContextQuoting.fromMessage({
    required String id,
    required ChatMessageComposerMessageData message,
    required QuotedAuthor author,
    List<QuotedFileInfo> files = const [],
  }) =>
      ChatMessageComposerComposeContextQuoting(
        id: id,
        delta: message.document.toDelta().applyListRealIndex,
        author: author,
        files: files,
      );
}

/// Режим ответа на сообщения
class ChatMessageComposerComposeContextReplying
    extends ChatMessageComposerComposeContextRQ {
  const ChatMessageComposerComposeContextReplying({
    required super.id,
    required super.delta,
    required super.author,
    super.files = const [],
  });

  factory ChatMessageComposerComposeContextReplying.fromMessage({
    required String id,
    required ChatMessageComposerMessageData message,
    required QuotedAuthor author,
    List<QuotedFileInfo> files = const [],
  }) =>
      ChatMessageComposerComposeContextReplying(
        id: id,
        delta: message.document.toDelta().applyListRealIndex,
        author: author,
        files: files,
      );
}

abstract class QuotedAuthor {
  String get displayName;
}
