import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer/src/chat_message_composer/chat_message_composer_handlers.dart';
import 'package:chat_message_composer/src/domain/entities/mention_command.dart';
import 'package:chat_message_composer/src/presentation/bloc/compose_context/compose_context_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/mention_panel/mention_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRepo implements MentionRepository {
  @override
  Future<List<Mention>> getMentions(String query) async => const [];
}

/// Позволяет подменить состояние панели упоминаний для проверки handleEnterPressed.
class _StubMentionPanelBloc extends MentionPanelBloc {
  _StubMentionPanelBloc(this._stub)
      : super(mentionRepository: _StubRepo(), onCommand: _noop);

  final MentionPanelState _stub;

  static void _noop(MentionCommand _) {}

  @override
  MentionPanelState get state => _stub;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MessageFilesBloc filesBloc;
  late ComposeContextBloc composeBloc;
  late QuillController controller;

  setUp(() {
    filesBloc = MessageFilesBloc();
    composeBloc = ComposeContextBloc();
    controller = QuillController.basic()
      ..document.insert(0, 'hello');
  });

  tearDown(() async {
    await filesBloc.close();
    await composeBloc.close();
    controller.dispose();
  });

  ChatMessageComposerMessageData? send(MentionPanelState panelState) {
    ChatMessageComposerMessageData? sent;
    final panelBloc = _StubMentionPanelBloc(panelState);
    addTearDown(panelBloc.close);

    ChatMessageComposerHandlers.handleEnterPressed(
      controller: controller,
      messageFilesBloc: filesBloc,
      mentionPanelBloc: panelBloc,
      composeContextBloc: composeBloc,
      onSendTap: (message, action) => sent = message,
    );
    return sent;
  }

  test('Enter во время загрузки упоминаний НЕ отправляет', () {
    final sent = send(const MentionPanelState$Loading());
    expect(sent, isNull);
  });

  test('Enter при видимой панели с данными НЕ отправляет', () {
    final sent = send(const MentionPanelState$Data(
      mentions: [],
      selectedIndex: -1,
      query: '',
    ));
    expect(sent, isNull);
  });

  test('Enter без активной панели (Initial) отправляет', () {
    final sent = send(const MentionPanelState$Initial());
    expect(sent, isNotNull);
  });

  test('Enter при ошибке панели (Error, не видима) отправляет', () {
    final sent = send(const MentionPanelState$Error(error: 'boom'));
    expect(sent, isNotNull);
  });
}
