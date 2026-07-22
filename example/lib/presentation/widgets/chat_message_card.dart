import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer_example/presentation/utils/mention_config.dart';
import 'package:chat_message_composer_example/presentation/widgets/file_name_chip.dart';
import 'package:chat_message_composer_example/presentation/widgets/image_thumbnail.dart';
import 'package:chat_message_composer_example/presentation/widgets/reply_preview.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/material.dart';

/// Виджет карточки для отображения сообщения чата.
///
/// Отображает документ с текстом, изображения (если есть) и имена файлов
/// (если есть файлы, не являющиеся изображениями).
class ChatMessageCard extends StatelessWidget {
  /// Создает карточку сообщения чата.
  ///
  /// [message] - сообщение для отображения.
  /// [messageId] - идентификатор для редактирования (например индекс в списке).
  /// [onEdit] - вызывается при нажатии «Редактировать».
  /// [onReply] - вызывается при нажатии «Ответить».
  /// [onQuote] - вызывается при нажатии «цирировать».
  /// [replyData] - цитируемое сообщение (если это ответ).
  const ChatMessageCard({
    super.key,
    required this.message,
    this.messageId,
    this.onEdit,
    this.onReply,
    this.onQuote,
    this.replyData,
  });

  final ChatMessageComposerMessageData message;
  final String? messageId;
  final void Function(
    String messageId,
    ChatMessageComposerMessageData message,
  )? onEdit;
  final void Function(
    String messageId,
    ChatMessageComposerMessageData message,
  )? onReply;
  final void Function(
    String messageId,
    ChatMessageComposerMessageData message,
  )? onQuote;
  final ChatMessageComposerMessageData? replyData;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final imageFiles = message.files.where((file) => file.isImage()).toList();
    final nonImageFiles = message.files.where((file) => !file.isImage()).toList();
    final hasText = message.document.toPlainText().trim().isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        color: colors.surfaceSecondary,
        child: Padding(
          padding: const EdgeInsets.all(ChatEditorSpacing.px12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (messageId != null && (onEdit != null || onReply != null))
                Padding(
                  padding: const EdgeInsets.only(bottom: ChatEditorSpacing.px8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onReply != null)
                          TextButton(
                            onPressed: () => onReply!(messageId!, message),
                            child: const Text('Ответить'),
                          ),
                        if (onQuote != null)
                          TextButton(
                            onPressed: () => onQuote!(messageId!, message),
                            child: const Text('цитировать'),
                          ),
                        if (onEdit != null)
                          TextButton(
                            onPressed: () => onEdit!(messageId!, message),
                            child: const Text('Редактировать'),
                          ),
                      ],
                    ),
                  ),
                ),
              if (replyData != null) ReplyPreview(replyData: replyData!),
              if (hasText)
                DeltaTextView(
                  emojiConfig: const EmojiConfig(),
                  delta: message.document.toDelta(),
                  defaultStyle: ChatEditorTypography.body.r16_24,
                  mentionConfig: buildMentionConfig(context),
                ),
              if (imageFiles.isNotEmpty) ...[
                if (hasText) const SizedBox(height: ChatEditorSpacing.px8),
                Wrap(
                  spacing: ChatEditorSpacing.px8,
                  runSpacing: ChatEditorSpacing.px8,
                  children: imageFiles.map((file) => ImageThumbnail(file: file)).toList(),
                ),
              ],
              if (nonImageFiles.isNotEmpty) ...[
                if (hasText || imageFiles.isNotEmpty) const SizedBox(height: ChatEditorSpacing.px8),
                Wrap(
                  spacing: ChatEditorSpacing.px8,
                  runSpacing: ChatEditorSpacing.px8,
                  children: nonImageFiles.map((file) => FileNameChip(file: file)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
