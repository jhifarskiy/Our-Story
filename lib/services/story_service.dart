// DOCUMENT filename="story_service.dart"
import '../models/story_settings.dart';
import 'google_ai_service.dart';
import 'storage_service.dart';

/// Сервис для работы с историями
class StoryService {
  final GoogleAiService _aiService = GoogleAiService();
  late final StorageService _storage;

  StoryService() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageService.getInstance();
  }

  /// Генерация истории с помощью AI (с retry и улучшенной обработкой ошибок)
  Future<String> generateStory(String prompt) async {
    try {
      // Используем новый метод с retry
      return await _aiService.generateTextWithRetry(prompt);
    } catch (e) {
      // Логируем для отладки
      print('Story Service Error: $e');
      rethrow;
    }
  }

  /// Улучшенная генерация истории с валидацией промпта
  Future<String> generateStoryWithValidation(String prompt) async {
    // Валидируем промпт
    if (prompt.trim().isEmpty) {
      throw Exception('Промпт не может быть пустым');
    }

    if (prompt.length < 10) {
      throw Exception('Промпт слишком короткий');
    }

    // Улучшаем промпт если нужно
    final enhancedPrompt = _enhancePrompt(prompt);

    return await generateStory(enhancedPrompt);
  }

  String _enhancePrompt(String originalPrompt) {
    // Добавляем контекст и инструкции для лучшего качества
    return '''$originalPrompt

ВАЖНЫЕ ИНСТРУКЦИИ:
- Используй ТОЧНО указанный формат ответа
- История должна быть интересной и захватывающей
- Варианты действий должны быть разнообразными и значимыми
- Пиши живым, образным языком
- Избегай клише и банальности
- Каждый вариант должен вести к разным развитиям сюжета''';
  }

  /// Генерация диалога персонажа
  Future<String> generateDialogue(String character, String situation) async {
    final prompt =
        '''Создай реплику персонажа "$character" в ситуации: $situation
Стиль: естественный диалог, соответствующий характеру персонажа.''';

    return await generateStory(prompt);
  }

  /// Генерация вариантов выбора
  Future<List<String>> generateChoices(String situation) async {
    final prompt = '''Создай 3 варианта действий для ситуации: $situation
Формат: список из 3 пунктов, каждый с новой строки.''';

    final result = await generateStory(prompt);
    return _parseChoices(result);
  }

  /// Генерация описания сцены
  Future<String> generateSceneDescription(String location, String mood) async {
    final prompt = '''Опиши сцену в локации "$location" с настроением "$mood"
Стиль: атмосферное описание для визуальной новеллы, 2-3 предложения.''';

    return await generateStory(prompt);
  }

  /// Генерация текста в режиме streaming
  Stream<String> generateTextStream(String prompt) async* {
    yield* _aiService.generateTextStream(prompt);
  }

  /// Парсит варианты выбора из ответа AI
  List<String> _parseChoices(String result) {
    return result.split('\n').where((line) => line.trim().isNotEmpty).toList();
  }

  /// Генерация полной истории на основе настроек
  Future<GeneratedStory> generateFullStory(StorySettings settings) async {
    final prompt = _buildStoryPrompt(settings);

    try {
      // Генерируем основную структуру истории
      final storyStructure = await generateStory(prompt);

      // Парсим и создаем главы
      final chapters = await _generateChapters(settings, storyStructure);

      return GeneratedStory(
        title: _generateTitle(settings),
        description: _generateDescription(settings),
        chapters: chapters,
        characters: {
          'player1': settings.player1Name,
          'player2': settings.player2Name,
          'narrator': 'Рассказчик',
        },
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Ошибка генерации истории: $e');
    }
  }

  /// Сохранить сгенерированную историю
  Future<void> saveGeneratedStory(GeneratedStory story) async {
    await _storage.saveMap(
      'generated_story_${story.createdAt.millisecondsSinceEpoch}',
      story.toJson(),
    );
  }

  /// Создать мультиплеер сессию
  Future<MultiplayerSession> createMultiplayerSession(
    GeneratedStory story,
  ) async {
    // Генерируем код комнаты
    final sessionCode = _generateSessionCode();

    return MultiplayerSession(
      code: sessionCode,
      hostName: 'Хост',
      players: ['Хост'],
      story: story,
      createdAt: DateTime.now(),
    );
  }

  // Присоединиться к мультиплеер сессии
  Future<MultiplayerSession> joinMultiplayerSession(
    String sessionId, [
    String? playerName,
  ]) async {
    // В реальном приложении здесь будет API вызов
    await Future.delayed(const Duration(seconds: 1));

    return MultiplayerSession(
      code: sessionId,
      hostName: 'Хост',
      players: ['Хост', playerName ?? 'Гость'],
      story: GeneratedStory(
        title: 'Совместная история',
        description: 'История созданная вместе',
        chapters: [],
        characters: {},
        createdAt: DateTime.now(),
      ),
      createdAt: DateTime.now(),
    );
  }

  /// Генерирует код сессии
  String _generateSessionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  /// Сохранение настройки
  Future<void> saveSetting<T>(String key, T value) async {
    final settings = _storage.getSettings() ?? <String, dynamic>{};
    settings[key] = value;
    await _storage.saveSettings(settings);
  }

  /// Получение настройки
  T? getSetting<T>(String key) {
    final settings = _storage.getSettings();
    return settings?[key] as T?;
  }

  /// Построение промпта для генерации истории
  String _buildStoryPrompt(StorySettings settings) {
    return '''
Создай интерактивную историю с двумя персонажами:
- ${settings.player1Name}
- ${settings.player2Name}

Жанр: ${_getGenreDescription(settings.genre)}
Отношения: ${_getRelationshipDescription(settings.relationshipType)}
Место действия: ${settings.setting}
Количество глав: ${settings.storyLength}
Уровень сложности: ${settings.complexityLevel}/5

${settings.customPrompt.isNotEmpty ? 'Дополнительные требования: ${settings.customPrompt}' : ''}

Создай структуру истории с основными событиями и поворотными моментами.
''';
  }

  /// Генерация глав истории
  Future<List<GeneratedChapter>> _generateChapters(
    StorySettings settings,
    String storyStructure,
  ) async {
    final chapters = <GeneratedChapter>[];

    for (int i = 0; i < settings.storyLength; i++) {
      final chapterPrompt =
          '''
Создай подробную главу ${i + 1} для истории со следующими персонажами:
- ${settings.player1Name}
- ${settings.player2Name}

Контекст истории: $storyStructure

Создай диалоги, события и 2-3 важных выбора для игроков.
Каждый выбор должен влиять на отношения и развитие сюжета.

Формат: последовательность сообщений с указанием кто говорит и какие есть варианты выбора.
''';

      final chapterContent = await generateStory(chapterPrompt);

      final chapter = GeneratedChapter(
        id: 'chapter_${i + 1}',
        title: 'Глава ${i + 1}',
        description: 'Глава ${i + 1} истории',
        messages: _parseChapterMessages(chapterContent, i),
        order: i + 1,
      );

      chapters.add(chapter);
    }

    return chapters;
  }

  /// Парсинг сообщений главы
  List<GeneratedMessage> _parseChapterMessages(
    String content,
    int chapterNumber,
  ) {
    final messages = <GeneratedMessage>[];

    // Создаем базовые сообщения для главы
    messages.add(
      GeneratedMessage(
        id: 'msg_${chapterNumber}_1',
        characterId: chapterNumber % 2 == 0 ? 'player1' : 'player2',
        text: content.split('\n').first,
        choices: _generateDefaultChoices(chapterNumber),
      ),
    );

    // Добавляем сообщение с выбором
    if (chapterNumber < 4) {
      final choiceMessage = GeneratedMessage(
        id: 'choice_${chapterNumber}',
        characterId: 'system',
        text: 'Что вы будете делать?',
        choices: [
          GeneratedChoice(
            id: 'choice_${chapterNumber}_a',
            text: 'Продолжить разговор',
            nextMessageId: 'msg_${chapterNumber + 1}_1',
          ),
          GeneratedChoice(
            id: 'choice_${chapterNumber}_b',
            text: 'Предложить что-то новое',
            nextMessageId: 'msg_${chapterNumber + 1}_1',
            effects: {'relationship': 5},
          ),
        ],
      );
      messages.add(choiceMessage);
    }

    return messages;
  }

  String _generateTitle(StorySettings settings) {
    final templates = [
      'История ${settings.player1Name} и ${settings.player2Name}',
      'Приключения двоих',
      'Наша сказка',
      'Путешествие вместе',
      'Две судьбы',
    ];
    return templates[DateTime.now().millisecond % templates.length];
  }

  String _generateDescription(StorySettings settings) {
    return 'Интерактивная история о ${settings.player1Name} и ${settings.player2Name} в жанре ${_getGenreDescription(settings.genre)}';
  }

  String _getRelationshipDescription(RelationshipType type) {
    switch (type) {
      case RelationshipType.lovers:
        return 'романтические отношения, влюбленные';
      case RelationshipType.friends:
        return 'дружеские отношения, лучшие друзья';
      case RelationshipType.rivals:
        return 'соперничество, конкуренция';
      case RelationshipType.enemies:
        return 'враждебные отношения, конфликт';
      case RelationshipType.strangers:
        return 'незнакомые люди, первая встреча';
      case RelationshipType.colleagues:
        return 'рабочие отношения, коллеги';
    }
  }

  String _getGenreDescription(StoryGenre genre) {
    switch (genre) {
      case StoryGenre.romance:
        return 'романтика и любовь';
      case StoryGenre.adventure:
        return 'приключения и путешествия';
      case StoryGenre.fantasy:
        return 'фэнтези с магией';
      case StoryGenre.scifi:
        return 'научная фантастика';
      case StoryGenre.mystery:
        return 'детектив и тайны';
      case StoryGenre.horror:
        return 'хоррор и ужасы';
      case StoryGenre.comedy:
        return 'комедия и юмор';
      case StoryGenre.drama:
        return 'драма и переживания';
    }
  }

  List<GeneratedChoice> _generateDefaultChoices(int chapterNumber) {
    return [
      GeneratedChoice(
        id: 'choice_${chapterNumber}_1',
        text: 'Исследовать дальше',
        nextMessageId: 'msg_${chapterNumber + 1}_1',
      ),
      GeneratedChoice(
        id: 'choice_${chapterNumber}_2',
        text: 'Поговорить с партнером',
        nextMessageId: 'msg_${chapterNumber + 1}_1',
        effects: {'relationship': 3},
      ),
    ];
  }
}
