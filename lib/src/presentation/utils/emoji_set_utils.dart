import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Возвращает набор эмодзи с объединёнными ключевыми словами из EN и RU,
/// что позволяет искать смайлы как на русском, так и на английском.
List<CategoryEmoji> getBilingualEmojiSet(Locale _) {
  final ruMap = _buildEmojiMap(emojiSetRussian);

  return emojiSetEnglish.map((category) {
    final mergedEmojis = category.emoji.map((emoji) {
      final ruEmoji = ruMap[emoji.emoji];
      if (ruEmoji == null) return emoji;
      return emoji.copyWith(name: '${emoji.name} | ${ruEmoji.name}');
    }).toList();
    return category.copyWith(emoji: mergedEmojis);
  }).toList();
}

Map<String, Emoji> _buildEmojiMap(List<CategoryEmoji> set) {
  final map = <String, Emoji>{};
  for (final category in set) {
    for (final emoji in category.emoji) {
      map[emoji.emoji] = emoji;
    }
  }
  return map;
}
