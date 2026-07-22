import 'package:flutter/material.dart';

final class ButtonColorScheme {
  ButtonColorScheme({
    required this.enabled,
    required this.hovered,
    required this.pressed,
    required this.disabled,
    required this.iconEnabled,
    required this.iconHovered,
    required this.iconPressed,
    required this.iconDisabled,
  });
  final Color enabled;
  final Color hovered;
  final Color pressed;
  final Color disabled;

  final Color iconDisabled;
  final Color iconEnabled;
  final Color iconHovered;
  final Color iconPressed;
}
