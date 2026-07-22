import 'package:flutter/material.dart';

/// Шкала скруглений редактора ввода сообщений.
abstract final class ChatEditorRadii {
  static const br4 = BorderRadius.all(Radius.circular(4));
  static const br8 = BorderRadius.all(Radius.circular(8));
  static const br10 = BorderRadius.all(Radius.circular(10));
  static const br9999 = BorderRadius.all(Radius.circular(9999));

  /// Скругление полей ввода и подобных элементов.
  static const inputs = BorderRadius.all(Radius.circular(12));
}
