import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _progressKey = 'game_progress';
  static const String _settingsKey = 'app_settings';

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Сохранение данных
  Future<bool> saveString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    return await _prefs!.setString(key, jsonEncode(value));
  }

  // Загрузка данных
  String? getString(String key) {
    return _prefs!.getString(key);
  }

  Map<String, dynamic>? getMap(String key) {
    final jsonString = _prefs!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Удаление данных
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // Очистка всех данных
  Future<bool> clear() async {
    return await _prefs!.clear();
  }

  // Специализированные методы для игры
  Future<bool> saveProgress(Map<String, dynamic> progress) async {
    return await saveMap(_progressKey, progress);
  }

  Map<String, dynamic>? getProgress() {
    return getMap(_progressKey);
  }

  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    return await saveMap(_settingsKey, settings);
  }

  Map<String, dynamic>? getSettings() {
    return getMap(_settingsKey);
  }
}
