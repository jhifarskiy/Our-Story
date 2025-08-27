// Модель диалога/сообщения в истории
class StoryMessage {
  final String id;
  final String characterId;
  final String text;
  final String? emotion;
  final String? backgroundImage;
  final List<Choice>? choices;
  final DateTime timestamp;

  StoryMessage({
    required this.id,
    required this.characterId,
    required this.text,
    this.emotion,
    this.backgroundImage,
    this.choices,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory StoryMessage.fromJson(Map<String, dynamic> json) {
    return StoryMessage(
      id: json['id'] as String,
      characterId: json['characterId'] as String,
      text: json['text'] as String,
      emotion: json['emotion'] as String?,
      backgroundImage: json['backgroundImage'] as String?,
      choices: json['choices'] != null
          ? (json['choices'] as List)
                .map((choice) => Choice.fromJson(choice))
                .toList()
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'characterId': characterId,
      'text': text,
      'emotion': emotion,
      'backgroundImage': backgroundImage,
      'choices': choices?.map((choice) => choice.toJson()).toList(),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

// Модель выбора игрока
class Choice {
  final String id;
  final String text;
  final String nextMessageId;
  final Map<String, dynamic>? effects; // Эффекты на игру

  const Choice({
    required this.id,
    required this.text,
    required this.nextMessageId,
    this.effects,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] as String,
      text: json['text'] as String,
      nextMessageId: json['nextMessageId'] as String,
      effects: json['effects'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'nextMessageId': nextMessageId,
      'effects': effects,
    };
  }
}
