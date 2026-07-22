import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

class CloseBtn extends StatelessWidget {
  const CloseBtn({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(
          const Size(22, 22),
        ),
        maximumSize: WidgetStateProperty.all(
          const Size(22, 22),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: ChatEditorRadii.br9999,
          ),
        ),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colors.neutralFilled.withAlpha(200);
          }
          return colors.neutralFilled;
        }),
        elevation: WidgetStateProperty.all(0),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        visualDensity: VisualDensity.standard,
      ),
      child: Icon(
        ChatEditorIcons.closeBoldFilled,
        size: ChatEditorSpacing.px16,
        color: colors.contentOnFilled,
      ),
    );
  }
}
