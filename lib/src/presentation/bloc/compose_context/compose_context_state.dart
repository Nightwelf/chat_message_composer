part of 'compose_context_bloc.dart';

/// Состояние compose-контекста редактора.
class ComposeContextState extends Equatable {
  const ComposeContextState({this.composeContext, this.previousComposeContext});

  final ChatMessageComposerComposeContext? composeContext;
  final ChatMessageComposerComposeContext? previousComposeContext;

  @override
  List<Object?> get props => [composeContext, previousComposeContext];
}
