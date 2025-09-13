// Модель настроек для создания истории
class StorySettings {
  final String player1Name;
  final String player2Name;
  final StoryGenre genre;
  final RelationshipType relationshipType;
  final String setting;
  final int storyLength;
  final int complexityLevel;
  final String customPrompt;

  const StorySettings({
    required this.player1Name,
    required this.player2Name,
    required this.genre,
    required this.relationshipType,
    required this.setting,
    required this.storyLength,
    required this.complexityLevel,
    this.customPrompt = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'player1Name': player1Name,
      'player2Name': player2Name,
      'genre': genre.name,
      'relationshipType': relationshipType.name,
      'setting': setting,
      'storyLength': storyLength,
      'complexityLevel': complexityLevel,
      'customPrompt': customPrompt,
    };
  }

  factory StorySettings.fromJson(Map<String, dynamic> json) {
    return StorySettings(
      player1Name: json['player1Name'] as String,
      player2Name: json['player2Name'] as String,
      genre: StoryGenre.values.firstWhere(
        (e) => e.name == json['genre'],
        orElse: () => StoryGenre.romance,
      ),
      relationshipType: RelationshipType.values.firstWhere(
        (e) => e.name == json['relationshipType'],
        orElse: () => RelationshipType.lovers,
      ),
      setting: json['setting'] as String,
      storyLength: json['storyLength'] as int,
      complexityLevel: json['complexityLevel'] as int,
      customPrompt: json['customPrompt'] as String? ?? '',
    );
  }

  StorySettings copyWith({
    String? player1Name,
    String? player2Name,
    StoryGenre? genre,
    RelationshipType? relationshipType,
    String? setting,
    int? storyLength,
    int? complexityLevel,
    String? customPrompt,
  }) {
    return StorySettings(
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      genre: genre ?? this.genre,
      relationshipType: relationshipType ?? this.relationshipType,
      setting: setting ?? this.setting,
      storyLength: storyLength ?? this.storyLength,
      complexityLevel: complexityLevel ?? this.complexityLevel,
      customPrompt: customPrompt ?? this.customPrompt,
    );
  }
}

// Жанры историй
enum StoryGenre {
  romance,
  adventure,
  fantasy,
  scifi,
  mystery,
  horror,
  comedy,
  drama,
}

// Типы отношений между персонажами
enum RelationshipType {
  lovers, // Влюбленные
  friends, // Друзья
  rivals, // Соперники
  enemies, // Враги
  strangers, // Незнакомцы
  colleagues, // Коллеги
}

// Состояние генерации истории
class GeneratedStory {
  final String title;
  final String description;
  final List<GeneratedChapter> chapters;
  final Map<String, String> characters;
  final DateTime createdAt;

  const GeneratedStory({
    required this.title,
    required this.description,
    required this.chapters,
    required this.characters,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'characters': characters,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GeneratedStory.fromJson(Map<String, dynamic> json) {
    return GeneratedStory(
      title: json['title'] as String,
      description: json['description'] as String,
      chapters: (json['chapters'] as List)
          .map((c) => GeneratedChapter.fromJson(c))
          .toList(),
      characters: Map<String, String>.from(json['characters']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Глава сгенерированной истории
class GeneratedChapter {
  final String id;
  final String title;
  final String description;
  final List<GeneratedMessage> messages;
  final int order;

  const GeneratedChapter({
    required this.id,
    required this.title,
    required this.description,
    required this.messages,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'messages': messages.map((m) => m.toJson()).toList(),
      'order': order,
    };
  }

  factory GeneratedChapter.fromJson(Map<String, dynamic> json) {
    return GeneratedChapter(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      messages: (json['messages'] as List)
          .map((m) => GeneratedMessage.fromJson(m))
          .toList(),
      order: json['order'] as int,
    );
  }
}

// Сообщение в сгенерированной истории
class GeneratedMessage {
  final String id;
  final String characterId;
  final String text;
  final String? emotion;
  final List<GeneratedChoice>? choices;
  final MessageType type;

  const GeneratedMessage({
    required this.id,
    required this.characterId,
    required this.text,
    this.emotion,
    this.choices,
    this.type = MessageType.dialogue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'characterId': characterId,
      'text': text,
      'emotion': emotion,
      'choices': choices?.map((c) => c.toJson()).toList(),
      'type': type.name,
    };
  }

  factory GeneratedMessage.fromJson(Map<String, dynamic> json) {
    return GeneratedMessage(
      id: json['id'] as String,
      characterId: json['characterId'] as String,
      text: json['text'] as String,
      emotion: json['emotion'] as String?,
      choices: json['choices'] != null
          ? (json['choices'] as List)
                .map((c) => GeneratedChoice.fromJson(c))
                .toList()
          : null,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.dialogue,
      ),
    );
  }
}

// Выбор в сгенерированной истории
class GeneratedChoice {
  final String id;
  final String text;
  final String nextMessageId;
  final Map<String, dynamic>? effects;
  final String? requiredPlayer; // null = оба игрока, 'player1' или 'player2'

  const GeneratedChoice({
    required this.id,
    required this.text,
    required this.nextMessageId,
    this.effects,
    this.requiredPlayer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'nextMessageId': nextMessageId,
      'effects': effects,
      'requiredPlayer': requiredPlayer,
    };
  }

  factory GeneratedChoice.fromJson(Map<String, dynamic> json) {
    return GeneratedChoice(
      id: json['id'] as String,
      text: json['text'] as String,
      nextMessageId: json['nextMessageId'] as String,
      effects: json['effects'] as Map<String, dynamic>?,
      requiredPlayer: json['requiredPlayer'] as String?,
    );
  }
}

// Типы сообщений
enum MessageType {
  dialogue, // Диалог
  narration, // Повествование
  choice, // Момент выбора
  event, // Событие
}

// Состояние мультиплеерной сессии
class MultiplayerSession {
  final String code;
  final String hostName;
  final List<String> players;
  final GeneratedStory? story;
  final Map<String, dynamic> gameState;
  final DateTime createdAt;

  const MultiplayerSession({
    required this.code,
    required this.hostName,
    this.players = const [],
    this.story,
    this.gameState = const {},
    required this.createdAt,
  });

  MultiplayerSession copyWith({
    String? code,
    String? hostName,
    List<String>? players,
    GeneratedStory? story,
    Map<String, dynamic>? gameState,
    DateTime? createdAt,
  }) {
    return MultiplayerSession(
      code: code ?? this.code,
      hostName: hostName ?? this.hostName,
      players: players ?? this.players,
      story: story ?? this.story,
      gameState: gameState ?? this.gameState,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MultiplayerState {
  final String? sessionCode;
  final List<String> connectedPlayers;
  final bool isHost;
  final bool isConnected;
  final String? error;

  const MultiplayerState({
    this.sessionCode,
    this.connectedPlayers = const [],
    this.isHost = false,
    this.isConnected = false,
    this.error,
  });

  MultiplayerState copyWith({
    String? sessionCode,
    List<String>? connectedPlayers,
    bool? isHost,
    bool? isConnected,
    String? error,
  }) {
    return MultiplayerState(
      sessionCode: sessionCode ?? this.sessionCode,
      connectedPlayers: connectedPlayers ?? this.connectedPlayers,
      isHost: isHost ?? this.isHost,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
    );
  }
}

// Статус мультиплеерной сессии
enum SessionStatus {
  waiting, // Ожидание второго игрока
  ready, // Готов к игре
  playing, // Игра идет
  paused, // Пауза
  finished, // Завершена
  disconnected, // Потеряно соединение
}
