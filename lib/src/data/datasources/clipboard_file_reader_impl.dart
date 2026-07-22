import 'dart:async';
import 'dart:typed_data';

import 'package:chat_message_composer/src/domain/datasources/clipboard_file_reader.dart';
import 'package:cross_file/cross_file.dart';
import 'package:mime/mime.dart';
import 'package:pasteboard/pasteboard.dart';

class ClipboardFileReaderImpl implements ClipboardFileReader {
  const ClipboardFileReaderImpl();

  @override
  Future<List<XFile>> readFiles() async {
    try {
      final filePaths = await Pasteboard.files();
      if (filePaths.isNotEmpty) {
        final files = <XFile>[];
        for (final path in filePaths) {
          final name = path.split('/').last;
          final mime = lookupMimeType(name) ?? 'application/octet-stream';
          files.add(XFile(path, name: name, mimeType: mime));
        }
        return files;
      }

      final imageBytes = await Pasteboard.image;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final mimeType = _detectImageMimeType(imageBytes);
        final extension = _getExtensionFromMimeType(mimeType);

        return [
          XFile.fromData(
            imageBytes,
            name: 'clipboard_image.$extension',
            mimeType: mimeType,
          ),
        ];
      }

      return const [];
    } on Exception catch (_) {
      return const [];
    }
  }

  String _detectImageMimeType(Uint8List bytes) {
    if (bytes.length < 4) return 'image/png';

    // PNG signature: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }

    // JPEG signature: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // GIF signature: 47 49 46
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return 'image/gif';
    }

    // WEBP signature: RIFF ... WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }

    return 'image/png';
  }

  String _getExtensionFromMimeType(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/gif':
        return 'gif';
      case 'image/webp':
        return 'webp';
      default:
        return 'png';
    }
  }
}
