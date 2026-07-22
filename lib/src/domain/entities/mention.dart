import 'package:equatable/equatable.dart';

/// Сущность для представления упоминания пользователя в чате.
///
/// Содержит информацию о пользователе, которого можно упомянуть через @.
class Mention extends Equatable {
  /// Создает объект упоминания пользователя.
  ///
  /// [id] - уникальный идентификатор пользователя.
  /// [name] - отображаемое имя пользователя.
  /// [avatar] - опциональный URL аватара пользователя.
  /// [nickname] - опциональный ник пользователя.
  /// [additional] - опциональный дополнительные сведения пользователя.
  ///
  const Mention({
    required this.id,
    required this.name,
    this.avatar,
    this.nickname,
    this.additional,
  });

  /// Уникальный идентификатор пользователя.
  final String id;

  /// Отображаемое имя пользователя.
  final String name;

  /// Опциональный URL аватара пользователя.
  final String? avatar;

  /// Ник
  final String? nickname;

  /// дополнительна информация, может потребоваться потом
  final Object? additional;

  @override
  List<Object?> get props => [id, name, avatar, nickname, additional];
}
