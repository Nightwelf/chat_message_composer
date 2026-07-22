import 'dart:ui' show Size;

import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:equatable/equatable.dart';

/// Класс для представления сообщения чата с текстом и файлами.
///
/// Содержит документ с форматированным текстом и список прикрепленных файлов.
class ChatMessageComposerMessageData extends Equatable {
  /// Создает объект сообщения чата.
  ///
  /// [document] - документ с текстом сообщения.
  /// [files] - список прикрепленных файлов.
  /// [fileDimensions] - размеры изображений по пути файла.
  const ChatMessageComposerMessageData({
    required this.document,
    required this.files,
    this.fileDimensions = const {},
  });

  /// Документ с текстом сообщения.
  final Document document;

  /// Список прикрепленных файлов.
  final List<XFile> files;

  /// Размеры изображений по пути файла (path → Size).
  final Map<String, Size> fileDimensions;

  /// Преобразует все незаконченные mention_input embeds обратно в текст.
  ///
  /// Каждый embed заменяется литералом '@' (embed стоит на месте исходного '@',
  /// см. `ChatMessageComposerController.insertMentionInputEmbed`), а query-текст после
  /// него сохраняется. Это согласовано с отменой ввода через ESC/разделитель
  /// (`cancelMentionInput`), которая тоже восстанавливает '@query', и не теряет
  /// набранный текст, если отправка произошла во время активного '@'-ввода.
  ///
  /// Также удаляет атрибут цвета из текста, следующего за mention_input.
  /// Возвращает новый экземпляр [ChatMessageComposerMessageData] с очищенным документом.
  /// Если в документе нет mention_input embeds, возвращает текущий экземпляр.
  ChatMessageComposerMessageData removeMentionInputEmbeds() {
    final delta = document.toDelta();
    final operations = delta.toList();

    final hasMentionInput = operations.any((op) {
      if (op.isInsert && op.data is Map) {
        final data = op.data! as Map;
        return data.containsKey(mentionInputType);
      }
      return false;
    });

    if (!hasMentionInput) {
      return this;
    }

    final cleanDelta = Delta();
    var skipNextColorAttribute = false;

    for (var i = 0; i < operations.length; i++) {
      final op = operations[i];

      if (op.isInsert && op.data is Map) {
        final data = op.data! as Map;
        if (data.containsKey(mentionInputType)) {
          cleanDelta.insert('@');
          skipNextColorAttribute = true;
          continue;
        }
      }

      if (skipNextColorAttribute && op.isInsert && op.data is String) {
        if (op.attributes != null && op.attributes!.containsKey('color')) {
          final newAttributes = Map<String, dynamic>.from(op.attributes!)
            ..remove('color');

          if (newAttributes.isEmpty) {
            cleanDelta.insert(op.data);
          } else {
            cleanDelta.insert(op.data, newAttributes);
          }
          skipNextColorAttribute = false;
          continue;
        }
        skipNextColorAttribute = false;
      }

      cleanDelta.push(op);
    }

    final cleanDocument = Document.fromDelta(cleanDelta);

    return ChatMessageComposerMessageData(
      document: cleanDocument,
      files: files,
      fileDimensions: fileDimensions,
    );
  }

  @override
  List<Object?> get props => [
        // Document и XFile не реализуют value-equality, поэтому сравниваем по
        // содержимому: Delta документа и путям файлов.
        document.toDelta(),
        files.map((f) => f.path).toList(),
        fileDimensions,
      ];
}
