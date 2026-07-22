import 'dart:convert';

import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальное хранилище истории сообщений примера (SharedPreferences).
class ChatMessagesLocalRepository {
  const ChatMessagesLocalRepository();

  static const _storageKey = 'saved_messages';

  Future<List<ChatMessageComposerMessageData>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList(_storageKey);
    if (messagesJson == null || messagesJson.isEmpty) return const [];

    final loadedMessages = <ChatMessageComposerMessageData>[];
    for (final deltaJson in messagesJson) {
      try {
        final deltaList = jsonDecode(deltaJson) as List<dynamic>;
        final deltaOperations = deltaList.map((item) => item as Map<String, dynamic>).toList();
        loadedMessages.add(ChatMessageComposerMessageData(
          document: Document.fromJson(deltaOperations),
          files: const [],
        ));
      } catch (_) {
        // Пропускаем повреждённую запись.
      }
    }
    return loadedMessages;
  }

  Future<void> save(List<ChatMessageComposerMessageData> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson =
        messages.map((message) => jsonEncode(message.document.toDelta().toJson())).toList();
    await prefs.setStringList(_storageKey, messagesJson);
  }
}
