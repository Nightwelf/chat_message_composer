import 'dart:typed_data';

import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:flutter/material.dart';

/// Виджет миниатюры изображения.
class ImageThumbnail extends StatelessWidget {
  const ImageThumbnail({super.key, required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    const thumbnailSize = 100.0;

    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: ChatEditorRadii.br8,
            child: Image.memory(
              snapshot.data!,
              width: thumbnailSize,
              height: thumbnailSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: thumbnailSize,
                  height: thumbnailSize,
                  color: colors.surfaceQuaternary,
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            width: thumbnailSize,
            height: thumbnailSize,
            decoration: BoxDecoration(
              color: colors.surfaceQuaternary,
              borderRadius: ChatEditorRadii.br8,
            ),
            child: const Icon(Icons.broken_image),
          );
        } else {
          return Container(
            width: thumbnailSize,
            height: thumbnailSize,
            decoration: BoxDecoration(
              color: colors.surfaceQuaternary,
              borderRadius: ChatEditorRadii.br8,
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
      },
    );
  }
}
