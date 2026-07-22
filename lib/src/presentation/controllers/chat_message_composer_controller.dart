import 'dart:async';

import 'package:chat_message_composer/src/domain/entities/mention_command.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_command/mention_command_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/utils/delta_mention_analyzer.dart';
import 'package:chat_message_composer/src/presentation/utils/line_ending_utils.dart';
import 'package:chat_message_composer/src/presentation/utils/list_numbering_utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../data/datasources/clipboard_file_reader_impl.dart';
import '../../data/datasources/message_file_picker_impl.dart';
import '../../data/models/chat_message_composer_compose_context.dart';
import '../../domain/entities/mention.dart';
import '../../domain/entities/mention_embed.dart';
import '../bloc/message_files/message_files_bloc.dart';

/// A [FocusNode] that can temporarily suppress [requestFocus] calls, and
/// that only closes the keyboard on an explicit, user-driven action.
///
/// When [suppressRequests] is true, any call to [requestFocus] is a no-op.
/// Used by the mobile emoji panel to prevent flutter_quill's cursor-animation
/// dirty-state loop from re-gaining focus (and re-showing the keyboard) while
/// the emoji panel is open.
///
/// Plain [unfocus] is disabled on purpose: a bare `.unfocus()` call anywhere
/// in the tree (our code, flutter_quill internals, a stray `onTapOutside`
/// firing for a tap on a button that lives inside the input bar, etc.) must
/// not be able to silently drop the keyboard — that reads as the keyboard
/// "spontaneously" closing (e.g. right after tapping Send). Real,
/// user-intentional closes (swipe-to-dismiss, back button/gesture, tapping
/// the message list) must go through [closeKeyboard] instead.
class SuppressableFocusNode extends FocusNode {
  bool suppressRequests = false;

  @override
  void requestFocus([FocusNode? node]) {
    if (!suppressRequests) super.requestFocus(node);
  }

  @override
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) {}

  /// Closes the keyboard in response to an explicit user action.
  void closeKeyboard({UnfocusDisposition disposition = UnfocusDisposition.scope}) {
    super.unfocus(disposition: disposition);
  }
}

class ChatMessageComposerController extends ChangeNotifier {
  ChatMessageComposerController({
    required this.disableMentions,
    this.onDocumentChange,
    Delta? initialDelta,
  }) : _initialDelta = initialDelta;

  static const filePicker = MessageFilePickerImpl();
  static const clipboardReader = ClipboardFileReaderImpl();

  final bool disableMentions;
  final void Function(Delta delta)? onDocumentChange;
  Delta? _initialDelta;

  final QuillController quillController = QuillController(
    document: Document(),
    selection: const TextSelection.collapsed(offset: 0),
    config: QuillControllerConfig(
      // Экспериментальный API flutter_quill: используем осознанно, чтобы
      // отключить внешнюю rich-вставку (обрабатываем paste сами).
      // ignore: experimental_member_use
      clipboardConfig: QuillClipboardConfig(
        // Тот же экспериментальный API flutter_quill (осознанное использование).
        // ignore: experimental_member_use
        enableExternalRichPaste: false,
        // Windows кладёт в буфер обмена переносы строк как `\r\n`, из-за чего
        // при вставке визуальный line-breaking (Unicode UAX#14 трактует `\r`
        // как обязательный разрыв) расходится с моделью документа Quill
        // (разбивает строки только по `\n`) — курсор смещается на строку вверх,
        // а строка вставки визуально "съедается". На Linux буфер обычно
        // содержит только `\n`, поэтому баг воспроизводится только под Windows.
        // ignore: experimental_member_use
        onPlainTextPaste: (plainText) async => normalizeLineEndings(plainText),
      ),
    ),
  );
  final SuppressableFocusNode editorFocusNode = SuppressableFocusNode();
  final ScrollController editorScrollController = ScrollController();
  final ScrollController toolbarScrollController = ScrollController();

  StreamSubscription<DocChange>? _documentChangesSubscription;

  bool _isTextFormatEnabled = false;
  int _styledQueryLength = 0;

  /// Последний применённый compose-контекст. Используется для идемпотентности
  /// [applyComposeContext]: повторное применение того же контекста (например,
  /// listener-эхо начального `ComposeContext$Set`, уже применённого в initState)
  /// не должно заново пересоздавать документ и очищать/перечитывать файлы.
  ///
  /// initState выставляет его после синхронного применения начального контекста.
  ChatMessageComposerComposeContext? lastAppliedComposeContext;

  bool get isTextFormatEnabled => _isTextFormatEnabled;

