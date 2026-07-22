import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'message_input_intents.dart';

class MessageInputEnterAction extends Action<MessageInputEnterIntent> {
  MessageInputEnterAction({required this.onEnter});
  final VoidCallback? onEnter;

  @override
  Object? invoke(MessageInputEnterIntent intent) {
    onEnter?.call();
    return null;
  }
}

class EditorPasteAction extends Action<EditorPasteIntent> {
  EditorPasteAction({required this.onPaste});
  final VoidCallback? onPaste;

  @override
  Object? invoke(EditorPasteIntent intent) {
    onPaste?.call();
    return null;
  }
}

class EditorCopyAction extends Action<EditorCopyIntent> {
  EditorCopyAction({required this.controller});
  final QuillController controller;

  @override
  Object? invoke(EditorCopyIntent intent) {
    // ignore: experimental_member_use
    controller.clipboardSelection(true);
    return null;
  }
}
