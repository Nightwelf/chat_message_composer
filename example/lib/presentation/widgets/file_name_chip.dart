import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:flutter/material.dart';

/// Виджет чипа с именем файла.
class FileNameChip extends StatelessWidget {
  const FileNameChip({super.key, required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final fileName = file.name;

    return Chip(
      backgroundColor: colors.surfaceQuaternary,
      label: Text(
        fileName,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      avatar: Icon(
        Icons.insert_drive_file,
        size: 18,
        color: colors.neutralFilled,
      ),
    );
  }
}
