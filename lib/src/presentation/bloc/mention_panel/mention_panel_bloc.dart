import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_message_composer/src/domain/entities/mention.dart';
import 'package:chat_message_composer/src/domain/entities/mention_command.dart';
import 'package:chat_message_composer/src/domain/repositories/mention_repository.dart';
import 'package:chat_message_composer/src/presentation/utils/delta_mention_analyzer.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mention_panel_event.dart';
part 'mention_panel_state.dart';

/// BLoC для управления состоянием панели упоминаний (@).
///
/// Обрабатывает изменения документа, загрузку и фильтрацию списка пользователей,
/// навигацию стрелками и выбор элемента из списка.
/// При обнаружении '@' или выборе упоминания отправляет команды через
/// колбэк `onCommand`.
class MentionPanelBloc extends Bloc<MentionPanelEvent, MentionPanelState> {
  MentionPanelBloc({
    required MentionRepository mentionRepository,
    required void Function(MentionCommand) onCommand,
  })  : _mentionRepository = mentionRepository,
        _onCommand = onCommand,
        super(const MentionPanelState$Initial()) {
    on<MentionPanelEvent$DocumentChanged>(
      _onDocumentChanged,
      transformer: restartable(),
    );
    on<MentionPanelEvent>(
      (event, emit) => switch (event) {
        MentionPanelEvent$NavigateUp() => _onNavigateUp(event, emit),
        MentionPanelEvent$NavigateDown() => _onNavigateDown(event, emit),
        MentionPanelEvent$SelectFirstOrCurrent() =>
          _onSelectFirstOrCurrent(event, emit),
        MentionPanelEvent$Hover() => _onHover(event, emit),
        MentionPanelEvent$Select() => _onSelect(event, emit),
        MentionPanelEvent$Reset() => _onReset(event, emit),
        MentionPanelEvent$DocumentChanged() => null,
      },
      transformer: sequential(),
    );
  }

  final MentionRepository _mentionRepository;
  final void Function(MentionCommand) _onCommand;

  List<Mention> _cachedMentions = [];
  int _cachedSelectedIndex = -1;
  int _lastEmbedPosition = -1;
  String? _lastQuery;

  Future<void> _onDocumentChanged(
    MentionPanelEvent$DocumentChanged event,
    Emitter<MentionPanelState> emit,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final analyzer = DeltaMentionAnalyzer(
      delta: event.delta,
      cursorPosition: event.cursorPosition,
    );

    if (event.cursorPosition < 0 ||
        event.cursorPosition > analyzer.documentLength) {
      if (state is MentionPanelState$Data ||
          state is MentionPanelState$Loading) {
        _reset();
        emit(const MentionPanelState$Initial());
      }
      return;
    }

    // Embed считается активным, если в его query нет разделителей
    final query = analyzer.mentionInputQuery;
    final hasActiveEmbed = analyzer.hasMentionInputEmbed &&
        !query.contains(' ') &&
        !query.contains('\n');

    // 1. Если есть '@' и нет активного embed - создаём новый mention_input
    if (analyzer.hasActiveAt && !hasActiveEmbed) {
      _onCommand(InsertMentionInputCommand(atPosition: analyzer.lastAtIndex));
      return;
    }

    // 2. Если есть активный embed - показываем/обновляем панель
    if (hasActiveEmbed) {
      _lastEmbedPosition = analyzer.mentionInputEmbedIndex;

      if (_lastQuery != null &&
          query == _lastQuery &&
          state is MentionPanelState$Data) {
        return;
      }

      _lastQuery = query;

      emit(MentionPanelState$Loading(
        mentions: _cachedMentions,
        selectedIndex: _cachedSelectedIndex,
        query: query,
      ));

      try {
        final mentions = await _mentionRepository.getMentions(query);
        _cachedMentions = mentions;
        _cachedSelectedIndex = _preserveSelectedIndex(mentions);

        // Точное совпадение введённого текста с именем (с учётом регистра)
        // означает, что упоминание уже «подцепилось» — конвертируем черновик
        // в подтверждённое упоминание автоматически, не дожидаясь Enter/клика.
        final exactMatch = _findExactNameMatch(mentions, query);
        if (exactMatch != null) {
          _onCommand(InsertMentionCommand(
              mention: exactMatch, embedPosition: _lastEmbedPosition));
          _reset();
          emit(const MentionPanelState$Initial());
          return;
        }

        emit(MentionPanelState$Data(
          mentions: mentions,
          selectedIndex: _cachedSelectedIndex,
          query: query,
        ));
      } on Exception catch (e) {
        emit(MentionPanelState$Error(error: e.toString()));
      }
      return;
    }

    // 3. Ничего не найдено - скрываем панель
    if (state is! MentionPanelState$Initial) {
      // Если embed есть в документе, но стал неактивным из-за разделителя
      // (пробел/перенос) — конвертируем его обратно в текст.
      // query уже содержит разделитель, поэтому addTrailingSpace = false.
      if (analyzer.hasMentionInputEmbed && _lastEmbedPosition >= 0) {
        _onCommand(CancelMentionInputCommand(
          embedPosition: _lastEmbedPosition,
          query: query,
        ));
      }
      _reset();
      emit(const MentionPanelState$Initial());
    }
  }

