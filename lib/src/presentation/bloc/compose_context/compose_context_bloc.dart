import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'compose_context_event.dart';

part 'compose_context_state.dart';

/// BLoC для управления compose-контекстом редактора (edit/quote/idle).
///
/// Потребитель устанавливает контекст через [ComposeContext$Set].
/// Пакет сбрасывает контекст через [ComposeContext$Clear] при отправке или отмене.
class ComposeContextBloc extends Bloc<ComposeContextEvent, ComposeContextState> {
  ComposeContextBloc({ChatMessageComposerComposeContext? initialContext})
      : super(ComposeContextState(composeContext: initialContext)) {
    on<ComposeContextEvent>(
      (event, emit) => switch (event) {
        ComposeContext$Set(:final context) => emit(
            ComposeContextState(
              composeContext: context,
              previousComposeContext: state.composeContext,
            ),
          ),
        ComposeContext$Clear() => emit(ComposeContextState(previousComposeContext: state.composeContext)),
      },
      transformer: sequential(),
    );
  }
}
