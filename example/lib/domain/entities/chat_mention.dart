import 'package:delta_text_view/delta_text_view.dart';
import 'package:equatable/equatable.dart';

/// Упоминание пользователя в сообщении чата.
class ChatMention extends Equatable implements MentionDelta {
  const ChatMention({
    required this.id,
    required this.name,
    this.avatar,
    this.nickname,
  });

  @override
  String get displayData => name;

  final String id;
  final String name;
  final String? avatar;
  final String? nickname;

  factory ChatMention.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    if (id == null || name == null) {
      throw ArgumentError('ChatMention requires both id and name');
    }
    return ChatMention(
      id: id,
      name: name,
      avatar: json['avatar'] as String?,
      nickname: json['nickname'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (avatar != null) 'avatar': avatar,
        if (nickname != null) 'nickname': nickname,
      };

  @override
  List<Object?> get props => [id, name, avatar, nickname];
}
