part of 'compose_context_bloc.dart';

/// События управления compose-контекстом редактора.
sealed class ComposeContextEvent extends Equatable {
  const ComposeContextEvent();

  @override
  List<Object?> get props => [];
}

/// Установить контекст (edit/quote/idle/reply).
final class ComposeContext$Set extends ComposeContextEvent {
  const ComposeContext$Set(this.context);

  final ChatMessageComposerComposeContext context;

  @override
  List<Object?> get props => [context];
}

/// Сбросить контекст (после отправки или отмены).
final class ComposeContext$Clear extends ComposeContextEvent {
  const ComposeContext$Clear();
}