  Document? documentForComposeContext(ChatMessageComposerComposeContext? ctx) {
    return switch (ctx) {
      ChatMessageComposerComposeContextEditing(:final originalDocument) => originalDocument,
      ChatMessageComposerComposeContextQuoting() => null,
      ChatMessageComposerComposeContextReplying() => null,
      ChatMessageComposerComposeContextIdle(:final initialDocument) =>
        initialDocument ?? (_initialDelta != null ? Document.fromDelta(_initialDelta!) : Document()),
      null => null,
    };
  }

  List<XFile> initialFilesForComposeContext(ChatMessageComposerComposeContext? ctx) {
    return switch (ctx) {
      ChatMessageComposerComposeContextEditing(:final originalFiles) => originalFiles,
      ChatMessageComposerComposeContextIdle(:final initialFiles) => initialFiles,
      _ => const [],
    };
  }

  void applyComposeContext(
    BuildContext context,
    ChatMessageComposerComposeContext? ctx,
    ChatMessageComposerComposeContext? previousCtx,
  ) {
    // Контекст не изменился — нечего применять (контексты Equatable). Защищает
    // от listener-эха начального Set и дублирующих уведомлений: без этого
    // повторный проход делает MessageFiles$Clear+Add (фликер, повторный декод
    // файлов и потеря widget.initialFiles).
    if (ctx == lastAppliedComposeContext) return;
    lastAppliedComposeContext = ctx;

    final isRQContext = ctx is ChatMessageComposerComposeContextReplying || ctx is ChatMessageComposerComposeContextQuoting;
    final wasEditing = previousCtx is ChatMessageComposerComposeContextEditing;

    final document = (ctx == null && wasEditing)
        ? (_initialDelta != null ? Document.fromDelta(_initialDelta!) : Document())
        : documentForComposeContext(ctx);

    if (document != null) {
      quillController.document = document;
    }
    updateDocumentSubscription(context);
    if (!isRQContext && (ctx != null || wasEditing)) {
      final files = initialFilesForComposeContext(ctx);
      context.read<MessageFilesBloc>().add(const MessageFiles$Clear());
      if (files.isNotEmpty) {
        context.read<MessageFilesBloc>().add(MessageFiles$Add(files));
      }
    }
    if (ctx != null && editorFocusNode.canRequestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final len = quillController.document.length;
        quillController.updateSelection(
          TextSelection.collapsed(offset: len),
          ChangeSource.local,
        );
        if (editorFocusNode.canRequestFocus) {
          editorFocusNode.requestFocus();
        }
      });
    }
  }

  void focusNodeListener(BuildContext context) {
    if (!disableMentions && editorFocusNode.hasFocus && context.mounted) {
      context.read<MentionPanelBloc>().add(const MentionPanelEvent$Reset());
    }
  }

  void updateDocumentSubscription(BuildContext context) {
    _documentChangesSubscription?.cancel();
    _documentChangesSubscription = quillController.document.changes.listen(
      (change) {
        if (context.mounted) {
          onDocumentChanged(change, context);
        }
      },
    );
  }

  void onDocumentChanged(DocChange change, BuildContext context) {
    if (!context.mounted) return;

    // Пропускаем изменения от applyListRealIndexUpdates, чтобы не попасть в рекурсию
    if (quillController.document.history.ignoreChange) return;

    if (change.change.operations.every((op) => op.isRetain)) {
      // Retain-only: форматирование (например, toolbar). Обновляем LRI только если
      // изменился атрибут list — это означает, что пользователь применил/снял список.
      final hasListAttrChange = change.change.operations.any(
        (op) => op.isRetain && (op.attributes?.containsKey('list') ?? false),
      );
      if (!hasListAttrChange) return;
    }

    ListNumberingUtils.updateListNumbering(quillController.document);

    final delta = quillController.document.toDelta();

    onDocumentChange?.call(delta);

    if (disableMentions) return;

    final cursorPosition = quillController.selection.isValid ? quillController.selection.baseOffset : -1;

    context.read<MentionPanelBloc>().add(MentionPanelEvent$DocumentChanged(
          cursorPosition: cursorPosition,
          delta: delta,
        ));

    _trackMentionQueryRange(delta, cursorPosition);
  }

  /// Отслеживает диапазон query-текста после embed mention_input в документе.
  ///
  /// Query не подсвечивается — синий цвет означает, что упоминание уже
  /// «подцепилось» (см. [insertMention]), а не то, что оно ещё вводится.
  /// Диапазон нужен только для корректного удаления query при конвертации
  /// embed в финальное упоминание.
  void _trackMentionQueryRange(Delta delta, int cursorPosition) {
    if (cursorPosition < 0) {
      _styledQueryLength = 0;
      return;
    }

    final analyzer = DeltaMentionAnalyzer(delta: delta, cursorPosition: cursorPosition);
    final query = analyzer.mentionInputQuery;
    final hasActiveEmbed = analyzer.hasMentionInputEmbed && !query.contains(' ') && !query.contains('\n');

    if (hasActiveEmbed) {
      final queryStart = analyzer.mentionInputEmbedIndex + 1;
      _styledQueryLength = cursorPosition - queryStart;
    } else {
      _styledQueryLength = 0;
    }
  }

  void insertMentionInputEmbed(int atPosition, BuildContext context) {
    try {
      const mentionInputEmbed = MentionInputEmbed(query: '');
      final embedData = mentionInputEmbed.toDeltaInsert();
      final embeddable = Embeddable(
        mentionInputType,
        embedData[mentionInputType] as Map<String, dynamic>? ?? {},
      );

      quillController.document.replace(atPosition, 1, embeddable);
      quillController.updateSelection(
        TextSelection.collapsed(offset: atPosition + 1),
        ChangeSource.local,
      );
    } on Exception catch (_) {
      if (context.mounted) {
        context.read<MentionPanelBloc>().add(const MentionPanelEvent$Reset());
      }
    }
  }

  void insertMention(Mention mention, int embedPosition, BuildContext context) {
    try {
      final mentionEmbed = MentionEmbed(
        id: mention.id,
        name: mention.name,
        avatar: mention.avatar,
        nickname: mention.nickname,
        additional: mention.additional,
      );
      final mentionEmbedData = mentionEmbed.toDeltaInsert();
      final embeddable = Embeddable(
        mentionType,
        mentionEmbedData[mentionType] as Map<String, dynamic>? ?? {},
      );

      final deleteLength = 1 + (_styledQueryLength > 0 ? _styledQueryLength : 0);
      _styledQueryLength = 0;

      quillController.document.replace(embedPosition, deleteLength, embeddable);
      final spacePosition = embedPosition + 1;
      quillController.document.replace(spacePosition, 0, ' ');
      quillController.updateSelection(
        TextSelection.collapsed(offset: spacePosition + 1),
        ChangeSource.local,
      );

      if (editorFocusNode.canRequestFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (editorFocusNode.canRequestFocus) editorFocusNode.requestFocus();
        });
      }
    } on Exception catch (_) {
      if (context.mounted) {
        context.read<MentionPanelBloc>().add(const MentionPanelEvent$Reset());
      }
    }
  }

  void onTextFormat({required bool pressed}) {
    _isTextFormatEnabled = pressed;
    notifyListeners();
  }

  void clearInitialDelta() {
    _initialDelta = null;
  }

  void cancelMentionInput(
    int embedPosition,
    String query,
    BuildContext context, {
    required bool addTrailingSpace,
  }) {
    try {
      // Используем query.length для deleteLength, а не _styledQueryLength:
      // к моменту выполнения команды _styledQueryLength может быть уже сброшен
      // (например, контроллер обработал смену документа раньше блока).
      final deleteLength = 1 + query.length;
      _styledQueryLength = 0;

      // addTrailingSpace=true для ESC: пробела в документе нет, добавляем сами,
      // чтобы '@' не считался активным и панель не открылась снова.
      // addTrailingSpace=false для разделителя: пробел уже есть внутри query.
      final insertText = addTrailingSpace ? '@$query ' : '@$query';
      quillController.document.replace(embedPosition, deleteLength, insertText);
      quillController.updateSelection(
        TextSelection.collapsed(offset: embedPosition + insertText.length),
        ChangeSource.local,
      );
    } on Object catch (_) {
      // ignore: позиции устарели — отменять mention-ввод уже не на чем
    }
  }

  void handleMentionCommand(MentionCommandState state, BuildContext context) {
    if (state is MentionCommandState$Pending) {
      switch (state.command) {
        case InsertMentionInputCommand(:final atPosition):
          insertMentionInputEmbed(atPosition, context);
        case InsertMentionCommand(:final mention, :final embedPosition):
          insertMention(mention, embedPosition, context);
        case CancelMentionInputCommand(:final embedPosition, :final query, :final addTrailingSpace):
          cancelMentionInput(embedPosition, query, context, addTrailingSpace: addTrailingSpace);
      }
      context.read<MentionCommandBloc>().add(const MentionCommandEvent$Processed());
    }
  }

  @override
  void dispose() {
    _documentChangesSubscription?.cancel();
    editorFocusNode.dispose();
    quillController.dispose();
    editorScrollController.dispose();
    toolbarScrollController.dispose();
    super.dispose();
  }
}
