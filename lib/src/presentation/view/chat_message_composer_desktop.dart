import 'dart:async';

import 'package:chat_message_composer/src/chat_message_composer/chat_message_composer_handlers.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_message_data.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_send_action.dart';
import 'package:chat_message_composer/src/domain/datasources/message_file_picker.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/controllers/chat_message_composer_controller.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart' as th;
import 'package:chat_message_composer/src/presentation/widgets/components/edit_mode_indicator/edit_mode_indicator_desktop.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/editor_drop_zone/editor_drop_zone.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/editor_toolbar/editor_toolbar.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/message_files_list.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_embed_builder.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_panel.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/reply_quoted_message_preview/reply_quoted_message_preview.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel/send_panel.dart';
import 'package:chat_message_composer/src/presentation/widgets/message_input/message_input.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Редактор ввода сообщений для десктопной версии приложения.
///
/// Виджет предоставляет полнофункциональный интерфейс для создания и отправки
/// сообщений в чате. Включает следующие компоненты:
/// - Панель упоминаний пользователей (@)
/// - Панель форматирования текста (опционально)
/// - Поле ввода сообщения с поддержкой форматирования
/// - Список прикрепленных файлов
/// - Панель управления с кнопками для добавления контента и отправки
///
/// Особенности десктопной версии:
/// - Панель форматирования текста расположена над полем ввода
/// - Все элементы сгруппированы в единый блок с закругленными углами
/// - Поддержка горизонтальной прокрутки панели инструментов колесиком мыши
/// - Оптимизированная компоновка для больших экранов
///
/// Виджет требует наличия BLoC провайдеров:
/// - [MentionPanelBloc] для управления панелью упоминаний
/// - [MessageFilesBloc] для управления прикрепленными файлами
///
/// Пример использования:
/// ```dart
/// ChatMessageComposerDesktop(
///   controller: quillController,
///   editorFocusNode: focusNode,
///   editorScrollController: scrollController,
///   toolbarScrollController: toolbarScrollController,
///   onSendTap: (message) => _handleSend(message),
///   updateDocumentSubscription: () => _updateSubscription(),
///   isTextFormatEnabled: true,
///   onTextFormat: (enabled) => _handleTextFormat(enabled),
///   filePicker: filePicker,
/// )
/// ```
class ChatMessageComposerDesktop extends StatelessWidget {
  /// Создает редактор ввода сообщений для десктопной версии.
  ///
  /// [controller] - контроллер Flutter Quill для управления содержимым
  /// текстового редактора. Обязательный параметр.
  ///
  /// [editorFocusNode] - узел фокуса для поля ввода сообщения.
  /// Используется для управления фокусом и обработки событий клавиатуры.
  /// Обязательный параметр.
  ///
  /// [editorScrollController] - контроллер прокрутки для поля ввода сообщения.
  /// Используется для программного управления прокруткой содержимого.
  /// Обязательный параметр.
  ///
  /// [toolbarScrollController] - контроллер прокрутки для панели инструментов
  /// форматирования текста. Используется для горизонтальной прокрутки
  /// кнопок форматирования. Обязательный параметр.
  ///
  /// [onSendTap] - callback, вызываемый при отправке сообщения.
  /// Передает созданный объект [ChatMessageComposerMessageData] с содержимым и прикрепленными файлами.
  ///
  /// [updateDocumentSubscription] - callback, вызываемый при очистке документа.
  /// Используется для обновления подписок на изменения документа.
  /// Обязательный параметр.
  ///
  /// [isTextFormatEnabled] - флаг, определяющий, отображается ли панель
  /// форматирования текста. Обязательный параметр.
  ///
  /// [onTextFormat] - callback, вызываемый при изменении состояния
  /// панели форматирования текста. Передает новое состояние (true/false).
  ///
  /// [filePicker] - реализация выбора файлов для прикрепления к сообщению.
  /// Используется для выбора фото, видео и документов.
  /// Обязательный параметр.
  ///
  /// [disableMentions] - отключает упоминания пользователей через @. По умолчанию false.
  ///
  /// [messageInputMaxHeight] - максимальная высота поля ввода сообщения. По умолчанию 280.
  const ChatMessageComposerDesktop({
    required this.controller,
    required this.editorFocusNode,
    required this.editorScrollController,
    required this.toolbarScrollController,
    required this.updateDocumentSubscription,
    required this.isTextFormatEnabled,
    required this.onTextFormat,
    required this.filePicker,
    required this.mentionItemBuilder,
    this.rqMentionConfig,
    this.rqImageBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onSendTap,
    this.onMentionTap,
    this.onMentionLongTap,
    this.onArrowUpAtStart,
    this.autofocus = false,
    this.disableMentions = false,
    this.messageInputMaxHeight = 280,
    this.renderMentionPanel = true,
    this.constraints,
    this.padding,
    super.key,
  });

