import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';
import '../services/story_service.dart';
import '../services/story_storage_service.dart';
import '../models/story_settings.dart';

class SoloStoryPlayScreen extends ConsumerStatefulWidget {
  final StorySettings settings;
  final SavedStory? savedStory;

  const SoloStoryPlayScreen({
    super.key,
    required this.settings,
    this.savedStory,
  });

  @override
  ConsumerState<SoloStoryPlayScreen> createState() =>
      _SoloStoryPlayScreenState();
}

class _SoloStoryPlayScreenState extends ConsumerState<SoloStoryPlayScreen>
    with TickerProviderStateMixin {
  final StoryService _storyService = StoryService();
  late StoryStorageService _storageService;

  List<SoloStorySegment> _storySegments = [];
  int _currentSegmentIndex = 0;
  bool _isGenerating = false;
  bool _isGameComplete = false;
  String? _storyId;

  late AnimationController _fadeController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.savedStory != null) {
      _loadSavedStory();
    } else {
      _startNewStory();
    }
  }

  Future<void> _initializeStorage() async {
    _storageService = await StoryStorageService.getInstance();
  }

  void _loadSavedStory() {
    final savedStory = widget.savedStory!;
    _storyId = savedStory.id;

    // Конвертируем сохраненные сегменты в SoloStorySegment
    _storySegments = savedStory.segments.map((savedSegment) {
      return SoloStorySegment(
        text: savedSegment.text,
        choices: savedSegment.choices,
        index: _storySegments.length,
      );
    }).toList();

    _currentSegmentIndex = savedStory.currentSegmentIndex;
    _isGameComplete = savedStory.isCompleted;

    setState(() {});
    _fadeController.forward();
  }

  void _startNewStory() {
    _storyId = DateTime.now().millisecondsSinceEpoch.toString();
    _generateFirstSegment();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _generateFirstSegment() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final prompt =
          '''
Создай начало интерактивной истории в жанре "${_getGenreText(widget.settings.genre.name)}" с главным персонажем "${widget.settings.player1Name}".

Место действия: ${widget.settings.setting}
Уровень сложности: ${widget.settings.complexityLevel}/5

${widget.settings.customPrompt.isNotEmpty ? 'Дополнительные требования: ${widget.settings.customPrompt}' : ''}

Создай захватывающее начало истории (2-3 абзаца) и предложи 3 варианта действий для игрока.

Формат ответа:
ИСТОРИЯ: [начало истории 2-3 абзаца]
ВАРИАНТЫ:
1. [первый вариант действия]
2. [второй вариант действия]
3. [третий вариант действия]
''';

      final response = await _storyService.generateStory(prompt);
      final segment = _parseStoryResponse(response, 0);

      setState(() {
        _storySegments.add(segment);
        _isGenerating = false;
      });

      // Сохраняем первый сегмент
      await _saveProgress();

      await _fadeController.forward();
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError('Ошибка генерации: $e');
    }
  }

  Future<void> _makeChoice(int choiceIndex) async {
    if (_isGenerating || _isGameComplete) return;

    setState(() {
      _isGenerating = true;
      _currentSegmentIndex++;
    });

    try {
      final currentSegment = _storySegments[_currentSegmentIndex - 1];
      final chosenAction = currentSegment.choices[choiceIndex];

      final storyContext = _storySegments.map((s) => s.text).join('\n\n');

      final prompt =
          '''
История до сих пор:
$storyContext

Игрок "${widget.settings.player1Name}" выбрал: "$chosenAction"

Развей события дальше с учетом выбора игрока. ${_storySegments.length >= 4 ? 'Это должна быть финальная сцена с завершением истории.' : 'Предложи 3 новых варианта действий.'}

${_storySegments.length >= 4 ? 'Формат ответа:\nФИНАЛ: [завершение истории 2-3 абзаца]' : '''Формат ответа:
ИСТОРИЯ: [продолжение истории 2-3 абзаца]
ВАРИАНТЫ:
1. [первый вариант действия]
2. [второй вариант действия]
3. [третий вариант действия]'''}
''';

      final response = await _storyService.generateStory(prompt);
      final segment = _parseStoryResponse(response, _storySegments.length);

      setState(() {
        _storySegments.add(segment);
        _isGenerating = false;
        if (segment.choices.isEmpty) {
          _isGameComplete = true;
        }
      });

      // Сохраняем прогресс
      await _saveProgress();

      // Плавная анимация появления
      _fadeController.reset();
      await _fadeController.forward();

      // Небольшая задержка для лучшего UX
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _currentSegmentIndex--;
      });
      _showError('Ошибка генерации: $e');
    }
  }

  SoloStorySegment _parseStoryResponse(String response, int index) {
    try {
      if (response.contains('ФИНАЛ:')) {
        final storyText = response.split('ФИНАЛ:')[1].trim();
        return SoloStorySegment(text: storyText, choices: [], index: index);
      }

      final parts = response.split('ВАРИАНТЫ:');
      final storyText = parts[0].replaceAll('ИСТОРИЯ:', '').trim();

      final choicesText = parts.length > 1 ? parts[1] : '';
      final choices = <String>[];

      final lines = choicesText.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith(RegExp(r'[123]\.'))) {
          choices.add(trimmed.substring(2).trim());
        }
      }

      if (choices.isEmpty && !response.contains('ФИНАЛ:')) {
        choices.addAll([
          'Продолжить исследование',
          'Принять решение',
          'Поговорить с кем-то',
        ]);
      }

      return SoloStorySegment(text: storyText, choices: choices, index: index);
    } catch (e) {
      return SoloStorySegment(
        text: response,
        choices: response.contains('ФИНАЛ:')
            ? []
            : [
                'Продолжить исследование',
                'Принять решение',
                'Поговорить с кем-то',
              ],
        index: index,
      );
    }
  }

  Future<void> _saveProgress() async {
    if (_storyId == null) return;

    try {
      final savedSegments = _storySegments.map((segment) {
        return SavedStorySegment(
          text: segment.text,
          choices: segment.choices,
          createdAt: DateTime.now(),
        );
      }).toList();

      final savedStory = SavedStory(
        id: _storyId!,
        title: _generateStoryTitle(),
        createdAt: widget.savedStory?.createdAt ?? DateTime.now(),
        lastPlayedAt: DateTime.now(),
        settings: widget.settings,
        segments: savedSegments,
        currentSegmentIndex: _currentSegmentIndex,
        isCompleted: _isGameComplete,
        gameMode: 'solo',
      );

      await _storageService.saveStory(savedStory);
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  String _generateStoryTitle() {
    if (_storySegments.isEmpty) {
      return '${_getGenreText(widget.settings.genre.name)} - ${widget.settings.player1Name}';
    }

    // Берем первые слова из первого сегмента как заголовок
    final firstSegment = _storySegments.first.text;
    final words = firstSegment.split(' ').take(5).join(' ');
    return words.length > 30 ? '${words.substring(0, 30)}...' : words;
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _storySegments.clear();
      _currentSegmentIndex = 0;
      _isGameComplete = false;
    });
    _generateFirstSegment();
  }

  String _getGenreText(String genre) {
    switch (genre) {
      case 'romance':
        return 'романтика';
      case 'adventure':
        return 'приключения';
      case 'mystery':
        return 'детектив';
      case 'fantasy':
        return 'фэнтези';
      case 'scifi':
        return 'научная фантастика';
      case 'horror':
        return 'ужасы';
      case 'comedy':
        return 'комедия';
      case 'drama':
        return 'драма';
      default:
        return genre;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.settings.player1Name} - ${_getGenreText(widget.settings.genre.name)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _restartGame,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: _isGenerating && _storySegments.isEmpty
                    ? _buildLoadingWidget()
                    : _storySegments.isEmpty
                    ? _buildEmptyState()
                    : _buildStoryContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Генерируем вашу историю...',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Начинаем вашу историю...',
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
    );
  }

  Widget _buildStoryContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // История - увеличенное окно
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(
              minHeight: 400, // Минимальная высота для истории
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._storySegments.map(
                    (segment) => _buildStorySegment(segment),
                  ),
                  if (_isGenerating)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Выборы
          if (!_isGameComplete &&
              _storySegments.isNotEmpty &&
              !_isGenerating &&
              _storySegments[_currentSegmentIndex].choices.isNotEmpty)
            _buildChoices(_storySegments[_currentSegmentIndex]),

          // Кнопка завершения
          if (_isGameComplete)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _restartGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Новая история'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.home),
                      label: const Text('Главная'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Отступ внизу для удобного скроллинга
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStorySegment(SoloStorySegment segment) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Text(
        segment.text,
        style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.6),
      ),
    );
  }

  Widget _buildChoices(SoloStorySegment segment) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите действие:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...segment.choices.asMap().entries.map((entry) {
            final index = entry.key;
            final choice = entry.value;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _makeChoice(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${index + 1}. $choice',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Модель сегмента истории для соло игры
class SoloStorySegment {
  final String text;
  final List<String> choices;
  final int index;

  SoloStorySegment({
    required this.text,
    required this.choices,
    required this.index,
  });
}
