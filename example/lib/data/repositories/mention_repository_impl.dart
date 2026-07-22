import 'package:chat_message_composer/chat_message_composer.dart';
import 'package:chat_message_composer_example/data/datasources/mention_datasource.dart';

/// Реализация [MentionRepository] с использованием источника данных.
class MentionRepositoryImpl implements MentionRepository {
  MentionRepositoryImpl({required MentionDataSource dataSource})
      : _dataSource = dataSource;

  final MentionDataSource _dataSource;

  @override
  Future<List<Mention>> getMentions(String query) {
    return _dataSource.getMentions(query);
  }
}
