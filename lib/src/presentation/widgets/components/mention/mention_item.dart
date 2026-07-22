import 'package:chat_message_composer/src/domain/entities/mention.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart' as th;
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_avatar.dart';
import 'package:flutter/material.dart';

class MentionItem extends StatefulWidget {
  const MentionItem({
    required this.mention,
    required this.isSelected,
    required this.onTap,
    required this.onHover,
    super.key,
  });

  final Mention mention;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  State<MentionItem> createState() => _MentionItemState();
}

class _MentionItemState extends State<MentionItem> {
  Widget? _avatar;

  @override
  void initState() {
    super.initState();
    _avatar = _buildAvatar();
  }

  @override
  void didUpdateWidget(MentionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mention.avatar != widget.mention.avatar ||
        oldWidget.mention.name != widget.mention.name) {
      _avatar = _buildAvatar();
    }
  }

  Widget _buildAvatar() {
    final mention = widget.mention;
    if (mention.avatar == null) return const SizedBox.shrink();
    return RepaintBoundary(
      child: MentionAvatar(
        address: mention.avatar,
        initials: mention.name.isNotEmpty ? mention.name[0] : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    final mention = widget.mention;
    return MouseRegion(
      onEnter: (_) => widget.onHover(),
      child: SizedBox(
        height: 48,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: th.ChatEditorSpacing.px4,
              vertical: th.ChatEditorSpacing.px1,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.isSelected ? ChatEditorRadii.br8 : null,
                border: widget.isSelected
                    ? Border.all(color: context.chatColors.borderSubtle)
                    : null,
                color: widget.isSelected
                    ? colors.neutralSoftHover
                    : colors.surfaceSecondary,
              ),
              child: Row(
                children: [
                  if (mention.avatar != null)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: ChatEditorSpacing.px12),
                      child: Center(child: _avatar),
                    ),
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: mention.name,
                            style: ChatEditorTypography.body.m15_22
                                .copyWith(color: colors.textPrimary),
                          ),
                          if (mention.nickname != null) ...[
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: '@${mention.nickname}',
                              style: ChatEditorTypography.body.r15_22
                                  .copyWith(color: colors.textMuted),
                            ),
                          ],
                        ],
                      ),
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
