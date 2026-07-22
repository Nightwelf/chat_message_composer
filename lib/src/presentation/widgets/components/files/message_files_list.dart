import 'package:chat_message_composer/src/domain/entities/attached_file.dart';
import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/bloc/message_files/message_files_bloc.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart' as theme;
import 'package:chat_message_composer/src/presentation/widgets/components/files/file_widget_factory.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/files/trash_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Виджет для отображения списка файлов.
///
/// Отображает вертикальный список файлов с автоматическим переносом элементов
/// и возможностью удаления. Высота виджета динамически изменяется от 68 до 136 пикселей
/// в зависимости от количества элементов.
class MessageFilesList extends StatelessWidget {
  const MessageFilesList({
    this.clearButtonText,
    this.thumbnailSize = 38.0,
    this.cardColor,
    this.textColor,
    this.iconColor,
    this.padding,
    this.clearButtonStyle,
    this.trashPosition = TrashPosition.right,
    this.scrollDirection = Axis.vertical,
    this.fillThumbnail = false,
    super.key,
  });

  /// Текст кнопки удаления всех файлов.
  ///
  /// Если не указан, будет использоваться значение из [ChatMessageComposerLocalizationRepository] из контекста.
  final String? clearButtonText;

  /// Размер миниатюры для изображений.
  final double thumbnailSize;

  final bool fillThumbnail;

  /// Цвет фона карточки.
  final Color? cardColor;

  /// Цвет текста.
  final Color? textColor;

  /// Цвет иконки удаления.
  final Color? iconColor;

  /// Отступы внутри карточки.
  final EdgeInsets? padding;

  /// Стиль кнопки удаления всех файлов.
  final ButtonStyle? clearButtonStyle;

  /// Положение кнопки удаления.
  final TrashPosition? trashPosition;

  /// Направление прокрутки списка файлов.
  ///
  /// [Axis.vertical] — многострочный список с переносом (по умолчанию).
  /// [Axis.horizontal] — однострочный горизонтальный скролл.
  final Axis scrollDirection;

  static const double _minHorizontalHeight = 68;
  static const double _minVerticalHeight = 74;
  static const double _maxHeight = 136;

  List<Widget> _buildChildren(BuildContext context, List<AttachedFile> files) => [
        if (trashPosition == TrashPosition.left)
          TrashWidget(
            onTap: () {
              context.read<MessageFilesBloc>().add(const MessageFiles$Clear());
            },
          ),
        ...files.map((file) {
          return FileWidgetFactory.auto(
            key: ValueKey(file.id),
            params: FileTileParams(
              file: file,
              onTapClose: () {
                context.read<MessageFilesBloc>().add(MessageFiles$Remove(file.id));
              },
            ),
            filled: fillThumbnail,
          );
        }),
        if (trashPosition == TrashPosition.right)
          TrashWidget(
            onTap: () {
              context.read<MessageFilesBloc>().add(const MessageFiles$Clear());
            },
          ),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageFilesBloc, MessageFilesState>(
      builder: (context, state) {
        return switch (state) {
          MessageFilesState$Data(:final files) when files.isEmpty => const SizedBox.shrink(),
          MessageFilesState$Data(:final files) => scrollDirection == Axis.horizontal
              ? SizedBox(
                  height: _minVerticalHeight,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: theme.ChatEditorSpacing.px8),
                      child: Row(
                        spacing: theme.ChatEditorSpacing.px6,
                        children: _buildChildren(context, files),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(theme.ChatEditorSpacing.px8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: _minHorizontalHeight,
                        maxHeight: _maxHeight,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: Wrap(
                              spacing: theme.ChatEditorSpacing.px6,
                              runSpacing: theme.ChatEditorSpacing.px6,
                              children: _buildChildren(context, files),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
        };
      },
    );
  }
}

enum TrashPosition {
  left,
  right,
}
