import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';

/// Круглый аватар упоминания: изображение по адресу, либо инициалы при его
/// отсутствии или ошибке загрузки.
class MentionAvatar extends StatelessWidget {
  const MentionAvatar({required this.address, required this.initials, super.key});

  final String? address;
  final String initials;

  static const double _dimension = ChatEditorSpacing.px32;

  @override
  Widget build(BuildContext context) {
    final colors = context.chatColors;
    return SizedBox.square(
      dimension: _dimension,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.surfacePrimary),
          color: colors.surfaceQuaternary,
        ),
        child: ClipOval(
          child: (address?.isNotEmpty ?? false)
              ? Image.network(
                  address!,
                  width: _dimension,
                  height: _dimension,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _Initials(initials: initials, colors: colors),
                )
              : _Initials(initials: initials, colors: colors),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials, required this.colors});

  final String initials;
  final ChatEditorColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: ChatEditorTypography.label.m12_18.copyWith(color: colors.textStrong),
      ),
    );
  }
}
