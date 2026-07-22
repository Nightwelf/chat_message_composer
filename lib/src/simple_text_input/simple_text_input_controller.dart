import 'package:chat_message_composer/src/presentation/controllers/chat_message_composer_controller.dart';
import 'package:chat_message_composer/src/presentation/utils/line_ending_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class SimpleTextInputController extends ChangeNotifier {
  final QuillController quillController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
    config: QuillControllerConfig(
      // Экспериментальный API flutter_quill: осознанно отключаем внешнюю
      // rich-вставку (paste обрабатывается отдельно).
      // ignore: experimental_member_use
      clipboardConfig: QuillClipboardConfig(
        // Тот же экспериментальный API flutter_quill (осознанное использование).
        // ignore: experimental_member_use
        enableExternalRichPaste: false,
        // См. line_ending_utils.dart: нормализация `\r\n`/`\r` из буфера
        // обмена Windows, иначе строка вставки визуально "съедается".
        // ignore: experimental_member_use
        onPlainTextPaste: (plainText) async => normalizeLineEndings(plainText),
      ),
    ),
  );
  final SuppressableFocusNode editorFocusNode = SuppressableFocusNode();
  final ScrollController editorScrollController = ScrollController();

  @override
  void dispose() {
    quillController.dispose();
    editorFocusNode.dispose();
    editorScrollController.dispose();
    super.dispose();
  }
}
