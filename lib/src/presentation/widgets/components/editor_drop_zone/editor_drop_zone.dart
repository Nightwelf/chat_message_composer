import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';

class EditorDropZone extends StatefulWidget {
  const EditorDropZone({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<EditorDropZone> createState() => _EditorDropZoneState();
}

class _EditorDropZoneState extends State<EditorDropZone> {
  bool _isDraggingOver = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDraggingOver = true),
      onDragExited: (_) => setState(() => _isDraggingOver = false),
      onDragDone: (details) {
        setState(() => _isDraggingOver = false);
        if (details.files.isNotEmpty && context.mounted) {
          final files = details.files.map((f) {
            final mime = lookupMimeType(f.name) ??
                f.mimeType ??
                'application/octet-stream';
            return XFile(f.path, name: f.name, mimeType: mime);
          }).toList();
          context.read<MessageFilesBloc>().add(MessageFiles$Add(files));
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_isDraggingOver)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.chatColors.outgoingBubbleBackground,
                    borderRadius: widget.borderRadius,
                    border: Border.all(
                      color: context.chatColors.brandDefault,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      ChatEditorIcons.upload,
                      size: 40,
                      color: context.chatColors.brandDefault,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
