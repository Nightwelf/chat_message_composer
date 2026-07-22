import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/controlled_stated_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/bottom_sheet_menu_widget.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/custom_context_menu.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/overlay_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Кнопка "Плюс" для открытия меню добавления медиафайлов и контента.
///
/// Виджет отображает кнопку с иконкой плюса, при нажатии на которую
/// открывается меню с опциями для добавления различных типов контента:
/// - Камера (только для bottom sheet режима)
/// - Фото или видео
/// - Документ
/// - Контакт
/// - Опрос
/// - Событие
///
/// Меню может отображаться в двух режимах:
/// - [isUseBottomSheet] = true: меню отображается как bottom sheet
/// - [isUseBottomSheet] = false: меню отображается как overlay (контекстное меню)
///
/// Кнопка автоматически скрывается, если не задан ни один из callbacks
/// для опций меню.
///
/// Пример использования:
/// ```dart
/// PlusButton(
///   onPhotoOrVideoTap: () => _handlePhotoOrVideo(),
///   onDocumentTap: () => _handleDocument(),
///   onContactTap: () => _handleContact(),
///   focusNode: focusNode,
///   isUseBottomSheet: true,
/// )
/// ```
class PlusButton extends StatefulWidget {
  const PlusButton({
    this.onCameraTap,
    this.onPhotoOrVideoTap,
    this.onDocumentTap,
    this.onContactTap,
    this.onPollTap,
    this.onEventTap,
    this.focusNode,
    this.buttonColorScheme,
    this.isUseBottomSheet = false,
    super.key,
  });

  /// Отображается только в режиме bottom sheet ([isUseBottomSheet] = true).
  final VoidCallback? onCameraTap;

  final VoidCallback? onPhotoOrVideoTap;
  final VoidCallback? onDocumentTap;
  final VoidCallback? onContactTap;
  final VoidCallback? onPollTap;
  final VoidCallback? onEventTap;
  final FocusNode? focusNode;
  final ButtonColorScheme? buttonColorScheme;

  /// true — bottom sheet, false — overlay (контекстное меню).
  final bool isUseBottomSheet;
  @override
  State<PlusButton> createState() => _PlusButtonState();
}

class _PlusButtonState extends State<PlusButton> {
  final ValueNotifier<bool> _isMenuOpen = ValueNotifier(false);
  final WidgetStatesController _controller = WidgetStatesController();

  List<CustomContextMenuEntry> _buildMenuItems(BuildContext context) {
    final localization = context.read<ChatMessageComposerLocalizationRepository>();
    return <CustomContextMenuEntry>[
      // Камера доступна только в bottom sheet режиме
      if (widget.onCameraTap != null && widget.isUseBottomSheet)
        CustomContextMenuItemEntry(
          icon: ChatEditorIcons.camera,
          title: localization.camera,
          onTap: widget.onCameraTap!,
        ),
      if (widget.onPhotoOrVideoTap != null)
        CustomContextMenuItemEntry(
          icon: ChatEditorIcons.photo,
          title: localization.insertImageOrVideo,
          onTap: widget.onPhotoOrVideoTap!,
        ),
      if (widget.onDocumentTap != null)
        CustomContextMenuItemEntry(
          icon: ChatEditorIcons.file,
          title: localization.insertDocument,
          onTap: widget.onDocumentTap!,
        ),
      if (widget.onContactTap != null)
        CustomContextMenuItemEntry(
          icon: ChatEditorIcons.userRound,
          title: localization.attachContact,
          onTap: widget.onContactTap!,
        ),
      if (!widget.isUseBottomSheet)
        if ((widget.onPhotoOrVideoTap != null ||
                widget.onDocumentTap != null ||
                widget.onContactTap != null) &&
            (widget.onPollTap != null && widget.onEventTap != null))
          CustomContextMenuDividerEntry(),
      if (widget.onPollTap != null)
        CustomContextMenuItemEntry(
          icon: ChatEditorIcons.chartBarVertical,
          title: localization.createPoll,
          onTap: widget.onPollTap!,
        ),
      if (widget.onEventTap != null)
        CustomContextMenuItemEntry(
          icon: ChatEditorIcons.calendar,
          title: localization.createEvent,
          onTap: widget.onEventTap!,
        ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _buildMenuItems(context);
    if (menuItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final button = ValueListenableBuilder(
      valueListenable: _isMenuOpen,
      builder: (context, isOpen, child) {
        return ControlledStatedButton.pressed(
          controller: _controller,
          icon: ChatEditorIcons.plusAdd,
          isPressed: isOpen,
          buttonColorScheme: widget.buttonColorScheme,
        );
      }
    );

    if (widget.isUseBottomSheet) {
      return BottomSheetMenuWidget(
        controller: _controller,
        menuContent: menuItems,
        onStateChanged: (isOpen) => _isMenuOpen.value = isOpen,
        child: button,
      );
    }

    return OverlayMenuWidget(
      controller: _controller,
      focusNode: widget.focusNode,
      menuContent: menuItems,
      onStateChanged: (isOpen) => _isMenuOpen.value = isOpen,
      child: button,
    );
  }
}
