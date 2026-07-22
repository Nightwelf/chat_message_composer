import 'package:equatable/equatable.dart';
import 'package:flutter_quill/quill_delta.dart';

import '../../../chat_message_composer.dart';

/// Тип действия при отправке из редактора.
sealed class ChatMessageComposerSendAction extends Equatable {
  const ChatMessageComposerSendAction();

  @override
  List<Object?> get props => [];
}

/// Отправка нового сообщения.
class ChatMessageComposerSendActionSend extends ChatMessageComposerSendAction {
  const ChatMessageComposerSendActionSend();
}

/// Редактирование существующего сообщения.
class ChatMessageComposerSendActionEdit extends ChatMessageComposerSendAction {
  const ChatMessageComposerSendActionEdit({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// Отправка сообщения с цитированием (ответ на сообщение).
class ChatMessageComposerSendActionQuote extends ChatMessageComposerSendAction {
  const ChatMessageComposerSendActionQuote({
    required this.quoteToMessageId,
    required this.quotedDelta,
    required this.quotedAuthor,
  });

  final String quoteToMessageId;
  final Delta quotedDelta;
  final QuotedAuthor quotedAuthor;

  @override
  List<Object?> get props => [quoteToMessageId, quotedDelta, quotedAuthor];
}

/// Отправка сообщения с цитированием (ответ на сообщение).
class ChatMessageComposerSendActionReply extends ChatMessageComposerSendAction {
  const ChatMessageComposerSendActionReply({
    required this.replyToMessageId,
    required this.replyDelta,
    required this.replyAuthor,
  });

  final String replyToMessageId;
  final Delta replyDelta;
  final QuotedAuthor replyAuthor;

  @override
  List<Object?> get props => [replyToMessageId, replyDelta, replyAuthor];
}
