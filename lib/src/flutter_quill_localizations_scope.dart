import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Scope для добавления FlutterQuill локализации к существующим делегатам
/// Получает делегаты из контекста выше по дереву и добавляет к ним FlutterQuill делегат
class FlutterQuillLocalizationsScope extends StatelessWidget {
  const FlutterQuillLocalizationsScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final existingDelegates = _getDelegatesFromContext(context);
        final allDelegates = [
          ...existingDelegates,
          FlutterQuillLocalizations.delegate,
        ];

        return Localizations.override(
          context: context,
          delegates: allDelegates,
          child: child,
        );
      },
    );
  }

  List<LocalizationsDelegate<dynamic>> _getDelegatesFromContext(
    BuildContext context,
  ) {
    MaterialApp? materialApp;
    context.visitAncestorElements((element) {
      if (element.widget is MaterialApp) {
        materialApp = element.widget as MaterialApp;
        return false;
      }
      return true;
    });

    if (materialApp != null && materialApp!.localizationsDelegates != null) {
      return List<LocalizationsDelegate<dynamic>>.from(
        materialApp!.localizationsDelegates!,
      );
    }

    return <LocalizationsDelegate<dynamic>>[];
  }
}
