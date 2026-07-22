import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Size;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_message_composer/src/domain/entities/attached_file.dart';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'message_files_event.dart';

part 'message_files_state.dart';

/// BLoC для управления файлами сообщений.
///
/// Обрабатывает добавление, удаление файлов и предоставляет состояние с текущим списком файлов.
class MessageFilesBloc extends Bloc<MessageFilesEvent, MessageFilesState> {
  MessageFilesBloc({this.onFilesTooLarge}) : super(const MessageFilesState$Data()) {
    on<MessageFilesEvent>(
      (event, emit) => switch (event) {
        MessageFiles$Add() => _onAdd(event, emit),
        MessageFiles$Remove() => _onRemove(event, emit),
        MessageFiles$RemoveMultiple() => _onRemoveMultiple(event, emit),
        MessageFiles$Clear() => _onClear(event, emit),
      },
      transformer: sequential(),
    );
  }

  static const double _maxFileSizeBytes = 50 * 1024 * 1024;

  final void Function(List<String> fileNames)? onFilesTooLarge;

  Future<void> _onAdd(
    MessageFiles$Add event,
    Emitter<MessageFilesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MessageFilesState$Data) {
      return;
    }

    // Проверка на дубликаты по пути файла (файлы без пути, напр. clipboard images, всегда уникальны)
    final existingPaths = currentState.files
        .map((f) => f.data.path)
        .where((p) => p.isNotEmpty)
        .toSet();
    final deduped = event.files
        .where((f) => f.path.isEmpty || !existingPaths.contains(f.path))
        .toList();

    if (deduped.isEmpty) {
      return;
    }

    // Помечаем состояние как "идёт добавление" на время асинхронного чтения
    // размера/байтов/декодирования превью, чтобы отправка сообщения могла
    // дождаться завершения и не потерять файл, добавление которого ещё не
    // попало в state (см. IsSendEnabled.isEnabled и onSendTap).
    emit(currentState.copyWith(isProcessing: true));

    // Проверка ограничения на размер файла (50 МБ)
    final tooLargeNames = <String>[];
    final validFiles = <XFile>[];
    for (final file in deduped) {
      try {
        final size = await file.length();
        if (size > _maxFileSizeBytes) {
          tooLargeNames.add(file.name);
        } else {
          validFiles.add(file);
        }
      } on Object {
        // Файл стал недоступен между выбором и чтением (удалён/перемещён) —
        // пропускаем его вместо падения всего обработчика события.
        continue;
      }
    }
    if (tooLargeNames.isNotEmpty) {
      onFilesTooLarge?.call(tooLargeNames);
    }
    if (validFiles.isEmpty) {
      emit(currentState.copyWith(isProcessing: false));
      return;
    }

    final newFileFutures = validFiles.map(_toAttachedFile).toList();
    final resolvedFiles = await Future.wait(newFileFutures);

    // Дедуп по хэшу содержимого — покрывает clipboard-изображения (пустой
    // path, поэтому дедуп по пути их не видит) и повторы внутри одного батча.
    final existingContentHashes = currentState.files
        .map((f) => f.contentHash)
        .whereType<int>()
        .toSet();
    final dedupedResolved = resolvedFiles
        .where((f) =>
            f.contentHash == null || existingContentHashes.add(f.contentHash!))
        .toList();

