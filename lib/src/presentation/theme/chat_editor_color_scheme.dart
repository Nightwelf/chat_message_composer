import 'package:flutter/material.dart';

/// Набор цветовых токенов редактора ввода сообщений.
///
/// Подключается в тему хост-приложения через `ThemeData.extensions` и
/// читается виджетами пакета через [ChatEditorThemeContext.chatColors].
class ChatEditorColorScheme extends ThemeExtension<ChatEditorColorScheme> {
  const ChatEditorColorScheme({
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.surfaceQuaternary,
    required this.overlaySurface,
    required this.textPrimary,
    required this.textStrong,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.textDisabled,
    required this.contentOnFilled,
    required this.contentInverted,
    required this.brandDefault,
    required this.brandHover,
    required this.brandPressed,
    required this.neutralFilled,
    required this.neutralSoftDefault,
    required this.neutralSoftHover,
    required this.neutralSoftPressed,
    required this.borderDivider,
    required this.borderSubtle,
    required this.outgoingBubbleBackground,
  });

  factory ChatEditorColorScheme.light() => const ChatEditorColorScheme(
        surfacePrimary: Color(0xFFFFFFFF),
        surfaceSecondary: Color(0xFFF9FAFA),
        surfaceTertiary: Color(0xFFF4F5F6),
        surfaceQuaternary: Color(0xFFEEEFF1),
        overlaySurface: Color(0xFFFFFFFF),
        textPrimary: Color(0xFF1C1E21),
        textStrong: Color(0xFF3D4148),
        textSecondary: Color(0xFF50555E),
        textTertiary: Color(0xFF5E646E),
        textMuted: Color(0xFF757D8A),
        textDisabled: Color(0xFFACB1B9),
        contentOnFilled: Color(0xFFF4F5F6),
        contentInverted: Color(0xFFFFFFFF),
        brandDefault: Color(0xFF1456B8),
        brandHover: Color(0xFF124DA5),
        brandPressed: Color(0xFF0C336E),
        neutralFilled: Color(0xFF34373D),
        neutralSoftDefault: Color(0xFFF4F5F6),
        neutralSoftHover: Color(0xFFEEEFF1),
        neutralSoftPressed: Color(0xFFE3E5E8),
        borderDivider: Color(0xFFC8CBD0),
        borderSubtle: Color(0xFFEEEFF1),
        outgoingBubbleBackground: Color(0xFFE3EDFC),
      );

  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color surfaceQuaternary;
  final Color overlaySurface;

  final Color textPrimary;
  final Color textStrong;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color textDisabled;
  final Color contentOnFilled;
  final Color contentInverted;

  final Color brandDefault;
  final Color brandHover;
  final Color brandPressed;

  final Color neutralFilled;
  final Color neutralSoftDefault;
  final Color neutralSoftHover;
  final Color neutralSoftPressed;

  final Color borderDivider;
  final Color borderSubtle;

  final Color outgoingBubbleBackground;

  @override
  ChatEditorColorScheme copyWith({
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceTertiary,
    Color? surfaceQuaternary,
    Color? overlaySurface,
    Color? textPrimary,
    Color? textStrong,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMuted,
    Color? textDisabled,
    Color? contentOnFilled,
    Color? contentInverted,
    Color? brandDefault,
    Color? brandHover,
    Color? brandPressed,
    Color? neutralFilled,
    Color? neutralSoftDefault,
    Color? neutralSoftHover,
    Color? neutralSoftPressed,
    Color? borderDivider,
    Color? borderSubtle,
    Color? outgoingBubbleBackground,
  }) {
    return ChatEditorColorScheme(
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      surfaceQuaternary: surfaceQuaternary ?? this.surfaceQuaternary,
      overlaySurface: overlaySurface ?? this.overlaySurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textStrong: textStrong ?? this.textStrong,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      contentOnFilled: contentOnFilled ?? this.contentOnFilled,
      contentInverted: contentInverted ?? this.contentInverted,
      brandDefault: brandDefault ?? this.brandDefault,
      brandHover: brandHover ?? this.brandHover,
      brandPressed: brandPressed ?? this.brandPressed,
      neutralFilled: neutralFilled ?? this.neutralFilled,
      neutralSoftDefault: neutralSoftDefault ?? this.neutralSoftDefault,
      neutralSoftHover: neutralSoftHover ?? this.neutralSoftHover,
      neutralSoftPressed: neutralSoftPressed ?? this.neutralSoftPressed,
      borderDivider: borderDivider ?? this.borderDivider,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      outgoingBubbleBackground: outgoingBubbleBackground ?? this.outgoingBubbleBackground,
    );
  }

  @override
  ChatEditorColorScheme lerp(ThemeExtension<ChatEditorColorScheme>? other, double t) {
    if (other is! ChatEditorColorScheme) return this;
    return ChatEditorColorScheme(
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      surfaceQuaternary: Color.lerp(surfaceQuaternary, other.surfaceQuaternary, t)!,
      overlaySurface: Color.lerp(overlaySurface, other.overlaySurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      contentOnFilled: Color.lerp(contentOnFilled, other.contentOnFilled, t)!,
      contentInverted: Color.lerp(contentInverted, other.contentInverted, t)!,
      brandDefault: Color.lerp(brandDefault, other.brandDefault, t)!,
      brandHover: Color.lerp(brandHover, other.brandHover, t)!,
      brandPressed: Color.lerp(brandPressed, other.brandPressed, t)!,
      neutralFilled: Color.lerp(neutralFilled, other.neutralFilled, t)!,
      neutralSoftDefault: Color.lerp(neutralSoftDefault, other.neutralSoftDefault, t)!,
      neutralSoftHover: Color.lerp(neutralSoftHover, other.neutralSoftHover, t)!,
      neutralSoftPressed: Color.lerp(neutralSoftPressed, other.neutralSoftPressed, t)!,
      borderDivider: Color.lerp(borderDivider, other.borderDivider, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      outgoingBubbleBackground: Color.lerp(outgoingBubbleBackground, other.outgoingBubbleBackground, t)!,
    );
  }
}

/// Доступ к [ChatEditorColorScheme] текущей темы.
extension ChatEditorThemeContext on BuildContext {
  ChatEditorColorScheme get chatColors => Theme.of(this).extension<ChatEditorColorScheme>()!;
}
