import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/controlled_stated_button.dart';
import 'package:flutter/material.dart';

class AtButton extends StatefulWidget {
  const AtButton({
    this.onTap,
    this.buttonColorScheme,
    super.key,
  });

  final VoidCallback? onTap;
  final ButtonColorScheme? buttonColorScheme;

  @override
  State<AtButton> createState() => _AtButtonState();
}

class _AtButtonState extends State<AtButton> {
  final WidgetStatesController _controller = WidgetStatesController();

  @override
  Widget build(BuildContext context) {
    return ControlledStatedButton.action(
      controller: _controller,
      icon: ChatEditorIcons.at,
      onTap: widget.onTap,
      buttonColorScheme: widget.buttonColorScheme,
    );
  }
}
