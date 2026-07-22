import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_message_composer/src/domain/entities/mention_command.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mention_command_event.dart';
part 'mention_command_state.dart';

/// BLoC для управления командами модификации документа.
///
/// Получает команды через события и держит состояние PendingCommand
/// пока виджет не подтвердит выполнение через CommandProcessed.
class MentionCommandBloc
    extends Bloc<MentionCommandEvent, MentionCommandState> {
  MentionCommandBloc() : super(const MentionCommandState$Idle()) {
    on<MentionCommandEvent>(
      (event, emit) => switch (event) {
        MentionCommandEvent$Requested(:final command) =>
          _onRequested(command, emit),
        MentionCommandEvent$Processed() => _onProcessed(emit),
      },
      transformer: sequential(),
    );
  }

  void _onRequested(
    MentionCommand command,
    Emitter<MentionCommandState> emit,
  ) {
    emit(MentionCommandState$Pending(command: command));
  }

  void _onProcessed(Emitter<MentionCommandState> emit) {
    emit(const MentionCommandState$Idle());
  }
}
