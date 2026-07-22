import 'package:chat_message_composer/src/domain/entities/editor_context.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/keyboard_panel/keyboard_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_command/mention_command_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/controllers/chat_message_composer_controller.dart';
import 'package:chat_message_composer/src/presentation/view/chat_message_composer_desktop.dart';
import 'package:chat_message_composer/src/presentation/view/chat_message_composer_mobile.dart';
import 'package:delta_text_view/delta_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chat_message_composer.dart';

/// Виджет для ввода и редактирования сообщений в чате с поддержкой форматирования текста.
///
/// Предоставляет полнофункциональный редактор текста на основе [QuillController],
/// который включает:
/// - Редактор текста с поддержкой форматирования (жирный, курсив, подчеркивание,
///   зачеркивание, списки, цитаты, блоки кода, ссылки)
/// - Панель инструментов форматирования, которая отображается при включении
///   режима форматирования
/// - Панель упоминаний, которая автоматически появляется при вводе символа '@'
///   и позволяет выбирать пользователей для упоминания (отключается через [disableMentions])
/// - Панель управления с кнопками для вставки файлов (фото/видео, документы),
///   смайликов, упоминаний, контактов, опросов, событий и переключения режима форматирования
/// - Кнопку отправки сообщения, которая автоматически активируется при наличии
///   текста или файлов в редакторе
/// - Область для отображения выбранных файлов
///
/// Редактор автоматически получает фокус при инициализации, что позволяет
/// сразу начинать ввод текста.
///
/// После отправки сообщения редактор и список файлов автоматически очищаются
/// и готовы к вводу следующего сообщения.
///
/// Пример использования:
/// ```dart
/// ChatMessageComposerScope(
///   localizationRepository: localizationRepository,
///   mentionRepository: mentionRepository,
///   child: ChatMessageComposer(
///     onSendTap: (message, action) {
///       final text = message.document.toPlainText();
///       final files = message.files;
///     },
///   ),
/// )
/// ```
///
/// Примечание: [ChatMessageComposer] должен быть обернут в [ChatMessageComposerScope]
/// для работы с файлами, упоминаниями и локализацией.
class ChatMessageComposer extends StatefulWidget {
  /// Создает виджет редактора сообщений чата.
  ///
  /// [onSendTap] - callback, вызываемый при нажатии на кнопку отправки.
  /// В качестве параметра передается объект [ChatMessageComposerMessageData], содержащий
  /// [Document] с содержимым редактора и список файлов из [MessageFilesBloc].
  /// После вызова callback (если он указан) редактор и список файлов
  /// автоматически очищаются. Если callback не указан, редактор и файлы
  /// все равно очищаются, но callback не вызывается.
  ///
  const ChatMessageComposer({
    super.key,
    this.onSendTap,
    this.delta,
    this.initialFiles = const [],
    this.initialComposeContext,
    this.onDispose,
    this.isPlatformMobile = false,
    this.autofocus = true,
    this.onMentionTap,
    this.onMentionLongTap,
    this.disableMentions = false,
    this.desktopMessageInputMaxHeight = 280,
    this.mobileMessageInputMaxHeight = 96,
    this.constraints,
    this.padding,
    this.desktopMentionItemBuilder,
    this.mobileMentionItemBuilder,
    this.desktopLoadingBuilder,
    this.mobileLoadingBuilder,
    this.desktopEmptyBuilder,
    this.mobileEmptyBuilder,
    this.desktopErrorBuilder,
    this.mobileErrorBuilder,
    this.onDocumentChange,
    this.rqMentionConfig,
    this.rqImageBuilder,
    this.renderMentionPanel = true,
    this.useKeyboardReplacement = false,
    this.onArrowUpAtStart,
    this.onFocusChanged,
    this.onFilesChanged,
  });

  /// Начальный документ
  final Delta? delta;

  /// Начальный список файлов пользователя (например, при восстановлении черновика).
  final List<XFile> initialFiles;

