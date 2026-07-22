import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer_example/data/datasources/mention_datasource.dart';
import 'package:chat_message_composer_example/data/hardcoded_localization_repository.dart';
import 'package:chat_message_composer_example/data/repositories/chat_messages_local_repository.dart';
import 'package:chat_message_composer_example/data/repositories/mention_repository_impl.dart';
import 'package:chat_message_composer_example/domain/entities/chat_message.dart';
import 'package:chat_message_composer_example/domain/entities/example_quoted_author.dart';
import 'package:chat_message_composer_example/presentation/screens/drag_auto_scroll_demo.dart';
import 'package:chat_message_composer_example/presentation/utils/mention_config.dart';
import 'package:chat_message_composer_example/presentation/widgets/chat_message_card.dart';
import 'package:flutter/material.dart';

class CurrentChatScreen extends StatefulWidget {
  const CurrentChatScreen({super.key});

  @override
  State<CurrentChatScreen> createState() => _CurrentChatScreenState();
}

class _CurrentChatScreenState extends State<CurrentChatScreen> with WidgetsBindingObserver {
  List<ChatMessage> _messages = [];
  final _localizationRepository = const HardcodedLocalizationRepository();
  final _messagesRepository = const ChatMessagesLocalRepository();
  final ScrollController _scrollController = ScrollController();
  final _simpleInputController = SimpleTextInputController();

  bool _isPlatformMobile = false;
  bool _useSimpleInput = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMessages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      Future.microtask(_saveMessages);
    }
  }

  @override
  void dispose() {
    _simpleInputController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Future.microtask(_saveMessages);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final loaded = await _messagesRepository.load();
    if (loaded.isEmpty || !mounted) return;
    setState(() {
      _messages = loaded.map<ChatMessage>((data) => StandardUserMessage(data: data)).toList();
    });
    _scrollToBottom();
  }

  Future<void> _saveMessages() async {
    final data = _messages
        .whereType<StandardUserMessage>()
        .map((message) => message.data)
        .whereType<ChatMessageComposerMessageData>()
        .toList();
    await _messagesRepository.save(data);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSendTap(ChatMessageComposerMessageData message, ChatMessageComposerSendAction action) {
    setState(() {
      switch (action) {
        case ChatMessageComposerSendActionEdit(:final messageId):
          final index = int.tryParse(messageId);
          if (index != null && index >= 0 && index < _messages.length) {
            _messages[index] = StandardUserMessage(data: message);
          }

        case ChatMessageComposerSendActionQuote(quoteToMessageId: final replyToMessageId):
          final index = int.tryParse(replyToMessageId);
          ChatMessageComposerMessageData? replyData;
          if (index != null && index >= 0 && index < _messages.length) {
            final original = _messages[index];
            if (original is UserMessage) replyData = original.data;
          }
          _messages.add(ReplyUserMessage(data: message, replyData: replyData));
        case _:
          _messages.add(StandardUserMessage(data: message));
      }
    });
    Future.microtask(_saveMessages);
    _scrollToBottom();
  }

  void _onSimpleSendTap(Document document) {
    setState(() {
      _messages.add(StandardUserMessage(
        data: ChatMessageComposerMessageData(document: document, files: const []),
      ));
    });
    Future.microtask(_saveMessages);
    _scrollToBottom();
  }

  Widget _buildMessageList(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 920),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              switch (message) {
                case StandardUserMessage(:final data):
                  if (data == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: ChatEditorSpacing.px8),
                    child: Align(
                      alignment: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
                      child: ChatMessageCard(
                        message: data,
                        messageId: index.toString(),
                        onEdit: context.setChatInputEditingContext,
                        onReply: (id, msg) => context.setChatInputReplyContext(
                            id: id, message: msg, author: const ExampleQuotedAuthor()),
                        onQuote: (id, msg) => context.setChatInputQuotingContext(
                            id: id, message: msg, author: const ExampleQuotedAuthor()),
                      ),
                    ),
                  );
                case ReplyUserMessage(:final data, :final replyData):
                  if (data == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: ChatEditorSpacing.px8),
                    child: Align(
                      alignment: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
                      child: ChatMessageCard(
                        message: data,
                        messageId: index.toString(),
                        replyData: replyData,
                        onEdit: context.setChatInputEditingContext,
                        onReply: (id, msg) => context.setChatInputReplyContext(
                            id: id, message: msg, author: const ExampleQuotedAuthor()),
                        onQuote: (id, msg) => context.setChatInputQuotingContext(
                            id: id, message: msg, author: const ExampleQuotedAuthor()),
                      ),
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: !_isPlatformMobile,
      body: Stack(
        children: [
          Center(
            child: _useSimpleInput ? _buildSimpleInputLayout(context) : _buildFullEditorLayout(context),
          ),
          SafeArea(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _isPlatformMobile = !_isPlatformMobile),
                  child: Text(_isPlatformMobile ? 'Mobile' : 'Desktop'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _useSimpleInput = !_useSimpleInput),
                  child: Text(_useSimpleInput ? 'Simple' : 'Full'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DragAutoScrollDemo(),
                    ),
                  ),
                  child: const Text('Drag autoscroll demo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInputLayout(BuildContext context) {
    return SimpleTextInputScope(
      localizationRepository: _localizationRepository,
      child: Column(
        children: [
          _buildMessageList(context),
          SimpleTextInput(
            controller: _simpleInputController,
            isPlatformMobile: _isPlatformMobile,
            onSendTap: _onSimpleSendTap,
          ),
        ],
      ),
    );
  }

  Widget _buildFullEditorLayout(BuildContext context) {
    return ChatMessageComposerScope(
      localizationRepository: _localizationRepository,
      mentionRepository: MentionRepositoryImpl(dataSource: MentionDataSource()),
      child: Builder(
        builder: (context) => Column(
          children: [
            _buildMessageList(context),
            ChatMessageComposer(
              autofocus: false,
              isPlatformMobile: _isPlatformMobile,
              useKeyboardReplacement: _isPlatformMobile,
              disableMentions: false,
              onSendTap: _onSendTap,
              onMentionTap: (mention) => debugPrint('Mention tapped: $mention'),
              onMentionLongTap: (mention) => debugPrint('Mention long tapped: $mention'),
              rqMentionConfig: buildMentionConfig(context),
              onFocusChanged: (hasFocus, _) => debugPrint('Has focus: $hasFocus'),
            ),
          ],
        ),
      ),
    );
  }
}
