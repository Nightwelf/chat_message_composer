import 'package:flutter/material.dart';

/// Текстовые стили редактора ввода сообщений (шрифт `CIEInter`).
final class ChatEditorTypography {
  const ChatEditorTypography._();

  static const ChatEditorTypographyBody body = ChatEditorTypographyBody();
  static const ChatEditorTypographyLabel label = ChatEditorTypographyLabel();
}

sealed class _CieInterFont extends TextStyle {
  const _CieInterFont({
    required double fontSize,
    required double height,
    required List<FontVariation> weight,
  }) : super(
          fontFamily: 'CIEInter',
          package: 'chat_message_composer',
          fontSize: fontSize,
          height: height * 0.85,
          fontVariations: weight,
          fontFeatures: const [FontFeature.liningFigures()],
        );
}

final class _CieInterMedium extends _CieInterFont {
  const _CieInterMedium({required super.fontSize, required super.height})
      : super(weight: const [FontVariation.weight(500)]);
}

final class _CieInterRegular extends _CieInterFont {
  const _CieInterRegular({required super.fontSize, required super.height})
      : super(weight: const [FontVariation.weight(400)]);
}

final class ChatEditorTypographyBody {
  const ChatEditorTypographyBody();

  TextStyle get m14_20 => const _CieInterMedium(fontSize: 14, height: 1.428);

  TextStyle get r14_20 => const _CieInterRegular(fontSize: 14, height: 1.428);

  TextStyle get m15_22 => const _CieInterMedium(fontSize: 15, height: 1.466);

  TextStyle get r15_22 => const _CieInterRegular(fontSize: 15, height: 1.466);

  TextStyle get r16_24 => const _CieInterRegular(fontSize: 16, height: 1.5);
}

final class ChatEditorTypographyLabel {
  const ChatEditorTypographyLabel();

  TextStyle get m12_18 => const _CieInterMedium(fontSize: 12, height: 1.5);

  TextStyle get r12_18 => const _CieInterRegular(fontSize: 12, height: 1.5);
}