  /// Начальный compose-контекст для восстановления черновика (reply/quote).
  final ChatMessageComposerComposeContext? initialComposeContext;

  /// Вызывается при удалении редактора из дерева с текущим текстом, файлами и контекстом.
  final void Function(Delta delta, List<XFile> files, ChatMessageComposerComposeContext? composeContext)? onDispose;

  /// Callback, вызываемый при нажатии на кнопку отправки сообщения.
  ///
  /// Передает [ChatMessageComposerMessageData] и [ChatMessageComposerSendAction] (Send / Edit / Quote).
  /// После вызова редактор и список файлов очищаются; compose-контекст сбрасывается через [ComposeContextBloc].
  final void Function(ChatMessageComposerMessageData message, ChatMessageComposerSendAction action)? onSendTap;

  /// Автоматически запрашивать фокус при инициализации редактора.
  /// По умолчанию true. Для мобильных устройств рекомендуется false,
  /// чтобы клавиатура не появлялась автоматически.
  final bool autofocus;

  /// Флаг, определяющий, является ли платформа мобильной.
  ///
  /// Если true, то используется мобильная версия редактора.
  /// Если false, то используется десктопная версия редактора.
  /// По умолчанию false.
  final bool isPlatformMobile;

  /// Callback, вызываемый при нажатии на упоминание пользователя.
  ///
  /// Передает объект [MentionEmbed] с id и именем пользователя.
  final MentionTapCallback? onMentionTap;

  /// Callback, вызываемый при долгом нажатии на упоминание пользователя.
  ///
  /// Передает объект [MentionEmbed] с id и именем пользователя.
  final MentionTapCallback? onMentionLongTap;

  /// Отключает ли упоминания пользователей через @ (панель выбора при вводе '@').
  /// По умолчанию false.
  final bool disableMentions;

  /// Максимальная высота поля ввода сообщения для десктопной версии. По умолчанию 280.
  final double desktopMessageInputMaxHeight;

  /// Максимальная высота поля ввода сообщения для мобильной версии. По умолчанию 96.
  final double mobileMessageInputMaxHeight;
  final BoxConstraints? constraints;
  final EdgeInsets? padding;

  final MentionItemBuilder? desktopMentionItemBuilder;
  final MentionItemBuilder? mobileMentionItemBuilder;
  final MentionPanelLoadingBuilder? desktopLoadingBuilder;
  final MentionPanelLoadingBuilder? mobileLoadingBuilder;
  final MentionPanelEmptyBuilder? desktopEmptyBuilder;
  final MentionPanelEmptyBuilder? mobileEmptyBuilder;
  final MentionPanelErrorBuilder? desktopErrorBuilder;
  final MentionPanelErrorBuilder? mobileErrorBuilder;

  /// Описание того, как будет отрисовано упоминание в цитировании
  final MentionConfig? rqMentionConfig;

  /// Билдер для загрузки изображений с авторизацией в превью цитируемого сообщения.
  final QuotedImageBuilder? rqImageBuilder;

  final void Function(Delta current, EditorContext context)? onDocumentChange;

  /// Если false — MentionPanel не рендерится внутри редактора (для внешнего размещения).
  final bool renderMentionPanel;

  /// Если true — виджет сам управляет отступом под клавиатуру и заменяет её
  /// панелью эмодзи без дёргания макета. Требует [resizeToAvoidBottomInset: false]
  /// на родительском [Scaffold].
  final bool useKeyboardReplacement;

  /// Callback, вызываемый при нажатии стрелки вверх когда курсор находится
  /// в начале документа или документ пустой.
  final VoidCallback? onArrowUpAtStart;

  final void Function(bool hasFocus, EditorContext context)? onFocusChanged;

  final void Function(List<XFile> files, EditorContext context)? onFilesChanged;

  @override
  State<ChatMessageComposer> createState() => _ChatMessageComposerState();
}

