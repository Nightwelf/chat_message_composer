import 'package:chat_message_composer/src/presentation/widgets/message_input/editor_drag_auto_scroll.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const viewportHeight = 100.0;
  const contentHeight = 400.0;

  Widget buildTestWidget(ScrollController controller) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: viewportHeight,
            width: 200,
            child: EditorDragAutoScroll(
              scrollController: controller,
              child: SingleChildScrollView(
                controller: controller,
                child: const SizedBox(height: contentHeight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'скроллит вниз, когда указатель мыши удерживается у нижнего края во время выделения',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestWidget(controller));
      await tester.pumpAndSettle();

      expect(controller.offset, 0);

      final gesture = await tester.startGesture(
        const Offset(50, 10),
        kind: PointerDeviceKind.mouse,
      );

      // Указатель у самого нижнего края видимой области редактора.
      await gesture.moveTo(const Offset(50, viewportHeight - 2));
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.offset, greaterThan(0));

      await gesture.up();
    },
  );

  testWidgets(
    'скроллит вверх, когда указатель мыши удерживается у верхнего края во время выделения',
    (tester) async {
      final controller = ScrollController(initialScrollOffset: 200);
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestWidget(controller));
      await tester.pumpAndSettle();

      expect(controller.offset, 200);

      final gesture = await tester.startGesture(
        const Offset(50, viewportHeight - 10),
        kind: PointerDeviceKind.mouse,
      );

      // Указатель у самого верхнего края видимой области редактора.
      await gesture.moveTo(const Offset(50, 2));
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.offset, lessThan(200));

      await gesture.up();
    },
  );

  testWidgets(
    'не скроллит, когда указатель находится в центре видимой области',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestWidget(controller));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(50, viewportHeight / 2),
        kind: PointerDeviceKind.mouse,
      );

      await gesture.moveTo(const Offset(60, viewportHeight / 2));
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.offset, 0);

      await gesture.up();
    },
  );

  testWidgets(
    'останавливает автоскролл при отпускании кнопки мыши',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestWidget(controller));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        const Offset(50, 10),
        kind: PointerDeviceKind.mouse,
      );

      await gesture.moveTo(const Offset(50, viewportHeight - 2));
      await tester.pump(const Duration(milliseconds: 200));

      final offsetBeforeRelease = controller.offset;
      expect(offsetBeforeRelease, greaterThan(0));

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.offset, offsetBeforeRelease);
    },
  );
}
