import 'package:hive/hive.dart';
import '../models/chapter.dart';
import '../models/character.dart';
import '../models/story_message.dart';
import '../models/game_progress.dart';

class StoryService {
  static const String _progressBoxName = 'game_progress';
  static const String _settingsBoxName = 'settings';

  // Получение всех глав
  Future<List<Chapter>> getChapters() async {
    // В реальном приложении здесь будет загрузка из JSON файлов или API
    return [
      Chapter(
        id: 'chapter_1',
        title: 'Знакомство',
        description: 'Первая встреча главных героев',
        thumbnailPath: 'assets/images/chapter1_thumb.jpg',
        order: 1,
        isUnlocked: true,
        messages: await _getChapter1Messages(),
      ),
      Chapter(
        id: 'chapter_2',
        title: 'Развитие отношений',
        description: 'Герои узнают друг друга лучше',
        thumbnailPath: 'assets/images/chapter2_thumb.jpg',
        order: 2,
        isUnlocked: false,
        messages: [],
      ),
    ];
  }

  // Получение всех персонажей
  Future<List<Character>> getCharacters() async {
    return [
      const Character(
        id: 'alex',
        name: 'Алекс',
        avatarPath: 'assets/images/alex_avatar.jpg',
        description: 'Главный герой истории',
        emotions: {
          'happy': 'assets/images/alex_happy.jpg',
          'sad': 'assets/images/alex_sad.jpg',
          'surprised': 'assets/images/alex_surprised.jpg',
        },
      ),
      const Character(
        id: 'maria',
        name: 'Мария',
        avatarPath: 'assets/images/maria_avatar.jpg',
        description: 'Главная героиня',
        emotions: {
          'happy': 'assets/images/maria_happy.jpg',
          'sad': 'assets/images/maria_sad.jpg',
          'love': 'assets/images/maria_love.jpg',
        },
      ),
    ];
  }

  // Сохранение прогресса игры
  Future<void> saveProgress(GameProgress progress) async {
    final box = await Hive.openBox(_progressBoxName);
    await box.put('current_progress', progress.toJson());
  }

  // Загрузка прогресса игры
  Future<GameProgress?> loadProgress() async {
    final box = await Hive.openBox(_progressBoxName);
    final progressData = box.get('current_progress');

    if (progressData != null) {
      return GameProgress.fromJson(Map<String, dynamic>.from(progressData));
    }
    return null;
  }

  // Получение сообщений для первой главы (пример)
  Future<List<StoryMessage>> _getChapter1Messages() async {
    return [
      StoryMessage(
        id: 'msg_1',
        characterId: 'alex',
        text: 'Привет! Меня зовут Алекс. Рад познакомиться!',
        emotion: 'happy',
        backgroundImage: 'assets/images/cafe_background.jpg',
      ),
      StoryMessage(
        id: 'msg_2',
        characterId: 'maria',
        text: 'Привет, Алекс! Я Мария. Тоже очень рада знакомству!',
        emotion: 'happy',
        choices: [
          const Choice(
            id: 'choice_1',
            text: 'Хочешь прогуляться?',
            nextMessageId: 'msg_3a',
          ),
          const Choice(
            id: 'choice_2',
            text: 'Может, останемся в кафе?',
            nextMessageId: 'msg_3b',
          ),
        ],
      ),
    ];
  }

  // Сохранение настроек
  Future<void> saveSetting(String key, dynamic value) async {
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(key, value);
  }

  // Получение настройки
  Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    final box = await Hive.openBox(_settingsBoxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }
}
