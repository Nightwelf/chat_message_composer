part of 'keyboard_panel_bloc.dart';

sealed class KeyboardPanelState extends Equatable {
  const KeyboardPanelState({required this.lastKnownHeight});

  /// Последняя известная высота клавиатуры. Сохраняется при смене состояний.
  final double lastKnownHeight;

  @override
  List<Object?> get props => [lastKnownHeight];
}

/// Панель не отображается. Клавиатура может быть показана.
final class KeyboardPanelState$Empty extends KeyboardPanelState {
  const KeyboardPanelState$Empty(
      {required super.lastKnownHeight, this.expectKeyboard = true});

  /// Ожидается ли появление клавиатуры после закрытия панели.
  final bool expectKeyboard;

  @override
  List<Object?> get props => [...super.props, expectKeyboard];
}

/// Показана панель эмодзи. Клавиатура скрыта.
final class KeyboardPanelState$Emoji extends KeyboardPanelState {
  const KeyboardPanelState$Emoji({required super.lastKnownHeight});
}
