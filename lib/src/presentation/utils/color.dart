import 'dart:ui';

extension ColorExtension on Color {
  String get toHexString => '#${toARGB32().toRadixString(16).padLeft(8, '0')}';
}
