import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

final class EditorContext {
  EditorContext({
    required this.delta,
    required this.files,
    required this.composeContext,
  });

  final Delta delta;
  final List<XFile> files;
  final ChatMessageComposerComposeContext? composeContext;
}
