import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

class CustomContextMenuDivider extends StatelessWidget {
  const CustomContextMenuDivider({
    super.key,
    this.height = 8.0,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ChatEditorSpacing.px4),
      child: SizedBox(
        height: height,
        child: Center(
          child: ColoredBox(
            color: colors.borderSubtle,
            child: const SizedBox(height: 1, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
