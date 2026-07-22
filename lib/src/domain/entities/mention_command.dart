import 'package:chat_message_composer/src/domain/entities/mention.dart';

/// Команда для модификации документа редактора.
sealed class MentionCommand {
  const MentionCommand();
}

/// Команда: заменить '@' на embed mention_input.
final class InsertMentionInputCommand extends MentionCommand {
  const InsertMentionInputCommand({required this.atPosition});

  final int atPosition;
}

/// Команда: вставить упоминание пользователя.
final class InsertMentionCommand extends MentionCommand {
  const InsertMentionCommand({
    required this.mention,
    required this.embedPosition,
  });

  final Mention mention;
  final int embedPosition;
}

/// Команда: отменить ввод упоминания — заменить embed mention_input обратно на текст.
final class CancelMentionInputCommand extends MentionCommand {
  const CancelMentionInputCommand({
    required this.embedPosition,
    required this.query,
    this.addTrailingSpace = false,
  });

  /// Позиция embed mention_input в документе.
  final int embedPosition;

  /// Текст, набранный после '@' (query из embed + текст до курсора).
  final String query;

  /// Нужно ли добавить пробел в конец вставляемого текста.
  /// true — для ESC (пробел не в документе, нужен чтобы не re-триггерить '@').
  /// false — для разделителя (пробел уже есть в query и документе).
  final bool addTrailingSpace;
}
