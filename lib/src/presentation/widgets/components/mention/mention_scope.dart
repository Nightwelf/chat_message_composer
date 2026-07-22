import 'package:chat_message_composer/src/domain/repositories/mention_repository.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_command/mention_command_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scope для mention-подсистемы.
///
/// Регистрирует [MentionCommandBloc] и [MentionPanelBloc] в правильном порядке:
/// [MentionCommandBloc] должен быть выше [MentionPanelBloc] в дереве,
/// так как [MentionPanelBloc] обращается к нему через колбэк в момент создания.
class MentionScope extends StatelessWidget {
  const MentionScope({
    required this.mentionRepository,
    required this.child,
    super.key,
  });

  final MentionRepository mentionRepository;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MentionCommandBloc>(create: (_) => MentionCommandBloc()),
        BlocProvider<MentionPanelBloc>(
          create: (context) => MentionPanelBloc(
            mentionRepository: mentionRepository,
            onCommand: (command) => context.read<MentionCommandBloc>().add(
                  MentionCommandEvent$Requested(command: command),
                ),
          ),
        ),
      ],
      child: child,
    );
  }
}
