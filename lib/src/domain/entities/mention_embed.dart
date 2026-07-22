import 'package:equatable/equatable.dart';

/// Тип embed для временного состояния ввода упоминания.
const String mentionInputType = 'mention_input';

/// Тип embed для финального упоминания пользователя.
const String mentionType = 'mention';

/// Временный embed-объект при вводе '@' для упоминания.
///
/// Используется для отслеживания активного ввода упоминания и показа панели выбора.
class MentionInputEmbed extends Equatable {
  /// Создает embed-объект для ввода упоминания.
  ///
  /// [query] - текущий запрос для фильтрации пользователей.
  const MentionInputEmbed({
    required this.query,
  });

  /// Создает MentionInputEmbed из Delta операции.
  factory MentionInputEmbed.fromDelta(dynamic data) {
    if (data is Map<String, dynamic>) {
      return MentionInputEmbed(
        query: data['query'] as String? ?? '',
      );
    }
    return const MentionInputEmbed(query: '');
  }

  /// Создает MentionInputEmbed из JSON.
  factory MentionInputEmbed.fromJson(Map<String, dynamic> json) {
    return MentionInputEmbed(
      query: json['query'] as String? ?? '',
    );
  }

  /// Текущий запрос для фильтрации пользователей.
  final String query;

  /// Преобразует MentionInputEmbed в JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': mentionInputType,
      'query': query,
    };
  }

  /// Преобразует MentionInputEmbed в формат Delta операции (для insert).
  Map<String, dynamic> toDeltaInsert() {
    return {
      mentionInputType: {
        'query': query,
      },
    };
  }

  @override
  String toString() => '@$query';

  @override
  List<Object?> get props => [query];
}

/// Финальный embed-объект с данными упоминания пользователя.
///
/// Используется для отображения выбранного упоминания в документе.
class MentionEmbed extends Equatable {
  /// Создает embed-объект для упоминания пользователя.
  ///
  /// [id] - уникальный идентификатор пользователя.
  /// [name] - отображаемое имя пользователя.
  /// [avatar] - опциональный URL аватара пользователя.
  /// [nickname] - опциональный ник пользователя.
  /// [additional] - опциональные дополнительные сведения пользователя.
  const MentionEmbed({
    required this.id,
    required this.name,
    this.avatar,
    this.nickname,
    this.additional,
  });

  /// Создает MentionEmbed из JSON.
  factory MentionEmbed.fromJson(Map<String, dynamic> json) {
    return MentionEmbed(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      nickname: json['nickname'] as String?,
      additional: json['additional'],
    );
  }

  /// Создает MentionEmbed из Delta операции.
  factory MentionEmbed.fromDelta(dynamic data) {
    if (data is Map<String, dynamic>) {
      return MentionEmbed(
        id: data['id'] as String,
        name: data['name'] as String,
        avatar: data['avatar'] as String?,
        nickname: data['nickname'] as String?,
        additional: data['additional'],
      );
    }
    throw ArgumentError('Invalid data for MentionEmbed');
  }

  /// Уникальный идентификатор пользователя.
  final String id;

  /// Отображаемое имя пользователя.
  final String name;

  /// Опциональный URL аватара пользователя.
  final String? avatar;

  /// Опциональный ник пользователя.
  final String? nickname;

  /// Опциональные дополнительные сведения пользователя.
  final Object? additional;

  /// Преобразует MentionEmbed в JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': mentionType,
      'id': id,
      'name': name,
      if (avatar != null) 'avatar': avatar,
      if (nickname != null) 'nickname': nickname,
      if (additional != null) 'additional': additional,
    };
  }

  /// Преобразует MentionEmbed в формат Delta операции (для insert).
  Map<String, dynamic> toDeltaInsert() {
    return {
      mentionType: {
        'id': id,
        'name': name,
        if (avatar != null) 'avatar': avatar,
        if (nickname != null) 'nickname': nickname,
        if (additional != null) 'additional': additional,
      },
    };
  }

  @override
  String toString() => '@$name';

  @override
  List<Object?> get props => [id, name, avatar, nickname, additional];
}
