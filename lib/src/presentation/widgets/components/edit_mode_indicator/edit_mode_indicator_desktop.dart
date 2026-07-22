import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart' as th;
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/chat_editor_ghost_icon_button.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Индикатор режима редактирования сообщения для десктопной версии.
///
/// Показывает иконку карандаша, заголовок «Редактирование», превью старого
/// сообщения и кнопку отмены. По нажатию на отмену отправляется [ComposeContext$Clear].
class EditModeIndicatorDesktop extends StatelessWidget {
  const EditModeIndicatorDesktop({
    super.key,
    this.editingContext,
    this.mentionConfig,
  });

  /// Контекст редактирования с оригинальным документом для превью старого сообщения.
  final ChatMessageComposerComposeContextEditing? editingContext;

  /// Конфигурация отображения упоминаний в превью.
  final MentionConfig? mentionConfig;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final localization = context.read<ChatMessageComposerLocalizationRepository>();

    final delta = editingContext?.originalDocument.toDelta();
    final hasContent = delta != null && delta.toPlainText.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: th.ChatEditorSpacing.px4),
      child: SizedBox(
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            border: Border.all(color: colors.borderSubtle),
            borderRadius: ChatEditorRadii.br8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Icon(
                ChatEditorIcons.edit,
                size: ChatEditorSpacing.px20,
                color: colors.brandDefault,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: th.ChatEditorSpacing.px12,
                    vertical: th.ChatEditorSpacing.px8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localization.editingMessage,
                        style: ChatEditorTypography.label.m12_18.copyWith(
                          color: colors.brandDefault,
                        ),
                      ),
                      if (hasContent)
                        DeltaTextView(
                          delta: delta,
                          mentionConfig: mentionConfig,
                          defaultStyle: ChatEditorTypography.label.r12_18
                              .copyWith(color: colors.textStrong),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          emojiOnlySize: null,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ChatEditorGhostIconButton.md(
                onTap: () => context
                    .read<ComposeContextBloc>()
                    .add(const ComposeContext$Clear()),
                icon: ChatEditorIcons.closeRegularMd,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