  /// Контроллер Flutter Quill для управления содержимым текстового редактора.
  final QuillController controller;

  /// Узел фокуса для поля ввода сообщения.
  /// Используется для управления фокусом и обработки событий клавиатуры.
  final FocusNode editorFocusNode;

  /// Контроллер прокрутки для поля ввода сообщения.
  /// Используется для программного управления прокруткой содержимого.
  final ScrollController editorScrollController;

  /// Контроллер прокрутки для панели инструментов форматирования текста.
  /// Используется для горизонтальной прокрутки кнопок форматирования.
  final ScrollController toolbarScrollController;

  /// Callback, вызываемый при отправке сообщения (message и [ChatMessageComposerSendAction]).
  final void Function(
          ChatMessageComposerMessageData message, ChatMessageComposerSendAction action)?
      onSendTap;

  /// Вызывается после очистки документа для обновления подписок редактора.
  final void Function() updateDocumentSubscription;

  /// Флаг, определяющий, отображается ли панель форматирования текста.
  final bool isTextFormatEnabled;

  /// Callback, вызываемый при изменении состояния панели форматирования текста.
  /// Передает новое состояние: true - панель открыта, false - закрыта.
  final ValueChanged<bool>? onTextFormat;

  /// Реализация выбора файлов для прикрепления к сообщению.
  /// Используется для выбора фото, видео и документов.
  final MessageFilePicker filePicker;

  /// Callback, вызываемый при нажатии на упоминание пользователя.
  final MentionTapCallback? onMentionTap;

  /// Callback, вызываемый при долгом нажатии на упоминание пользователя.
  final MentionTapCallback? onMentionLongTap;

  /// Callback, вызываемый при нажатии стрелки вверх когда документ пустой.
  final VoidCallback? onArrowUpAtStart;

  /// Отключает ли упоминания пользователей через @.
  final bool disableMentions;

  /// Максимальная высота поля ввода сообщения.
  final double messageInputMaxHeight;

  /// Если false — MentionPanel не рендерится внутри редактора.
  final bool renderMentionPanel;

  final BoxConstraints? constraints;
  final EdgeInsets? padding;

  /// Автоматически запрашивать фокус при инициализации.
  final bool autofocus;

  final MentionItemBuilder? mentionItemBuilder;
  final MentionPanelLoadingBuilder? loadingBuilder;
  final MentionPanelEmptyBuilder? emptyBuilder;
  final MentionPanelErrorBuilder? errorBuilder;

  /// Описание того, как будет отрисовано упоминание в цитировании
  final MentionConfig? rqMentionConfig;

  /// Билдер для загрузки изображений с авторизацией в превью цитируемого сообщения.
  final QuotedImageBuilder? rqImageBuilder;

