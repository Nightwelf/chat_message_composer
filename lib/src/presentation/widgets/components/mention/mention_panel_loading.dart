import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

class MentionPanelLoading extends StatelessWidget {
  const MentionPanelLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        border: Border(
          left: BorderSide(color: colors.borderSubtle),
          right: BorderSide(color: colors.borderSubtle),
          top: BorderSide(color: colors.borderSubtle),
        ),
      ),
      child: SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
