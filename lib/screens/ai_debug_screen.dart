import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/google_ai_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/animated_button.dart';

class AiDebugScreen extends ConsumerStatefulWidget {
  const AiDebugScreen({super.key});

  @override
  ConsumerState<AiDebugScreen> createState() => _AiDebugScreenState();
}

class _AiDebugScreenState extends ConsumerState<AiDebugScreen> {
  final GoogleAiService _aiService = GoogleAiService();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<TestResult> _testResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _promptController.text =
        "Придумай короткую историю про кота в космосе. Не больше 3 предложений.";
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _runSingleTest() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prompt = _promptController.text.trim();
      final startTime = DateTime.now();

      final response = await _aiService.generateText(prompt);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final result = TestResult(
        id: DateTime.now().millisecondsSinceEpoch,
        prompt: prompt,
        response: response,
        timestamp: DateTime.now(),
        duration: duration,
        success: !response.startsWith('Ошибка:'),
      );

      setState(() {
        _testResults.insert(0, result);
        _isLoading = false;
      });

      // Автоскролл вниз
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      final result = TestResult(
        id: DateTime.now().millisecondsSinceEpoch,
        prompt: _promptController.text.trim(),
        response: 'Ошибка: $e',
        timestamp: DateTime.now(),
        duration: Duration.zero,
        success: false,
      );

      setState(() {
        _testResults.insert(0, result);
        _isLoading = false;
      });
    }
  }

  Future<void> _runMultipleTests() async {
    final testPrompts = [
      "Назови текущую дату и время",
      "Какая сегодня погода в Москве?",
      "Расскажи последние новости",
      "Сгенерируй случайное число от 1 до 1000000",
      "Придумай уникальную историю про ${DateTime.now().millisecondsSinceEpoch}",
      "Ответь одним словом: ${['красный', 'синий', 'зеленый', 'желтый'][DateTime.now().millisecond % 4]}?",
    ];

    for (final prompt in testPrompts) {
      _promptController.text = prompt;
      await _runSingleTest();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  void _copyResult(TestResult result) {
    final text =
        '''
ПРОМТ: ${result.prompt}

ОТВЕТ: ${result.response}

ВРЕМЯ: ${result.timestamp}
ДЛИТЕЛЬНОСТЬ: ${result.duration.inMilliseconds}ms
УСПЕХ: ${result.success}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Результат скопирован')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Тест ИИ подключения',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _clearResults,
                      icon: const Icon(Icons.clear_all, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Поле ввода промпта
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Введите промпт для тестирования...',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Кнопки управления
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        onPressed: _isLoading ? null : _runSingleTest,
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Тестируем...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            : const Text(
                                'Один тест',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedButton(
                        onPressed: _isLoading ? null : _runMultipleTests,
                        child: const Text(
                          'Серия тестов',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Статистика
              if (_testResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Всего', '${_testResults.length}'),
                      _buildStat(
                        'Успешно',
                        '${_testResults.where((r) => r.success).length}',
                      ),
                      _buildStat(
                        'Ошибок',
                        '${_testResults.where((r) => !r.success).length}',
                      ),
                      _buildStat(
                        'Ср. время',
                        '${_testResults.map((r) => r.duration.inMilliseconds).reduce((a, b) => a + b) ~/ _testResults.length}ms',
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Результаты тестов
              Expanded(
                child: _testResults.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет результатов тестирования.\nЗапустите тест для проверки ИИ.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _testResults.length,
                        itemBuilder: (context, index) {
                          final result = _testResults[index];
                          return _buildResultCard(result);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildResultCard(TestResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: result.success
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.success
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          result.prompt.length > 50
              ? '${result.prompt.substring(0, 50)}...'
              : result.prompt,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          '${_formatTime(result.timestamp)} • ${result.duration.inMilliseconds}ms • ${result.success ? "✓" : "✗"}',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ПРОМПТ:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.prompt,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  'ОТВЕТ:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.response,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${result.id}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _copyResult(result),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Копировать',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

class TestResult {
  final int id;
  final String prompt;
  final String response;
  final DateTime timestamp;
  final Duration duration;
  final bool success;

  const TestResult({
    required this.id,
    required this.prompt,
    required this.response,
    required this.timestamp,
    required this.duration,
    required this.success,
  });
}
