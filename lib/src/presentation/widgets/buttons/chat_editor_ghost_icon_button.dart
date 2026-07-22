import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

enum _ChatEditorGhostIconButtonSize {
  sm(ChatEditorSpacing.px32, 20, ChatEditorRadii.br8),
  md(ChatEditorSpacing.px40, 24, ChatEditorRadii.br10);

  const _ChatEditorGhostIconButtonSize(this.dimension, this.iconSize, this.radius);

  final double dimension;
  final double iconSize;
  final BorderRadius radius;
}

/// Прозрачная иконочная кнопка без фона в состоянии по умолчанию,
/// с заливкой при наведении/нажатии.
class ChatEditorGhostIconButton extends StatelessWidget {
  const ChatEditorGhostIconButton.sm({
    required this.icon,
    this.onTap,
    this.enabled = true,
    super.key,
  }) : _size = _ChatEditorGhostIconButtonSize.sm;

  const ChatEditorGhostIconButton.md({
    required this.icon,
    this.onTap,
    this.enabled = true,
    super.key,
  }) : _size = _ChatEditorGhostIconButtonSize.md;

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final _ChatEditorGhostIconButtonSize _size;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return ElevatedButton(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        visualDensity: VisualDensity.standard,
        minimumSize: WidgetStateProperty.all(Size.square(_size.dimension)),
        maximumSize: WidgetStateProperty.all(Size.square(_size.dimension)),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: _size.radius),
        ),
        iconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.textDisabled;
          return colors.textStrong;
        }),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.transparent;
          if (states.contains(WidgetState.pressed)) return colors.neutralSoftPressed;
          if (states.contains(WidgetState.hovered)) return colors.neutralSoftHover;
          return Colors.transparent;
        }),
      ),
      onPressed: enabled ? onTap : null,
      child: Icon(icon, size: _size.iconSize),
    );
  }
}
