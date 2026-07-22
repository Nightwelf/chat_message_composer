import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/simple_text_input/simple_text_input_controller.dart';
import 'package:chat_message_composer/src/simple_text_input/simple_text_input_desktop.dart';
import 'package:chat_message_composer/src/simple_text_input/simple_text_input_mobile.dart';
import 'package:chat_message_composer/src/simple_text_input/simple_text_input_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Упрощённый однострочный виджет ввода: только текст, смайлы и отправка.
///
/// Не поддерживает файлы, упоминания, форматирование и режимы edit/quote.
///
/// Для корректной работы на мобильных платформах родительский [Scaffold] должен
/// иметь [resizeToAvoidBottomInset: false].
///
/// Должен быть обёрнут в [SimpleTextInputScope] (или задавать [localizationRepository]
/// напрямую через параметр, тогда scope создаётся внутри автоматически).
///
/// Пример:
/// ```dart
/// SimpleTextInputScope(
///   localizationRepository: MyLocalizationRepo(),
///   child: SimpleTextInput(
///     controller: _controller,
///     isPlatformMobile: Platform.isAndroid || Platform.isIOS,
///     onSendTap: (document) { /* ... */ },
///   ),
/// )
/// ```
class SimpleTextInput extends StatefulWidget {
  const SimpleTextInput({
    required this.isPlatformMobile,
    required this.onSendTap,
    this.controller,
    this.localizationRepository,
    this.autofocus = false,
    this.forceSendEnabled = false,
    super.key,
  });

  /// Если true — используется мобильный layout (emoji-панель под клавиатурой).
  /// Если false — используется desktop layout (emoji-popup).
  final bool isPlatformMobile;

  /// Вызывается при отправке. Получает [Document] с текстом и вставленными эмодзи.
  final void Function(Document document) onSendTap;

  /// Внешний контроллер. Если не задан — создаётся и управляется внутри виджета.
  final SimpleTextInputController? controller;

  /// Репозиторий локализации. Если задан — создаёт внутренний [SimpleTextInputScope].
  /// Если не задан — ожидает [SimpleTextInputScope] выше по дереву.
  final ChatMessageComposerLocalizationRepository? localizationRepository;

  /// Автофокус при инициализации.
  final bool autofocus;

  /// Если true — кнопка отправки всегда активна, независимо от содержимого поля.
  final bool forceSendEnabled;

  @override
  State<SimpleTextInput> createState() => _SimpleTextInputState();
}

class _SimpleTextInputState extends State<SimpleTextInput> {
  SimpleTextInputController? _ownedController;

  SimpleTextInputController get _controller =>
      widget.controller ?? (_ownedController ??= SimpleTextInputController());

  void _onSend() {
    final doc = _controller.quillController.document;
    if (!widget.forceSendEnabled && doc.isEmpty()) return;
    widget.onSendTap(doc);
    _controller.quillController.document = Document();
    if (_controller.editorFocusNode.canRequestFocus) {
      _controller.editorFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isPlatformMobile) {
      return SimpleTextInputMobile(
        quillController: _controller.quillController,
        editorFocusNode: _controller.editorFocusNode,
        editorScrollController: _controller.editorScrollController,
        onSendTap: _onSend,
        autofocus: widget.autofocus,
        forceSendEnabled: widget.forceSendEnabled,
      );
    }
    return SimpleTextInputDesktop(
      quillController: _controller.quillController,
      editorFocusNode: _controller.editorFocusNode,
      editorScrollController: _controller.editorScrollController,
      onSendTap: _onSend,
      autofocus: widget.autofocus,
      forceSendEnabled: widget.forceSendEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locRepo = widget.localizationRepository;
    if (locRepo != null) {
      return SimpleTextInputScope(
        localizationRepository: locRepo,
        child: _buildContent(context),
      );
    }
    return _buildContent(context);
  }
}
