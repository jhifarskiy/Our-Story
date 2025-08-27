import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// AI Story Engine using Ollama HTTP API for offline text generation
class AiStoryEngine {
  static final AiStoryEngine _instance = AiStoryEngine._internal();
  factory AiStoryEngine() => _instance;

  AiStoryEngine._internal();

  bool _isInitialized = false;
  String _model = "tinyllama"; // название модели в Ollama
  final String _baseUrl = "http://127.0.0.1:11434/api";

  bool get isInitialized => _isInitialized;

  /// Инициализация Ollama (проверка, что API доступно)
  Future<void> init({String model = "tinyllama"}) async {
    if (_isInitialized) return;

    _model = model;

    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/tags"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception("❌ Ollama API not available: ${response.body}");
      }

      print("✅ Ollama initialized. Available models:\n${response.body}");
      _isInitialized = true;
    } catch (e) {
      throw Exception("⚠️ Ollama API not responding: $e");
    }
  }

  /// Синхронная генерация текста (полный ответ за раз)
  Future<String> generateText(String prompt) async {
    if (!_isInitialized) {
      throw Exception("⚠️ Model not initialized. Call init() first.");
    }

    final response = await http.post(
      Uri.parse("$_baseUrl/generate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"model": _model, "prompt": prompt, "stream": false}),
    );

    if (response.statusCode != 200) {
      throw Exception("❌ Ollama error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["response"]?.toString().trim() ?? "";
  }

  /// Потоковая генерация текста (по токенам/чанкам)
  Stream<String> generateStream(String prompt) async* {
    if (!_isInitialized) {
      throw Exception("⚠️ Model not initialized. Call init() first.");
    }

    final request = http.Request("POST", Uri.parse("$_baseUrl/generate"))
      ..headers["Content-Type"] = "application/json"
      ..body = jsonEncode({"model": _model, "prompt": prompt, "stream": true});

    final client = http.Client();
    final response = await client.send(request);

    if (response.statusCode != 200) {
      final err = await response.stream.bytesToString();
      throw Exception("❌ Ollama stream error: $err");
    }

    final stream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line);
        if (data.containsKey("response")) {
          yield data["response"];
        }
      } catch (_) {
        // если не JSON — игнорируем
      }
    }

    client.close();
  }

  /// Очистка ресурсов
  Future<void> dispose() async {
    _isInitialized = false;
    print("🧹 Engine disposed");
  }
}

/// Тестовый запуск
Future<void> main() async {
  final engine = AiStoryEngine();

  print("🚀 Starting Ollama HTTP test...");

  try {
    await engine.init(model: "tinyllama");

    final response = await engine.generateText(
      "Придумай короткую сказку про дракона.",
    );
    print("LLM: $response");

    print("\n--- Stream test ---");
    await for (final token in engine.generateStream(
      "Напиши диалог рыцаря и мага.",
    )) {
      stdout.write(token);
    }
  } finally {
    await engine.dispose();
  }
}
