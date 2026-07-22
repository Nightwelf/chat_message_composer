import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:flutter/material.dart';

/// Микро-пример для проверки [EditorDragAutoScroll]: базовый редактор,
/// ограниченный по высоте, с достаточным количеством строк, чтобы появился
/// внутренний скролл. Выделите текст мышью и потяните за верхний/нижний край
/// поля — содержимое должно докручиваться без "зависания" выделения.
class DragAutoScrollDemo extends StatefulWidget {
  const DragAutoScrollDemo({super.key});

  @override
  State<DragAutoScrollDemo> createState() => _DragAutoScrollDemoState();
}

class _DragAutoScrollDemoState extends State<DragAutoScrollDemo> {
  late final QuillController _controller;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    for (var i = 1; i <= 30; i++) {
      _controller.document.insert(
        _controller.document.length - 1,
        'Строка $i для проверки автоскролла при выделении\n',
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EditorDragAutoScroll demo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: EditorDragAutoScroll(
                  scrollController: _scrollController,
                  child: QuillEditor(
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    controller: _controller,
                    config: const QuillEditorConfig(maxHeight: 200),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}