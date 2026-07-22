part of 'mention_panel_bloc.dart';

/// Базовый класс для состояний панели упоминаний.
sealed class MentionPanelState extends Equatable {
  const MentionPanelState();

  /// Возвращает true, если панель должна быть видима.
  bool get isVisible => switch (this) {
        MentionPanelState$Loading(:final showPanel) => showPanel,
        MentionPanelState$Data() => true,
        _ => false,
      };

  @override
  List<Object?> get props => [];
}

/// Начальное состояние (панель скрыта).
final class MentionPanelState$Initial extends MentionPanelState {
  const MentionPanelState$Initial();
}

/// Состояние загрузки данных.
final class MentionPanelState$Loading extends MentionPanelState {
  const MentionPanelState$Loading({
    this.mentions = const [],
    this.selectedIndex = -1,
    this.query = '',
    this.showPanel = true,
  });

  final List<Mention> mentions;
  final int selectedIndex;
  final String query;
  final bool showPanel;

  @override
  List<Object?> get props => [mentions, selectedIndex, query, showPanel];
}

/// Панель с загруженными данными.
final class MentionPanelState$Data extends MentionPanelState {
  const MentionPanelState$Data({
    required this.mentions,
    required this.selectedIndex,
    required this.query,
    this.shouldScroll = false,
  });

  final List<Mention> mentions;
  final int selectedIndex;
  final String query;
  final bool shouldScroll;

  @override
  List<Object?> get props => [mentions, selectedIndex, query, shouldScroll];

  MentionPanelState$Data copyWith({
    List<Mention>? mentions,
    int? selectedIndex,
    String? query,
    bool? shouldScroll,
  }) {
    return MentionPanelState$Data(
      mentions: mentions ?? this.mentions,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      query: query ?? this.query,
      shouldScroll: shouldScroll ?? this.shouldScroll,
    );
  }
}

/// Состояние ошибки.
final class MentionPanelState$Error extends MentionPanelState {
  const MentionPanelState$Error({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