  /// Ищет упоминание, чьё name точно (с учётом регистра) совпадает
  /// с введённым query, среди уже загруженного списка [mentions].
  Mention? _findExactNameMatch(List<Mention> mentions, String query) {
    if (query.isEmpty) return null;
    for (final mention in mentions) {
      if (mention.name == query) return mention;
    }
    return null;
  }

  /// Сохраняет selectedIndex если выбранный пользователь есть в новом списке.
  int _preserveSelectedIndex(List<Mention> newMentions) {
    if (_cachedSelectedIndex < 0 ||
        _cachedSelectedIndex >= _cachedMentions.length) {
      return -1;
    }

    final previousMention = _cachedMentions[_cachedSelectedIndex];
    final newIndex = newMentions.indexWhere((m) => m.id == previousMention.id);
    return newIndex >= 0 ? newIndex : -1;
  }

  void _onNavigateUp(
    MentionPanelEvent$NavigateUp event,
    Emitter<MentionPanelState> emit,
  ) {
    final currentState = state;
    if (currentState is! MentionPanelState$Data ||
        currentState.mentions.isEmpty) {
      return;
    }
    final newIndex = currentState.selectedIndex <= 0
        ? currentState.mentions.length - 1
        : currentState.selectedIndex - 1;
    _cachedSelectedIndex = newIndex;
    emit(currentState.copyWith(selectedIndex: newIndex, shouldScroll: true));
  }

  void _onNavigateDown(
    MentionPanelEvent$NavigateDown event,
    Emitter<MentionPanelState> emit,
  ) {
    final currentState = state;
    if (currentState is! MentionPanelState$Data ||
        currentState.mentions.isEmpty) {
      return;
    }
    final newIndex = currentState.selectedIndex < 0
        ? 0
        : (currentState.selectedIndex >= currentState.mentions.length - 1
            ? -1
            : currentState.selectedIndex + 1);
    _cachedSelectedIndex = newIndex;
    emit(currentState.copyWith(selectedIndex: newIndex, shouldScroll: true));
  }

  void _onHover(
    MentionPanelEvent$Hover event,
    Emitter<MentionPanelState> emit,
  ) {
    final currentState = state;
    if (currentState is! MentionPanelState$Data ||
        currentState.mentions.isEmpty) {
      return;
    }
    final index = event.index;
    if (index < 0 || index >= currentState.mentions.length) {
      return;
    }
    _cachedSelectedIndex = index;
    emit(currentState.copyWith(selectedIndex: index, shouldScroll: false));
  }

  void _onSelectFirstOrCurrent(
    MentionPanelEvent$SelectFirstOrCurrent event,
    Emitter<MentionPanelState> emit,
  ) {
    final currentState = state;
    if (currentState is! MentionPanelState$Data ||
        currentState.mentions.isEmpty) {
      return;
    }
    final index =
        currentState.selectedIndex >= 0 ? currentState.selectedIndex : 0;
    if (index < _cachedMentions.length) {
      final mention = _cachedMentions[index];
      _onCommand(InsertMentionCommand(
          mention: mention, embedPosition: _lastEmbedPosition));
      _reset();
      emit(const MentionPanelState$Initial());
    }
  }

  void _onSelect(
    MentionPanelEvent$Select event,
    Emitter<MentionPanelState> emit,
  ) {
    final index = event.index ?? _cachedSelectedIndex;
    if (index >= 0 && index < _cachedMentions.length) {
      final mention = _cachedMentions[index];
      _onCommand(InsertMentionCommand(
          mention: mention, embedPosition: _lastEmbedPosition));
      _reset();
      emit(const MentionPanelState$Initial());
    }
  }

  void _onReset(
    MentionPanelEvent$Reset event,
    Emitter<MentionPanelState> emit,
  ) {
    if (event.convertEmbedToText && _lastEmbedPosition >= 0) {
      _onCommand(CancelMentionInputCommand(
        embedPosition: _lastEmbedPosition,
        query: _lastQuery ?? '',
        addTrailingSpace: true,
      ));
    }
    _reset();
    emit(const MentionPanelState$Initial());
  }

  void _reset() {
    _cachedMentions = [];
    _cachedSelectedIndex = -1;
    _lastEmbedPosition = -1;
    _lastQuery = null;
  }
}
