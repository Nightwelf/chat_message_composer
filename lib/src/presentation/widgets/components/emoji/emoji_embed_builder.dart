import 'package:chat_message_composer/src/domain/entities/emoji_embed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Inline embed builder для эмодзи в QuillEditor.
///
/// Рендерит эмодзи как виджет, обходя проблему с fontFamilyFallback
/// при использовании шрифтов с параметром package (InterV).
/// На Linux: FittedBox рендерит текст при размере 109/DPR px, что даёт
/// ровно 109ppem — размер CBDT-битмапов в Noto Color Emoji.
class EmojiEmbedBuilder implements EmbedBuilder {
  const EmojiEmbedBuilder();

  // Размер CBDT-битмапов в NotoColorEmoji.ttf.
  static const double _notoColorEmojiPpem = 109;

  // Визуальный размер эмодзи в dp — соответствует высоте строки 16px текста.
  static const double _displaySize = 20;

  @override
  String get key => emojiEmbedType;

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data = embedContext.node.value.data;
    final emoji = data is String ? data : '';

    // Вычисляем fontSize так, чтобы text engine рендерил при точном ppem для CBDT.
    // На macOS/iOS/Windows/Android emoji-шрифты векторные — это не влияет на них.
    final emojiFontSize =
        _notoColorEmojiPpem / MediaQuery.devicePixelRatioOf(context);

    return SizedBox.square(
      dimension: _displaySize,
      child: FittedBox(
        child: Text(
          emoji,
          style: TextStyle(
            inherit: false,
            fontSize: emojiFontSize,
            height: 1,
            // Без fontFamily: не наследуем InterV+package, не попадаем
            // в fontconfig-цепочку InterV → DejaVu Sans (outline emoji).
            // fontFamilyFallback идёт напрямую к цветным emoji-шрифтам.
            fontFamilyFallback: const [
              'Apple Color Emoji',
              'Noto Color Emoji',
              'Segoe UI Emoji',
            ],
          ),
        ),
      ),
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) => WidgetSpan(
        child: widget,
        alignment: PlaceholderAlignment.middle,
        baseline: TextBaseline.alphabetic,
      );

  @override
  String toPlainText(Embed node) {
    final data = node.value.data;
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      return data['emoji'] as String? ?? '';
    }
    return '';
  }
}
