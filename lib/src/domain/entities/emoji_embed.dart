const String emojiEmbedType = 'emoji';

class EmojiEmbed {
  const EmojiEmbed({required this.emoji});

  factory EmojiEmbed.fromDelta(dynamic data) {
    if (data is String) return EmojiEmbed(emoji: data);
    return const EmojiEmbed(emoji: '');
  }

  final String emoji;

  Map<String, dynamic> toDeltaInsert() => {emojiEmbedType: emoji};

  @override
  String toString() => emoji;
}
