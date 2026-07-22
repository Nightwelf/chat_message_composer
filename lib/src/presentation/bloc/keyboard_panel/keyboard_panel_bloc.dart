import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'keyboard_panel_event.dart';
part 'keyboard_panel_state.dart';

/// BLoC для управления панелью, заменяющей клавиатуру на мобильных устройствах.
///
/// Хранит актуальную высоту клавиатуры и управляет отображением панели.
/// Состояние [KeyboardPanelState$Empty] — клавиатура может быть показана.
/// Состояние [KeyboardPanelState$Emoji] — панель эмодзи показана, клавиатура скрыта.
class KeyboardPanelBloc extends Bloc<KeyboardPanelEvent, KeyboardPanelState> {
  KeyboardPanelBloc()
      : super(const KeyboardPanelState$Empty(
            lastKnownHeight: _defaultEmojiPanelHeight)) {
    on<KeyboardPanel$ShowEmoji>(_onShowEmoji, transformer: droppable());
    on<KeyboardPanel$Close>(_onClose, transformer: droppable());
    on<KeyboardPanel$FocusGained>(_onFocusGained, transformer: droppable());
    on<KeyboardPanel$UpdateHeight>(_onUpdateHeight, transformer: droppable());
  }

  static const double _defaultEmojiPanelHeight = 280;

  void _onShowEmoji(
      KeyboardPanel$ShowEmoji event, Emitter<KeyboardPanelState> emit) {
    if (state is KeyboardPanelState$Emoji) return;
    final height = state.lastKnownHeight > 0
        ? state.lastKnownHeight
        : _defaultEmojiPanelHeight;
    emit(KeyboardPanelState$Emoji(lastKnownHeight: height));
  }

  void _onClose(KeyboardPanel$Close event, Emitter<KeyboardPanelState> emit) {
    emit(KeyboardPanelState$Empty(
        lastKnownHeight: state.lastKnownHeight,
        expectKeyboard: event.expectKeyboard));
  }

  void _onFocusGained(
      KeyboardPanel$FocusGained event, Emitter<KeyboardPanelState> emit) {
    // Ignore programmatic focus events (e.g. from emoji insertion) while emoji
    // panel is open. Explicit user tap on the input field is handled via
    // KeyboardPanel$Close dispatched from the Listener in the mobile layout.
    if (state is KeyboardPanelState$Emoji) return;
    emit(KeyboardPanelState$Empty(lastKnownHeight: state.lastKnownHeight));
  }

  void _onUpdateHeight(
      KeyboardPanel$UpdateHeight event, Emitter<KeyboardPanelState> emit) {
    if (state is! KeyboardPanelState$Empty) return;
    if (event.height == 0) return; // не сбрасываем при закрытии клавиатуры
    if (event.height == state.lastKnownHeight) return;
    emit(KeyboardPanelState$Empty(lastKnownHeight: event.height));
  }
}
