import 'package:flutter/material.dart';
import '../main.dart';

class AiStoryScreen extends StatefulWidget {
  const AiStoryScreen({super.key});

  @override
  State<AiStoryScreen> createState() => _AiStoryScreenState();
}

class _AiStoryScreenState extends State<AiStoryScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _generatedStory = '';
  bool _isGenerating = false;
  bool _isEngineReady = false;

  @override
  void initState() {
    super.initState();
    _checkEngineStatus();
  }

  void _checkEngineStatus() {
    setState(() {
      _isEngineReady = OurStoryApp.aiEngine.isInitialized;
    });

    // Если движок еще не готов, проверяем каждую секунду
    if (!_isEngineReady) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _checkEngineStatus();
        }
      });
    }
  }

  void _generateStory() async {
    if (!_isEngineReady) {
      _showSnackBar('AI движок еще не готов. Пожалуйста, подождите...');
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showSnackBar('Введите описание истории');
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedStory = '';
    });

    try {
      String story = '';
      await for (final token in OurStoryApp.aiEngine.generateStream(prompt)) {
        setState(() {
          story += token;
          _generatedStory = story; // обновляем UI по мере генерации
        });
      }

      _showSnackBar('История успешно сгенерирована!');
    } catch (e) {
      _showSnackBar('Ошибка генерации: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }

  void _clearStory() {
    setState(() {
      _generatedStory = '';
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Генератор Историй'),
        backgroundColor: const Color(0xFF6B4E3D),
        foregroundColor: Colors.white,
        actions: [
          if (_generatedStory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearStory,
              tooltip: 'Очистить',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Статус AI движка
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isEngineReady
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isEngineReady ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isEngineReady
                            ? Icons.check_circle
                            : Icons.hourglass_empty,
                        color: _isEngineReady ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEngineReady
                            ? 'AI движок готов к работе'
                            : 'Инициализация AI движка...',
                        style: TextStyle(
                          color: _isEngineReady ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Поле ввода промпта
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Опишите желаемую историю:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _promptController,
                          decoration: const InputDecoration(
                            hintText:
                                'Например: романтическая встреча в зимнем лесу',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 4,
                          enabled: !_isGenerating,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_isGenerating || !_isEngineReady)
                                ? null
                                : _generateStory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4E3D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isGenerating
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Генерирую историю...'),
                                    ],
                                  )
                                : const Text(
                                    'Сгенерировать историю',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Область отображения истории
                Expanded(
                  child: Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_stories,
                                color: Color(0xFF6B4E3D),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Сгенерированная история:',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF6B4E3D),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                _generatedStory.isEmpty
                                    ? 'Здесь появится ваша сгенерированная история...\n\n💡 Введите описание желаемой истории выше и нажмите "Сгенерировать историю"'
                                    : _generatedStory,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: _generatedStory.isEmpty
                                      ? Colors.grey[600]
                                      : Colors.black87,
                                  fontFamily: 'Cinzel',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Информационная панель
                if (_generatedStory.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'История создана с помощью AI. Длина: ${_generatedStory.length} символов',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
