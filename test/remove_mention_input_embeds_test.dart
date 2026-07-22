import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessageComposerMessageData.removeMentionInputEmbeds', () {
    test('заменяет mention_input embed на "@" и сохраняет query-текст', () {
      final delta = Delta()
        ..insert(<String, dynamic>{
          mentionInputType: <String, dynamic>{'query': ''},
        })
        ..insert('jo', <String, dynamic>{'color': '#ffaa00'})
        ..insert('\n');

      final data = ChatMessageComposerMessageData(
        document: Document.fromDelta(delta),
        files: const [],
      );

      final result = data.removeMentionInputEmbeds();
      final ops = result.document.toDelta().toList();

      // Текст сохранён как "@jo"
      expect(result.document.toPlainText(), '@jo\n');

      // В документе больше нет mention_input embed
      final hasEmbed = ops.any((op) =>
          op.data is Map && (op.data! as Map).containsKey(mentionInputType));
      expect(hasEmbed, isFalse);

      // С query-текста снят атрибут color
      final coloredOps = ops.where(
        (op) => op.attributes?.containsKey('color') ?? false,
      );
      expect(coloredOps, isEmpty);
    });

    test('возвращает тот же экземпляр, если embed нет', () {
      final delta = Delta()..insert('hello\n');
      final data = ChatMessageComposerMessageData(
        document: Document.fromDelta(delta),
        files: const [],
      );

      final result = data.removeMentionInputEmbeds();
      expect(identical(result, data), isTrue);
    });
  });
}
