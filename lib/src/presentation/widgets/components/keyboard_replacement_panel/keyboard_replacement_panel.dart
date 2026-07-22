import 'dart:async';
import 'dart:math' as math;

import 'package:chat_message_composer/src/domain/repositories/chat_message_composer_localization_repository.dart';
import 'package:chat_message_composer/src/presentation/bloc/keyboard_panel/keyboard_panel_bloc.dart';
import 'package:chat_message_composer/src/presentation/theme/chat_editor_theme.dart';
import 'package:chat_message_composer/src/presentation/utils/emoji_set_utils.dart';
import 'package:chat_message_composer/src/presentation/widgets/components/send_panel_buttons/emoji_search_view.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Панель-замена клавиатуры для мобильных устройств.
///
/// Отслеживает высоту клавиатуры через [MediaQuery.viewInsetsOf] и сохраняет
/// её в [KeyboardPanelBloc]. При переходе в состояние [KeyboardPanelState$Emoji]
/// отображает выбор эмодзи высотой, равной последней известной высоте клавиатуры.
///
/// Используется совместно с [resizeToAvoidBottomInset: false] у родительского [Scaffold].
///

class KeyboardReplacementPanel extends StatefulWidget {
  const KeyboardReplacementPanel({
    required this.quillController,
    super.key,
  });

  final QuillController quillController;

  @override
  State<KeyboardReplacementPanel> createState() =>
      _KeyboardReplacementPanelState();
}

class _KeyboardReplacementPanelState extends State<KeyboardReplacementPanel> {
  // Пока ждём, что после закрытия панели эмодзи системная клавиатура снова
  // откроется на прежнюю высоту, резервируем место под неё, чтобы избежать
  // визуального "схлопывания". Но если клавиатура так и не открылась, либо
  // открылась на другую (обычно чуть меньшую) высоту — inset никогда не
  // достигнет _transitionHeight, и место останется зарезервированным
  // навсегда. Раньше это было видно как пустая белая область, поэтому
  // таймаут держали коротким; теперь на время ожидания сетка эмодзи не
  // прячется (см. showEmojiContent в build) и визуально "наезжает" клавиатурой
  // сверху донизу без пустот, так что можно спокойно держать более длинный
  // и безопасный таймаут с запасом над длительностью нативной анимации.
  static const _transitionTimeout = Duration(milliseconds: 500);
  // Небольшая длительность специально: пока идёт нативная анимация показа
  // клавиатуры, effectiveHeight и так меняется вместе с ней кадр за кадром
  // (см. build) — этот AnimatedContainer не должен заметно от неё отставать.
  // Нужен он в первую очередь, чтобы срабатывание _transitionTimeout не
  // выглядело как рывок, а не для сглаживания самой открывающейся клавиатуры.
  static const _heightAnimationDuration = Duration(milliseconds: 150);

  double _lastDispatchedHeight = 0;
  double? _transitionHeight;
  Timer? _transitionTimer;
  bool _isSearchFocused = false;

