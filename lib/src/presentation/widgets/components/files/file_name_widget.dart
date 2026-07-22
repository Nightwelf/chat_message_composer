import 'package:chat_message_composer/src/domain/extensions/x_file_extensions.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

class FileNameWidget extends StatelessWidget {
  const FileNameWidget({
    required this.file,
    super.key,
  });

  final XFile file;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return FutureBuilder(
        future: file.formatFileSize(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                file.name,
                overflow: TextOverflow.ellipsis,
                style: ChatEditorTypography.body.m14_20.copyWith(color: colors.textPrimary),
              ),
              Text(
                snapshot.data.toString(),
                style: ChatEditorTypography.label.r12_18.copyWith(color: colors.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        });
  }
}
