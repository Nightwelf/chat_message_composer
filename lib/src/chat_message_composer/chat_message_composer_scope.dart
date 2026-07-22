import 'package:chat_message_composer/src/data/models/chat_message_composer_compose_context.dart';
import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/domain/repositories/mention_repository.dart';
import 'package:chat_message_composer/src/flutter_quill_localizations_scope.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/keyboard_panel/keyboard_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/mention/mention_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Scope виджет для предоставления BLoC-ов и репозиториев дочерним виджетам.
///
/// Предоставляет:
/// - [ChatMessageComposerLocalizationRepository] для локализации
/// - [MentionRepository] для получения списка пользователей для упоминаний
/// - [ComposeContextBloc] для управления контекстом compose (edit/quote)
class ChatMessageComposerScope extends StatelessWidget {
  const ChatMessageComposerScope({
    required this.child,
    required this.localizationRepository,
    required this.mentionRepository,
    this.initialComposeContext,
    this.onFilesTooLarge,
    super.key,
  });

  final Widget child;
  final ChatMessageComposerLocalizationRepository localizationRepository;
  final MentionRepository mentionRepository;
  final ChatMessageComposerComposeContext? initialComposeContext;
  final void Function(List<String> fileNames)? onFilesTooLarge;

  @override
  Widget build(BuildContext context) {
    return FlutterQuillLocalizationsScope(
      child: Provider<ChatMessageComposerLocalizationRepository>.value(
        value: localizationRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<MessageFilesBloc>(create: (_) => MessageFilesBloc(onFilesTooLarge: onFilesTooLarge)),
            BlocProvider<ComposeContextBloc>(
              create: (_) =>
                  ComposeContextBloc(initialContext: initialComposeContext),
            ),
            BlocProvider<KeyboardPanelBloc>(create: (_) => KeyboardPanelBloc()),
          ],
          child: MentionScope(
            mentionRepository: mentionRepository,
            child: child,
          ),
        ),
      ),
    );
  }
}
