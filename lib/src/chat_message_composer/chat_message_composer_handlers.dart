import 'dart:async';

import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_message_data.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_send_action.dart';
import 'package:chat_message_composer/src/domain/datasources/clipboard_file_reader.dart';
import 'package:chat_message_composer/src/domain/datasources/message_file_picker.dart';
import 'package:chat_message_composer/src/domain/entities/attached_file.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Обработчики событий для ChatMessageComposer.
///
/// Содержит статические методы для обработки различных действий пользователя
/// в редакторе сообщений чата, таких как отправка сообщения, выбор файлов,
/// навигация по панели упоминаний и т.д.
abstract class ChatMessageComposerHandlers {
  /// Обрабатывает нажатие на кнопку отправки сообщения.
  ///
  /// Формирует [ChatMessageComposerSendAction] из контекста [composeContextBloc], создает
  /// [ChatMessageComposerMessageData] и вызывает [onSendTap].
  /// После отправки очищает документ и файлы, вызывает [onDocumentCleared], затем
  /// добавляет [ComposeContext$Clear]. Если передан [editorFocusNode], переносит фокус
  /// в поле ввода в следующем кадре.
  static void onSendTap({
    required QuillController controller,
    required MessageFilesBloc messageFilesBloc,
    required MentionPanelBloc mentionPanelBloc,
    required ComposeContextBloc composeContextBloc,
    void Function(ChatMessageComposerMessageData message,
            ChatMessageComposerSendAction action)?
        onSendTap,
    void Function()? onDocumentCleared,
    FocusNode? editorFocusNode,
  }) {
    final currentState = messageFilesBloc.state;

    // Пока идёт асинхронное добавление файла, он ещё не попал в state — если
    // отправить сейчас, сообщение уйдёт без него. Блокируем отправку до
    // завершения (см. MessageFilesState$Data.isProcessing).
    if (currentState is MessageFilesState$Data && currentState.isProcessing) {
      return;
    }

    final enabled = !controller.document.isEmpty() ||
        switch (currentState) {
          MessageFilesState$Data(:final files) => files.isNotEmpty,
        };
    if (!enabled) {
      return;
    }

    final composeContext = composeContextBloc.state.composeContext;
    final files = currentState is MessageFilesState$Data
        ? List<AttachedFile>.from(currentState.files)
        : <AttachedFile>[];

    final action = switch (composeContext) {
      null => const ChatMessageComposerSendActionSend(),
      ChatMessageComposerComposeContextIdle() =>
        const ChatMessageComposerSendActionSend(),
      ChatMessageComposerComposeContextEditing(:final messageId) =>
        ChatMessageComposerSendActionEdit(messageId: messageId),
      ChatMessageComposerComposeContextQuoting(
        :final id,
        :final delta,
        :final author
      ) =>
        ChatMessageComposerSendActionQuote(
            quoteToMessageId: id, quotedDelta: delta, quotedAuthor: author),
      ChatMessageComposerComposeContextReplying(
        :final id,
        :final delta,
        :final author
      ) =>
        ChatMessageComposerSendActionReply(
            replyToMessageId: id, replyDelta: delta, replyAuthor: author),
    };

    final documentCopy =
        Document.fromDelta(controller.document.toDelta().applyListRealIndex);
    final fileDimensions = {
      for (final f in files)
        if (f.imageSize != null) f.data.path: f.imageSize!,
    };
    final message = ChatMessageComposerMessageData(
      document: documentCopy,
      files: files.map((e) => e.data).toList(),
      fileDimensions: fileDimensions,
    );
    onSendTap?.call(message, action);
    controller.document = Document();
    messageFilesBloc.add(const MessageFiles$Clear());
    onDocumentCleared?.call();
    mentionPanelBloc.add(const MentionPanelEvent$Reset());
    composeContextBloc.add(const ComposeContext$Clear());
    if (editorFocusNode != null && editorFocusNode.canRequestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (editorFocusNode.canRequestFocus) editorFocusNode.requestFocus();
      });
    }
  }

  /// Обрабатывает нажатие клавиши Enter.
  ///
  /// Если панель упоминаний видима, обрабатывает навигацию и выбор упоминания.
  /// В противном случае вызывает отправку сообщения.
  static void handleEnterPressed({
    required QuillController controller,
    required MessageFilesBloc messageFilesBloc,
    required MentionPanelBloc mentionPanelBloc,
    required ComposeContextBloc composeContextBloc,
    void Function(ChatMessageComposerMessageData message,
            ChatMessageComposerSendAction action)?
        onSendTap,
    void Function()? onDocumentCleared,
    FocusNode? editorFocusNode,
  }) {
    // Пока активен '@'-ввод (панель видима — Loading или Data), Enter не должен
    // отправлять сообщение: при Data с элементами выбираем упоминание, в
    // остальных случаях (например, идёт загрузка списка) просто поглощаем Enter,
    // чтобы не отправить незавершённый mention-ввод и не потерять набранный текст.
    if (mentionPanelBloc.state.isVisible) {
      final mentionPanelState = mentionPanelBloc.state;
      if (mentionPanelState is MentionPanelState$Data &&
          mentionPanelState.mentions.isNotEmpty) {
        mentionPanelBloc.add(const MentionPanelEvent$SelectFirstOrCurrent());
      }
      return;
    }
    ChatMessageComposerHandlers.onSendTap(
      controller: controller,
      messageFilesBloc: messageFilesBloc,
      mentionPanelBloc: mentionPanelBloc,
      composeContextBloc: composeContextBloc,
      onSendTap: onSendTap,
      onDocumentCleared: onDocumentCleared,
      editorFocusNode: editorFocusNode,
    );
  }

  /// Обрабатывает нажатие клавиши стрелка вверх.
  ///
  /// Если панель упоминаний видима, перемещает выделение вверх.
  /// Возвращает `true`, если событие обработано, иначе `false`.
  static bool handleArrowUpPressed({
    required MentionPanelBloc mentionPanelBloc,
  }) {
    if (mentionPanelBloc.state.isVisible) {
      mentionPanelBloc.add(const MentionPanelEvent$NavigateUp());
      return true;
    }
    return false;
  }

  /// Обрабатывает нажатие клавиши стрелка вниз.
  ///
  /// Если панель упоминаний видима, перемещает выделение вниз.
  /// Возвращает `true`, если событие обработано, иначе `false`.
  static bool handleArrowDownPressed({
    required MentionPanelBloc mentionPanelBloc,
  }) {
    if (mentionPanelBloc.state.isVisible) {
      mentionPanelBloc.add(const MentionPanelEvent$NavigateDown());
      return true;
    }
    return false;
  }

  /// Обрабатывает нажатие клавиши Escape.
  ///
  /// Если панель упоминаний видима, закрывает её.
  /// Возвращает `true`, если событие обработано, иначе `false`.
  static bool handleEscapePressed({
    required MentionPanelBloc mentionPanelBloc,
    required FocusNode editorFocusNode,
  }) {
    if (mentionPanelBloc.state.isVisible) {
      mentionPanelBloc
          .add(const MentionPanelEvent$Reset(convertEmbedToText: true));
      if (editorFocusNode.canRequestFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (editorFocusNode.canRequestFocus) editorFocusNode.requestFocus();
        });
      }
      return true;
    }
    return false;
  }

  /// Обрабатывает выбор фото или видео.
  ///
  /// Открывает диалог выбора изображений и добавляет выбранные файлы
  /// в [MessageFilesBloc].
  /// [isMounted] вызывается после `await`, чтобы проверить, что виджет ещё смонтирован.
  static Future<void> onPhotoOrVideoTap({
    required MessageFilesBloc bloc,
    required MessageFilePicker filePicker,
    required bool Function() isMounted,
  }) async {
    final files = await filePicker.pickMediaFiles(allowMultiple: true);
    if (files.isNotEmpty && isMounted()) {
      bloc.add(MessageFiles$Add(files));
    }
  }

  /// Обрабатывает выбор камеры.
  ///
  ///Открывает камеру и позволяет сделать фото или видео
  /// и добавляет выбранные файлы в [MessageFilesBloc].
  /// [context] - контекст для навигации к экрану камеры.
  /// [isMounted] вызывается после `await`, чтобы проверить, что виджет ещё смонтирован.
  static Future<void> onCameraTap({
    required BuildContext context,
    required MessageFilesBloc bloc,
    required MessageFilePicker filePicker,
    required bool Function() isMounted,
  }) async {
    final files = await filePicker.pickCameraImage(context);
    if (files.isNotEmpty && isMounted()) {
      bloc.add(MessageFiles$Add(files));
    }
  }

  /// Обрабатывает выбор документа.
  ///
  /// Открывает диалог выбора файлов и добавляет выбранные файлы
  /// в [MessageFilesBloc].
  /// [isMounted] вызывается после `await`, чтобы проверить, что виджет ещё смонтирован.
  static Future<void> onDocumentTap({
    required MessageFilesBloc bloc,
    required MessageFilePicker filePicker,
    required bool Function() isMounted,
  }) async {
    final files = await filePicker.pickFiles(allowMultiple: true);
    if (files.isNotEmpty && isMounted()) {
      bloc.add(MessageFiles$Add(files));
    }
  }

  /// Обрабатывает нажатие на кнопку контакта.
  static void onContactTap() {}

  /// Обрабатывает нажатие на кнопку опроса.
  static void onPollTap() {}

  /// Обрабатывает нажатие на кнопку события.
  static void onEventTap() {}

  /// Обрабатывает нажатие на кнопку смайлика.
  static void onSmileTap() {}

  /// Обрабатывает нажатие на кнопку упоминания.
  ///
  /// Вставляет символ `@` в текущую позицию курсора и переносит фокус
  /// в поле ввода.
  static void onAtTap({
    required QuillController controller,
    FocusNode? editorFocusNode,
  }) {
    final index = controller.selection.baseOffset;
    final safeIndex = index < 0 ? 0 : index;
    controller.replaceText(
        safeIndex, 0, '@', TextSelection.collapsed(offset: safeIndex + 1));
    if (editorFocusNode != null && editorFocusNode.canRequestFocus) {
      editorFocusNode.requestFocus();
    }
  }

  /// Обрабатывает вставку из буфера обмена (Ctrl/Cmd+V).
  ///
  /// Сначала проверяет [DeltaClipboard]: если есть Delta (скопирована из чата),
  /// вставляет её с сохранением форматирования (списки, жирный и т.д.).
  /// Иначе проверяет файлы/изображения в системном буфере.
  /// Иначе вызывает [onFallbackPaste] для вставки обычного текста через Quill.
  /// [isMounted] вызывается после `await`, чтобы проверить, что виджет ещё смонтирован.
  static Future<void> onPaste({
    required ClipboardFileReader clipboardReader,
    required MessageFilesBloc messageFilesBloc,
    required bool Function() isMounted,
    required Future<bool> Function() onFallbackPaste,
    QuillController? controller,
  }) async {
    final deltaToPaste = DeltaClipboard.consume();
    if (deltaToPaste != null && controller != null) {
      _insertDeltaAtCursor(controller, deltaToPaste);
      return;
    }

    final files = await clipboardReader.readFiles();
    if (!isMounted()) return;
    if (files.isNotEmpty) {
      messageFilesBloc.add(MessageFiles$Add(files));
    } else {
      await onFallbackPaste();
    }
  }

  // Нормализует ordered-элементы перед вставкой в QuillEditor.
  //
  // QuillEditor не знает про list-real-index и всегда нумерует с 1.
  // Если список начинается не с 1 (fragment), конвертируем такие строки
  // в plain text с встроенным номером ("2. текст"), сохраняя inline-форматирование.
  // Полные списки (начинающиеся с 1 подряд) остаются реальными list items.
  static Delta _normalizeOrderedListsForPaste(Delta delta) {
    final ops = delta.toJson() as List<dynamic>;
    final result = <Map<String, dynamic>>[];
    final lineOps = <Map<String, dynamic>>[];
    var orderedCounter = 0;
    var isConvertingOrderedList = false;

    void flushLine(Map<String, dynamic> newlineOp) {
      final rawAttr = newlineOp['attributes'] as Map<String, dynamic>?;

      if (rawAttr?['list'] == 'ordered') {
        orderedCounter++;
        final realIndex =
            (rawAttr!['list-real-index'] as int?) ?? orderedCounter;

        if (!isConvertingOrderedList && realIndex != orderedCounter) {
          isConvertingOrderedList = true;
        }

        if (isConvertingOrderedList) {
          if (lineOps.isNotEmpty && lineOps.first['insert'] is String) {
            final first = Map<String, dynamic>.from(lineOps.first as Map);
            first['insert'] = '$realIndex. ${lineOps.first['insert']}';
            lineOps[0] = first;
          } else {
            lineOps.insert(0, {'insert': '$realIndex. '});
          }
          result
            ..addAll(lineOps)
            ..add({'insert': '\n'});
        } else {
          final newAttr = Map<String, dynamic>.from(rawAttr)
            ..remove('list-real-index');
          result
            ..addAll(lineOps)
            ..add({
              'insert': '\n',
              if (newAttr.isNotEmpty) 'attributes': newAttr
            });
        }
      } else {
        if (rawAttr?['list'] == null) {
          orderedCounter = 0;
          isConvertingOrderedList = false;
        }
        result
          ..addAll(lineOps)
          ..add(newlineOp);
      }
      lineOps.clear();
    }

    for (final op in ops) {
      final insert = (op as Map<String, dynamic>)['insert'];
      if (insert is String && insert == '\n') {
        flushLine(op);
      } else {
        lineOps.add(op);
      }
    }
    result.addAll(lineOps);

    return Delta.fromJson(result);
  }

  static void _insertDeltaAtCursor(
      QuillController controller, Delta deltaToPaste) {
    final sel = controller.selection;
    final index = sel.baseOffset < 0 ? 0 : sel.baseOffset;
    final selLength =
        sel.isCollapsed ? 0 : (sel.extentOffset - sel.baseOffset).abs();

    // Убираем финальный \n из вставляемого Delta если следующий символ уже \n
    // (иначе появится лишняя пустая строка после вставки).
    final ops = _normalizeOrderedListsForPaste(deltaToPaste).toList();
    final lastOp = ops.isNotEmpty ? ops.last : null;
    final hasTrailingNewline = lastOp != null &&
        lastOp.data is String &&
        lastOp.data == '\n' &&
        (lastOp.attributes == null || lastOp.attributes!.isEmpty);

    final docLength = controller.document.length;
    final nextCharIsNewline = (index < docLength) &&
        controller.document.getPlainText(index, 1) == '\n';

    final insertOps = (hasTrailingNewline && nextCharIsNewline)
        ? ops.sublist(0, ops.length - 1)
        : ops;

    var composeDelta = Delta()..retain(index);
    if (selLength > 0) composeDelta = composeDelta..delete(selLength);
    for (final op in insertOps) {
      composeDelta.push(op);
    }

    controller.document.compose(composeDelta, ChangeSource.local);

    final insertedLength =
        insertOps.fold<int>(0, (sum, op) => sum + (op.length ?? 0));
    controller.updateSelection(
      TextSelection.collapsed(offset: index + insertedLength),
      ChangeSource.local,
    );
  }
}
