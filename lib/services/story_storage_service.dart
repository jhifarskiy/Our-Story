import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_settings.dart';

/// Модель для сохраненной истории
class SavedStory {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final StorySettings settings;
  final List<SavedStorySegment> segments;
  final int currentSegmentIndex;
  final bool isCompleted;
  final String gameMode; // 'solo' или 'multiplayer'

  const SavedStory({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastPlayedAt,
    required this.settings,
    required this.segments,
    required this.currentSegmentIndex,
    required this.isCompleted,
    required this.gameMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'settings': settings.toJson(),
      'segments': segments.map((s) => s.toJson()).toList(),
      'currentSegmentIndex': currentSegmentIndex,
      'isCompleted': isCompleted,
      'gameMode': gameMode,
    };
  }

  factory SavedStory.fromJson(Map<String, dynamic> json) {
    return SavedStory(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      lastPlayedAt: DateTime.parse(json['lastPlayedAt']),
      settings: StorySettings.fromJson(json['settings']),
      segments: (json['segments'] as List)
          .map((s) => SavedStorySegment.fromJson(s))
          .toList(),
      currentSegmentIndex: json['currentSegmentIndex'],
      isCompleted: json['isCompleted'],
      gameMode: json['gameMode'],
    );
  }

  SavedStory copyWith({
    String? title,
    DateTime? lastPlayedAt,
    List<SavedStorySegment>? segments,
    int? currentSegmentIndex,
    bool? isCompleted,
  }) {
    return SavedStory(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      settings: settings,
      segments: segments ?? this.segments,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      gameMode: gameMode,
    );
  }
}

/// Модель для сегмента сохраненной истории
class SavedStorySegment {
  final String text;
  final List<String> choices;
  final int? selectedChoice;
  final DateTime createdAt;

  const SavedStorySegment({
    required this.text,
    required this.choices,
    this.selectedChoice,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'choices': choices,
      'selectedChoice': selectedChoice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedStorySegment.fromJson(Map<String, dynamic> json) {
    return SavedStorySegment(
      text: json['text'],
      choices: List<String>.from(json['choices']),
      selectedChoice: json['selectedChoice'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Сервис для управления сохраненными историями
class StoryStorageService {
  static const String _storiesKey = 'saved_stories';
  static const int _maxStoredStories = 50; // Лимит сохраненных историй

  static StoryStorageService? _instance;
  late SharedPreferences _prefs;

  StoryStorageService._();

  static Future<StoryStorageService> getInstance() async {
    _instance ??= StoryStorageService._();
    _instance!._prefs = await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Сохранить историю
  Future<void> saveStory(SavedStory story) async {
    final stories = await getAllStories();

    // Удаляем старую версию если есть
    stories.removeWhere((s) => s.id == story.id);

    // Добавляем новую
    stories.add(story);

    // Сортируем по последней игре (новые сверху)
    stories.sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt));

    // Ограничиваем количество
    if (stories.length > _maxStoredStories) {
      stories.removeRange(_maxStoredStories, stories.length);
    }

    await _saveStories(stories);
  }

  /// Получить все истории
  Future<List<SavedStory>> getAllStories() async {
    final storiesJson = _prefs.getString(_storiesKey);
    if (storiesJson == null) return [];

    try {
      final List<dynamic> storiesList = jsonDecode(storiesJson);
      return storiesList.map((json) => SavedStory.fromJson(json)).toList();
    } catch (e) {
      print('Error loading stories: $e');
      return [];
    }
  }

  /// Получить историю по ID
  Future<SavedStory?> getStoryById(String id) async {
    final stories = await getAllStories();
    try {
      return stories.firstWhere((story) => story.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Удалить историю
  Future<void> deleteStory(String id) async {
    final stories = await getAllStories();
    stories.removeWhere((story) => story.id == id);
    await _saveStories(stories);
  }

  /// Получить незавершенные истории
  Future<List<SavedStory>> getIncompleteStories() async {
    final stories = await getAllStories();
    return stories.where((story) => !story.isCompleted).toList();
  }

  /// Получить завершенные истории
  Future<List<SavedStory>> getCompletedStories() async {
    final stories = await getAllStories();
    return stories.where((story) => story.isCompleted).toList();
  }

  /// Получить статистику
  Future<Map<String, int>> getStatistics() async {
    final stories = await getAllStories();

    return {
      'total': stories.length,
      'completed': stories.where((s) => s.isCompleted).length,
      'incomplete': stories.where((s) => !s.isCompleted).length,
      'solo': stories.where((s) => s.gameMode == 'solo').length,
      'multiplayer': stories.where((s) => s.gameMode == 'multiplayer').length,
    };
  }

  /// Очистить все истории
  Future<void> clearAllStories() async {
    await _prefs.remove(_storiesKey);
  }

  /// Экспорт истории в текст
  String exportStoryToText(SavedStory story) {
    final buffer = StringBuffer();

    buffer.writeln('=== ${story.title} ===');
    buffer.writeln('Жанр: ${_getGenreText(story.settings.genre.name)}');
    buffer.writeln('Персонаж: ${story.settings.player1Name}');
    buffer.writeln('Дата создания: ${_formatDate(story.createdAt)}');
    buffer.writeln('');

    for (int i = 0; i < story.segments.length; i++) {
      final segment = story.segments[i];
      buffer.writeln('--- Часть ${i + 1} ---');
      buffer.writeln(segment.text);
      buffer.writeln('');

      if (segment.choices.isNotEmpty && segment.selectedChoice != null) {
        buffer.writeln('Выбранное действие:');
        buffer.writeln(
          '${segment.selectedChoice! + 1}. ${segment.choices[segment.selectedChoice!]}',
        );
        buffer.writeln('');
      } else if (segment.choices.isNotEmpty) {
        buffer.writeln('Доступные действия:');
        for (int j = 0; j < segment.choices.length; j++) {
          buffer.writeln('${j + 1}. ${segment.choices[j]}');
        }
        buffer.writeln('');
      }
    }

    if (story.isCompleted) {
      buffer.writeln('--- КОНЕЦ ИСТОРИИ ---');
    } else {
      buffer.writeln('--- ИСТОРИЯ НЕ ЗАВЕРШЕНА ---');
    }

    return buffer.toString();
  }

  Future<void> _saveStories(List<SavedStory> stories) async {
    final storiesJson = jsonEncode(stories.map((s) => s.toJson()).toList());
    await _prefs.setString(_storiesKey, storiesJson);
  }

  String _getGenreText(String genre) {
    switch (genre) {
      case 'romance':
        return 'Романтика';
      case 'adventure':
        return 'Приключения';
      case 'mystery':
        return 'Детектив';
      case 'fantasy':
        return 'Фэнтези';
      case 'scifi':
        return 'Научная фантастика';
      case 'horror':
        return 'Ужасы';
      case 'comedy':
        return 'Комедия';
      case 'drama':
        return 'Драма';
      default:
        return genre;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
