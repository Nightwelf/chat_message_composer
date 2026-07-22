import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer_example/presentation/screens/current_chat_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Input Editor Example',
      theme: ThemeData(
        useMaterial3: true,
        extensions: [ChatEditorColorScheme.light()],
      ),
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
      ],
      home: const CurrentChatScreen(),
    );
  }
}
