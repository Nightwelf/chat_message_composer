import 'package:chat_message_composer/src/domain/entities/emoji_embed.dart';
import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/models/button_color_scheme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/utils/emoji_set_utils.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/controlled_stated_button.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/custom_context_menu/overlay_menu_widget.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/emoji_search_view.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

Widget _hiddenCategoryView(Config config, EmojiViewState state,
        TabController tabController, PageController pageController) =>
    const SizedBox.shrink();

class SmileButton extends StatefulWidget {
  const SmileButton({
    required this.quillController,
    this.focusNode,
    this.buttonColorScheme,
    this.alignment = Alignment.bottomLeft,
    super.key,
  });

  final QuillController quillController;
  final FocusNode? focusNode;
  final ButtonColorScheme? buttonColorScheme;

  /// Привязка popup к кнопке. [Alignment.bottomLeft] — меню открывается вправо,
  /// [Alignment.bottomRight] — меню открывается влево.
  final Alignment alignment;

  @override
  State<SmileButton> createState() => _SmileButtonState();
}

class _SmileButtonState extends State<SmileButton> {
  bool _isContainerOpen = false;
  final WidgetStatesController _controller = WidgetStatesController();
  final ValueNotifier<bool> _closeNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _closeNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final controller = widget.quillController;
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;
    final embeddable = Embeddable(emojiEmbedType, emoji.emoji);
    controller.skipRequestKeyboard = true;
    if (length > 0) {
      controller.document.replace(index, length, embeddable);
    } else {
      controller.document.replace(index, 0, embeddable);
    }
    controller.updateSelection(
      TextSelection.collapsed(offset: index + 1),
      ChangeSource.local,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayMenuWidget(
      controller: _controller,
      focusNode: widget.focusNode,
      closeNotifier: _closeNotifier,
      alignment: widget.alignment,
      customContent: SizedBox(
        width: 320,
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(ChatEditorSpacing.px8),
          child: EmojiPicker(
            onEmojiSelected: _onEmojiSelected,
            config: Config(
              height: 280,
              emojiSet: getBilingualEmojiSet,
              viewOrderConfig: const ViewOrderConfig(
                top: EmojiPickerItem.searchBar,
                bottom: EmojiPickerItem.categoryBar,
              ),
              emojiViewConfig: EmojiViewConfig(
                columns: 8,
                emojiSizeMax: 32,
                backgroundColor: context.chatColors.overlaySurface,
              ),
              categoryViewConfig: const CategoryViewConfig(
                recentTabBehavior: RecentTabBehavior.NONE,
                initCategory: Category.SMILEYS,
                customCategoryView: _hiddenCategoryView,
              ),
              bottomActionBarConfig: const BottomActionBarConfig(
                customBottomActionBar: EmojiSearchBar.new,
              ),
              searchViewConfig: SearchViewConfig(
                hintText:
                    context.read<ChatMessageComposerLocalizationRepository>().emojiSearch,
                customSearchView: (config, state, showEmojiView) =>
                    EmojiSearchView(
                  config,
                  state,
                  showEmojiView,
                  notFoundText: context
                      .read<ChatMessageComposerLocalizationRepository>()
                      .emojiNotFound,
                ),
              ),
            ),
          ),
        ),
      ),
      onStateChanged: (isOpen) {
        setState(() {
          _isContainerOpen = isOpen;
        });
      },
      child: ControlledStatedButton.pressed(
        controller: _controller,
        icon: ChatEditorIcons.face,
        isPressed: _isContainerOpen,
        buttonColorScheme: widget.buttonColorScheme,
      ),
    );
  }
}
