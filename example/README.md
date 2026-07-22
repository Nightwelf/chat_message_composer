# Пример использования chat_message_composer

Этот пример демонстрирует использование пакета `chat_message_composer` для создания редактора ввода текста в чате.

## Запуск на macOS

Для запуска примера на macOS выполните следующие команды:

```bash
cd example
flutter pub get
flutter run -d macos
```

Или откройте проект в Xcode:

```bash
open macos/Runner.xcworkspace
```

Затем запустите проект из Xcode (⌘R).

## Структура примера

- `main.dart` - точка входа приложения
- `current_chat.dart` - страница с примером использования ChatMessageComposer
- `hardcoded_localization_repository.dart` - пример реализации репозитория локализации
- `chat_message_card.dart` - виджет для отображения сообщений

## Что демонстрирует пример

Пример показывает:

1. **Настройку ChatMessageComposerScope** - как обернуть редактор в scope с репозиторием локализации
2. **Использование ChatMessageComposer** - базовое использование редактора с обработкой отправки сообщений
3. **Реализацию локализации** - пример реализации `ChatInputLocalizationRepository` с хардкодом русских строк
4. **Отображение сообщений** - как отображать отправленные сообщения с текстом и файлами

## Требования

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- macOS для запуска на Mac
