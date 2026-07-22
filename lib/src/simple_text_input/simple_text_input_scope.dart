import 'package:chat_message_composer/chat_message_composer.dart' show SimpleTextInput;
import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/flutter_quill_localizations_scope.dart';
import 'package:chat_message_composer/src/presentation/bloc/keyboard_panel/keyboard_panel_bloc.dart';
import 'package:chat_message_composer/src/simple_text_input/simple_text_input.dart'
    show SimpleTextInput;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scope для [SimpleTextInput].
///
/// Предоставляет [ChatMessageComposerLocalizationRepository] и [KeyboardPanelBloc] (для мобильного
/// режима замены клавиатуры панелью эмодзи) дочернему дереву.
class SimpleTextInputScope extends StatelessWidget {
  const SimpleTextInputScope({
    required this.localizationRepository,
    required this.child,
    super.key,
  });

  final ChatMessageComposerLocalizationRepository localizationRepository;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ChatMessageComposerLocalizationRepository>.value(
      value: localizationRepository,
      child: BlocProvider<KeyboardPanelBloc>(
        create: (_) => KeyboardPanelBloc(),
        child: FlutterQuillLocalizationsScope(child: child),
      ),
    );
  }
}