class _ChatMessageComposerState extends State<ChatMessageComposer> {
  late final ChatMessageComposerController _editorController;
  late final MessageFilesBloc _messageFilesBloc;
  late final ComposeContextBloc _composeContextBloc;

  @override
  void initState() {
    super.initState();

    _messageFilesBloc = context.read<MessageFilesBloc>();
    _composeContextBloc = context.read<ComposeContextBloc>();

    _editorController = ChatMessageComposerController(
      disableMentions: widget.disableMentions,
      onDocumentChange: (delta) {
        final files = switch (_messageFilesBloc.state) {
          MessageFilesState$Data(:final files) => files.map((f) => f.data).toList(),
        };
        widget.onDocumentChange?.call(
          delta,
          EditorContext(
            delta: delta,
            files: files,
            composeContext: _composeContextBloc.state.composeContext,
          ),
        );
      },
      initialDelta: widget.delta,
    );

    _editorController.editorFocusNode.addListener(_focusNodeListener);

    final ctx = widget.initialComposeContext ?? _composeContextBloc.state.composeContext;

    final document = switch (ctx) {
      ChatMessageComposerComposeContextEditing() => _editorController.documentForComposeContext(ctx),
      ChatMessageComposerComposeContextIdle() => _editorController.documentForComposeContext(ctx),
      _ when widget.delta != null => Document.fromDelta(widget.delta!),
      _ => _editorController.documentForComposeContext(ctx),
    };
    if (document != null) {
      _editorController.quillController.document = document;
    }

    final files = _editorController.initialFilesForComposeContext(ctx);
    if (files.isNotEmpty) {
      _messageFilesBloc.add(MessageFiles$Add(files));
    }
    if (widget.initialFiles.isNotEmpty) {
      _messageFilesBloc.add(MessageFiles$Add(widget.initialFiles));
    }

    // Начальный контекст уже применён синхронно выше (документ + файлы). Помечаем
    // его применённым, чтобы listener-эхо ComposeContext$Set ниже не пересоздало
    // документ и не очистило/перечитало файлы (фликер, потеря initialFiles).
    _editorController.lastAppliedComposeContext = ctx;
    if (widget.initialComposeContext != null) {
      _composeContextBloc.add(ComposeContext$Set(widget.initialComposeContext!));
    }
    if (widget.delta != null) {
      final len = _editorController.quillController.document.length;
      _editorController.quillController.updateSelection(
        TextSelection.collapsed(offset: len),
        ChangeSource.local,
      );
    }
    if (widget.autofocus && _editorController.editorFocusNode.canRequestFocus) {
      _editorController.editorFocusNode.requestFocus();
    }
    _editorController.updateDocumentSubscription(context);
  }

  void _focusNodeListener() {
    _editorController.focusNodeListener(context);
    final hasFocus = _editorController.editorFocusNode.hasFocus;
    final delta = _editorController.quillController.document.toDelta();
    final files = switch (_messageFilesBloc.state) {
      MessageFilesState$Data(:final files) => files.map((f) => f.data).toList(),
    };
    widget.onFocusChanged?.call(
      hasFocus,
      EditorContext(
        delta: delta,
        files: files,
        composeContext: _composeContextBloc.state.composeContext,
      ),
    );
    if (widget.useKeyboardReplacement && hasFocus && context.mounted) {
      context.read<KeyboardPanelBloc>().add(const KeyboardPanel$FocusGained());
    }
  }

  void _handleSendTap(ChatMessageComposerMessageData message, ChatMessageComposerSendAction action) {
    _editorController.clearInitialDelta();
    widget.onSendTap?.call(message.removeMentionInputEmbeds(), action);
  }

