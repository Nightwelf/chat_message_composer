import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/controllers/chat_message_composer_controller.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/emoji/emoji_embed_builder.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_embed_builder.dart';
import 'package:chat_message_composer/src/presentation/widgets/message_input/editor_drag_auto_scroll.dart';
import 'package:chat_message_composer/src/presentation/widgets/message_input/message_input_actions.dart';
import 'package:chat_message_composer/src/presentation/widgets/message_input/message_input_intents.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({
    required double maxHeight,
    required FocusNode editorFocusNode,
    required ScrollController editorScrollController,
    required QuillController controller,
    super.key,
    bool autofocus = false,
    VoidCallback? onEnterPressed,
    bool Function()? onArrowUpPressed,
    bool Function()? onArrowDownPressed,
    bool Function()? onEscapePressed,
    bool Function()? onPastePressed,
    VoidCallback? onArrowUpAtStart,
    MentionTapCallback? onMentionTap,
    MentionTapCallback? onMentionLongTap,
  })  : _editorFocusNode = editorFocusNode,
        _editorScrollController = editorScrollController,
        _controller = controller,
        _autofocus = autofocus,
        _onEnterPressed = onEnterPressed,
        _onArrowUpPressed = onArrowUpPressed,
        _onArrowDownPressed = onArrowDownPressed,
        _onEscapePressed = onEscapePressed,
        _onPastePressed = onPastePressed,
        _onArrowUpAtStart = onArrowUpAtStart,
        _onMentionTap = onMentionTap,
        _onMentionLongTap = onMentionLongTap,
        _maxHeight = maxHeight;

  final FocusNode _editorFocusNode;
  final ScrollController _editorScrollController;
  final QuillController _controller;
  final bool _autofocus;
  final VoidCallback? _onEnterPressed;
  final bool Function()? _onArrowUpPressed;
  final bool Function()? _onArrowDownPressed;
  final bool Function()? _onEscapePressed;
  final bool Function()? _onPastePressed;
  final VoidCallback? _onArrowUpAtStart;
  final MentionTapCallback? _onMentionTap;
  final MentionTapCallback? _onMentionLongTap;
  final double _maxHeight;

  @override
  Widget build(BuildContext context) {
    final localizationRepository =
        context.read<ChatMessageComposerLocalizationRepository>();
    // Реализация перехвата Enter и NumPad Enter через Shortcuts и Actions
    // А не через QuillEditorConfig, тк последний работает не корректно на Linux
    final child = EditorDragAutoScroll(
      scrollController: _editorScrollController,
      child: TextSelectionTheme(
        data: TextSelectionThemeData(
          selectionColor: Colors.blue.withValues(alpha: 0.3),
          selectionHandleColor: Colors.blue,
          cursorColor: context.chatColors.textPrimary,
        ),
        child: QuillEditor(
          focusNode: _editorFocusNode,
          scrollController: _editorScrollController,
          controller: _controller,
          config: QuillEditorConfig(
            maxHeight: _maxHeight,
            autoFocus: _autofocus,
            // На Android/iOS клавиатура не должна закрываться от тапа/скролла
            // по ленте чата — pointer down тут срабатывает даже в начале жеста
            // прокрутки, до того как GestureArena распознает его как скролл, а
            // не тап. Пользователь на мобильных должен закрыть клавиатуру сам
            // (свайп/системная кнопка "назад"/переключение на панель эмодзи).
            // На остальных платформах тап вне поля ввода закрывает её как раньше.
            onTapOutside: (event, node) {
              if (node is! SuppressableFocusNode) {
                node.unfocus();
                return;
              }
              switch (defaultTargetPlatform) {
                case TargetPlatform.android:
                case TargetPlatform.iOS:
                  return;
                case TargetPlatform.fuchsia:
                case TargetPlatform.linux:
                case TargetPlatform.macOS:
                case TargetPlatform.windows:
                  node.closeKeyboard();
              }
            },
            placeholder: localizationRepository.messageText,
            embedBuilders: [
              ...MentionEmbedBuilder.createBuilders(
                onMentionTap: _onMentionTap,
                onMentionLongTap: _onMentionLongTap,
              ),
              const EmojiEmbedBuilder(),
            ],
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                ChatEditorTypography.body.r16_24.copyWith(
                  letterSpacing: 0,
                  color: context.chatColors.textPrimary,
                ),
                HorizontalSpacing.zero,
                VerticalSpacing.zero,
                VerticalSpacing.zero,
                null,
              ),
              placeHolder: DefaultTextBlockStyle(
                ChatEditorTypography.body.r16_24.copyWith(
                  letterSpacing: 0,
                  color: context.chatColors.textMuted,
                ),
                HorizontalSpacing.zero,
                VerticalSpacing.zero,
                VerticalSpacing.zero,
                null,
              ),
            ),
          ),
        ),
      ),
    );

    Widget result = child;

    // На вебе браузер перехватывает Ctrl+C нативно и копирует embed-объекты
    // как U+FFFC, поэтому перехватываем вручную и вызываем clipboardSelection.
    if (kIsWeb) {
      result = Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.keyC, control: true):
              EditorCopyIntent(),
          SingleActivator(LogicalKeyboardKey.keyC, meta: true):
              EditorCopyIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            EditorCopyIntent: EditorCopyAction(controller: _controller),
          },
          child: result,
        ),
      );
    }

    if (_onPastePressed != null) {
      // Оборачиваем в Shortcuts/Actions для paste
      result = Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.keyV, control: true):
              EditorPasteIntent(),
          SingleActivator(LogicalKeyboardKey.keyV, meta: true):
              EditorPasteIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            EditorPasteIntent: EditorPasteAction(onPaste: _onPastePressed),
          },
          child: result,
        ),
      );
    }

    if (_onArrowUpPressed != null ||
        _onArrowDownPressed != null ||
        _onEnterPressed != null ||
        _onEscapePressed != null) {
      // Для Enter используем Shortcuts/Actions
      if (_onEnterPressed != null) {
        result = Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter):
                MessageInputEnterIntent(),
            SingleActivator(LogicalKeyboardKey.numpadEnter):
                MessageInputEnterIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              MessageInputEnterIntent:
                  MessageInputEnterAction(onEnter: _onEnterPressed),
            },
            child: result,
          ),
        );
      }
      // Для стрелок и Escape используем BlocBuilder для условной обработки.
      // Focus-обёртка всегда присутствует в дереве — это принципиально важно:
      // если добавлять/убирать Focus при изменении видимости панели, Flutter
      // переподключает поддерево и _editorFocusNode теряет фокус.
      if (_onArrowUpPressed != null ||
          _onArrowDownPressed != null ||
          _onEscapePressed != null ||
          _onArrowUpAtStart != null) {
        final editorWidget = result;
        result = BlocBuilder<MentionPanelBloc, MentionPanelState>(
          builder: (context, mentionState) {
            final isPanelVisible = mentionState.isVisible;
            return Focus(
              onKeyEvent: (node, event) {
                // ESC перехватывается кем-то на KeyDown, поэтому обрабатываем KeyUp
                if (event is KeyUpEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  if (isPanelVisible && _onEscapePressed != null) {
                    _onEscapePressed!();
                    _editorFocusNode.requestFocus();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                }

                // Стрелки обрабатываем на KeyDown как обычно
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    if (isPanelVisible && _onArrowUpPressed != null) {
                      _onArrowUpPressed!();
                      return KeyEventResult.handled;
                    }
                    if (_onArrowUpAtStart != null &&
                        _controller.document.isEmpty()) {
                      _onArrowUpAtStart!();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    if (isPanelVisible && _onArrowDownPressed != null) {
                      _onArrowDownPressed!();
                      return KeyEventResult.handled;
                    }
                  }
                }
                return KeyEventResult.ignored;
              },
              child: editorWidget,
            );
          },
        );
      }
    }
    return result;
  }
}
