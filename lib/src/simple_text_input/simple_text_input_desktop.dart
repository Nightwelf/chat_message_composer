import 'package:chat_message_composer/src/extensions/document_ext.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/send_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/smile_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/message_input/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class SimpleTextInputDesktop extends StatelessWidget {
  const SimpleTextInputDesktop({
    required this.quillController,
    required this.editorFocusNode,
    required this.editorScrollController,
    required this.onSendTap,
    this.autofocus = false,
    this.forceSendEnabled = false,
    super.key,
  });

  final QuillController quillController;
  final FocusNode editorFocusNode;
  final ScrollController editorScrollController;
  final VoidCallback onSendTap;
  final bool autofocus;
  final bool forceSendEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ChatEditorSpacing.px12,
          vertical: ChatEditorSpacing.px8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceTertiary,
                  borderRadius: ChatEditorRadii.br10,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: ChatEditorSpacing.px12,
                          right: ChatEditorSpacing.px6,
                          top: ChatEditorSpacing.px8,
                          bottom: ChatEditorSpacing.px8,
                        ),
                        child: MessageInput(
                          maxHeight: 120,
                          autofocus: autofocus,
                          editorFocusNode: editorFocusNode,
                          editorScrollController: editorScrollController,
                          controller: quillController,
                          onEnterPressed: onSendTap,
                        ),
                      ),
                    ),
                    SmileButton(
                      quillController: quillController,
                      focusNode: editorFocusNode,
                      alignment: Alignment.bottomRight,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: ChatEditorSpacing.px8),
            ListenableBuilder(
              listenable: quillController,
              builder: (context, _) => SendButton(
                enabled: forceSendEnabled || !quillController.document.isBlank,
                onTap: onSendTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