    if (dedupedResolved.isEmpty) {
      emit(currentState.copyWith(isProcessing: false));
      return;
    }
    emit(MessageFilesState$Data(
        files: [...currentState.files, ...dedupedResolved]));
  }

  Future<AttachedFile> _toAttachedFile(XFile xFile) async {
    final id = const Uuid().v4();

    if (xFile.path.isEmpty) {
      // Clipboard-изображение: читаем байты один раз, используем и для XFile, и для превью
      final ext = _extensionFromMime(xFile.mimeType);
      final name = 'screenshot_$id.$ext';
      final bytes = await xFile.readAsBytes();
      final file = XFile.fromData(bytes,
          name: name, mimeType: xFile.mimeType, path: name);
      final preview = await _resolveImagePreviewFromBytes(bytes, xFile.mimeType);
      return AttachedFile(
          id: id,
          cachedSize: bytes.length,
          data: file,
          imageSize: preview.size,
          thumbnailBytes: preview.thumbnail,
          contentHash: _fnv1aHash(bytes));
    } else {
      final preview = await _resolveImagePreviewFromXFile(xFile);
      return AttachedFile(
          id: id,
          cachedSize: await xFile.length(),
          data: xFile,
          imageSize: preview.size,
          thumbnailBytes: preview.thumbnail);
    }
  }

  /// Максимальная длина большей стороны генерируемой миниатюры (px).
  /// `FileTile.thumbnailSize` = 50 логических px; запас под DPR≈3 и filled-вариант.
  static const int _thumbnailMaxSide = 200;

  /// Декодирует изображение один раз и возвращает его исходный размер и
  /// уменьшенную PNG-миниатюру. Полный декодированный кадр освобождается, чтобы
  /// не удерживать оригинал в памяти.
  static Future<({Size? size, Uint8List? thumbnail})>
      _resolveImagePreviewFromBytes(Uint8List bytes, String? mimeType) async {
    final mime = mimeType ?? '';
    if (!mime.startsWith('image/')) return (size: null, thumbnail: null);
    ui.Image? fullImage;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      fullImage = frame.image;
      final size =
          Size(fullImage.width.toDouble(), fullImage.height.toDouble());
      final thumbnail = await _encodeThumbnail(fullImage);
      codec.dispose();
      return (size: size, thumbnail: thumbnail);
    } on Object catch (_) {
      return (size: null, thumbnail: null);
    } finally {
      fullImage?.dispose();
    }
  }

  static Future<({Size? size, Uint8List? thumbnail})>
      _resolveImagePreviewFromXFile(XFile file) async {
    if (!_isImageFile(file)) return (size: null, thumbnail: null);
    try {
      final bytes = await file.readAsBytes();
      return _resolveImagePreviewFromBytes(
          bytes, file.mimeType ?? _mimeFromPath(file.path));
    } on Object catch (_) {
      return (size: null, thumbnail: null);
    }
  }

  /// Масштабирует декодированное изображение до [_thumbnailMaxSide] по большей
  /// стороне (с сохранением пропорций) и кодирует результат в PNG.
  static Future<Uint8List?> _encodeThumbnail(ui.Image image) async {
    final w = image.width;
    final h = image.height;
    if (w <= 0 || h <= 0) return null;

    final longest = math.max(w, h);
    final scale = longest > _thumbnailMaxSide ? _thumbnailMaxSide / longest : 1.0;
    final targetW = math.max(1, (w * scale).round());
    final targetH = math.max(1, (h * scale).round());

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      ui.Rect.fromLTWH(0, 0, targetW.toDouble(), targetH.toDouble()),
      ui.Paint()
        ..filterQuality = ui.FilterQuality.medium
        ..isAntiAlias = true,
    );
    final picture = recorder.endRecording();
    ui.Image? scaled;
    try {
      scaled = await picture.toImage(targetW, targetH);
      final data = await scaled.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } on Object catch (_) {
      return null;
    } finally {
      picture.dispose();
      scaled?.dispose();
    }
  }

  /// FNV-1a 32-бит хэш байтов файла (безопасен для компиляции в JS/web). Не
  /// криптографический, но достаточен для дедупликации содержимого без
  /// хранения полных байтов в памяти.
  static int _fnv1aHash(Uint8List bytes) {
    const fnvPrime = 0x01000193;
    const fnvOffsetBasis = 0x811c9dc5;
    var hash = fnvOffsetBasis;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }

  static bool _isImageFile(XFile file) {
    final mime = file.mimeType ?? '';
    if (mime.startsWith('image/')) return true;
    final lower = file.path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  static String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }

  static String _extensionFromMime(String? mimeType) => switch (mimeType) {
        'image/jpeg' => 'jpg',
        'image/gif' => 'gif',
        'image/webp' => 'webp',
        _ => 'png',
      };

  void _onRemove(
    MessageFiles$Remove event,
    Emitter<MessageFilesState> emit,
  ) {
    final currentState = state;
    if (currentState is! MessageFilesState$Data) {
      return;
    }

    final updatedFiles =
        currentState.files.where((f) => f.id != event.fileId).toList();

    emit(MessageFilesState$Data(files: updatedFiles));
  }

  void _onRemoveMultiple(
    MessageFiles$RemoveMultiple event,
    Emitter<MessageFilesState> emit,
  ) {
    final currentState = state;
    if (currentState is! MessageFilesState$Data) {
      return;
    }

    final idsToRemove = event.fileIds.toSet();
    final updatedFiles =
        currentState.files.where((f) => !idsToRemove.contains(f.id)).toList();

    emit(MessageFilesState$Data(files: updatedFiles));
  }

  void _onClear(
    MessageFiles$Clear event,
    Emitter<MessageFilesState> emit,
  ) {
    emit(const MessageFilesState$Data());
  }
}
