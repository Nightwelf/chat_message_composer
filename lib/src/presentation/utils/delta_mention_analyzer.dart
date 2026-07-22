import 'package:chat_message_composer/src/domain/entities/mention_embed.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Анализатор Delta для поиска упоминаний.
///
/// Обходит Delta один раз при создании и кэширует результаты.
/// Предоставляет информацию о:
/// - Позиции последнего активного символа '@'
/// - Позиции и query последнего embed mention_input
/// - Длине документа в символах
class DeltaMentionAnalyzer {
  DeltaMentionAnalyzer({
    required Delta delta,
    required int cursorPosition,
  })  : _delta = delta,
        _cursorPosition = cursorPosition {
    _analyze();
  }

  final Delta _delta;
  final int _cursorPosition;

  int _lastAtIndex = -1;
  int _mentionInputEmbedIndex = -1;
  String _mentionInputQuery = '';
  int _documentLength = 0;

  /// Позиция последнего активного символа '@' в Delta, или -1 если не найден.
  ///
  /// Активным считается '@':
  /// - Перед которым пробел, перенос строки или начало документа
  /// - После которого до курсора нет пробелов или переносов строк
  int get lastAtIndex => _lastAtIndex;

  /// Позиция последнего embed mention_input в Delta, или -1 если не найден.
  int get mentionInputEmbedIndex => _mentionInputEmbedIndex;

  /// Query для фильтрации из embed mention_input + текст после него до курсора.
  String get mentionInputQuery => _mentionInputQuery;

  /// Длина документа в символах (для валидации позиции курсора).
  int get documentLength => _documentLength;

  /// Есть ли embed mention_input перед курсором.
  bool get hasMentionInputEmbed => _mentionInputEmbedIndex != -1;

  /// Есть ли активный символ '@' перед курсором.
  bool get hasActiveAt => _lastAtIndex != -1;

  /// Анализирует Delta и заполняет все кэшированные результаты.
  void _analyze() {
    final atPositions = <int>[];
    final charBeforeAt = <int, String?>{};
    final textAfterAt = <int, String>{};

    var lastMentionInputOffset = -1;
    var queryFromEmbed = '';

    var currentOffset = 0;
    String? previousChar;
    var previousWasEmbed = false;

    for (final op in _delta.operations) {
      if (!op.isInsert) {
        if (op.isRetain) {
          currentOffset += op.length ?? 0;
        }
        continue;
      }

      if (op.data is String) {
        final text = op.data as String? ?? '';
        final textStart = currentOffset;
        final textEnd = currentOffset + text.length;

        for (var i = 0;
            i < text.length && textStart + i < _cursorPosition;
            i++) {
          final char = text[i];

          if (char == '@') {
            final atPosition = textStart + i;
            atPositions.add(atPosition);

            if (i > 0) {
              charBeforeAt[atPosition] = text[i - 1];
            } else if (previousWasEmbed) {
              // '\x00' — сентинел «перед '@' embed», недопустимый символ
              charBeforeAt[atPosition] = '\x00';
            } else {
              charBeforeAt[atPosition] = previousChar;
            }
          }
        }

        if (text.isNotEmpty) {
          previousChar = text[text.length - 1];
          previousWasEmbed = false;
        }

        currentOffset = textEnd;
      } else if (op.data is Map<String, dynamic>) {
        final data = op.data as Map<String, dynamic>? ?? {};

        if (data.containsKey(mentionInputType) &&
            currentOffset < _cursorPosition) {
          final embedData = data[mentionInputType] as Map<String, dynamic>?;
          if (embedData != null) {
            _mentionInputEmbedIndex = currentOffset;
            lastMentionInputOffset = currentOffset;
            queryFromEmbed = embedData['query'] as String? ?? '';
          }
        }

        previousChar = null;
        previousWasEmbed = true;
        currentOffset += 1;
      } else {
        previousChar = null;
        previousWasEmbed = true;
        currentOffset += 1;
      }
    }

    _documentLength = currentOffset;

    if (lastMentionInputOffset >= 0) {
      final textAfterEmbed = _extractTextBetween(
        lastMentionInputOffset + 1,
        _cursorPosition,
      );
      _mentionInputQuery = queryFromEmbed + textAfterEmbed;
    }

    for (final atPos in atPositions) {
      textAfterAt[atPos] = _extractTextBetween(atPos + 1, _cursorPosition);
    }

    // С конца, чтобы найти самый последний активный '@'
    for (var i = atPositions.length - 1; i >= 0; i--) {
      final atPos = atPositions[i];

      final charBefore = charBeforeAt[atPos];
      if (charBefore != null &&
          charBefore != ' ' &&
          charBefore != '\n' &&
          charBefore != '\x00') {
        continue;
      }
      if (charBefore == '\x00') {
        continue;
      }

      final textAfter = textAfterAt[atPos] ?? '';
      if (textAfter.contains(' ') || textAfter.contains('\n')) {
        continue;
      }

      _lastAtIndex = atPos;
      break;
    }
  }

  /// Извлекает текст из Delta между двумя позициями.
  String _extractTextBetween(int startPos, int endPos) {
    if (startPos >= endPos) {
      return '';
    }

    final buffer = StringBuffer();
    var currentOffset = 0;

    for (final op in _delta.operations) {
      if (!op.isInsert) {
        if (op.isRetain) {
          currentOffset += op.length ?? 0;
        }
        continue;
      }

      if (op.data is String) {
        final text = op.data as String? ?? '';
        final textStart = currentOffset;
        final textEnd = currentOffset + text.length;

        if (textEnd > startPos && textStart < endPos) {
          final extractStart = textStart < startPos ? startPos - textStart : 0;
          final extractEnd =
              textEnd <= endPos ? text.length : endPos - textStart;

          if (extractStart < extractEnd) {
            buffer.write(text.substring(extractStart, extractEnd));
          }
        }

        currentOffset = textEnd;
        if (currentOffset >= endPos) {
          break;
        }
      } else {
        // Embed занимает 1 позицию, но не добавляет текст
        currentOffset += 1;
        if (currentOffset >= endPos) {
          break;
        }
      }
    }

    return buffer.toString();
  }
}