  /// Строит виджет редактора ввода сообщений для десктопной версии.
  ///
  /// Компоновка виджета:
  /// 1. Панель упоминаний (@) - отображается вверху
  /// 2. Панель форматирования текста - отображается над полем ввода
  ///    (если [isTextFormatEnabled] = true)
  /// 3. Поле ввода сообщения с поддержкой форматирования
  /// 4. Список прикрепленных файлов (если есть)
  /// 5. Панель управления с кнопками для добавления контента и отправки
  ///
  /// Панель форматирования поддерживает горизонтальную прокрутку
  /// колесиком мыши через обработку [PointerScrollEvent].
  ///
  /// Все элементы обернуты в декорированные контейнеры с закругленными углами
  /// и границами для визуального разделения.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ConstrainedBox(
        constraints:
            constraints ?? const BoxConstraints(minWidth: 200, maxWidth: 920),
        child: ColoredBox(
          color: context.chatColors.surfacePrimary,
          child: BlocBuilder<ComposeContextBloc, ComposeContextState>(
            buildWhen: (previous, current) =>
                previous.composeContext != current.composeContext,
            builder: (context, composeState) {
              final composeContext = composeState.composeContext;
              return Column(
                children: [
                  if (!disableMentions && renderMentionPanel)
                    MentionPanel(
                      isPlatformMobile: false,
                      mentionItemBuilder: mentionItemBuilder,
                      loadingBuilder: loadingBuilder,
                      emptyBuilder: emptyBuilder,
                      errorBuilder: errorBuilder,
                    ),
                  if (composeContext is ChatMessageComposerComposeContextRQ)
                    ReplyQuotedMessagePreview(
                      rqContext: composeContext,
                      isPlatformMobile: false,
                      mentionConfig: rqMentionConfig,
                      imageBuilder: rqImageBuilder,
                    ),
                  if (composeContext is ChatMessageComposerComposeContextEditing)
                    EditModeIndicatorDesktop(
                      editingContext: composeContext,
                      mentionConfig: rqMentionConfig,
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.chatColors.surfaceSecondary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(th.ChatEditorSpacing.px8),
                        topRight: Radius.circular(th.ChatEditorSpacing.px8),
                      ),
                      border: Border.all(color: context.chatColors.borderSubtle),
                    ),
                    child: isTextFormatEnabled
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: th.ChatEditorSpacing.px8,
                              vertical: th.ChatEditorSpacing.px4,
                            ),
                            child: SizedBox(
                              height: 40,
                              width: double.infinity,
                              child:
                                  // Панель редактора текста
                                  ScrollConfiguration(
                                behavior:
                                    ScrollConfiguration.of(context).copyWith(
                                  scrollbars: false,
                                  dragDevices: {
                                    PointerDeviceKind.mouse,
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind.stylus,
                                    PointerDeviceKind.trackpad,
                                  },
                                ),
                                child: Listener(
                                  onPointerSignal: (event) {
                                    if (event is PointerScrollEvent &&
                                        toolbarScrollController.hasClients) {
                                      final delta = event.scrollDelta.dx != 0
                                          ? event.scrollDelta.dx
                                          : event.scrollDelta.dy;
                                      if (delta != 0) {
                                        final newOffset =
                                            (toolbarScrollController.offset -
                                                    delta)
                                                .clamp(
                                          0.0,
                                          toolbarScrollController
                                              .position.maxScrollExtent,
                                        );
                                        toolbarScrollController
                                            .jumpTo(newOffset);
                                      }
                                    }
                                  },
                                  child: SingleChildScrollView(
                                    controller: toolbarScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: EditorToolbar(
                                      editorFocusNode: editorFocusNode,
                                      editorController: controller,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  EditorDropZone(
                    borderRadius: isTextFormatEnabled
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(th.ChatEditorSpacing.px8),
                            bottomRight: Radius.circular(th.ChatEditorSpacing.px8),
                          )
                        : const BorderRadius.all(
                            Radius.circular(th.ChatEditorSpacing.px8)),
                    child: DecoratedBox(
                      decoration: isTextFormatEnabled
                          ? BoxDecoration(
                              color: context.chatColors.surfaceSecondary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(th.ChatEditorSpacing.px8),
                                bottomRight: Radius.circular(th.ChatEditorSpacing.px8),
                              ),
                              border: Border(
                                left: BorderSide(color: context.chatColors.borderSubtle),
                                right:
                                    BorderSide(color: context.chatColors.borderSubtle),
                                bottom:
                                    BorderSide(color: context.chatColors.borderSubtle),
                              ),
                            )
                          : BoxDecoration(
                              color: context.chatColors.surfaceSecondary,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(th.ChatEditorSpacing.px8)),
                              border: Border.all(color: context.chatColors.borderSubtle),
                            ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: ChatEditorSpacing.px16,
                              right: ChatEditorSpacing.px16,
                              top: ChatEditorSpacing.px16,
                              bottom: ChatEditorSpacing.px8,
                            ),
                            // Инпут для ввода сообщения
                            child: MessageInput(
                              maxHeight: messageInputMaxHeight,
                              autofocus: autofocus,
                              editorFocusNode: editorFocusNode,
                              editorScrollController: editorScrollController,
                              controller: controller,
                              onPastePressed: () {
                                unawaited(ChatMessageComposerHandlers.onPaste(
                                  clipboardReader:
                                      ChatMessageComposerController.clipboardReader,
                                  messageFilesBloc:
                                      context.read<MessageFilesBloc>(),
                                  isMounted: () => context.mounted,
                                  // clipboardPaste — экспериментальный API
                                  // flutter_quill, fallback для обычного текста.
                                  // ignore: experimental_member_use
                                  onFallbackPaste: controller.clipboardPaste,
                                  controller: controller,
                                ));
                                return true;
                              },
                              onEnterPressed: () =>
                                  ChatMessageComposerHandlers.handleEnterPressed(
                                controller: controller,
                                messageFilesBloc:
                                    context.read<MessageFilesBloc>(),
                                mentionPanelBloc:
                                    context.read<MentionPanelBloc>(),
                                composeContextBloc:
                                    context.read<ComposeContextBloc>(),
                                onSendTap: onSendTap,
                                onDocumentCleared: updateDocumentSubscription,
                                editorFocusNode: editorFocusNode,
                              ),
                              onArrowUpPressed: () =>
                                  ChatMessageComposerHandlers.handleArrowUpPressed(
                                mentionPanelBloc:
                                    context.read<MentionPanelBloc>(),
                              ),
                              onArrowDownPressed: () => ChatMessageComposerHandlers
                                  .handleArrowDownPressed(
                                mentionPanelBloc:
                                    context.read<MentionPanelBloc>(),
                              ),
                              onEscapePressed: () =>
                                  ChatMessageComposerHandlers.handleEscapePressed(
                                mentionPanelBloc:
                                    context.read<MentionPanelBloc>(),
                                editorFocusNode: editorFocusNode,
                              ),
                              onArrowUpAtStart: onArrowUpAtStart,
                              onMentionTap: onMentionTap,
                              onMentionLongTap: onMentionLongTap,
                            ),
                          ),
                          const MessageFilesList(),
                          // Кнопки для вставки файла, смайликов, стилей текста
                          Padding(
                            padding: const EdgeInsets.all(th.ChatEditorSpacing.px8),
                            child: SendPanel(
                              document: controller.document,
                              quillController: controller,
                              focusNode: editorFocusNode,
                              onPhotoOrVideoTap: () =>
                                  ChatMessageComposerHandlers.onPhotoOrVideoTap(
                                bloc: context.read<MessageFilesBloc>(),
                                filePicker: filePicker,
                                isMounted: () => context.mounted,
                              ),
                              onDocumentTap: () =>
                                  ChatMessageComposerHandlers.onDocumentTap(
                                bloc: context.read<MessageFilesBloc>(),
                                filePicker: filePicker,
                                isMounted: () => context.mounted,
                              ),
                              // onContactTap: ChatMessageComposerHandlers.onContactTap,
                              // onPollTap: ChatMessageComposerHandlers.onPollTap,
                              // onEventTap: ChatMessageComposerHandlers.onEventTap,
                              onAtTap: !disableMentions
                                  ? () => ChatMessageComposerHandlers.onAtTap(
                                        controller: controller,
                                        editorFocusNode: editorFocusNode,
                                      )
                                  : null,
                              onTextFormat: onTextFormat,
                              onSendTap: () =>
                                  ChatMessageComposerHandlers.onSendTap(
                                controller: controller,
                                messageFilesBloc:
                                    context.read<MessageFilesBloc>(),
                                mentionPanelBloc:
                                    context.read<MentionPanelBloc>(),
                                composeContextBloc:
                                    context.read<ComposeContextBloc>(),
                                onSendTap: onSendTap,
                                onDocumentCleared: updateDocumentSubscription,
                                editorFocusNode: editorFocusNode,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // EditorDropZone
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
