import 'package:chat_message_composer/src/domain/entities/mention.dart';

/// Репозиторий для получения списка пользователей для упоминаний.
///
/// Предоставляет метод для получения и фильтрации списка пользователей
/// по текстовому запросу.
abstract class MentionRepository {
  /// Получает список пользователей, отфильтрованный по запросу.
  Future<List<Mention>> getMentions(String query);
}
