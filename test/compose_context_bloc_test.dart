import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComposeContextBloc.previousComposeContext', () {
    test('заполняется при Set и при Clear (надёжный контракт 1.3)', () async {
      const a = ChatMessageComposerComposeContextIdle();
      final b = ChatMessageComposerComposeContextEditing(
        messageId: '1',
        originalDocument: Document(),
      );

      final bloc = ComposeContextBloc();
      addTearDown(bloc.close);

      final states = <ComposeContextState>[];
      final sub = bloc.stream.listen(states.add);

      bloc
        ..add(const ComposeContext$Set(a))
        ..add(ComposeContext$Set(b))
        ..add(const ComposeContext$Clear());

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states, hasLength(3));

      // Set(A): previous пуст (исходный composeContext был null)
      expect(states[0].composeContext, a);
      expect(states[0].previousComposeContext, isNull);

      // Set(B): previous == A (раньше заполнялся только при Clear)
      expect(states[1].composeContext, b);
      expect(states[1].previousComposeContext, a);

      // Clear: composeContext == null, previous == B
      expect(states[2].composeContext, isNull);
      expect(states[2].previousComposeContext, b);
    });
  });
}
