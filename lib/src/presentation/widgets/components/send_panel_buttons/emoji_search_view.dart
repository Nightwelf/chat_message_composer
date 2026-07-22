import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/buttons/chat_editor_ghost_icon_button.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Кнопка-поле поиска, которая открывает search view при нажатии.
/// Используется как customBottomActionBar, размещается сверху через ViewOrderConfig.
class EmojiSearchBar extends StatelessWidget {
  const EmojiSearchBar(this.config, this.state, this.showSearchBar,
      {super.key});

  final Config config;
  final EmojiViewState state;
  final VoidCallback showSearchBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: showSearchBar,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceTertiary,
                borderRadius: ChatEditorRadii.inputs,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      ChatEditorIcons.search,
                      size: 20,
                      color: colors.textDisabled,
                    ),
                  ),
                  Flexible(
                    child: SizedBox(
                      child: Text(config.searchViewConfig.hintText ?? 'Поиск',
                          style: ChatEditorTypography.body.r14_20
                              .copyWith(color: colors.textDisabled)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Search view с кастомным полем поиска сверху и результатами снизу.
class EmojiSearchView extends SearchView {
  const EmojiSearchView(super.config, super.state, super.showEmojiView,
      {super.key,
      this.onFocusChanged,
      this.notFoundText = 'Эмодзи не найдены'});

  final ValueChanged<bool>? onFocusChanged;
  final String notFoundText;

  @override
  EmojiSearchViewState createState() => EmojiSearchViewState();
}

class EmojiSearchViewState extends SearchViewState<EmojiSearchView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChanged?.call(focusNode.hasFocus);
  }

  List<Emoji> get _displayEmojis {
    if (_textController.text.isEmpty) {
      return widget.state.categoryEmoji.expand((c) => c.emoji).toList();
    }
    return results;
  }

  void _clearSearch() {
    _textController.clear();
    onTextInputChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final emojiSize =
          widget.config.emojiViewConfig.getEmojiSize(constraints.maxWidth);
      final emojiBoxSize =
          widget.config.emojiViewConfig.getEmojiBoxSize(constraints.maxWidth);

      return ColoredBox(
        color: widget.config.emojiViewConfig.backgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.chatColors.surfaceQuaternary,
                    borderRadius: ChatEditorRadii.inputs,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ExcludeFocus(
                          child: ChatEditorGhostIconButton.sm(
                            onTap: () {
                              focusNode.unfocus();
                              widget.showEmojiView();
                            },
                            icon: ChatEditorIcons.search,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          groupId: 'emoji_search',
                          controller: _textController,
                          focusNode: focusNode,
                          autofocus: true,
                          onChanged: onTextInputChanged,
                          style: ChatEditorTypography.body.r14_20
                              .copyWith(color: context.chatColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: widget.config.searchViewConfig.hintText ??
                                'Поиск',
                            hintStyle: ChatEditorTypography.body.r14_20
                                .copyWith(color: context.chatColors.textDisabled),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      TapRegion(
                        groupId: 'emoji_search',
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: ExcludeFocus(
                            child: ChatEditorGhostIconButton.sm(
                              onTap: _clearSearch,
                              icon: ChatEditorIcons.closeRegularSm,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _displayEmojis.isEmpty && _textController.text.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(ChatEditorSpacing.px8),
                      child: Text(
                        widget.notFoundText,
                        style: ChatEditorTypography.body.r14_20.copyWith(
                          color: context.chatColors.textStrong,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: widget.config.emojiViewConfig.gridPadding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.config.emojiViewConfig.columns,
                      ),
                      itemCount: _displayEmojis.length,
                      itemBuilder: (context, index) => buildEmoji(
                        _displayEmojis[index],
                        emojiSize,
                        emojiBoxSize,
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
