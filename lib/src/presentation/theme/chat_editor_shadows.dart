import 'package:flutter/material.dart';

/// Тени редактора ввода сообщений.
abstract final class ChatEditorShadows {
  /// Для элементов над основным интерфейсом: контекстные меню, всплывающие панели.
  static const overlay = [
    BoxShadow(color: Color(0x4F0C2245), blurRadius: 1),
    BoxShadow(color: Color(0x260C2245), blurRadius: 12, offset: Offset(0, 8)),
  ];
}
