import 'package:chat_message_composer/src/domain/entities/mention_embed.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Callback для обработки нажатий на упоминание.
typedef MentionTapCallback = void Function(MentionEmbed mention);

/// Строитель виджетов для отображения embed-объектов упоминаний в QuillEditor.
class MentionEmbedBuilder {
  /// Создает список embed builders для всех типов упоминаний.
  ///
  /// [onMentionTap] - callback, вызываемый при нажатии на упоминание.
  /// [onMentionLongTap] - callback, вызываемый при долгом нажатии на упоминание.
  static List<EmbedBuilder> createBuilders({
    MentionTapCallback? onMentionTap,
    MentionTapCallback? onMentionLongTap,
  }) {
    return [
      const MentionInputEmbedBuilder(),
      MentionFinalEmbedBuilder(
        onTap: onMentionTap,
        onLongTap: onMentionLongTap,
      ),
    ];
  }
}

/// Builder для временного embed-объекта ввода упоминания.
class MentionInputEmbedBuilder implements EmbedBuilder {
  const MentionInputEmbedBuilder();

  @override
  String get key => mentionInputType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final embeddable = embedContext.node.value;
    return _MentionEmbedBuilderHelper.buildMentionInput(
      context: context,
      embed: embeddable,
      readOnly: embedContext.readOnly,
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(
      child: widget,
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
    );
  }

  @override
  String toPlainText(Embed node) {
    return '@';
  }

  @override
  bool get expanded => false;
}

/// Builder для финального embed-объекта упоминания.
class MentionFinalEmbedBuilder implements EmbedBuilder {
  /// Создает builder для финального упоминания.
  ///
  /// [onTap] - callback при нажатии на упоминание.
  /// [onLongTap] - callback при долгом нажатии на упоминание.
  const MentionFinalEmbedBuilder({
    this.onTap,
    this.onLongTap,
  });

  /// Callback при нажатии на упоминание.
  final MentionTapCallback? onTap;

  /// Callback при долгом нажатии на упоминание.
  final MentionTapCallback? onLongTap;

  @override
  String get key => mentionType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final embeddable = embedContext.node.value;
    return _MentionEmbedBuilderHelper.buildMention(
      context: context,
      embed: embeddable,
      readOnly: embedContext.readOnly,
      onTap: onTap,
      onLongTap: onLongTap,
    );
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(
      child: widget,
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
    );
  }

  @override
  String toPlainText(Embed node) {
    final embeddable = node.value;
    final data = embeddable.data;
    if (data is Map<String, dynamic>) {
      final name = data['name'] as String? ?? '';
      return '@$name';
    }
    return '@';
  }

  @override
  bool get expanded => false;
}

/// Вспомогательный класс для создания виджетов упоминаний.
class _MentionEmbedBuilderHelper {
  /// Создает виджет для отображения временного embed-объекта ввода упоминания.
  ///
  /// Показывает индикатор ввода (например, "@" с подчеркиванием).
  static Widget buildMentionInput({
    required BuildContext context,
    required Embeddable embed,
    required bool readOnly,
  }) {
    final data = embed.data;
    var query = '';
    if (data is Map<String, dynamic>) {
      query = data['query'] as String? ?? '';
    }
    return Text(
      '@$query',
      style: ChatEditorTypography.body.r16_24.copyWith(letterSpacing: 0, color: context.chatColors.textPrimary),
    );
  }

  /// Создает виджет для отображения финального embed-объекта упоминания.
  ///
  /// Отображает имя пользователя в специальном стиле (например, синий цвет).
  /// [onTap] - callback при нажатии на упоминание.
  /// [onLongTap] - callback при долгом нажатии на упоминание.
  static Widget buildMention({
    required BuildContext context,
    required Embeddable embed,
    required bool readOnly,
    MentionTapCallback? onTap,
    MentionTapCallback? onLongTap,
  }) {
    final data = embed.data;
    var id = '';
    var name = '';
    String? avatar;
    String? nickname;
    Object? additional;
    if (data is Map<String, dynamic>) {
      id = data['id'] as String? ?? '';
      name = data['name'] as String? ?? '';
      avatar = data['avatar'] as String?;
      nickname = data['nickname'] as String?;
      additional = data['additional'];
    }

    final mentionEmbed = MentionEmbed(
      id: id,
      name: name,
      avatar: avatar,
      nickname: nickname,
      additional: additional,
    );

    Widget child = Text(
      '@$name',
      style: ChatEditorTypography.body.r16_24.copyWith(letterSpacing: 0, color: context.chatColors.brandDefault),
    );

    if (onTap != null || onLongTap != null) {
      child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap != null ? () => onTap(mentionEmbed) : null,
          onLongPress: onLongTap != null ? () => onLongTap(mentionEmbed) : null,
          child: child,
        ),
      );
    }

    return child;
  }
}
