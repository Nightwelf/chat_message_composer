import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/custom_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Виджет для отображения контекстного меню в overlay при нажатии на контроллер.
///
/// Отслеживает состояние [controller] и показывает overlay меню, когда
/// контроллер содержит [WidgetState.pressed]. Меню автоматически закрывается
/// при изменении размера экрана, при клике вне меню или при выборе элемента.
///
/// [menuContent] и [customContent] взаимоисключающие: при обоих заданных
/// приоритет у [menuContent]. Меню позиционируется относительно [child] с
/// учётом [offset] и [alignment].
class OverlayMenuWidget extends StatefulWidget {
  const OverlayMenuWidget({
    required this.child,
    required this.controller,
    this.menuContent,
    this.customContent,
    this.focusNode,
    this.onStateChanged,
    this.closeNotifier,
    this.offset = const Offset(0, 6),
    this.alignment = Alignment.bottomLeft,
    super.key,
  });

  final Widget child;
  final WidgetStatesController controller;
  final List<CustomContextMenuEntry>? menuContent;
  final Widget? customContent;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onStateChanged;
  final Offset offset;
  final Alignment alignment;

  /// Когда значение становится true, меню закрывается извне — например,
  /// после выбора элемента в кастомном контенте.
  final ValueNotifier<bool>? closeNotifier;

  @override
  State<OverlayMenuWidget> createState() => _OverlayMenuState();
}

class _OverlayMenuState extends State<OverlayMenuWidget>
    with WidgetsBindingObserver {
  bool _isOpen = false;
  bool _isOpening = false;
  OverlayEntry? _overlayEntry;
  Size? _previousSize;
  bool _ignoreNextMetricsChange = false;
  Set<WidgetState> _previousControllerState = {};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
    widget.closeNotifier?.addListener(_onCloseNotifier);
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _previousSize = MediaQuery.of(context).size;
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    widget.closeNotifier?.removeListener(_onCloseNotifier);
    WidgetsBinding.instance.removeObserver(this);
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _onCloseNotifier() {
    if (widget.closeNotifier?.value ?? false) {
      _closeMenu();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    // Первое изменение метрик после открытия меню игнорируется — оно может
    // быть вызвано самим открытием меню.
    if (_ignoreNextMetricsChange) {
      _ignoreNextMetricsChange = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _previousSize = MediaQuery.of(context).size;
        }
      });
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentSize = MediaQuery.of(context).size;
      if (_isOpen &&
          _previousSize != null &&
          (currentSize.width != _previousSize!.width ||
              currentSize.height != _previousSize!.height)) {
        _closeMenu();
      }
      _previousSize = currentSize;
    });
  }

  void _listener() {
    final currentState = widget.controller.value;
    final wasPressed = _previousControllerState.contains(WidgetState.pressed);
    final isPressed = currentState.contains(WidgetState.pressed);

    if (isPressed && !wasPressed) {
      if (!_isOpen && !_isOpening) {
        _toggleMenu();
      }
    }

    _previousControllerState = Set.from(currentState);
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else if (!_isOpening) {
      _showMenu();
    }
  }

  void _showMenu() {
    if (widget.menuContent == null && widget.customContent == null) {
      return;
    }

    if (_isOpening || _isOpen) {
      return;
    }

    _isOpening = true;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      _isOpening = false;
      return;
    }

    final globalPosition = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenHeight = screenSize.height;

    _previousSize = screenSize;
    _ignoreNextMetricsChange = true;

    setState(() {
      _isOpen = true;
      _isOpening = false;
    });
    widget.onStateChanged?.call(true);

    final anchorRight = widget.alignment.x > 0;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: anchorRight ? null : globalPosition.dx + widget.offset.dx,
              right: anchorRight
                  ? screenSize.width -
                      (globalPosition.dx + renderBox.size.width) -
                      widget.offset.dx
                  : null,
              bottom: screenHeight - globalPosition.dy + widget.offset.dy,
              child: _buildContent(overlayContext),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildContent(BuildContext overlayContext) {
    if (widget.menuContent != null) {
      final wrappedItems = widget.menuContent!.map((item) {
        if (item is CustomContextMenuItemEntry) {
          return CustomContextMenuItemEntry(
            icon: item.icon,
            title: item.title,
            onTap: () {
              _closeMenu();
              item.onTap();
            },
            enabled: item.enabled,
          );
        }
        return item;
      }).toList();
      return CustomContextMenu(
        items: wrappedItems,
      );
    }

    if (widget.customContent != null) {
      return Builder(
        builder: (builderContext) {
          final colors = builderContext.chatColors;
          return Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: colors.overlaySurface,
                borderRadius: ChatEditorRadii.br10,
                boxShadow: ChatEditorShadows.overlay,
              ),
              child: ClipRRect(
                borderRadius: ChatEditorRadii.br10,
                child: widget.customContent,
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _closeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() {
        _isOpen = false;
        _isOpening = false;
      });
      widget.onStateChanged?.call(false);

      if (widget.focusNode != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          widget.focusNode?.requestFocus();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
