# chat_message_composer

Редактор сообщений для чата с поддержкой форматирования текста и вставки файлов.

## Описание

`chat_message_composer` — это Flutter пакет, предоставляющий полнофункциональный редактор текста для чата с поддержкой:

- **Форматирования текста**: жирный, курсив, подчеркивание, зачеркивание, списки, цитаты, блоки кода, ссылки
- **Вложений**: изображения, видео и документы — выбор файлов, drag-and-drop (desktop), вставка из буфера обмена, съёмка фото с камеры
- **Упоминаний**: панель «@» с поиском и навигацией стрелками
- **Режимов composing**: обычный ввод, редактирование и цитирование/ответ на сообщение
- **Эмодзи**: поиск и вставка, включая замену клавиатуры на панель эмодзи на мобильных устройствах
- **Интуитивного интерфейса**: панель инструментов, кнопки управления и визуальное отображение прикрепленных файлов

## Установка

Добавьте зависимость в ваш `pubspec.yaml`:

```yaml
dependencies:
  chat_message_composer: ^1.0.0
```

Затем выполните:

```bash
flutter pub get
```

## Настройка платформ

### iOS

Для использования камеры и выбора изображений из библиотеки на iOS необходимо добавить следующие ключи в файл `Info.plist` (расположен в `<project root>/ios/Runner/Info.plist`):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Приложению необходим доступ к библиотеке фотографий для выбора изображений</string>

<key>NSCameraUsageDescription</key>
<string>Приложению необходим доступ к камере для съемки фотографий</string>
```

### Android

На Android дополнительная настройка не требуется — плагин работает из коробки.

## Быстрый старт

### 1. Реализуйте репозиторий локализации

Создайте класс, реализующий `ChatMessageComposerLocalizationRepository`:

```dart
import 'package:chat_message_composer/chat_message_composer.dart';

class MyLocalizationRepository implements ChatMessageComposerLocalizationRepository {
  @override
  String get camera => 'Камера';

  @override
  String get messageText => 'Введите сообщение...';

  @override
  String get insertImageOrVideo => 'Вставить изображение или видео';

  @override
  String get insertDocument => 'Вставить документ';

  @override
  String get attachContact => 'Прикрепить контакт';

  @override
  String get createPoll => 'Новый опрос';

  @override
  String get createEvent => 'Запланировать событие';

  @override
  String get editingMessage => 'Редактирование сообщения';

  @override
  String get filesLabel => 'Файлы';

  @override
  String mentionPanelError(String error) => 'Ошибка: $error';

  @override
  String get mentionPanelNoUsersFound => 'Пользователи не найдены';

  @override
  String get emojiNotFound => 'Эмодзи не найдены';

  @override
  String get emojiSearch => 'Поиск';
}
```

### 2. Используйте ChatMessageComposer

Оберните `ChatMessageComposer` в `ChatMessageComposerScope`:

```dart
import 'package:flutter/material.dart';
import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationRepository = MyLocalizationRepository();

    return Scaffold(
      body: ChatMessageComposerScope(
        localizationRepository: localizationRepository,
        mentionRepository: mentionRepository, // реализация MentionRepository
        child: ChatMessageComposer(
          onSendTap: (ChatMessageComposerMessageData message, ChatMessageComposerSendAction action) {
            final text = message.document.toPlainText();
            final files = message.files;
            print('Отправлено: $text, файлов: ${files.length}');
          },
        ),
      ),
    );
  }
}
```

### 3. Настройте локализацию (опционально)

Если вы используете `flutter_localizations`, добавьте делегат для `FlutterQuillLocalizations`:

```dart
MaterialApp(
  localizationsDelegates: const [
    FlutterQuillLocalizations.delegate,
    // ... другие делегаты
  ],
  // ...
)
```

## Основные компоненты

### ChatMessageComposer

Основной виджет редактора сообщений.

**Параметры:**

- `onSendTap` — callback при нажатии на кнопку отправки. Получает `ChatMessageComposerMessageData` и `ChatMessageComposerSendAction` (Send / Edit / Quote)
- `isPlatformMobile` — использовать мобильный или десктопный layout
- `disableMentions` — отключение упоминаний «@» (по умолчанию `false`, т.е. упоминания включены)
- `initialFiles`, `initialComposeContext` — восстановление черновика (текст/файлы/режим composing)
- `desktopMessageInputMaxHeight`, `mobileMessageInputMaxHeight` — ограничение высоты поля ввода
- `useKeyboardReplacement` — панель эмодзи заменяет клавиатуру на мобильных устройствах вместо открытия поверх неё

> В меню "+" есть пункты «Контакт», «Опрос» и «Событие» (иконки, локализация `attachContact`/`createPoll`/`createEvent`), но их обработчики (`onContactTap`/`onPollTap`/`onEventTap`) в пакете — пустые заглушки, реальная логика не реализована ни в пакете, ни в `example/`.

**Особенности:**

- Автоматически очищается после отправки; контекст compose (режим редактирования/цитирования) сбрасывается через [ComposeContextBloc]
- Кнопка отправки активируется при наличии текста или файлов
- Поддержка отправки по Enter
- Отображение прикрепленных файлов

### ComposeContextBloc

BLoC для режима ввода: обычный ввод, редактирование сообщения или цитирование. Предоставляется через [ChatMessageComposerScope].

- Установка контекста: `context.read<ComposeContextBloc>().add(ComposeContext$Set(контекст))`
- Сброс выполняется пакетом при отправке или при нажатии «Отмена» в UI
- Типы контекста: [ChatMessageComposerComposeContextIdle], [ChatMessageComposerComposeContextEditing], [ChatMessageComposerComposeContextQuoting]

### ChatMessageComposerScope

Scope виджет для предоставления зависимостей дочерним виджетам.

**Параметры:**

- `localizationRepository` — репозиторий для локализованных строк
- `mentionRepository` — репозиторий для списка пользователей при вводе «@»
- `initialComposeContext` (опционально) — начальный контекст compose при первом отображении
- `onFilesTooLarge` (опционально) — колбэк, вызываемый при попытке прикрепить файл размером более 50 МБ
- `child` — дочерний виджет, обычно `ChatMessageComposer`

### ChatMessageComposerMessageData

Класс для представления сообщения чата.

**Поля:**

- `document` — `Document` из `flutter_quill` с форматированным текстом
- `files` — список `XFile` с прикрепленными файлами
- `fileDimensions` — размеры изображений среди файлов (`Map<String, Size>`, путь → размер)

Контекст composing (режим edit/quote) на момент отправки передаётся отдельно — вторым параметром колбэка `onSendTap` через `ChatMessageComposerSendAction`.

## Пример использования

Полный пример использования доступен в папке `example/`. Для запуска примера:

```bash
cd example
flutter pub get
flutter run -d macos
```

## Требования

- Flutter SDK >= 3.44.5
- Dart SDK >= 3.0.0

## Зависимости

- `flutter_quill` — редактор текста с форматированием
- `flutter_bloc` — управление состоянием
- `file_picker` — выбор файлов
- `cross_file` — кроссплатформенная работа с файлами
- `camera` — съёмка фото/видео
- `emoji_picker_flutter` — панель эмодзи
- `desktop_drop` — drag-and-drop файлов на десктопе
- `pasteboard` — вставка файлов из буфера обмена
- `delta_text_view` — рендер `flutter_quill`-контента вне редактора (превью цитаты и т.д.)

## Лицензия

См. файл [LICENSE](LICENSE) для подробностей.

