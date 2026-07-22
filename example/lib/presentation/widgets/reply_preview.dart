import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer_example/presentation/utils/mention_config.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/material.dart';

/// Виджет превью цитируемого сообщения внутри карточки.
class ReplyPreview extends StatelessWidget {
  const ReplyPreview({super.key, required this.replyData});

  final ChatMessageComposerMessageData replyData;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return Container(
      margin: const EdgeInsets.only(bottom: ChatEditorSpacing.px8),
      padding: const EdgeInsets.symmetric(
        horizontal: ChatEditorSpacing.px8,
        vertical: ChatEditorSpacing.px4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceQuaternary,
        borderRadius: ChatEditorRadii.br8,
        border: Border(
          left: BorderSide(color: colors.textStrong, width: 2),
        ),
      ),
      child: DeltaTextView(
        delta: replyData.document.toDelta(),
        mentionConfig: buildMentionConfig(context),
        emojiConfig: const EmojiConfig(),
        defaultStyle: ChatEditorTypography.body.r16_24,
      ),
    );
  }
}
