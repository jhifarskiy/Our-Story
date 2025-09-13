import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_settings.dart';
import '../services/story_service.dart';

// Провайдер для StoryService
final storyServiceProvider = Provider<StoryService>((ref) => StoryService());

// Провайдер для настроек истории
final storyBuilderProvider =
    StateNotifierProvider<StoryBuilderNotifier, StoryBuilderState>((ref) {
      return StoryBuilderNotifier(ref.read(storyServiceProvider));
    });

// Состояние Story Builder
class StoryBuilderState {
  final StorySettings? settings;
  final GeneratedStory? generatedStory;
  final bool isGenerating;
  final String? error;

  const StoryBuilderState({
    this.settings,
    this.generatedStory,
    this.isGenerating = false,
    this.error,
  });

  StoryBuilderState copyWith({
    StorySettings? settings,
    GeneratedStory? generatedStory,
    bool? isGenerating,
    String? error,
  }) {
    return StoryBuilderState(
      settings: settings ?? this.settings,
      generatedStory: generatedStory ?? this.generatedStory,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
    );
  }
}

// Нотификатор для Story Builder
class StoryBuilderNotifier extends StateNotifier<StoryBuilderState> {
  final StoryService _storyService;

  StoryBuilderNotifier(this._storyService) : super(const StoryBuilderState());

  // Установить настройки
  void setSettings(StorySettings settings) {
    state = state.copyWith(settings: settings, error: null);
  }

  // Генерация истории
  Future<void> generateStory() async {
    if (state.settings == null) {
      state = state.copyWith(error: 'Настройки не заданы');
      return;
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      final story = await _storyService.generateFullStory(state.settings!);
      state = state.copyWith(generatedStory: story, isGenerating: false);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Ошибка генерации: $e',
      );
    }
  }

  // Очистить состояние
  void clear() {
    state = const StoryBuilderState();
  }

  // Сохранить историю
  Future<void> saveStory() async {
    if (state.generatedStory == null) return;

    try {
      await _storyService.saveGeneratedStory(state.generatedStory!);
    } catch (e) {
      state = state.copyWith(error: 'Ошибка сохранения: $e');
    }
  }
}

// Состояние мультиплеера
class MultiplayerState {
  final String? sessionCode;
  final bool isConnected;
  final bool isHost;
  final List<String> connectedPlayers;
  final String? error;

  const MultiplayerState({
    this.sessionCode,
    this.isConnected = false,
    this.isHost = false,
    this.connectedPlayers = const [],
    this.error,
  });

  MultiplayerState copyWith({
    String? sessionCode,
    bool? isConnected,
    bool? isHost,
    List<String>? connectedPlayers,
    String? error,
  }) {
    return MultiplayerState(
      sessionCode: sessionCode ?? this.sessionCode,
      isConnected: isConnected ?? this.isConnected,
      isHost: isHost ?? this.isHost,
      connectedPlayers: connectedPlayers ?? this.connectedPlayers,
      error: error,
    );
  }
}

// Провайдер для мультиплеерных сессий
final multiplayerProvider =
    StateNotifierProvider<MultiplayerNotifier, MultiplayerState>((ref) {
      return MultiplayerNotifier(ref.read(storyServiceProvider));
    });

// Нотификатор для мультиплеера
class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  final StoryService _storyService;

  MultiplayerNotifier(this._storyService) : super(const MultiplayerState());

  // Создать сессию (хост)
  Future<String> createSession(GeneratedStory story) async {
    state = state.copyWith(isConnected: true, isHost: true, error: null);

    try {
      final session = await _storyService.createMultiplayerSession(story);
      state = state.copyWith(
        sessionCode: session.code,
        connectedPlayers: [session.hostName],
      );
      return session.code;
    } catch (e) {
      state = state.copyWith(error: 'Ошибка создания сессии: $e');
      rethrow;
    }
  }

  // Присоединиться к сессии (гость)
  Future<void> joinSession(String connectionCode, String playerName) async {
    state = state.copyWith(isConnected: true, isHost: false, error: null);

    try {
      await _storyService.joinMultiplayerSession(connectionCode, playerName);
      state = state.copyWith(
        sessionCode: connectionCode,
        connectedPlayers: [...state.connectedPlayers, playerName],
      );
    } catch (e) {
      state = state.copyWith(error: 'Ошибка подключения: $e');
      rethrow;
    }
  }

  // Очистить состояние
  void disconnect() {
    state = const MultiplayerState();
  }
}
