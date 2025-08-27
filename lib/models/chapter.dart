import 'story_message.dart';

// Модель главы истории
class Chapter {
  final String id;
  final String title;
  final String description;
  final String thumbnailPath;
  final List<StoryMessage> messages;
  final bool isUnlocked;
  final int order;

  const Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailPath,
    required this.messages,
    this.isUnlocked = false,
    required this.order,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      messages:
          (json['messages'] as List?)
              ?.map((message) => StoryMessage.fromJson(message))
              .toList() ??
          [],
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailPath': thumbnailPath,
      'messages': messages.map((message) => message.toJson()).toList(),
      'isUnlocked': isUnlocked,
      'order': order,
    };
  }

  Chapter copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailPath,
    List<StoryMessage>? messages,
    bool? isUnlocked,
    int? order,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      messages: messages ?? this.messages,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      order: order ?? this.order,
    );
  }
}
