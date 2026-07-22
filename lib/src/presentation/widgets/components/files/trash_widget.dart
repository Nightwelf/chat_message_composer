import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_tile.dart';
import 'package:flutter/material.dart';

class TrashWidget extends StatelessWidget {
  const TrashWidget({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  static const _buttonSize = Size.square(FileTile.thumbnailSize);

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;

    return SizedBox.square(
      dimension: FileTile.tileRealSize,
      child: Padding(
        padding: const EdgeInsets.only(top: FileTile.tileClosePadding, right: FileTile.tileClosePadding),
        child: ElevatedButton(
          onPressed: onTap,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(_buttonSize),
            maximumSize: const WidgetStatePropertyAll(_buttonSize),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            shape: const WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: ChatEditorRadii.br8,
              ),
            ),
            backgroundColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return colors.neutralSoftHover;
              }
              return colors.surfaceQuaternary;
            }),
            elevation: const WidgetStatePropertyAll(0),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            visualDensity: VisualDensity.standard,
          ),
          child: Icon(
            ChatEditorIcons.trash,
            size: ChatEditorSpacing.px32,
            color: colors.textStrong,
          ),
        ),
      ),
    );
  }
}
