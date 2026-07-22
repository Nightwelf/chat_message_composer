import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Автоскролл поля ввода при выделении текста мышью за пределы видимой
/// области.
///
/// `flutter_quill` не докручивает содержимое, когда выделение мышью
/// продолжается ниже/выше видимой области редактора с ограниченной
/// maxHeight — курсор "прыгает" между последней и предпоследней видимыми
/// строками вместо прокрутки. Виджет отслеживает позицию указателя во время
/// зажатой левой кнопки мыши и вручную докручивает [scrollController], когда
/// курсор находится у верхнего/нижнего края [child].
class EditorDragAutoScroll extends StatefulWidget {
  const EditorDragAutoScroll({
    required this.scrollController,
    required this.child,
    super.key,
  });

  final ScrollController scrollController;
  final Widget child;

  @override
  State<EditorDragAutoScroll> createState() => _EditorDragAutoScrollState();
}

class _EditorDragAutoScrollState extends State<EditorDragAutoScroll>
    with SingleTickerProviderStateMixin {
  static const _edgeThreshold = 32.0;
  static const _maxSpeedPerTick = 12.0;

  final GlobalKey _childKey = GlobalKey();

  Ticker? _ticker;
  double _scrollSpeed = 0;
  bool _isDragging = false;

  void _onPointerDown(PointerDownEvent event) {
    _isDragging = event.kind == PointerDeviceKind.mouse &&
        event.buttons == kPrimaryButton;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isDragging) return;
    _updateScrollSpeed(event.position);
  }

  void _onPointerStop(PointerEvent event) {
    _isDragging = false;
    _stopAutoScroll();
  }

  void _updateScrollSpeed(Offset globalPosition) {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      _stopAutoScroll();
      return;
    }

    final localY = renderBox.globalToLocal(globalPosition).dy;
    final height = renderBox.size.height;

    if (localY < _edgeThreshold) {
      final overshoot = (_edgeThreshold - localY).clamp(0.0, _edgeThreshold);
      _startAutoScroll(-_maxSpeedPerTick * overshoot / _edgeThreshold);
    } else if (localY > height - _edgeThreshold) {
      final overshoot =
          (localY - (height - _edgeThreshold)).clamp(0.0, _edgeThreshold);
      _startAutoScroll(_maxSpeedPerTick * overshoot / _edgeThreshold);
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(double speed) {
    _scrollSpeed = speed;
    if (_ticker?.isActive ?? false) return;
    (_ticker ??= createTicker(_onTick)).start();
  }

  void _stopAutoScroll() {
    _scrollSpeed = 0;
    _ticker?.stop();
  }

  void _onTick(Duration elapsed) {
    if (_scrollSpeed == 0 || !widget.scrollController.hasClients) return;
    final position = widget.scrollController.position;
    final target = (position.pixels + _scrollSpeed)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target != position.pixels) {
      widget.scrollController.jumpTo(target);
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerStop,
      onPointerCancel: _onPointerStop,
      child: KeyedSubtree(
        key: _childKey,
        child: widget.child,
      ),
    );
  }
}
