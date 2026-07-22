import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/controlled_stated_button.dart';
import 'package:flutter/material.dart';

/// Кнопка-переключатель с иконкой (форматирование, закрытие и т.д.).
///
/// При нажатии запрашивает фокус у [focusNode] и вызывает [onPressedState]
/// с новым состоянием. Поддерживает управляемое ([isPressed]) и локальное состояние.
class ToggleFormatButton extends StatefulWidget {
  const ToggleFormatButton({
    required this.icon,
    required this.initialPressed,
    required this.onPressedState,
    this.focusNode,
    this.isPressed,
    this.buttonColorScheme,
    super.key,
  });

  final IconData icon;
  final bool initialPressed;
  final ValueChanged<bool>? onPressedState;
  final FocusNode? focusNode;
  final bool? isPressed;
  final ButtonColorScheme? buttonColorScheme;

  @override
  State<ToggleFormatButton> createState() => _ToggleFormatButtonState();
}

class _ToggleFormatButtonState extends State<ToggleFormatButton> {
  final WidgetStatesController _controller = WidgetStatesController();
  late bool _isPressed;

  @override
  void initState() {
    super.initState();
    _isPressed = widget.initialPressed;
    _controller.addListener(_listener);
  }

  void _listener() {
    if (_controller.value.contains(WidgetState.pressed)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.focusNode?.requestFocus();
      });
    }
    if (!mounted) {
      return;
    }
    if (_controller.value.contains(WidgetState.pressed)) {
      final newState =
          widget.isPressed != null ? !widget.isPressed! : !_isPressed;
      widget.onPressedState?.call(newState);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          if (widget.isPressed == null) {
            setState(() {
              _isPressed = newState;
            });
          }
        } on Exception catch (_) {
          // Игнорируем ошибки во время размонтирования
        }
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
    return ControlledStatedButton.pressed(
      controller: _controller,
      icon: widget.icon,
      isPressed: widget.isPressed ?? _isPressed,
      buttonColorScheme: widget.buttonColorScheme,
    );
  }
}
