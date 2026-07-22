import 'package:chat_message_composer/chat_message_composer.dart';

/// Моковый источник данных для упоминаний пользователей.
///
/// Предоставляет предопределенный список пользователей для тестирования
/// функциональности MentionPanel.
class MentionDataSource {
  /// Предопределенный список пользователей для тестирования.
  static const List<Mention> _mockMentions = [

    Mention(id: '111111111', name: 'Alexander Ivanov', nickname: 'alex_ivanov1', avatar: 'https://i.pravatar.cc/150?u=1  '),
    Mention(id: '111111112', name: 'Maria Petrova', nickname: 'maria_p1', avatar: 'https://i.pravatar.cc/150?u=2  '),
    Mention(id: '111111113', name: 'Dmitry Sidorov', nickname: 'dmitry_s1', avatar: 'https://i.pravatar.cc/150?u=3  '),
    Mention(id: '111111114', name: 'Anna Kozlova', nickname: 'anna_koz1', avatar: 'https://i.pravatar.cc/150?u=4  '),
    Mention(id: '111111115', name: 'Sergey Volkov', nickname: 'sergey_v1', avatar: 'https://i.pravatar.cc/150?u=5  '),
    Mention(id: '111111116', name: 'Elena Novikova', nickname: 'elena_nov1', avatar: 'https://i.pravatar.cc/150?u=6  '),
    Mention(id: '111111117', name: 'Andrey Smirnov', nickname: 'andrey_sm1', avatar: 'https://i.pravatar.cc/150?u=7  '),
    Mention(id: '111111118', name: 'Olga Lebedeva', nickname: 'olga_leb1', avatar: 'https://i.pravatar.cc/150?u=8  '),
    Mention(id: '111111119', name: 'Ivan Fedorov', nickname: 'ivan_fed1', avatar: 'https://i.pravatar.cc/150?u=9  '),
    Mention(id: '1111111110', name: 'Tatyana Morozova', nickname: 'tatyana_m1', avatar: 'https://i.pravatar.cc/150?u=10  '),
    Mention(id: '1111111111', name: 'Pavel Orlov', nickname: 'pavel_orl1', avatar: 'https://i.pravatar.cc/150?u=11  '),
    Mention(id: '1111111112', name: 'Natalya Sokolova', nickname: 'natasha_s1', avatar: 'https://i.pravatar.cc/150?u=12  '),
    Mention(id: '1111111113', name: 'Vladimir Popov', nickname: 'vlad_pop1', avatar: 'https://i.pravatar.cc/150?u=13  '),
    Mention(id: '1111111114', name: 'Yuliya Vorobyeva', nickname: 'yulia_vor1', avatar: 'https://i.pravatar.cc/150?u=14  '),
    Mention(id: '1111111115', name: 'Roman Solovyev', nickname: 'roman_sol1', avatar: 'https://i.pravatar.cc/150?u=15  '),


    Mention(id: '1', name: 'Александр Иванов', nickname: 'alex_ivanov', avatar: 'https://i.pravatar.cc/150?u=1'),
    Mention(id: '2', name: 'Мария Петрова', nickname: 'maria_p', avatar: 'https://i.pravatar.cc/150?u=2'),
    Mention(id: '3', name: 'Дмитрий Сидоров', nickname: 'dmitry_s', avatar: 'https://i.pravatar.cc/150?u=3'),
    Mention(id: '4', name: 'Анна Козлова', nickname: 'anna_koz', avatar: 'https://i.pravatar.cc/150?u=4'),
    Mention(id: '5', name: 'Сергей Волков', nickname: 'sergey_v', avatar: 'https://i.pravatar.cc/150?u=5'),
    Mention(id: '6', name: 'Елена Новикова', nickname: 'elena_nov', avatar: 'https://i.pravatar.cc/150?u=6'),
    Mention(id: '7', name: 'Андрей Смирнов', nickname: 'andrey_sm', avatar: 'https://i.pravatar.cc/150?u=7'),
    Mention(id: '8', name: 'Ольга Лебедева', nickname: 'olga_leb', avatar: 'https://i.pravatar.cc/150?u=8'),
    Mention(id: '9', name: 'Иван Федоров', nickname: 'ivan_fed', avatar: 'https://i.pravatar.cc/150?u=9'),
    Mention(id: '10', name: 'Татьяна Морозова', nickname: 'tatyana_m', avatar: 'https://i.pravatar.cc/150?u=10'),
    Mention(id: '11', name: 'Павел Орлов', nickname: 'pavel_orl', avatar: 'https://i.pravatar.cc/150?u=11'),
    Mention(id: '12', name: 'Наталья Соколова', nickname: 'natasha_s', avatar: 'https://i.pravatar.cc/150?u=12'),
    Mention(id: '13', name: 'Владимир Попов', nickname: 'vlad_pop', avatar: 'https://i.pravatar.cc/150?u=13'),
    Mention(id: '14', name: 'Юлия Воробьева', nickname: 'yulia_vor', avatar: 'https://i.pravatar.cc/150?u=14'),
    Mention(id: '15', name: 'Роман Соловьев', nickname: 'roman_sol', avatar: 'https://i.pravatar.cc/150?u=15'),
  ];

  Future<List<Mention>> getMentions(String query) async {
    if (query.isEmpty) {
      return List<Mention>.from(_mockMentions);
    }
    final lowerQuery = query.toLowerCase();
    final filtered = _mockMentions
        .where((mention) => mention.name.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }
}
