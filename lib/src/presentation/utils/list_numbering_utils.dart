import 'package:flutter_quill/flutter_quill.dart';

/// Кастомный атрибут для хранения реального порядкового номера элемента нумерованного списка.
class ListRealIndexAttribute extends Attribute<int?> {
  const ListRealIndexAttribute(int? value)
      : super('list-real-index', AttributeScope.block, value);
}

/// Утилиты для работы с нумерацией списков.
abstract class ListNumberingUtils {
  const ListNumberingUtils._();

  /// Обновляет атрибуты list-real-index для всех элементов нумерованных списков в документе.
  ///
  /// Каждый элемент нумерованного списка получает атрибут list-real-index с его реальным
  /// порядковым номером (1, 2, 3...). При изменении списка индексы автоматически пересчитываются.
  ///
  /// Возвращает список изменений, которые нужно применить к документу.
  static List<_ListRealIndexUpdate> _calculateListRealIndexUpdates(
      Document document) {
    final updates = <_ListRealIndexUpdate>[];
    final delta = document.toDelta();
    final ops = delta.toList();

    var currentPosition = 0;
    var orderedListCounter = 0;

    for (final op in ops) {
      final data = op.data;
      final opLength = op.length ?? 0;
      final attrs = op.attributes;

      final isTextWithNewline = data is String && data.endsWith('\n');
      final isOrderedList =
          isTextWithNewline && attrs != null && attrs['list'] == 'ordered';

      if (isOrderedList) {
        orderedListCounter++;

        final currentRealIndex = attrs['list-real-index'] as int?;

        if (currentRealIndex != orderedListCounter) {
          // Атрибут list хранится на последнем символе (\n) операции
          updates.add(_ListRealIndexUpdate(
            position: currentPosition + opLength - 1,
            length: 1,
            realIndex: orderedListCounter,
          ));
        }
      } else if (isTextWithNewline &&
          (attrs == null || attrs['list'] == null)) {
        orderedListCounter = 0;
      }

      currentPosition += opLength;
    }

    return updates;
  }

  /// Применяет обновления list-real-index к документу.
  ///
  /// Использует [Document.format] для каждого обновления.
  /// Важно: изменения игнорируются в истории через `ignoreChange`.
  static void _applyListRealIndexUpdates(
      Document document, List<_ListRealIndexUpdate> updates) {
    if (updates.isEmpty) return;

    try {
      document.history.ignoreChange = true;

      for (final update in updates) {
        document.format(
          update.position,
          update.length,
          ListRealIndexAttribute(update.realIndex),
        );
      }
    } finally {
      document.history.ignoreChange = false;
    }
  }

  /// Обновляет нумерацию списков в документе.
  ///
  /// Вычисляет и устанавливает атрибут list-real-index для каждого элемента нумерованного списка.
  /// Возвращает true, если были внесены изменения.
  static bool updateListNumbering(Document document) {
    final updates = _calculateListRealIndexUpdates(document);
    if (updates.isEmpty) return false;

    _applyListRealIndexUpdates(document, updates);
    return true;
  }
}

/// Внутренний класс для хранения информации об обновлении list-real-index.
class _ListRealIndexUpdate {
  const _ListRealIndexUpdate({
    required this.position,
    required this.length,
    required this.realIndex,
  });

  final int position;
  final int length;
  final int realIndex;
}
