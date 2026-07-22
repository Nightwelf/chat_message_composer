import 'package:chat_message_composer/src/extensions/document_ext.dart';
import 'package:chat_message_composer/src/presentation/bloc/keyboard_panel/keyboard_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/controllers/chat_message_composer_controller.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/send_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/keyboard_replacement_panel/keyboard_replacement_panel.dart';
import 'package:chat_message_composer/src/presentation/widgets/message_input/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

class SimpleTextInputMobile extends StatelessWidget {
  const SimpleTextInputMobile({
    required this.quillController,
    required this.editorFocusNode,
    required this.editorScrollController,
    required this.onSendTap,
    this.autofocus = false,
    this.forceSendEnabled = false,
    super.key,
  });

  final QuillController quillController;
  final SuppressableFocusNode editorFocusNode;
  final ScrollController editorScrollController;
  final VoidCallback onSendTap;
  final bool autofocus;
  final bool forceSendEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeyboardPanelBloc, KeyboardPanelState>(
      buildWhen: (prev, curr) =>
          (prev is KeyboardPanelState$Emoji) !=
          (curr is KeyboardPanelState$Emoji),
      builder: (context, kpState) {
        final isEmojiOpen = kpState is KeyboardPanelState$Emoji;
        return PopScope(
          canPop: !isEmojiOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && isEmojiOpen) {
              editorFocusNode.suppressRequests = false;
              context
                  .read<KeyboardPanelBloc>()
                  .add(const KeyboardPanel$Close(expectKeyboard: false));
            }
          },
          child: BlocListener<KeyboardPanelBloc, KeyboardPanelState>(
            listenWhen: (prev, curr) =>
                prev is KeyboardPanelState$Emoji &&
                curr is! KeyboardPanelState$Emoji,
            listener: (context, state) {
              editorFocusNode.suppressRequests = false;
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.chatColors.borderSubtle)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ChatEditorSpacing.px12,
                      vertical: ChatEditorSpacing.px8,
                    ),
                    child: Row(                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        Flexible(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.chatColors.surfaceTertiary,
                              borderRadius: ChatEditorRadii.br10,
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Listener(
                                    onPointerDown: (_) {
                                      final bloc =
                                          context.read<KeyboardPanelBloc>();
                                      if (bloc.state
                                          is KeyboardPanelState$Emoji) {
                                        editorFocusNode.suppressRequests =
                                            false;
                                        bloc.add(const KeyboardPanel$Close());
                                      }
                                    },
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
                                        editorScrollController:
                                            editorScrollController,
                                        controller: quillController,
                                      ),
                                    ),
                                  ),
                                ),
                                BlocBuilder<KeyboardPanelBloc,
                                    KeyboardPanelState>(
                                  buildWhen: (prev, curr) =>
                                      (prev is KeyboardPanelState$Emoji) !=
                                      (curr is KeyboardPanelState$Emoji),
                                  builder: (context, state) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        final bloc =
                                            context.read<KeyboardPanelBloc>();
                                        if (bloc.state
                                            is KeyboardPanelState$Emoji) {
                                          editorFocusNode.suppressRequests =
                                              false;
                                          bloc.add(const KeyboardPanel$Close());
                                          editorFocusNode.requestFocus();
                                        } else {
                                          final currentHeight =
                                              MediaQuery.viewInsetsOf(context)
                                                  .bottom;
                                          editorFocusNode.suppressRequests =
                                              true;
                                          bloc.add(KeyboardPanel$ShowEmoji(
                                              currentHeight));
                                          editorFocusNode.closeKeyboard();
                                        }
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(ChatEditorSpacing.px8),
                                        child: Icon(
                                          state is KeyboardPanelState$Emoji
                                              ? ChatEditorIcons.keyboard
                                              : ChatEditorIcons.face,
                                          size: 24,
                                          color: context.chatColors.textMuted,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: ChatEditorSpacing.px8),
                        ListenableBuilder(
                          listenable: quillController,
                          builder: (context, _) => SendButton(
                            enabled: forceSendEnabled ||
                                !quillController.document.isBlank,
                            onTap: onSendTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  KeyboardReplacementPanel(quillController: quillController),
                  const _Area(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Area extends StatefulWidget {
  const _Area();

  @override
  State<_Area> createState() => _AreaState();
}

class _AreaState extends State<_Area> {
  double _lastDispatchedHeight = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    const deltaThreshold = 5.0;
    if (((inset - _lastDispatchedHeight).abs() > deltaThreshold ||
            (inset == 0 && _lastDispatchedHeight > 0)) &&
        inset != _lastDispatchedHeight) {
      _lastDispatchedHeight = inset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return BlocConsumer<KeyboardPanelBloc, KeyboardPanelState>(
      listenWhen: (prev, curr) =>
          prev is KeyboardPanelState$Emoji && curr is! KeyboardPanelState$Emoji,
      listener: (context, state) {},
      builder: (context, state) {
        final isEmojiMode = state is KeyboardPanelState$Emoji;
        if (isEmojiMode || keyboardHeight > 0) return const SizedBox.shrink();
        return const SafeArea(child: SizedBox.shrink());
      },
    );
  }
}