  Config? _cachedConfig;
  double? _lastConfigHeight;
  Color? _lastConfigBackgroundColor;
  String? _lastConfigEmojiSearch;
  String? _lastConfigEmojiNotFound;

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final controller = widget.quillController;
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;
    controller.replaceText(
      index,
      length,
      emoji.emoji,
      TextSelection.collapsed(offset: index + emoji.emoji.length),
    );
  }

  Config _getMemoizedConfig(BuildContext context, double height) {
    final backgroundColor = context.chatColors.surfaceTertiary;
    final localization = context.read<ChatMessageComposerLocalizationRepository>();
    final emojiSearch = localization.emojiSearch;
    final emojiNotFound = localization.emojiNotFound;

    if (_cachedConfig != null &&
        _lastConfigHeight == height &&
        _lastConfigBackgroundColor == backgroundColor &&
        _lastConfigEmojiSearch == emojiSearch &&
        _lastConfigEmojiNotFound == emojiNotFound) {
      return _cachedConfig!;
    }
    _lastConfigHeight = height;
    _lastConfigBackgroundColor = backgroundColor;
    _lastConfigEmojiSearch = emojiSearch;
    _lastConfigEmojiNotFound = emojiNotFound;
    _cachedConfig = Config(
      height: height,
      emojiSet: getBilingualEmojiSet,
      viewOrderConfig: const ViewOrderConfig(
        top: EmojiPickerItem.searchBar,
        bottom: EmojiPickerItem.categoryBar,
      ),
      emojiViewConfig: EmojiViewConfig(
        columns: 8,
        emojiSizeMax: 32,
        backgroundColor: backgroundColor,
      ),
      categoryViewConfig: CategoryViewConfig(
        recentTabBehavior: RecentTabBehavior.NONE,
        initCategory: Category.SMILEYS,
        customCategoryView: (_, __, ___, ____) => const SizedBox.shrink(),
      ),
      bottomActionBarConfig: const BottomActionBarConfig(
        customBottomActionBar: EmojiSearchBar.new,
      ),
      searchViewConfig: SearchViewConfig(
        hintText: emojiSearch,
        customSearchView: (config, state, showEmojiView) => EmojiSearchView(
          config,
          state,
          showEmojiView,
          onFocusChanged: _onSearchFocusChanged,
          notFoundText: emojiNotFound,
        ),
      ),
    );
    return _cachedConfig!;
  }

  void _onSearchFocusChanged(bool focused) {
    if (!mounted) return;
    setState(() => _isSearchFocused = focused);
  }

  void _updateKeyboardHeight(double inset) {
    const deltaThreshold = 5.0;
    final isSignificant =
        (inset - _lastDispatchedHeight).abs() > deltaThreshold;
    final isReset = inset == 0 && _lastDispatchedHeight > 0;

    if ((isSignificant || isReset) && inset != _lastDispatchedHeight) {
      _lastDispatchedHeight = inset;
      Future.microtask(() {
        if (!mounted) return;
        context
            .read<KeyboardPanelBloc>()
            .add(KeyboardPanel$UpdateHeight(inset));
      });
    }
  }

  void _armTransitionTimeout() {
    _transitionTimer?.cancel();
    _transitionTimer = Timer(_transitionTimeout, () {
      if (!mounted || _transitionHeight == null) return;
      setState(() => _transitionHeight = null);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateKeyboardHeight(MediaQuery.viewInsetsOf(context).bottom);
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return BlocConsumer<KeyboardPanelBloc, KeyboardPanelState>(
      listenWhen: (prev, curr) =>
          prev is KeyboardPanelState$Emoji && curr is! KeyboardPanelState$Emoji,
      listener: (context, state) {
        final expectKeyboard =
            state is KeyboardPanelState$Empty && state.expectKeyboard;
        _transitionHeight = expectKeyboard ? state.lastKnownHeight : null;
        _isSearchFocused = false;
        if (expectKeyboard) {
          _armTransitionTimeout();
        } else {
          _transitionTimer?.cancel();
        }
      },
      builder: (context, state) {
        if (_transitionHeight != null && keyboardHeight >= _transitionHeight!) {
          _transitionHeight = null;
          _transitionTimer?.cancel();
        }

        final isEmojiMode = state is KeyboardPanelState$Emoji;
        // Пока ждём, что клавиатура откроется обратно (_transitionHeight не
        // сброшен), держим сетку эмодзи на экране, а не прячем её сразу —
        // тогда клавиатура визуально "наезжает" на неё снизу как нативный
        // оверлей поверх остального контента, без промежуточной пустой
        // белой области.
        final showEmojiContent = isEmojiMode || _transitionHeight != null;
        final lastHeight = state.lastKnownHeight;
        final searchExtra = (isEmojiMode && _isSearchFocused)
            ? mediaQuery.size.height * 0.3
            : 0.0;

        const defaultHeight = 280.0;
        final effectiveHeight = switch (state) {
          KeyboardPanelState$Emoji() =>
            math.max(keyboardHeight, math.max(lastHeight, defaultHeight)) +
                searchExtra,
          KeyboardPanelState$Empty() => (_transitionHeight != null
              ? math.max(keyboardHeight, _transitionHeight!)
              : (keyboardHeight > 0
                  ? math.max(keyboardHeight, lastHeight)
                  : 0.0)),
        };

        return AnimatedContainer(
          duration: _heightAnimationDuration,
          curve: Curves.easeOut,
          height: effectiveHeight,
          width: double.infinity,
          child: Stack(
            children: [
              Offstage(
                offstage: !showEmojiContent,
                child: RepaintBoundary(
                  child: EmojiPicker(
                    onEmojiSelected: _onEmojiSelected,
                    // Высота конфига обязана совпадать с фактической высотой
                    // AnimatedContainer (effectiveHeight), а не пересчитываться
                    // отдельно: до этого фикса тут применялся defaultHeight-клэмп
                    // (math.max(lastHeight, defaultHeight)), которого не было в
                    // effectiveHeight на этапе ожидания клавиатуры — если
                    // реальная высота (_transitionHeight) оказывалась меньше
                    // defaultHeight, Column внутри EmojiPicker закладывался на
                    // большую высоту, чем реально давал контейнер, и оверфлоил.
                    config: _getMemoizedConfig(context, effectiveHeight),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
