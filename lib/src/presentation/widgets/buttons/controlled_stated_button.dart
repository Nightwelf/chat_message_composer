import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

/// Кнопка с программно управляемым состоянием через [WidgetStatesController].
///
/// Если задан [isPressed], кнопка визуально отображает переданное состояние
/// нажатия, а [onTap]/[onLongTap] игнорируются — используется для кнопок,
/// состояние которых управляется извне. Иначе кнопка работает как обычная.
///
/// Используйте именованные конструкторы [ControlledStatedButton.action] для обычного
/// режима или [ControlledStatedButton.pressed] для режима с программным управлением.
class ControlledStatedButton extends StatelessWidget {
  const ControlledStatedButton({
    required this.controller,
    required this.icon,
    super.key,
    this.onTap,
    this.onLongTap,
    this.enabled = true,
    this.isPressed,
    this.buttonColorScheme,
  });

  const ControlledStatedButton.action({
    required this.controller,
    required this.icon,
    super.key,
    this.onTap,
    this.onLongTap,
    this.enabled = true,
    this.buttonColorScheme,
  }) : isPressed = null;

  const ControlledStatedButton.pressed({
    required this.controller,
    required this.icon,
    required this.isPressed,
    super.key,
    this.enabled = true,
    this.buttonColorScheme,
  })  : onTap = null,
        onLongTap = null;

  final WidgetStatesController controller;

  /// Игнорируется, если [isPressed] задан или [enabled] равен `false`.
  final VoidCallback? onTap;

  /// Игнорируется, если [isPressed] задан или [enabled] равен `false`.
  final VoidCallback? onLongTap;

  final bool enabled;
  final IconData icon;
  final bool? isPressed;

  /// Если не задана, используется схема по умолчанию из темы приложения.
  final ButtonColorScheme? buttonColorScheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final colorScheme = buttonColorScheme ??
        ButtonColorScheme(
          enabled: Colors.transparent,
          hovered: colors.neutralSoftHover,
          pressed: colors.neutralSoftPressed,
          disabled: Colors.transparent,
          iconDisabled: colors.textDisabled.withAlpha(200),
          iconEnabled: colors.textStrong,
          iconHovered: colors.textStrong,
          iconPressed: colors.textStrong,
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
          } else if (states.contains(WidgetState.pressed) ||
              (isPressed != null && isPressed!)) {
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
          } else if (states.contains(WidgetState.pressed) ||
              (isPressed != null && isPressed!)) {
            return colorScheme.pressed;
          } else if (states.contains(WidgetState.hovered)) {
            return colorScheme.hovered;
          }
          return colorScheme.enabled;
        }),
      ),
      statesController: controller,
      onPressed: isPressed != null
          ? (onTap ?? () {})
          : enabled
              ? onTap
              : null,
      onLongPress: isPressed != null
          ? (onLongTap ?? () {})
          : enabled
              ? onLongTap
              : null,
      child: Icon(icon),
    );
  }
}
