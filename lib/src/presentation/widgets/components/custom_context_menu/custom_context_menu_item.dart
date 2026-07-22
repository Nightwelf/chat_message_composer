import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

class CustomContextMenuItem extends StatelessWidget {
  const CustomContextMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.enabled = true,
    this.itemHeight = 40.0,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool enabled;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: ChatEditorRadii.br8,
        child: Container(
          height: itemHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: ChatEditorSpacing.px12,
            vertical: ChatEditorSpacing.px8,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: ChatEditorSpacing.px24,
                color: enabled
                    ? colors.textStrong
                    : colors.textDisabled.withAlpha(200),
              ),
              const SizedBox(width: ChatEditorSpacing.px8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: enabled
                        ? colors.textStrong
                        : colors.textDisabled.withAlpha(200),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
