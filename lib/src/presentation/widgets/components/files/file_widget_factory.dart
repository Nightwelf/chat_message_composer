import 'package:chat_message_composer/src/domain/entities/attached_file.dart';
import 'package:chat_message_composer/src/domain/extensions/x_file_extensions.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_icon_widget.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_thumbnail_widget.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_thumbnail_widget_filled.dart';
import 'package:flutter/material.dart';

enum FileWidgetType {
  thumbnail,
  icon,
  auto,
}

final class FileTileParams {
  FileTileParams({
    required this.file,
    this.onTapClose,
    this.onTap,
    this.onLongPress,
  });

  final AttachedFile file;
  final VoidCallback? onTapClose;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
}

class FileWidgetFactory extends StatelessWidget {
  const FileWidgetFactory.thumbnail({
    required this.params,
    super.key,
    this.filled = false,
  }) : type = FileWidgetType.thumbnail;

  const FileWidgetFactory.icon({
    required this.params,
    super.key,
  })  : type = FileWidgetType.icon,
        filled = false;

  const FileWidgetFactory.auto({
    required this.params,
    super.key,
    this.filled = false,
  }) : type = FileWidgetType.auto;

  final FileWidgetType type;
  final FileTileParams params;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final file = params.file;
    final key = ObjectKey(file);
    final isThumbnail = type == FileWidgetType.thumbnail || type == FileWidgetType.auto && file.data.isImage();
    if (isThumbnail) {
      if (filled) {
        return FileThumbnailWidgetFilled(
          key: key,
          params: params,
        );
      }
      return FileThumbnailWidget(
        key: key,
        params: params,
      );
    }
    return FileIconWidget(
      key: key,
      params: params,
    );
  }
}
