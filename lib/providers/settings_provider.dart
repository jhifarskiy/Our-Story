import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/story_service.dart';
import 'story_provider.dart';

// Провайдер для управления настройками приложения
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier(ref.read(storyServiceProvider));
});

// Модель настроек приложения
class AppSettings {
  final double textSpeed;
  final double musicVolume;
  final double soundVolume;
  final bool autoPlay;
  final bool showCharacterNames;
  final String language;
  final bool darkMode;

  const AppSettings({
    this.textSpeed = 1.0,
    this.musicVolume = 0.7,
    this.soundVolume = 0.8,
    this.autoPlay = false,
    this.showCharacterNames = true,
    this.language = 'ru',
    this.darkMode = false,
  });

  AppSettings copyWith({
    double? textSpeed,
    double? musicVolume,
    double? soundVolume,
    bool? autoPlay,
    bool? showCharacterNames,
    String? language,
    bool? darkMode,
  }) {
    return AppSettings(
      textSpeed: textSpeed ?? this.textSpeed,
      musicVolume: musicVolume ?? this.musicVolume,
      soundVolume: soundVolume ?? this.soundVolume,
      autoPlay: autoPlay ?? this.autoPlay,
      showCharacterNames: showCharacterNames ?? this.showCharacterNames,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textSpeed': textSpeed,
      'musicVolume': musicVolume,
      'soundVolume': soundVolume,
      'autoPlay': autoPlay,
      'showCharacterNames': showCharacterNames,
      'language': language,
      'darkMode': darkMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      textSpeed: json['textSpeed']?.toDouble() ?? 1.0,
      musicVolume: json['musicVolume']?.toDouble() ?? 0.7,
      soundVolume: json['soundVolume']?.toDouble() ?? 0.8,
      autoPlay: json['autoPlay'] ?? false,
      showCharacterNames: json['showCharacterNames'] ?? true,
      language: json['language'] ?? 'ru',
      darkMode: json['darkMode'] ?? false,
    );
  }
}

// Нотификатор для управления настройками
class SettingsNotifier extends StateNotifier<AppSettings> {
  final StoryService _storyService;

  SettingsNotifier(this._storyService) : super(const AppSettings()) {
    _loadSettings();
  }

  // Загрузка настроек
  Future<void> _loadSettings() async {
    try {
      final settingsData = await _storyService.getSetting<Map>('app_settings');
      if (settingsData != null) {
        state = AppSettings.fromJson(Map<String, dynamic>.from(settingsData));
      }
    } catch (e) {
      print('Ошибка загрузки настроек: $e');
    }
  }

  // Сохранение настроек
  Future<void> _saveSettings() async {
    try {
      await _storyService.saveSetting('app_settings', state.toJson());
    } catch (e) {
      print('Ошибка сохранения настроек: $e');
    }
  }

  // Обновление скорости текста
  Future<void> updateTextSpeed(double speed) async {
    state = state.copyWith(textSpeed: speed);
    await _saveSettings();
  }

  // Обновление громкости музыки
  Future<void> updateMusicVolume(double volume) async {
    state = state.copyWith(musicVolume: volume);
    await _saveSettings();
  }

  // Обновление громкости звуков
  Future<void> updateSoundVolume(double volume) async {
    state = state.copyWith(soundVolume: volume);
    await _saveSettings();
  }

  // Переключение автопроигрывания
  Future<void> toggleAutoPlay() async {
    state = state.copyWith(autoPlay: !state.autoPlay);
    await _saveSettings();
  }

  // Переключение отображения имен персонажей
  Future<void> toggleCharacterNames() async {
    state = state.copyWith(showCharacterNames: !state.showCharacterNames);
    await _saveSettings();
  }

  // Изменение языка
  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  // Переключение темной темы
  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkMode: !state.darkMode);
    await _saveSettings();
  }
}
