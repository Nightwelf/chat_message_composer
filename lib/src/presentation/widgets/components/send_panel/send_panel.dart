import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/send_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/at_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/plus_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/smile_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/toggle_format_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Панель управления отправкой сообщений.
///
/// Виджет отображает горизонтальную панель с кнопками для управления
/// содержимым сообщения и его отправкой. Панель включает:
/// - Кнопку "Плюс" для добавления медиафайлов (фото, видео, документы и т.д.)
/// - Кнопку "Смайлик" для вставки эмодзи
/// - Кнопку "@" для упоминаний пользователей
/// - Кнопку форматирования текста
/// - Кнопку отправки сообщения
///
/// Кнопка отправки автоматически активируется, когда документ не пуст
/// или есть прикрепленные файлы.
///
/// Пример использования:
/// ```dart
/// SendPanel(
///   document: document,
///   onPhotoOrVideoTap: () => _handlePhotoOrVideo(),
///   onDocumentTap: () => _handleDocument(),
///   onSendTap: () => _handleSend(),
///   focusNode: focusNode,
/// )
/// ```
class SendPanel extends StatelessWidget {
  const SendPanel({
    required this.document,
    required this.quillController,
    this.onCameraTap,
    this.onPhotoOrVideoTap,
    this.onDocumentTap,
    this.onContactTap,
    this.onPollTap,
    this.onEventTap,
    this.onAtTap,
    this.onTextFormat,
    this.onSendTap,
    this.focusNode,
    this.buttonColorScheme,
    this.isPlusUseBottomSheet = false,
    this.onSmileMobileTap,
    this.isMobileEmojiPanelOpen = false,
    this.emojiEnabled = true,
    super.key,
  });

  final VoidCallback? onPhotoOrVideoTap;
  final VoidCallback? onDocumentTap;
  final VoidCallback? onContactTap;
  final VoidCallback? onPollTap;
  final VoidCallback? onEventTap;

  /// Если null, кнопка "@" не отображается.
  final GestureTapCallback? onAtTap;

  final VoidCallback? onSendTap;

  /// true — панель форматирования открыта, false — закрыта.
  final ValueChanged<bool>? onTextFormat;

  final bool isPlusUseBottomSheet;
  final VoidCallback? onCameraTap;
  final FocusNode? focusNode;
  final Document document;
  final QuillController quillController;
  final ButtonColorScheme? buttonColorScheme;

  /// Если задан — кнопка эмодзи не открывает overlay, а вызывает этот callback.
  final VoidCallback? onSmileMobileTap;

  final bool isMobileEmojiPanelOpen;
  final bool emojiEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComposeContextBloc, ComposeContextState>(
      buildWhen: (previous, current) =>
          previous.composeContext.runtimeType !=
          current.composeContext.runtimeType,
      builder: (context, composeState) {
        final isEditMode =
            composeState.composeContext is ChatMessageComposerComposeContextEditing;
        return Row(
          children: [
            Row(
              spacing: ChatEditorSpacing.px4,
              children: [
                if (!isEditMode)
                  PlusButton(
                    onCameraTap: onCameraTap,
                    isUseBottomSheet: isPlusUseBottomSheet,
                    onPhotoOrVideoTap: onPhotoOrVideoTap,
                    onDocumentTap: onDocumentTap,
                    onContactTap: onContactTap,
                    onPollTap: onPollTap,
                    onEventTap: onEventTap,
                    focusNode: focusNode,
                    buttonColorScheme: buttonColorScheme,
                  ),
                if (emojiEnabled)
                  SmileButton(
                    quillController: quillController,
                    focusNode: focusNode,
                    buttonColorScheme: buttonColorScheme,
                  ),
                if (onAtTap != null)
                  AtButton(
                    onTap: onAtTap,
                    buttonColorScheme: buttonColorScheme,
                  ),
                if (onTextFormat != null && !isEditMode)
                  ToggleFormatButton(
                    icon: ChatEditorIcons.txtFormat,
                    initialPressed: false,
                    focusNode: focusNode,
                    onPressedState: onTextFormat,
                    buttonColorScheme: buttonColorScheme,
                  ),
              ],
            ),
            const Spacer(),
            BlocBuilder<MessageFilesBloc, MessageFilesState>(
              builder: (context, state) => ListenableBuilder(
                listenable: quillController,
                builder: (context, _) => SendButton(
                  onTap: onSendTap,
                  enabled:
                      IsSendEnabled.isEnabled(quillController.document, state),
                  isEditMode: isEditMode,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
