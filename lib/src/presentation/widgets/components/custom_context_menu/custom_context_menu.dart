import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/custom_context_menu_divider.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/custom_context_menu_item.dart';
import 'package:flutter/material.dart';

sealed class CustomContextMenuEntry {}

class CustomContextMenuItemEntry extends CustomContextMenuEntry {
  CustomContextMenuItemEntry({
    required this.icon,
    required this.title,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool enabled;
}

class CustomContextMenuDividerEntry extends CustomContextMenuEntry {
  CustomContextMenuDividerEntry({
    this.height = 8.0,
  });

  final double height;
}

class CustomContextMenu extends StatelessWidget {
  const CustomContextMenu({
    required this.items,
    super.key,
    this.itemHeight = 40.0,
    this.maxWidth = 253.0,
  });

  final List<CustomContextMenuEntry> items;
  final double itemHeight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: colors.overlaySurface,
          borderRadius: ChatEditorRadii.br10,
          boxShadow: ChatEditorShadows.overlay,
        ),
        child: ClipRRect(
          borderRadius: ChatEditorRadii.br10,
          child: Padding(
            padding: const EdgeInsets.all(ChatEditorSpacing.px4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                return switch (item) {
                  CustomContextMenuItemEntry() => CustomContextMenuItem(
                      icon: item.icon,
                      title: item.title,
                      onTap: item.onTap,
                      enabled: item.enabled,
                      itemHeight: itemHeight,
                    ),
                  CustomContextMenuDividerEntry() => CustomContextMenuDivider(
                      height: item.height,
                    ),
                };
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required Offset position,
    required List<CustomContextMenuEntry> items,
    double itemHeight = 40.0,
    double maxWidth = 253.0,
    Alignment menuAlignment = Alignment.bottomLeft,
    Alignment childAlignment = Alignment.topLeft,
    Offset offset = const Offset(0, -6),
  }) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final globalPosition = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  overlayEntry.remove();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: globalPosition.dx +
                  (childAlignment.x + 1) / 2 * size.width +
                  offset.dx,
              top: globalPosition.dy +
                  (childAlignment.y + 1) / 2 * size.height +
                  offset.dy,
              child: Align(
                alignment: menuAlignment,
                child: CustomContextMenu(
                  items: items,
                  itemHeight: itemHeight,
                  maxWidth: maxWidth,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}
