import 'package:chat_message_composer/src/domain/entities/attached_file.dart';
import 'package:chat_message_composer/src/domain/extensions/x_file_extensions.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/close_btn/close_btn.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_name_widget.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_tile.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_widget_factory.dart';
import 'package:flutter/material.dart';

class FileThumbnailWidget extends StatelessWidget with FileTile {
  const FileThumbnailWidget({
    required this.params,
    super.key,
  });

  @override
  final FileTileParams params;

  AttachedFile get file => params.file;

  VoidCallback? get onTap => params.onTap;

  VoidCallback? get onLongPress => params.onLongPress;

  VoidCallback? get onTapClose => params.onTapClose;

  static ButtonStyle _buttonStyle(ChatEditorColorScheme colors) => ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(204, 50)),
        maximumSize: WidgetStateProperty.all(const Size(204, 50)),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: ChatEditorRadii.br8,
          ),
        ),
        backgroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colors.neutralSoftHover;
          }
          return colors.surfaceQuaternary;
        }),
        elevation: WidgetStateProperty.all(0),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        visualDensity: VisualDensity.standard,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheDim = (FileTile.thumbnailSize * dpr).round();

    return RepaintBoundary(
      child: SizedBox(
        width: 210,
        height: 56,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: onTap,
                onLongPress: onLongPress,
                style: _buttonStyle(colors),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: FileTile.thumbnailSize,
                      child: Padding(
                        padding: const EdgeInsets.all(ChatEditorSpacing.px6),
                        child: file.data.isImage() &&
                                file.thumbnailBytes != null
                            ? ClipRRect(
                                borderRadius: ChatEditorRadii.br4,
                                child: Image.memory(
                                  file.thumbnailBytes!,
                                  width: FileTile.thumbnailSize,
                                  height: FileTile.thumbnailSize,
                                  fit: BoxFit.cover,
                                  cacheWidth: cacheDim,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const BrokenImageBox();
                                  },
                                ),
                              )
                            : file.data.isImage()
                                ? const BrokenImageBox()
                                : const FileIconBox(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: ChatEditorSpacing.px12,
                          top: ChatEditorSpacing.px6,
                          bottom: ChatEditorSpacing.px6,
                        ),
                        child: FileNameWidget(file: file.data),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onTapClose != null)
              Align(
                alignment: Alignment.topRight,
                child: CloseBtn(onTap: onTapClose),
              ),
          ],
        ),
      ),
    );
  }
}
