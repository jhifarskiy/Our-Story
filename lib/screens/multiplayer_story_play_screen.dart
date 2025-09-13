import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';
import '../services/story_service.dart';
import '../services/story_storage_service.dart';
import '../models/story_settings.dart';

class MultiplayerStoryPlayScreen extends ConsumerStatefulWidget {
  final StorySettings settings;
  final bool isHost;
  final String? sessionCode;
  final SavedStory? savedStory;

  const MultiplayerStoryPlayScreen({
    super.key,
    required this.settings,
    required this.isHost,
    this.sessionCode,
    this.savedStory,
  });

  @override
  ConsumerState<MultiplayerStoryPlayScreen> createState() =>
      _MultiplayerStoryPlayScreenState();
}

class _MultiplayerStoryPlayScreenState
    extends ConsumerState<MultiplayerStoryPlayScreen>
    with TickerProviderStateMixin {
  final StoryService _storyService = StoryService();

  List<StorySegment> _storySegments = [];
  int _currentSegmentIndex = 0;
  bool _isGenerating = false;
  bool _isGameComplete = false;

  // Мультиплеер состояние
  bool _waitingForOtherPlayer = false;
  int? _myChoice;
  int? _otherPlayerChoice;
  String _otherPlayerName = '';

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _otherPlayerName = widget.isHost
        ? widget.settings.player2Name
        : widget.settings.player1Name;

    if (widget.isHost) {
      _generateFirstSegment();
    } else {
      _waitForHostToStart();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _generateFirstSegment() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final prompt =
          '''
Создай начало интерактивной истории в жанре "${_getGenreText(widget.settings.genre)}" с двумя персонажами: "${widget.settings.player1Name}" и "${widget.settings.player2Name}".

Тип отношений: ${_getRelationshipText(widget.settings.relationshipType)}
Место действия: ${widget.settings.setting}
Уровень сложности: ${widget.settings.complexityLevel}/5

${widget.settings.customPrompt.isNotEmpty ? 'Дополнительные требования: ${widget.settings.customPrompt}' : ''}

Создай захватывающее начало истории (2-3 абзаца) и предложи 3 варианта действий для игроков.

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

      // Синхронизируем с другим игроком
      if (widget.isHost) {
        _syncSegmentWithGuest(segment);
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError('Ошибка генерации: $e');
    }
  }

  Future<void> _waitForHostToStart() async {
    setState(() {
      _isGenerating = true;
    });

    // Ждем синхронизации с хостом
    // В реальном приложении здесь была бы логика сетевой синхронизации
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
    });
  }

  Future<void> _makeChoice(int choiceIndex) async {
    setState(() {
      _myChoice = choiceIndex;
      _waitingForOtherPlayer = true;
    });

    // Симулируем ожидание выбора другого игрока
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _otherPlayerChoice =
          (choiceIndex + 1) % 3; // Симуляция выбора другого игрока
      _waitingForOtherPlayer = false;
    });

    // Генерируем продолжение на основе выборов обоих игроков
    await _generateNextSegment();
  }

  Future<void> _generateNextSegment() async {
    if (_myChoice == null || _otherPlayerChoice == null) return;

    setState(() {
      _isGenerating = true;
      _currentSegmentIndex++;
    });

    try {
      final currentSegment = _storySegments[_currentSegmentIndex - 1];
      final myChoiceText = currentSegment.choices[_myChoice!];
      final otherChoiceText = currentSegment.choices[_otherPlayerChoice!];

      final myName = widget.isHost
          ? widget.settings.player1Name
          : widget.settings.player2Name;
      final otherName = widget.isHost
          ? widget.settings.player2Name
          : widget.settings.player1Name;

      final storyContext = _storySegments.map((s) => s.text).join('\n\n');

      final prompt =
          '''
Продолжи интерактивную историю. 

Контекст предыдущих событий:
$storyContext

$myName выбрал: "$myChoiceText"
$otherName выбрал: "$otherChoiceText"

Развей события дальше с учетом выборов обоих игроков. ${_storySegments.length >= 4 ? 'Это должна быть финальная сцена с завершением истории.' : 'Предложи 3 новых варианта действий.'}

${_storySegments.length >= 4 ? 'Формат ответа:\nФИНАЛ: [завершение истории 2-3 абзаца]' : '''Формат ответа:
ИСТОРИЯ: [2-3 абзаца развития событий]
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
        _myChoice = null;
        _otherPlayerChoice = null;
        if (segment.choices.isEmpty) {
          _isGameComplete = true;
        }
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _myChoice = null;
        _otherPlayerChoice = null;
      });
      _showError('Ошибка генерации: $e');
    }
  }

  void _syncSegmentWithGuest(StorySegment segment) {
    // В реальном приложении здесь была бы отправка данных гостю
    print('Синхронизируем сегмент с гостем: ${segment.text}');
  }

  StorySegment _parseStoryResponse(String response, int index) {
    try {
      if (response.contains('ФИНАЛ:')) {
        final storyText = response.split('ФИНАЛ:')[1].trim();
        return StorySegment(text: storyText, choices: [], index: index);
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
          'Поговорить с партнером',
          'Принять решение',
        ]);
      }

      return StorySegment(text: storyText, choices: choices, index: index);
    } catch (e) {
      return StorySegment(
        text: response,
        choices: response.contains('ФИНАЛ:')
            ? []
            : [
                'Продолжить исследование',
                'Поговорить с партнером',
                'Принять решение',
              ],
        index: index,
      );
    }
  }

  String _getGenreText(StoryGenre genre) {
    switch (genre) {
      case StoryGenre.romance:
        return 'романтика';
      case StoryGenre.adventure:
        return 'приключения';
      case StoryGenre.fantasy:
        return 'фэнтези';
      case StoryGenre.scifi:
        return 'научная фантастика';
      case StoryGenre.mystery:
        return 'детектив';
      case StoryGenre.horror:
        return 'хоррор';
      case StoryGenre.comedy:
        return 'комедия';
      case StoryGenre.drama:
        return 'драма';
    }
  }

  String _getRelationshipText(RelationshipType type) {
    switch (type) {
      case RelationshipType.lovers:
        return 'влюбленные';
      case RelationshipType.friends:
        return 'друзья';
      case RelationshipType.rivals:
        return 'соперники';
      case RelationshipType.enemies:
        return 'враги';
      case RelationshipType.strangers:
        return 'незнакомцы';
      case RelationshipType.colleagues:
        return 'коллеги';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _restartGame() {
    setState(() {
      _storySegments.clear();
      _currentSegmentIndex = 0;
      _isGameComplete = false;
      _myChoice = null;
      _otherPlayerChoice = null;
      _waitingForOtherPlayer = false;
    });

    if (widget.isHost) {
      _generateFirstSegment();
    } else {
      _waitForHostToStart();
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${widget.settings.player1Name} & ${widget.settings.player2Name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cinzel',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.isHost ? 'Вы - хост' : 'Вы - гость',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontFamily: 'Cinzel',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Индикатор прогресса
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${_currentSegmentIndex + 1}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Контент истории
              Expanded(
                child: _isGenerating && _storySegments.isEmpty
                    ? _buildLoadingScreen()
                    : _storySegments.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет контента',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : _buildStorySegment(_storySegments[_currentSegmentIndex]),
              ),

              // Кнопки управления для завершенной игры
              if (_isGameComplete)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.isHost ? _restartGame : null,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            widget.isHost ? 'Начать заново' : 'Ждите хоста',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isHost
                                ? Colors.purple
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.home),
                          label: const Text('В меню'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            widget.isHost ? 'Генерируем историю...' : 'Ждем хоста...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Cinzel',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySegment(StorySegment segment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Текст истории
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              segment.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.8,
                fontFamily: 'Cinzel',
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.justify,
            ),
          ),

          const SizedBox(height: 30),

          // Статус мультиплеера
          if (_myChoice != null && _waitingForOtherPlayer)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Ждем выбор $_otherPlayerName...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Cinzel',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ваш выбор: ${segment.choices[_myChoice!]}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: 'Cinzel',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          // Индикатор генерации
          else if (_isGenerating && segment.index == _currentSegmentIndex)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.withOpacity(0.4)),
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Генерируем продолжение...',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cinzel',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          // Варианты выбора
          else if (segment.choices.isNotEmpty &&
              segment.index == _currentSegmentIndex &&
              _myChoice == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Выберите действие:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cinzel',
                  ),
                ),
                const SizedBox(height: 15),
                ...segment.choices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final choice = entry.value;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _makeChoice(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              choice,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cinzel',
                                height: 1.3,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            )
          // Завершение игры
          else if (segment.choices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.celebration, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'История завершена!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cinzel',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Спасибо за совместную игру!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Cinzel',
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Модель сегмента истории для мультиплеера
class StorySegment {
  final String text;
  final List<String> choices;
  final int index;

  StorySegment({
    required this.text,
    required this.choices,
    required this.index,
  });
}
