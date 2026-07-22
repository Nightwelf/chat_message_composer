part of 'mention_panel_bloc.dart';

/// Базовый класс для событий панели упоминаний.
sealed class MentionPanelEvent extends Equatable {
  const MentionPanelEvent();

  @override
  List<Object?> get props => [];
}

/// Событие изменения документа редактора.
final class MentionPanelEvent$DocumentChanged extends MentionPanelEvent {
  const MentionPanelEvent$DocumentChanged({
    required this.cursorPosition,
    required this.delta,
  });

  /// Позиция курсора в Delta.
  final int cursorPosition;

  /// Delta документа для точной работы с форматированием и embed-объектами.
  final Delta delta;

  @override
  List<Object?> get props => [cursorPosition, delta];
}

/// Событие навигации вверх по списку.
final class MentionPanelEvent$NavigateUp extends MentionPanelEvent {
  const MentionPanelEvent$NavigateUp();
}

/// Событие навигации вниз по списку.
final class MentionPanelEvent$NavigateDown extends MentionPanelEvent {
  const MentionPanelEvent$NavigateDown();
}

/// Событие наведения мыши на элемент списка.
final class MentionPanelEvent$Hover extends MentionPanelEvent {
  const MentionPanelEvent$Hover({required this.index});

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Событие выбора элемента из списка.
final class MentionPanelEvent$Select extends MentionPanelEvent {
  const MentionPanelEvent$Select({this.index});

  final int? index;

  @override
  List<Object?> get props => [index];
}

/// Событие «выбрать текущий элемент или первый» (для Enter при открытой панели).
/// Обрабатывается синхронно в BLoC без чтения state после add().
final class MentionPanelEvent$SelectFirstOrCurrent extends MentionPanelEvent {
  const MentionPanelEvent$SelectFirstOrCurrent();
}

/// Событие сброса состояния панели (скрытие).
///
/// Если [convertEmbedToText] == true и в документе есть активный embed mention_input,
/// перед сбросом будет отправлена команда для замены embed обратно на текст `@{query}`.
final class MentionPanelEvent$Reset extends MentionPanelEvent {
  const MentionPanelEvent$Reset({this.convertEmbedToText = false});

  final bool convertEmbedToText;

  @override
  List<Object?> get props => [convertEmbedToText];
}
