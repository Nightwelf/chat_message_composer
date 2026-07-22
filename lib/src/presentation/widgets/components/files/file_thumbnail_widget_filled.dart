import 'package:chat_message_composer/src/domain/entities/attached_file.dart';
import 'package:chat_message_composer/src/domain/extensions/x_file_extensions.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/close_btn/close_btn.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_widget_factory.dart';
import 'package:flutter/material.dart';

import 'file_tile.dart';

class FileThumbnailWidgetFilled extends StatelessWidget with FileTile {
  const FileThumbnailWidgetFilled({
    required this.params,
    super.key,
  });

  @override
  final FileTileParams params;

  AttachedFile get file => params.file;

  VoidCallback? get onTap => params.onTap;

  VoidCallback? get onLongPress => params.onLongPress;

  VoidCallback? get onTapClose => params.onTapClose;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheDim = (FileTile.thumbnailSize * dpr).round();

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: FileTile.thumbnailSize + 6,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: GestureDetector(
                onTap: onTap,
                onLongPress: onLongPress,
                child: SizedBox.square(
                  dimension: FileTile.thumbnailSize,
                  child: file.data.isImage() && file.thumbnailBytes != null
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
