import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/chat_editor_ghost_icon_button.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Билдер для отображения изображения с авторизацией.
///
/// Используется в [ReplyQuotedMessagePreview] для превью первого файла-изображения.
/// Пакет не знает о механизме авторизации, поэтому загрузка делегируется
/// потребителю через этот callback.
typedef QuotedImageBuilder = Widget Function(BuildContext context, String url);

/// Превью ответа/цитируемого сообщения над полем ввода.
///
/// Показывает автора (если есть), сокращённый текст и кнопку закрытия.
/// Если сообщение содержит только файлы (текст пустой), показывает `filesLabel`
/// из локализации и превью первого файла-изображения (если передан [imageBuilder]).
/// По нажатию на закрытие отправляется [ComposeContext$Clear].
class ReplyQuotedMessagePreview extends StatelessWidget {
  const ReplyQuotedMessagePreview({
    required this.rqContext,
    required this.isPlatformMobile,
    this.mentionConfig,
    this.imageBuilder,
    super.key,
  });

  final ChatMessageComposerComposeContextRQ rqContext;
  final MentionConfig? mentionConfig;
  final bool isPlatformMobile;

  /// Билдер для отображения изображений с авторизацией.
  /// Если не передан, превью изображений не отображается.
  final QuotedImageBuilder? imageBuilder;

  static const _maxPreviewLines = 1;
  static const _imageThumbnailSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final quotedDelta = rqContext.delta;
    final authorName = rqContext.author.displayName;
    final files = rqContext.files;
    final isTextEmpty = quotedDelta.toPlainText.trim().isEmpty;

    final firstImageFile = files.isNotEmpty
        ? files.firstWhere((f) => f.isImage, orElse: () => files.first)
        : null;
    final showImagePreview = firstImageFile?.isImage ?? false;

    final decoration = isPlatformMobile
        ? BoxDecoration(
            color: colors.surfaceSecondary,
            border: Border(top: BorderSide(color: colors.borderSubtle)),
          )
        : BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: ChatEditorRadii.br8,
            border: Border.all(color: colors.borderSubtle),
          );

    final content = SizedBox(
      height: ChatEditorSpacing.px56,
      child: DecoratedBox(
        decoration: decoration,
        child: Row(
          children: [
            SizedBox(
              width: ChatEditorSpacing.px36,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  rqContext.isReplying
                      ? ChatEditorIcons.arrowAnswer
                      : ChatEditorIcons.quote,
                  size: ChatEditorSpacing.px24,
                  color: colors.brandDefault,
                ),
              ),
            ),
            const SizedBox(width: ChatEditorSpacing.px8),
            if (showImagePreview)
              Padding(
                padding: const EdgeInsets.only(
                    right: ChatEditorSpacing.px8,
                    bottom: ChatEditorSpacing.px6,
                    top: ChatEditorSpacing.px6),
                child: ClipRRect(
                  borderRadius: ChatEditorRadii.br4,
                  child: SizedBox.square(
                    dimension: _imageThumbnailSize,
                    child: imageBuilder!(context, firstImageFile!.url),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (authorName.isNotEmpty)
                    Text(
                      authorName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textStrong,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (isTextEmpty && files.isNotEmpty)
                    const _FilesLabel()
                  else
                    DeltaTextView(
                      delta: quotedDelta,
                      maxLines: _maxPreviewLines,
                      overflow: TextOverflow.ellipsis,
                      mentionConfig: mentionConfig,
                      defaultStyle: ChatEditorTypography.body.r16_24,
                    ),
                ],
              ),
            ),
            SizedBox(
              height: ChatEditorSpacing.px56,
              width: ChatEditorSpacing.px56,
              child: Center(
                child: ChatEditorGhostIconButton.md(
                  onTap: () => context
                      .read<ComposeContextBloc>()
                      .add(const ComposeContext$Clear()),
                  icon: ChatEditorIcons.closeRegularMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isPlatformMobile) return content;
    return Padding(
      padding: const EdgeInsets.only(bottom: ChatEditorSpacing.px4),
      child: content,
    );
  }
}

class _FilesLabel extends StatelessWidget {
  const _FilesLabel();

  @override
  Widget build(BuildContext context) {
    final localization = context.read<ChatMessageComposerLocalizationRepository>();
    final colors = context.chatColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ChatEditorIcons.paperclip,
          size: 14,
          color: colors.textSecondary,
        ),
        const SizedBox(width: 2),
        Text(
          localization.filesLabel,
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
