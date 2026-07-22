import 'package:chat_message_composer/src/domain/entities/mention.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_item.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_panel_empty.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_panel_error.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_panel_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef MentionItemBuilder = Widget Function(
  BuildContext context,
  Mention mention, {
  required bool isSelected,
  required VoidCallback onTap,
  required VoidCallback onHover,
});

typedef MentionPanelLoadingBuilder = Widget Function(BuildContext context);

typedef MentionPanelEmptyBuilder = Widget Function(BuildContext context);

typedef MentionPanelErrorBuilder = Widget Function(
    BuildContext context, Object error);

/// Виджет панели упоминаний (@).
///
/// Отображает список пользователей для упоминания, поддерживает фильтрацию
/// и навигацию стрелками.
class MentionPanel extends StatefulWidget {
  const MentionPanel({
    required this.isPlatformMobile,
    super.key,
    this.mentionItemBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final MentionItemBuilder? mentionItemBuilder;
  final MentionPanelLoadingBuilder? loadingBuilder;
  final MentionPanelEmptyBuilder? emptyBuilder;
  final MentionPanelErrorBuilder? errorBuilder;
  final bool isPlatformMobile;

  @override
  State<MentionPanel> createState() => _MentionPanelState();
}

class _MentionPanelState extends State<MentionPanel> {
  final ScrollController _scrollController = ScrollController();
  int? _previousSelectedIndex;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int selectedIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        const itemHeight = 60.0;
        final targetOffset = selectedIndex * itemHeight;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final viewportHeight = _scrollController.position.viewportDimension;
        final scrollOffset =
            (targetOffset - viewportHeight / 2 + itemHeight / 2)
                .clamp(0.0, maxScroll);
        _scrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MentionPanelBloc, MentionPanelState>(
      listener: (context, state) {
        if (state is MentionPanelState$Data &&
            state.selectedIndex >= 0 &&
            state.selectedIndex < state.mentions.length &&
            state.selectedIndex != _previousSelectedIndex &&
            state.shouldScroll) {
          _previousSelectedIndex = state.selectedIndex;
          _scrollToSelected(state.selectedIndex);
        } else if (state is MentionPanelState$Data) {
          if (state.selectedIndex < 0) {
            _previousSelectedIndex = null;
          } else if (!state.shouldScroll) {
            _previousSelectedIndex = state.selectedIndex;
          }
        }
      },
      child: BlocBuilder<MentionPanelBloc, MentionPanelState>(
        builder: (context, state) {
          return switch (state) {
            MentionPanelState$Initial() => const SizedBox.shrink(),
            MentionPanelState$Loading(:final mentions, :final selectedIndex) =>
              _buildPanel(
                mentions: mentions,
                selectedIndex: selectedIndex,
                isLoading: true,
              ),
            MentionPanelState$Data(:final mentions, :final selectedIndex) =>
              _buildPanel(
                mentions: mentions,
                selectedIndex: selectedIndex,
                isLoading: false,
              ),
            MentionPanelState$Error(:final error) => widget.errorBuilder != null
                ? widget.errorBuilder!(context, error)
                : MentionPanelError(error: error),
          };
        },
      ),
    );
  }

  Widget _buildPanel({
    required List<Mention> mentions,
    required int selectedIndex,
    required bool isLoading,
  }) {
    final colors = context.chatColors;
    // Если список пуст и идёт загрузка - показываем индикатор
    if (mentions.isEmpty && isLoading) {
      return widget.loadingBuilder != null
          ? widget.loadingBuilder!(context)
          : const MentionPanelLoading();
    }

    // Если список пуст - показываем сообщение
    if (mentions.isEmpty) {
      return widget.emptyBuilder != null
          ? widget.emptyBuilder!(context)
          : const MentionPanelEmpty();
    }
    if (widget.isPlatformMobile) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.chatColors.borderSubtle)),
            color: colors.surfaceSecondary,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: _content(
              mentions: mentions,
              selectedIndex: selectedIndex,
              isLoading: isLoading,
            ),
          ),
        ),
      );
    }
    // Показываем список с опциональным индикатором загрузки
    return Padding(
      padding: const EdgeInsetsGeometry.only(bottom: ChatEditorSpacing.px4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: ChatEditorRadii.br8,
          border: Border.all(color: context.chatColors.borderSubtle),
          color: colors.surfaceSecondary,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: ChatEditorSpacing.px4),
            child: _content(
              mentions: mentions,
              selectedIndex: selectedIndex,
              isLoading: isLoading,
            ),
          ),
        ),
      ),
    );
  }

  Widget _content({
    required List<Mention> mentions,
    required int selectedIndex,
    required bool isLoading,
  }) {
    final colors = context.chatColors;
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: mentions.length,
          itemBuilder: (context, index) {
            final mention = mentions[index];
            final isSelected = index == selectedIndex;
            final builder = widget.mentionItemBuilder ??
                (ctx, mention,
                        {required isSelected,
                        required onTap,
                        required onHover}) =>
                    MentionItem(
                      key: ValueKey(mention.id),
                      mention: mention,
                      isSelected: isSelected,
                      onTap: onTap,
                      onHover: onHover,
                    );
            return builder(
              context,
              mention,
              isSelected: isSelected,
              onTap: () => context
                  .read<MentionPanelBloc>()
                  .add(MentionPanelEvent$Select(index: index)),
              onHover: () => context
                  .read<MentionPanelBloc>()
                  .add(MentionPanelEvent$Hover(index: index)),
            );
          },
        ),
        // Индикатор загрузки поверх списка
        if (isLoading)
          Positioned(
            top: 4,
            right: 4,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
