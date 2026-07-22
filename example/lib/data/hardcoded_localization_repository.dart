import 'package:chat_message_composer/chat_message_composer.dart';

/// Пример реализации репозитория локализации с хардкодом русских строк.
///
/// Это демонстрационная реализация для примера использования пакета.
/// В реальном приложении следует использовать систему локализации,
/// например, flutter_localizations или другую библиотеку.
class HardcodedLocalizationRepository
    implements ChatMessageComposerLocalizationRepository {
  const HardcodedLocalizationRepository();
  @override
  String get camera => 'Камера';

  @override
  String get messageText => 'Сообщение';

  @override
  String get insertImageOrVideo => 'Изображение или видео';

  @override
  String get insertDocument => 'Документ';

  @override
  String get attachContact => 'Контакт';

  @override
  String get createPoll => 'Опрос';

  @override
  String get createEvent => 'Мероприятие';

  @override
  String get editingMessage => 'Редактирование сообщения';

  @override
  String mentionPanelError(String error) => 'Ошибка: $error';

  @override
  String get mentionPanelNoUsersFound => 'Пользователи не найдены';

  @override
  String get emojiNotFound => 'Эмодзи не найдены';

  @override
  String get emojiSearch => 'Поиск';

  @override
  String get filesLabel => "файлы";
}
