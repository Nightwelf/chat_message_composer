part of 'mention_command_bloc.dart';

/// Базовый класс для состояний MentionCommandBloc.
sealed class MentionCommandState extends Equatable {
  const MentionCommandState();

  @override
  List<Object?> get props => [];
}

/// Нет активной команды.
final class MentionCommandState$Idle extends MentionCommandState {
  const MentionCommandState$Idle();
}

/// Команда ожидает выполнения.
final class MentionCommandState$Pending extends MentionCommandState {
  const MentionCommandState$Pending({required this.command});

  final MentionCommand command;

  @override
  List<Object?> get props => [command];
}
