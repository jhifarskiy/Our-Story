import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_secrets.dart';

class GoogleAiService {
  late final GenerativeModel _model;
  static const String _requestCountKey = 'ai_request_count';
  static const String _lastResetDateKey = 'ai_last_reset_date';

  GoogleAiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppSecrets.googleAiApiKey,
    );
  }

  Future<void> _incrementRequestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastResetDate = prefs.getString(_lastResetDateKey);

    // Сброс счетчика если новый день
    if (lastResetDate != today) {
      await prefs.setInt(_requestCountKey, 0);
      await prefs.setString(_lastResetDateKey, today);
    }

    final currentCount = prefs.getInt(_requestCountKey) ?? 0;
    await prefs.setInt(_requestCountKey, currentCount + 1);
  }

  Future<int> getCurrentRequestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastResetDate = prefs.getString(_lastResetDateKey);

    if (lastResetDate != today) {
      return 0;
    }

    return prefs.getInt(_requestCountKey) ?? 0;
  }

  bool _isValidStoryResponse(String response) {
    // Проверяем базовую структуру ответа
    if (response.contains('ФИНАЛ:')) {
      return response.length > 50; // Минимальная длина для финала
    }

    return response.contains('ИСТОРИЯ:') ||
        response.contains('ВАРИАНТЫ:') ||
        response.length > 100; // Минимальная длина для истории
  }

  String _getFallbackResponse() {
    return '''ИСТОРИЯ: В этот момент что-то неожиданное происходит в вашей истории. Вы чувствуете, что приключение только начинается.

ВАРИАНТЫ:
1. Внимательно осмотреться вокруг
2. Продолжить идти вперёд
3. Попытаться понять, что происходит''';
  }

  /// Стрим генерации текста
  Stream<String> generateTextStream(String prompt) async* {
    try {
      await _incrementRequestCount();

      final content = [Content.text(prompt)];
      final response = _model.generateContentStream(content);

      String fullResponse = '';
      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null) {
          fullResponse += text;
          yield text;
        }
      }

      // Проверяем качество ответа
      if (fullResponse.trim().isEmpty) {
        throw Exception('ИИ вернул пустой ответ');
      }

      if (!_isValidStoryResponse(fullResponse)) {
        throw Exception('ИИ вернул ответ в неправильном формате');
      }
    } catch (e) {
      // Логируем ошибку для отладки
      print('AI Service Error: $e');

      // Возвращаем fallback ответ
      yield _getFallbackResponse();
      throw Exception('Ошибка генерации ИИ: $e');
    }
  }

  /// Генерация текста с улучшенной обработкой ошибок и retry
  Future<String> generateTextWithRetry(
    String prompt, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        String result = '';
        await for (final chunk in generateTextStream(prompt)) {
          result += chunk;
        }
        return result;
      } catch (e) {
        if (attempt == maxRetries - 1) {
          return _getFallbackResponse();
        }
        // Ждем перед повтором
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    return _getFallbackResponse();
  }

  /// Основной метод генерации текста (используется в story_service)
  Future<String> generateText(String prompt) async {
    return await generateTextWithRetry(prompt);
  }
}
