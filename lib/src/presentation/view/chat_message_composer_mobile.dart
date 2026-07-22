import 'dart:async';
import 'dart:math' as math;

import 'package:chat_message_composer/src/chat_message_composer/chat_message_composer_handlers.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_message_data.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_send_action.dart';
import 'package:chat_message_composer/src/domain/datasources/message_file_picker.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/keyboard_panel/keyboard_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/controllers/chat_message_composer_controller.dart';
import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/send_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/edit_mode_indicator/edit_mode_indicator_mobile.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/message_files_list.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/keyboard_replacement_panel/keyboard_replacement_panel.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_embed_builder.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_panel.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/reply_quoted_message_preview/reply_quoted_message_preview.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/plus_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/message_input/message_input.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Редактор ввода сообщений для мобильной версии приложения.
///
/// Виджет предоставляет полнофункциональный интерфейс для создания и отправки
/// сообщений в чате, оптимизированный для мобильных устройств. Включает следующие
/// компоненты:
/// - Список прикрепленных файлов (отображается вверху)
/// - Поле ввода сообщения с поддержкой форматирования
/// - Панель упоминаний пользователей (@)
/// - Панель форматирования текста с кнопкой закрытия (опционально)
/// - Панель управления с кнопками для добавления контента и отправки
///
/// Особенности мобильной версии:
/// - Вертикальная компоновка элементов для удобства на мобильных устройствах
/// - Панель форматирования текста отображается отдельно с кнопкой закрытия
/// - Список файлов отображается вверху с иконкой удаления слева
/// - Панель управления отображается только когда панель форматирования закрыта
/// - Поддержка горизонтальной прокрутки панели инструментов жестами
/// - Оптимизированная цветовая схема кнопок для мобильных устройств
///
/// Виджет требует наличия BLoC провайдеров:
/// - [MentionPanelBloc] для управления панелью упоминаний
/// - [MessageFilesBloc] для управления прикрепленными файлами
///
/// Пример использования:
/// ```dart
/// ChatMessageComposerMobile(
///   controller: quillController,
///   editorFocusNode: focusNode,
///   editorScrollController: scrollController,
///   toolbarScrollController: toolbarScrollController,
///   onSendTap: (message) => _handleSend(message),
///   updateDocumentSubscription: () => _updateSubscription(),
///   onTextFormat: (enabled) => _handleTextFormat(enabled),
///   filePicker: filePicker,
/// )
/// ```
class ChatMessageComposerMobile extends StatelessWidget {
  /// Создает редактор ввода сообщений для мобильной версии.
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
  /// [onTextFormat] - callback, вызываемый при изменении состояния
  /// панели форматирования текста. Передает новое состояние (true/false).
  ///
  /// [filePicker] - реализация выбора файлов для прикрепления к сообщению.
  /// Используется для выбора фото, видео и документов.
  /// Обязательный параметр.
  ///
  /// [disableMentions] - отключает ли упоминания пользователей через @. По умолчанию false.
  ///
  /// [messageInputMaxHeight] - максимальная высота поля ввода сообщения. По умолчанию 96.
  const ChatMessageComposerMobile({
    required this.controller,
    required this.editorFocusNode,
    required this.editorScrollController,
    required this.toolbarScrollController,
    required this.updateDocumentSubscription,
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
    this.messageInputMaxHeight = 96,
    this.renderMentionPanel = true,
    this.useKeyboardReplacement = false,
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

  /// Если true — виджет управляет заменой клавиатуры панелью эмодзи.
  final bool useKeyboardReplacement;

  /// Автоматически запрашивать фокус при инициализации.
  final bool autofocus;

  final MentionItemBuilder? mentionItemBuilder;
  final MentionPanelLoadingBuilder? loadingBuilder;
  final MentionPanelEmptyBuilder? emptyBuilder;
  final MentionPanelErrorBuilder? errorBuilder;

  /// Описание того, как будет отрисовано упоминание в ответе/цитировании
  final MentionConfig? rqMentionConfig;

  /// Билдер для загрузки изображений с авторизацией в превью цитируемого сообщения.
  final QuotedImageBuilder? rqImageBuilder;

  ButtonColorScheme buttonColorScheme(ChatEditorColorScheme colors) => ButtonColorScheme(
        enabled: Colors.transparent,
        hovered: colors.neutralSoftHover,
        pressed: colors.neutralSoftPressed,
        disabled: Colors.transparent,
        iconDisabled: colors.textDisabled.withAlpha(200),
        iconEnabled: colors.textStrong,
        iconHovered: colors.textStrong,
        iconPressed: colors.textStrong,
      );

  /// Закрывает клавиатуру по явному действию пользователя (открытие меню
  /// "плюс"/переключение на панель эмодзи и т.п.) — в обход
  /// [SuppressableFocusNode.unfocus], который для таких узлов не работает
  /// (см. документацию класса).
  void _closeKeyboard(FocusNode node) {
    if (node is SuppressableFocusNode) {
      node.closeKeyboard();
    } else {
      node.unfocus();
    }
  }

  /// Строит виджет редактора ввода сообщений для мобильной версии.
  ///
  /// Компоновка виджета (сверху вниз):
  /// 1. Панель упоминаний (@) - если [disableMentions] = false
  /// 2. Превью ответа/цитирования или индикатор режима редактирования -
  ///    в зависимости от текущего compose-контекста
  /// 3. Список прикрепленных файлов - если есть файлы
  /// 4. Строка ввода: кнопка "+", поле ввода сообщения, кнопка эмодзи
  ///    (переключает клавиатуру и панель эмодзи через [KeyboardPanelBloc]),
  ///    кнопка отправки
  ///
  /// Элементы разделены границами для визуального разделения.
  /// Кнопки используют специальную цветовую схему, оптимизированную для мобильных устройств.
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
              final fn = editorFocusNode;
              if (fn is SuppressableFocusNode) fn.suppressRequests = false;
              context
                  .read<KeyboardPanelBloc>()
                  .add(const KeyboardPanel$Close(expectKeyboard: false));
            }
          },
          child: _buildContent(context),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.chatColors;
    return BlocListener<KeyboardPanelBloc, KeyboardPanelState>(
      listenWhen: (prev, curr) =>
          prev is KeyboardPanelState$Emoji && curr is! KeyboardPanelState$Emoji,
      listener: (context, state) {
        // Clear focus suppression whenever emoji panel closes for any reason.
        if (editorFocusNode is SuppressableFocusNode) {
          (editorFocusNode as SuppressableFocusNode).suppressRequests = false;
        }
      },
      child: BlocBuilder<ComposeContextBloc, ComposeContextState>(
        buildWhen: (previous, current) =>
            previous.composeContext != current.composeContext,
        builder: (context, composeState) {
          final composeContext = composeState.composeContext;
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.chatColors.borderSubtle),
              ),
            ),
            child: Column(
              children: [
                if (!disableMentions && renderMentionPanel)
                  TapRegion(
                    groupId: EditableText,
                    child: MentionPanel(
                      isPlatformMobile: true,
                      mentionItemBuilder: mentionItemBuilder,
                      loadingBuilder: loadingBuilder,
                      emptyBuilder: emptyBuilder,
                      errorBuilder: errorBuilder,
                    ),
                  ),
                if (composeContext is ChatMessageComposerComposeContextRQ)
                  TapRegion(
                    groupId: EditableText,
                    child: ReplyQuotedMessagePreview(
                      rqContext: composeContext,
                      isPlatformMobile: true,
                      mentionConfig: rqMentionConfig,
                      imageBuilder: rqImageBuilder,
                    ),
                  ),
                if (composeContext is ChatMessageComposerComposeContextEditing)
                  TapRegion(
                    groupId: EditableText,
                    child: EditModeIndicatorMobile(
                      editingContext: composeContext,
                      mentionConfig: rqMentionConfig,
                    ),
                  ),
                BlocBuilder<MessageFilesBloc, MessageFilesState>(
                  builder: (context, state) => switch (state) {
                    MessageFilesState$Data(:final files) => files.isEmpty
                        ? const SizedBox.shrink()
                        : Divider(color: context.chatColors.borderSubtle, height: 1),
                  },
                ),
                const TapRegion(
                  groupId: EditableText,
                  child: MessageFilesList(
                    trashPosition: TrashPosition.left,
                    scrollDirection: Axis.horizontal,
                    fillThumbnail: true,
                  ),
                ),
                TapRegion(
                  groupId: EditableText,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ChatEditorSpacing.px12, vertical: ChatEditorSpacing.px8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (composeContext
                            is! ChatMessageComposerComposeContextEditing)
                          Padding(
                            padding: const EdgeInsetsGeometry.only(right: 0.5),
                            child: PlusButton(
                              onPhotoOrVideoTap: () async {
                                _closeKeyboard(editorFocusNode);
                                await ChatMessageComposerHandlers.onPhotoOrVideoTap(
                                  bloc: context.read<MessageFilesBloc>(),
                                  filePicker: filePicker,
                                  isMounted: () => context.mounted,
                                );
                              },
                              onDocumentTap: () async {
                                _closeKeyboard(editorFocusNode);
                                await ChatMessageComposerHandlers.onDocumentTap(
                                  bloc: context.read<MessageFilesBloc>(),
                                  filePicker: filePicker,
                                  isMounted: () => context.mounted,
                                );
                              },
                              focusNode: editorFocusNode,
                              onCameraTap: () {
                                _closeKeyboard(editorFocusNode);
                                ChatMessageComposerHandlers.onCameraTap(
                                  context: context,
                                  bloc: context.read<MessageFilesBloc>(),
                                  filePicker: filePicker,
                                  isMounted: () => context.mounted,
                                );
                              },
                              isUseBottomSheet: true,
                              buttonColorScheme:
                                  buttonColorScheme.call(context.chatColors),
                            ),
                          ),
                        Flexible(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceTertiary,
                              borderRadius: ChatEditorRadii.br10,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Flexible(
                                    child: Align(
                                      child: Listener(
                                        onPointerDown: (_) {
                                          final bloc =
                                              context.read<KeyboardPanelBloc>();
                                          if (bloc.state
                                              is KeyboardPanelState$Emoji) {
                                            final fn = editorFocusNode;
                                            if (fn is SuppressableFocusNode) {
                                              fn.suppressRequests = false;
                                            }
                                            bloc.add(
                                                const KeyboardPanel$Close());
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: ChatEditorSpacing.px8,
                                            right: ChatEditorSpacing.px6,
                                            top: ChatEditorSpacing.px8,
                                            bottom: ChatEditorSpacing.px8,
                                          ),
                                          child: MessageInput(
                                            maxHeight: messageInputMaxHeight,
                                            autofocus: autofocus,
                                            editorFocusNode: editorFocusNode,
                                            editorScrollController:
                                                editorScrollController,
                                            controller: controller,
                                            onPastePressed: () {
                                              unawaited(ChatMessageComposerHandlers
                                                  .onPaste(
                                                clipboardReader:
                                                    ChatMessageComposerController
                                                        .clipboardReader,
                                                messageFilesBloc: context
                                                    .read<MessageFilesBloc>(),
                                                isMounted: () =>
                                                    context.mounted,
                                                onFallbackPaste:
                                                    // clipboardPaste —
                                                    // экспериментальный API
                                                    // flutter_quill.
                                                    // ignore: experimental_member_use
                                                    controller.clipboardPaste,
                                                controller: controller,
                                              ));
                                              return true;
                                            },
                                            onEnterPressed: () {
                                              ChatMessageComposerHandlers
                                                  .handleEnterPressed(
                                                controller: controller,
                                                messageFilesBloc: context
                                                    .read<MessageFilesBloc>(),
                                                mentionPanelBloc: context
                                                    .read<MentionPanelBloc>(),
                                                composeContextBloc: context
                                                    .read<ComposeContextBloc>(),
                                                onSendTap: onSendTap,
                                                onDocumentCleared:
                                                    updateDocumentSubscription,
                                                editorFocusNode:
                                                    editorFocusNode,
                                              );
                                            },
                                            onArrowUpPressed: () =>
                                                ChatMessageComposerHandlers
                                                    .handleArrowUpPressed(
                                              mentionPanelBloc: context
                                                  .read<MentionPanelBloc>(),
                                            ),
                                            onArrowDownPressed: () =>
                                                ChatMessageComposerHandlers
                                                    .handleArrowDownPressed(
                                              mentionPanelBloc: context
                                                  .read<MentionPanelBloc>(),
                                            ),
                                            onEscapePressed: () =>
                                                ChatMessageComposerHandlers
                                                    .handleEscapePressed(
                                              mentionPanelBloc: context
                                                  .read<MentionPanelBloc>(),
                                              editorFocusNode: editorFocusNode,
                                            ),
                                            onArrowUpAtStart: onArrowUpAtStart,
                                            onMentionTap: onMentionTap,
                                            onMentionLongTap: onMentionLongTap,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Эмодзи
                                  BlocBuilder<KeyboardPanelBloc,
                                          KeyboardPanelState>(
                                      buildWhen: (prev, curr) =>
                                          (prev is KeyboardPanelState$Emoji) !=
                                          (curr is KeyboardPanelState$Emoji),
                                      builder: (context, state) {
                                        return Align(
                                          alignment: Alignment.bottomCenter,
                                          child: GestureDetector(
                                            onTap: () {
                                              final bloc = context
                                                  .read<KeyboardPanelBloc>();
                                              final fn = editorFocusNode;
                                              if (bloc.state
                                                  is KeyboardPanelState$Emoji) {
                                                // Панель открыта — разрешаем requestFocus, закрываем, показываем клавиатуру.
                                                if (fn
                                                    is SuppressableFocusNode) {
                                                  fn.suppressRequests = false;
                                                }
                                                bloc.add(
                                                    const KeyboardPanel$Close());
                                                fn.requestFocus();
                                              } else {
                                                // Захватываем высоту ДО unfocus/анимации закрытия клавиатуры.
                                                final currentHeight =
                                                    MediaQuery.viewInsetsOf(
                                                            context)
                                                        .bottom;
                                                // Подавляем requestFocus пока панель открыта,
                                                // чтобы flutter_quill не мог вернуть фокус через dirty-state.
                                                if (fn
                                                    is SuppressableFocusNode) {
                                                  fn.suppressRequests = true;
                                                }
                                                bloc.add(
                                                    KeyboardPanel$ShowEmoji(
                                                        currentHeight));
                                                _closeKeyboard(fn);
                                              }
                                            },
                                            behavior:
                                                HitTestBehavior.translucent,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  ChatEditorSpacing.px8),
                                              child: Icon(
                                                state is KeyboardPanelState$Emoji
                                                    ? ChatEditorIcons.keyboard
                                                    : ChatEditorIcons.face,
                                                size: 24,
                                                color: colors.textMuted,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ChatEditorSpacing.px8),
                        BlocBuilder<MessageFilesBloc, MessageFilesState>(
                          builder: (context, state) {
                            return ListenableBuilder(
                              listenable: controller,
                              builder: (context, _) {
                                return SendButton(
                                  onTap: () =>
                                      ChatMessageComposerHandlers.onSendTap(
                                    controller: controller,
                                    messageFilesBloc:
                                        context.read<MessageFilesBloc>(),
                                    mentionPanelBloc:
                                        context.read<MentionPanelBloc>(),
                                    composeContextBloc:
                                        context.read<ComposeContextBloc>(),
                                    onSendTap: onSendTap,
                                    onDocumentCleared:
                                        updateDocumentSubscription,
                                    editorFocusNode: editorFocusNode,
                                  ),
                                  enabled: IsSendEnabled.isEnabled(
                                      controller.document, state),
                                  isEditMode: composeState.composeContext
                                      is ChatMessageComposerComposeContextEditing,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (useKeyboardReplacement)
                  KeyboardReplacementPanel(
                    quillController: controller,
                  ),
                const Area(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Area extends StatefulWidget {
  const Area({
    super.key,
  });

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  // См. аналогичный таймаут в KeyboardReplacementPanel: если после закрытия
  // панели эмодзи ожидаемая клавиатура так и не появилась (или появилась на
  // другую высоту), inset никогда не достигнет _transitionHeight и SafeArea
  // "зависнет" в неверном состоянии.
  static const _transitionTimeout = Duration(milliseconds: 500);

  double? _transitionHeight;
  Timer? _transitionTimer;

  void _armTransitionTimeout() {
    _transitionTimer?.cancel();
    _transitionTimer = Timer(_transitionTimeout, () {
      if (!mounted || _transitionHeight == null) return;
      setState(() => _transitionHeight = null);
    });
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return BlocConsumer<KeyboardPanelBloc, KeyboardPanelState>(
      listenWhen: (prev, curr) =>
          prev is KeyboardPanelState$Emoji && curr is! KeyboardPanelState$Emoji,
      listener: (context, state) {
        final expectKeyboard =
            state is KeyboardPanelState$Empty && state.expectKeyboard;
        _transitionHeight = expectKeyboard ? state.lastKnownHeight : null;
        if (expectKeyboard) {
          _armTransitionTimeout();
        } else {
          _transitionTimer?.cancel();
        }
      },
      builder: (context, state) {
        if (_transitionHeight != null && keyboardHeight >= _transitionHeight!) {
          _transitionHeight = null;
          _transitionTimer?.cancel();
        }
        final lastHeight = state.lastKnownHeight;
        final effectiveHeight = switch (state) {
          KeyboardPanelState$Emoji() => math.max(keyboardHeight, lastHeight),
          KeyboardPanelState$Empty() => _transitionHeight != null
              ? math.max(keyboardHeight, _transitionHeight!)
              : (keyboardHeight > 0
                  ? math.max(keyboardHeight, lastHeight)
                  : 0.0),
        };

        if (effectiveHeight > 0) return const SizedBox();

        return const SafeArea(child: SizedBox.shrink());
      },
    );
  }
}
