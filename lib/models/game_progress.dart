// Модель прогресса игрока
class GameProgress {
  final String currentChapterId;
  final String currentMessageId;
  final Map<String, dynamic> playerChoices;
  final Map<String, int> characterRelationships;
  final DateTime lastPlayed;
  final int totalPlayTime; // в секундах

  const GameProgress({
    required this.currentChapterId,
    required this.currentMessageId,
    this.playerChoices = const {},
    this.characterRelationships = const {},
    required this.lastPlayed,
    this.totalPlayTime = 0,
  });

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      currentChapterId: json['currentChapterId'] as String,
      currentMessageId: json['currentMessageId'] as String,
      playerChoices: Map<String, dynamic>.from(json['playerChoices'] ?? {}),
      characterRelationships: Map<String, int>.from(
        json['characterRelationships'] ?? {},
      ),
      lastPlayed: DateTime.fromMillisecondsSinceEpoch(json['lastPlayed'] ?? 0),
      totalPlayTime: json['totalPlayTime'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentChapterId': currentChapterId,
      'currentMessageId': currentMessageId,
      'playerChoices': playerChoices,
      'characterRelationships': characterRelationships,
      'lastPlayed': lastPlayed.millisecondsSinceEpoch,
      'totalPlayTime': totalPlayTime,
    };
  }

  GameProgress copyWith({
    String? currentChapterId,
    String? currentMessageId,
    Map<String, dynamic>? playerChoices,
    Map<String, int>? characterRelationships,
    DateTime? lastPlayed,
    int? totalPlayTime,
  }) {
    return GameProgress(
      currentChapterId: currentChapterId ?? this.currentChapterId,
      currentMessageId: currentMessageId ?? this.currentMessageId,
      playerChoices: playerChoices ?? this.playerChoices,
      characterRelationships:
          characterRelationships ?? this.characterRelationships,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
    );
  }
}
