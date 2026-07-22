part of 'mention_command_bloc.dart';

/// Базовый класс для событий MentionCommandBloc.
sealed class MentionCommandEvent extends Equatable {
  const MentionCommandEvent();

  @override
  List<Object?> get props => [];
}

/// Запрос на выполнение команды (от репозитория).
final class MentionCommandEvent$Requested extends MentionCommandEvent {
  const MentionCommandEvent$Requested({required this.command});

  final MentionCommand command;

  @override
  List<Object?> get props => [command];
}

/// Подтверждение выполнения команды (от виджета).
final class MentionCommandEvent$Processed extends MentionCommandEvent {
  const MentionCommandEvent$Processed();
}