  @override
  void dispose() {
    if (widget.onDispose != null) {
      final delta = _editorController.quillController.document.toDelta();
      final files = switch (_messageFilesBloc.state) {
        MessageFilesState$Data(:final files) => files.map((f) => f.data).toList(),
      };
      widget.onDispose?.call(delta, files, _composeContextBloc.state.composeContext);
    }
    _editorController.editorFocusNode.removeListener(_focusNodeListener);
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MentionCommandBloc, MentionCommandState>(
          listener: (context, state) => _editorController.handleMentionCommand(state, context),
        ),
        BlocListener<ComposeContextBloc, ComposeContextState>(
          listener: (context, state) =>
              _editorController.applyComposeContext(context, state.composeContext, state.previousComposeContext),
        ),
        BlocListener<MessageFilesBloc, MessageFilesState>(
          listener: (context, state) {
            if (state is! MessageFilesState$Data) return;
            if (widget.onFilesChanged == null) return;
            final files = state.files.map((f) => f.data).toList();
            final delta = _editorController.quillController.document.toDelta();
            widget.onFilesChanged?.call(
              files,
              EditorContext(
                delta: delta,
                files: files,
                composeContext: _composeContextBloc.state.composeContext,
              ),
            );
          },
        ),
      ],
      child: ListenableBuilder(
        listenable: _editorController,
        builder: (context, _) => widget.isPlatformMobile
            ? ChatMessageComposerMobile(
                autofocus: widget.autofocus,
                controller: _editorController.quillController,
                editorFocusNode: _editorController.editorFocusNode,
                editorScrollController: _editorController.editorScrollController,
                toolbarScrollController: _editorController.toolbarScrollController,
                onSendTap: _handleSendTap,
                updateDocumentSubscription: () => _editorController.updateDocumentSubscription(context),
                onTextFormat: (opened) => _editorController.onTextFormat(pressed: opened),
                filePicker: ChatMessageComposerController.filePicker,
                onMentionTap: widget.onMentionTap,
                onMentionLongTap: widget.onMentionLongTap,
                onArrowUpAtStart: widget.onArrowUpAtStart,
                disableMentions: widget.disableMentions,
                messageInputMaxHeight: widget.mobileMessageInputMaxHeight,
                mentionItemBuilder: widget.mobileMentionItemBuilder,
                loadingBuilder: widget.mobileLoadingBuilder,
                emptyBuilder: widget.mobileEmptyBuilder,
                errorBuilder: widget.mobileErrorBuilder,
                rqMentionConfig: widget.rqMentionConfig,
                rqImageBuilder: widget.rqImageBuilder,
                renderMentionPanel: widget.renderMentionPanel,
                useKeyboardReplacement: widget.useKeyboardReplacement,
              )
            : ChatMessageComposerDesktop(
                autofocus: widget.autofocus,
                controller: _editorController.quillController,
                editorFocusNode: _editorController.editorFocusNode,
                editorScrollController: _editorController.editorScrollController,
                toolbarScrollController: _editorController.toolbarScrollController,
                onSendTap: _handleSendTap,
                updateDocumentSubscription: () => _editorController.updateDocumentSubscription(context),
                isTextFormatEnabled: _editorController.isTextFormatEnabled,
                onTextFormat: (opened) => _editorController.onTextFormat(pressed: opened),
                onMentionTap: widget.onMentionTap,
                onMentionLongTap: widget.onMentionLongTap,
                onArrowUpAtStart: widget.onArrowUpAtStart,
                filePicker: ChatMessageComposerController.filePicker,
                disableMentions: widget.disableMentions,
                messageInputMaxHeight: widget.desktopMessageInputMaxHeight,
                constraints: widget.constraints,
                padding: widget.padding,
                mentionItemBuilder: widget.desktopMentionItemBuilder,
                loadingBuilder: widget.desktopLoadingBuilder,
                emptyBuilder: widget.desktopEmptyBuilder,
                errorBuilder: widget.desktopErrorBuilder,
                rqMentionConfig: widget.rqMentionConfig,
                rqImageBuilder: widget.rqImageBuilder,
                renderMentionPanel: widget.renderMentionPanel,
              ),
      ),
    );
  }
}
