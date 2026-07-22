import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EditorToolbar extends StatefulWidget {
  const EditorToolbar({
    required this.editorController,
    this.useDevider = true,
    super.key,
    this.editorFocusNode,
  });

  final QuillController editorController;
  final FocusNode? editorFocusNode;
  final bool useDevider;

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;

    final colorScheme = ButtonColorScheme(
      enabled: colors.neutralSoftDefault,
      hovered: colors.neutralSoftHover,
      pressed: colors.neutralSoftPressed,
      disabled: Colors.transparent,
      iconDisabled: colors.textDisabled.withAlpha(200),
      iconEnabled: colors.textStrong,
      iconHovered: colors.textStrong,
      iconPressed: colors.textStrong,
    );

    final iconTheme = QuillIconTheme(
      iconButtonSelectedData: IconButtonData(
        style: ButtonStyle(
          backgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.disabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.pressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.hovered;
            }
            return colorScheme.pressed;
          }),
        ),
      ),
    );

    final divider = widget.useDevider
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: ChatEditorSpacing.px8),
            child: VerticalDivider(
              color: colors.borderDivider,
              width: 1,
            ),
          )
        : const SizedBox.shrink();
    return Theme(
      data: Theme.of(context).copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.all(colors.textPrimary),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: ChatEditorRadii.br10,
              ),
            ),
          ),
        ),
      ),
      child: Listener(
        onPointerUp: (_) {
          final focusNode = widget.editorFocusNode;
          if (focusNode != null && focusNode.canRequestFocus) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (focusNode.canRequestFocus) focusNode.requestFocus();
            });
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuillToolbarToggleStyleButton(
              controller: widget.editorController,
              attribute: Attribute.bold,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: ChatEditorIcons.txtFormatBold,
                iconTheme: iconTheme,
              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: widget.editorController,
              attribute: Attribute.italic,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: ChatEditorIcons.txtFormatItalic,
                iconTheme: iconTheme,
              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: widget.editorController,
              attribute: Attribute.underline,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: ChatEditorIcons.txtFormatUnderline,
                iconTheme: iconTheme,
              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: widget.editorController,
              attribute: Attribute.strikeThrough,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: ChatEditorIcons.txtFormatStrikethrough,
                iconTheme: iconTheme,
              ),
            ),
            divider,
            QuillToolbarLinkStyleButton(
              controller: widget.editorController,
              options: QuillToolbarLinkStyleButtonOptions(
                iconData: ChatEditorIcons.link,
                iconTheme: iconTheme,
              ),
            ),
            divider,
            QuillToolbarToggleStyleButton(
              controller: widget.editorController,
              attribute: Attribute.ol,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: ChatEditorIcons.listNumbers,
                iconTheme: iconTheme,
              ),
            ),
            QuillToolbarToggleStyleButton(
              controller: widget.editorController,
              attribute: Attribute.ul,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: ChatEditorIcons.list,
                iconTheme: iconTheme,
              ),
            ),
            divider,
            QuillToolbarToggleStyleButton(
              controller: widget.editorController,
              attribute: Attribute.blockQuote,
              options: QuillToolbarToggleStyleButtonOptions(
                iconData: ChatEditorIcons.quote,
                iconTheme: iconTheme,
              ),
            ),
            divider,
            QuillToolbarClearFormatButton(
              controller: widget.editorController,
              options: QuillToolbarClearFormatButtonOptions(
                iconData: ChatEditorIcons.eraser,
                iconTheme: iconTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
