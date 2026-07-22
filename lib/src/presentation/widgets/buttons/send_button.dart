import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:delta_text_view/domain/extensions/delta_extensions.dart';
import 'package:flutter/material.dart';

/// Кнопка отправки сообщения с иконкой отправки.
///
/// Используется для отправки сообщений в редакторе чата.
/// Кнопка имеет брендовую цветовую схему и автоматически меняет визуальный стиль
/// в зависимости от состояния: enabled, disabled, hovered, pressed.
class SendButton extends StatelessWidget {
  /// Создает кнопку отправки сообщения.
  ///
  /// [onTap] - колбэк, вызываемый при обычном нажатии на кнопку.
  /// Вызывается только если [enabled] == true.
  ///
  /// [onLongTap] - колбэк, вызываемый при длительном нажатии на кнопку.
  /// Вызывается только если [enabled] == true.
  ///
  /// [enabled] - определяет, активна ли кнопка. По умолчанию true.
  /// Если false, кнопка отображается в отключенном состоянии,
  /// и обработчики нажатий не вызываются.
  ///
  /// [isEditMode] - в режиме редактирования показывается иконка галочки
  /// (подтверждение) вместо иконки отправки.
  const SendButton({
    super.key,
    this.onTap,
    this.onLongTap,
    this.enabled = true,
    this.isEditMode = false,
  });

  /// Колбэк, вызываемый при обычном нажатии на кнопку.
  ///
  /// Вызывается только если кнопка включена ([enabled] == true).
  final VoidCallback? onTap;

  /// Колбэк, вызываемый при длительном нажатии на кнопку.
  ///
  /// Вызывается только если кнопка включена ([enabled] == true).
  final VoidCallback? onLongTap;

  /// Определяет, активна ли кнопка.
  ///
  /// Если false, кнопка отображается в отключенном состоянии,
  /// и обработчики нажатий ([onTap], [onLongTap]) не вызываются.
  final bool enabled;

  /// В режиме редактирования отображается иконка подтверждения (галочка)
  /// вместо иконки отправки.
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final colorScheme = ButtonColorScheme(
      enabled: colors.brandDefault,
      hovered: colors.brandHover,
      pressed: colors.brandPressed,
      disabled: Colors.transparent,
      iconDisabled: colors.textDisabled,
      iconEnabled: colors.contentInverted,
      iconHovered: colors.contentInverted,
      iconPressed: colors.contentInverted,
    );
    return ElevatedButton(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        visualDensity: VisualDensity.standard,
        minimumSize: WidgetStateProperty.all(
          const Size(
            ChatEditorSpacing.px40,
            ChatEditorSpacing.px40,
          ),
        ),
        maximumSize: WidgetStateProperty.all(
          const Size(
            ChatEditorSpacing.px40,
            ChatEditorSpacing.px40,
          ),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.all(ChatEditorSpacing.px8)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(borderRadius: ChatEditorRadii.br10)),
        iconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.iconDisabled;
          } else if (states.contains(WidgetState.pressed)) {
            return colorScheme.iconPressed;
          } else if (states.contains(WidgetState.hovered)) {
            return colorScheme.iconHovered;
          }
          return colorScheme.iconEnabled;
        }),
        iconSize: WidgetStateProperty.all(ChatEditorSpacing.px24),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.disabled;
          } else if (states.contains(WidgetState.pressed)) {
            return colorScheme.pressed;
          } else if (states.contains(WidgetState.hovered)) {
            return colorScheme.hovered;
          }
          return colorScheme.enabled;
        }),
      ),
      onPressed: enabled ? onTap : null,
      onLongPress: enabled ? onLongTap : null,
      child: Icon(
        isEditMode ? ChatEditorIcons.checkBold : ChatEditorIcons.paperPlane,
      ),
    );
  }
}

abstract class IsSendEnabled {
  /// Пока идёт асинхронное добавление файла ([MessageFilesState$Data.isProcessing]),
  /// кнопка отключена: файл ещё не попал в state, и отправка ушла бы без него.
  static bool isEnabled(Document document, MessageFilesState state) {
    if (state is MessageFilesState$Data && state.isProcessing) return false;
    return (!document.isBlank && document.toDelta().isPlainTextNotEmpty) ||
        switch (state) {
          MessageFilesState$Data(:final files) => files.isNotEmpty,
        };
  }
}
