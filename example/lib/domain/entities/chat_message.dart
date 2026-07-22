import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:equatable/equatable.dart';

/// Сообщение в чате примера.
///
/// Реализованы только варианты, которые фактически используются экраном чата
/// ([StandardUserMessage], [ReplyUserMessage]).
sealed class ChatMessage extends Equatable {
  const ChatMessage();

  @override
  List<Object?> get props => [];
}

sealed class UserMessage extends ChatMessage {
  const UserMessage({this.data});

  final ChatMessageComposerMessageData? data;

  @override
  List<Object?> get props => [data];
}

class StandardUserMessage extends UserMessage {
  const StandardUserMessage({super.data});
}

class ReplyUserMessage extends UserMessage {
  const ReplyUserMessage({super.data, this.replyData});

  final ChatMessageComposerMessageData? replyData;

  @override
  List<Object?> get props => [data, replyData];
}
