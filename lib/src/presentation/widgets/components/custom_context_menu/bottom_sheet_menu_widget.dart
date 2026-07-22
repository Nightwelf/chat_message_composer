import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/custom_context_menu.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/custom_context_menu_divider.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/custom_context_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Виджет для отображения контекстного меню в bottom sheet при нажатии на контроллер.
///
/// Отслеживает состояние [controller] и показывает bottom sheet меню, когда
/// контроллер содержит [WidgetState.pressed]. Меню автоматически закрывается
/// при изменении размера экрана, при клике вне меню или при выборе элемента.
///
/// [menuContent] и [customContent] взаимоисключающие: при обоих заданных
/// приоритет у [menuContent].
class BottomSheetMenuWidget extends StatefulWidget {
  const BottomSheetMenuWidget({
    required this.child,
    required this.controller,
    this.menuContent,
    this.customContent,
    this.onStateChanged,
    super.key,
  });

  final Widget child;
  final WidgetStatesController controller;
  final List<CustomContextMenuEntry>? menuContent;
  final Widget? customContent;
  final ValueChanged<bool>? onStateChanged;

  @override
  State<BottomSheetMenuWidget> createState() => _BottomSheetMenuState();
}

class _BottomSheetMenuState extends State<BottomSheetMenuWidget>
    with WidgetsBindingObserver {
  bool _isOpen = false;
  bool _isOpening = false;
  NavigatorState? _navigator;
  Size? _previousSize;
  bool _ignoreNextMetricsChange = false;
  Set<WidgetState> _previousControllerState = {};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
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
    WidgetsBinding.instance.removeObserver(this);
    if (_navigator != null && _isOpen) {
      _navigator!.pop();
      _navigator = null;
    }
    super.dispose();
  }

  // Первое изменение метрик после открытия меню игнорируется — оно может быть
  // вызвано самим открытием bottom sheet (изменение layout).
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

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
          _navigator != null &&
          (currentSize.width != _previousSize!.width ||
              currentSize.height != _previousSize!.height)) {
        _closeBottomSheet();
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
        _showBottomSheet();
      }
    }

    _previousControllerState = Set.from(currentState);
  }

  void _showBottomSheet() {
    if (widget.menuContent == null && widget.customContent == null) {
      return;
    }

    if (_isOpening || _isOpen) {
      return;
    }

    _isOpening = true;

    if (!mounted) {
      _isOpening = false;
      return;
    }

    _navigator = Navigator.of(context);
    final mediaQuery = MediaQuery.of(context);
    _previousSize = mediaQuery.size;
    _ignoreNextMetricsChange = true;

    setState(() {
      _isOpen = true;
      _isOpening = false;
    });
    widget.onStateChanged?.call(true);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: _buildContent,
    ).then((_) {
      if (mounted) {
        setState(() {
          _isOpen = false;
        });
        widget.controller.value = {};
        _navigator = null;
        widget.onStateChanged?.call(false);
      }
    });
  }

  Widget _buildContent(BuildContext bottomSheetContext) {
    final colors = bottomSheetContext.chatColors;

    if (widget.menuContent != null) {
      return Container(
        decoration: BoxDecoration(
          color: colors.overlaySurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(ChatEditorSpacing.px4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.menuContent!.map((item) {
                    return switch (item) {
                      CustomContextMenuItemEntry() => CustomContextMenuItem(
                          icon: item.icon,
                          title: item.title,
                          onTap: () {
                            Navigator.of(bottomSheetContext).pop();
                            item.onTap();
                          },
                          enabled: item.enabled,
                        ),
                      CustomContextMenuDividerEntry() =>
                        CustomContextMenuDivider(
                          height: item.height,
                        ),
                    };
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.customContent != null) {
      return Container(
        decoration: BoxDecoration(
          color: colors.overlaySurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: widget.customContent,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _closeBottomSheet() {
    if (_navigator != null && _isOpen) {
      _navigator!.pop();
      _navigator = null;
      setState(() {
        _isOpen = false;
        _isOpening = false;
      });
      widget.controller.value = {};
      widget.onStateChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
