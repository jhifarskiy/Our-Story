// Модель персонажа в истории
class Character {
  final String id;
  final String name;
  final String avatarPath;
  final String description;
  final Map<String, String> emotions; // emotion_name -> image_path

  const Character({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.description,
    this.emotions = const {},
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarPath: json['avatarPath'] as String,
      description: json['description'] as String,
      emotions: Map<String, String>.from(json['emotions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarPath': avatarPath,
      'description': description,
      'emotions': emotions,
    };
  }
}
