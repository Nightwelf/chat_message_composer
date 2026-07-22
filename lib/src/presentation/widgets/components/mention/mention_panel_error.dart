import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MentionPanelError extends StatelessWidget {
  const MentionPanelError({required this.error, super.key});

  final String error;

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
        height: 60,
        child: Center(
          child: Text(
            context
                .read<ChatMessageComposerLocalizationRepository>()
                .mentionPanelError(error),
            style: TextStyle(
              color: colors.textStrong,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
