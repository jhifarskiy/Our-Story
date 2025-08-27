import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chapter.dart';
import '../models/character.dart';
import '../models/game_progress.dart';
import '../services/story_service.dart';

// Провайдер для сервиса истории
final storyServiceProvider = Provider<StoryService>((ref) {
  return StoryService();
});

// Провайдер для получения глав
final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  final storyService = ref.read(storyServiceProvider);
  return await storyService.getChapters();
});

// Провайдер для получения персонажей
final charactersProvider = FutureProvider<List<Character>>((ref) async {
  final storyService = ref.read(storyServiceProvider);
  return await storyService.getCharacters();
});

// Провайдер для прогресса игры
final gameProgressProvider =
    StateNotifierProvider<GameProgressNotifier, AsyncValue<GameProgress?>>((
      ref,
    ) {
      return GameProgressNotifier(ref.read(storyServiceProvider));
    });

// Нотификатор для управления прогрессом игры
class GameProgressNotifier extends StateNotifier<AsyncValue<GameProgress?>> {
  final StoryService _storyService;

  GameProgressNotifier(this._storyService) : super(const AsyncValue.loading()) {
    _loadProgress();
  }

  // Загрузка прогресса
  Future<void> _loadProgress() async {
    try {
      final progress = await _storyService.loadProgress();
      state = AsyncValue.data(progress);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Сохранение прогресса
  Future<void> saveProgress(GameProgress progress) async {
    try {
      await _storyService.saveProgress(progress);
      state = AsyncValue.data(progress);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Обновление текущего сообщения
  Future<void> updateCurrentMessage(String chapterId, String messageId) async {
    final currentProgress = state.value;
    if (currentProgress != null) {
      final updatedProgress = currentProgress.copyWith(
        currentChapterId: chapterId,
        currentMessageId: messageId,
        lastPlayed: DateTime.now(),
      );
      await saveProgress(updatedProgress);
    }
  }

  // Добавление выбора игрока
  Future<void> addPlayerChoice(String choiceId, dynamic choiceData) async {
    final currentProgress = state.value;
    if (currentProgress != null) {
      final updatedChoices = Map<String, dynamic>.from(
        currentProgress.playerChoices,
      );
      updatedChoices[choiceId] = choiceData;

      final updatedProgress = currentProgress.copyWith(
        playerChoices: updatedChoices,
        lastPlayed: DateTime.now(),
      );
      await saveProgress(updatedProgress);
    }
  }

  // Обновление отношений с персонажем
  Future<void> updateCharacterRelationship(
    String characterId,
    int change,
  ) async {
    final currentProgress = state.value;
    if (currentProgress != null) {
      final updatedRelationships = Map<String, int>.from(
        currentProgress.characterRelationships,
      );
      updatedRelationships[characterId] =
          (updatedRelationships[characterId] ?? 0) + change;

      final updatedProgress = currentProgress.copyWith(
        characterRelationships: updatedRelationships,
        lastPlayed: DateTime.now(),
      );
      await saveProgress(updatedProgress);
    }
  }
}
