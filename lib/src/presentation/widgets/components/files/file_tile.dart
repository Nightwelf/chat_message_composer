import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_widget_factory.dart';
import 'package:flutter/material.dart';

abstract mixin class FileTile {
  FileTileParams get params;

  static const thumbnailSize = 50.0;
  static const tileClosePadding = 6.0;
  static const double tileRealSize = thumbnailSize + tileClosePadding;
}

class BrokenImageBox extends StatelessWidget {
  const BrokenImageBox({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return SizedBox.square(
      dimension: FileTile.thumbnailSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceQuaternary,
          borderRadius: ChatEditorRadii.br4,
        ),
        child: Icon(
          Icons.broken_image,
          size: 24,
          color: colors.brandDefault,
        ),
      ),
    );
  }
}

class FileIconBox extends StatelessWidget {
  const FileIconBox({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return SizedBox.square(
      dimension: FileTile.thumbnailSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceQuaternary,
          borderRadius: ChatEditorRadii.br4,
        ),
        child: Icon(
          ChatEditorIcons.file,
          size: 24,
          color: colors.neutralFilled,
        ),
      ),
    );
  }
}
