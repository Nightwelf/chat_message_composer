import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ChatMessageComposerContextX on BuildContext {
  void setChatInputInitialContext({
    List<XFile>? initialFiles,
    Document? initialDocument,
  }) {
    read<ComposeContextBloc>().add(
      ComposeContext$Set(
        ChatMessageComposerComposeContextIdle(
          initialDocument: initialDocument,
          initialFiles: initialFiles ?? <XFile>[],
        ),
      ),
    );
  }

  /// Включает режим редактирования сообщения в редакторе.
  void setChatInputEditingContext(
      String messageId, ChatMessageComposerMessageData message) {
    read<ComposeContextBloc>().add(
      ComposeContext$Set(
        ChatMessageComposerComposeContextEditing.fromMessage(messageId, message),
      ),
    );
  }

  /// Включает режим цитирования сообщения в редакторе.
  ///
  /// [files] — файлы цитируемого сообщения для превью.
  void setChatInputQuotingContext({
    required String id,
    required ChatMessageComposerMessageData message,
    required QuotedAuthor author,
    List<QuotedFileInfo> files = const [],
  }) {
    read<ComposeContextBloc>().add(
      ComposeContext$Set(
        ChatMessageComposerComposeContextQuoting.fromMessage(
          id: id,
          message: message,
          author: author,
          files: files,
        ),
      ),
    );
  }

  /// Включает режим ответа на сообщение в редакторе.
  ///
  /// `quotedFiles` — файлы цитируемого сообщения для превью.
  void setChatInputReplyContext({
    required String id,
    required ChatMessageComposerMessageData message,
    required QuotedAuthor author,
    List<QuotedFileInfo> files = const [],
  }) {
    read<ComposeContextBloc>().add(
      ComposeContext$Set(
        ChatMessageComposerComposeContextReplying.fromMessage(
          id: id,
          message: message,
          author: author,
          files: files,
        ),
      ),
    );
  }
}
