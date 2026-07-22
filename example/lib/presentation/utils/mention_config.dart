import 'package:chat_message_composer_example/domain/entities/chat_mention.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/material.dart';
import 'package:chat_message_composer/chat_message_composer.dart';

MentionConfig buildMentionConfig(BuildContext context) => MentionConfig(
      fromJson: ChatMention.fromJson,
      widgetBuilder: (mention) => Text(
        '@${mention.displayData}',
        style: ChatEditorTypography.body.r15_22.copyWith(
          color: context.chatColors.brandDefault,
        ),
      ),
    );
