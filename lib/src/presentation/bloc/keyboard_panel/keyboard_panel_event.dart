part of 'keyboard_panel_bloc.dart';

sealed class KeyboardPanelEvent extends Equatable {
  const KeyboardPanelEvent();

  @override
  List<Object?> get props => [];
}

/// Показать панель эмодзи.
/// [currentHeight] — высота клавиатуры в момент нажатия кнопки.
final class KeyboardPanel$ShowEmoji extends KeyboardPanelEvent {
  const KeyboardPanel$ShowEmoji(this.currentHeight);

  final double currentHeight;

  @override
  List<Object?> get props => [currentHeight];
}

/// Закрыть панель, вернуться в Empty.
/// [expectKeyboard] — true если после закрытия ожидается появление клавиатуры.
final class KeyboardPanel$Close extends KeyboardPanelEvent {
  const KeyboardPanel$Close({this.expectKeyboard = true});

  final bool expectKeyboard;

  @override
  List<Object?> get props => [expectKeyboard];
}

/// Поле ввода получило фокус — панель должна закрыться, клавиатура появится.
final class KeyboardPanel$FocusGained extends KeyboardPanelEvent {
  const KeyboardPanel$FocusGained();
}

/// Обновить сохранённую высоту клавиатуры.
final class KeyboardPanel$UpdateHeight extends KeyboardPanelEvent {
  const KeyboardPanel$UpdateHeight(this.height);

  final double height;

  @override
  List<Object?> get props => [height];
}
