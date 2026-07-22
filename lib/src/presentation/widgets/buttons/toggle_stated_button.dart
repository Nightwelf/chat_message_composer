import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

/// Кнопка-переключатель с внутренним управлением состоянием.
///
/// Если задан [pressedState], каждое нажатие переключает внутреннее состояние
/// между `true`/`false` и вызывает [pressedState] с новым значением; [onTap] и
/// [onLongTap] в этом режиме игнорируются. Если [pressedState] не задан, кнопка
/// работает как обычная — вызывает [onTap]/[onLongTap] при нажатии.
///
/// Используйте именованные конструкторы [ToggleStatedButton.toggle] для режима
/// переключателя или [ToggleStatedButton.action] для обычного режима.
class ToggleStatedButton extends StatefulWidget {
  const ToggleStatedButton({
    required this.icon,
    super.key,
    this.onTap,
    this.onLongTap,
    this.enabled = true,
    this.initialPressedState = false,
    this.pressedState,
    this.buttonColorScheme,
  });

  const ToggleStatedButton.toggle({
    required this.icon,
    required this.pressedState,
    super.key,
    this.initialPressedState = false,
    this.enabled = true,
    this.buttonColorScheme,
  })  : onTap = null,
        onLongTap = null;

  const ToggleStatedButton.action({
    required this.icon,
    super.key,
    this.onTap,
    this.onLongTap,
    this.enabled = true,
    this.buttonColorScheme,
  })  : initialPressedState = false,
        pressedState = null;

  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final bool enabled;
  final bool initialPressedState;
  final IconData icon;
  final ValueChanged<bool>? pressedState;

  /// Если не задана, используется схема по умолчанию из темы приложения.
  final ButtonColorScheme? buttonColorScheme;

  @override
  State<ToggleStatedButton> createState() => _ToggleStatedButtonState();
}

class _ToggleStatedButtonState extends State<ToggleStatedButton> {
  bool _isPressed = false;
  final WidgetStatesController _controller = WidgetStatesController();

  @override
  void initState() {
    super.initState();
    if (widget.pressedState != null) {
      _isPressed = widget.initialPressedState;
      _controller.addListener(_listener);
    }
  }

  void _listener() {
    if (_controller.value.contains(WidgetState.pressed)) {
      setState(() {
        _isPressed = !_isPressed;
        widget.pressedState?.call(_isPressed);
      });
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_listener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final colorScheme = widget.buttonColorScheme ??
        ButtonColorScheme(
          enabled: colors.neutralSoftDefault,
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
          } else if (states.contains(WidgetState.pressed) || _isPressed) {
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
          } else if (states.contains(WidgetState.pressed) || _isPressed) {
            return colorScheme.pressed;
          } else if (states.contains(WidgetState.hovered)) {
            return colorScheme.hovered;
          }
          return colorScheme.enabled;
        }),
      ),
      statesController: _controller,
      onPressed: widget.pressedState != null
          ? () {}
          : widget.enabled
              ? widget.onTap
              : null,
      onLongPress: widget.pressedState != null
          ? () {}
          : widget.enabled
              ? widget.onLongTap
              : null,
      child: Icon(widget.icon),
    );
  }
}
