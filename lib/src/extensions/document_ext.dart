import 'dart:convert';

import 'package:chat_message_composer/chat_message_composer.dart';

extension DocumentSimpleStringify on Document {
  String get stringify => jsonEncode(toDelta().toJson());

  String? toTrimmedJsonOrNull() {
    final plainText = toPlainText();

    final start = _leadingTrimIndex(plainText);
    final end = _trailingTrimIndex(plainText);

    if (start >= end) {
      return null;
    }

    final trimmedDocument = Document.fromDelta(toDelta());

    if (end < plainText.length) {
      trimmedDocument.replace(end, plainText.length - end, '');
    }

    if (start > 0) {
      trimmedDocument.replace(0, start, '');
    }

    return jsonEncode(trimmedDocument.toDelta().toJson());
  }

  int _leadingTrimIndex(String value) {
    var index = 0;

    while (index < value.length && _isTrimChar(value.codeUnitAt(index))) {
      index++;
    }

    return index;
  }

  int _trailingTrimIndex(String value) {
    var index = value.length;

    while (index > 0 && _isTrimChar(value.codeUnitAt(index - 1))) {
      index--;
    }

    return index;
  }

  bool _isTrimChar(int charCode) {
    switch (charCode) {
      case 0x0009: // \t
      case 0x000A: // \n
      case 0x000B: // vertical tab
      case 0x000C: // form feed
      case 0x000D: // \r
      case 0x0020: // space
      case 0x00A0: // no-break space
        return true;
      default:
        return false;
    }
  }

  bool get isBlank => toPlainText().trim().isEmpty;
}
