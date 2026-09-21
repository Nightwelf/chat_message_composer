import 'package:chat_message_composer/src/domain/datasources/message_file_picker.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/camera_picker/camera_picker_screen.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

/// Реализация [MessageFilePicker] с поддержкой платформ iOS и web.
class MessageFilePickerImpl implements MessageFilePicker {
  const MessageFilePickerImpl();

  @override
  Future<List<XFile>> pickFiles({bool allowMultiple = false}) async {
    try {
      final files = allowMultiple
          ? await FilePicker.pickFiles()
          : [await FilePicker.pickFile()].whereType<PlatformFile>().toList();

      if (files.isEmpty) {
        return [];
      }

      final result = <XFile>[];

      for (final platformFile in files) {
        final xFile = await _convertPlatformFileToXFile(platformFile);
        if (xFile != null) {
          result.add(xFile);
        }
      }

      return result;
    } on Exception catch (_) {
      return const [];
    }
  }

  @override
  Future<List<XFile>> pickMediaFiles({bool allowMultiple = false}) async {
    try {
      final files = allowMultiple
          ? await FilePicker.pickFiles(type: FileType.media)
          : [await FilePicker.pickFile(type: FileType.media)]
              .whereType<PlatformFile>()
              .toList();

      if (files.isEmpty) {
        return [];
      }

      final result = <XFile>[];

      for (final platformFile in files) {
        final xFile = await _convertPlatformFileToXFile(platformFile);
        if (xFile != null) {
          result.add(xFile);
        }
      }

      return result;
    } on Exception catch (_) {
      return [];
    }
  }

  @override
  Future<List<XFile>> pickCameraImage(BuildContext context) async {
    try {
      final result = await Navigator.of(context).push<XFile>(
        MaterialPageRoute(
          builder: (context) => const CameraPickerScreen(),
        ),
      );

      if (result != null) {
        return [result];
      }
      return [];
    } on Exception catch (_) {
      // На десктопных платформах (Windows, macOS, Linux) камера не поддерживается
      // по умолчанию, поэтому возвращаем пустой список.
      // На iOS требуется добавить NSCameraUsageDescription в Info.plist.
      // На Android работает из коробки.
      return [];
    }
  }

  Future<XFile?> _convertPlatformFileToXFile(PlatformFile platformFile) async {
    try {
      final fileName = platformFile.name;
      final mimeType =
          lookupMimeType(fileName) ?? _getFallbackMimeType(fileName);

      if (kIsWeb) {
        final bytes = await platformFile.readAsBytes();
        return XFile.fromData(bytes, name: fileName, mimeType: mimeType);
      } else {
        if (platformFile.path != null) {
          return XFile(platformFile.path!, name: fileName, mimeType: mimeType);
        }
        return null;
      }
    } on Exception catch (_) {
      return null;
    }
  }

  String _getFallbackMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    final fallbackMimeTypes = <String, String>{
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'txt': 'text/plain',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
      'mkv': 'video/x-matroska',
      'webm': 'video/webm',
    };
    return fallbackMimeTypes[extension] ?? 'application/octet-stream';
  }
}
