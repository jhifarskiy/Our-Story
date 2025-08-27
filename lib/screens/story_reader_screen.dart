import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../models/chapter.dart';
import '../models/character.dart';
import '../models/story_message.dart';
import '../providers/story_provider.dart';
import '../utils/image_utils.dart';

class StoryReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;

  const StoryReaderScreen({super.key, required this.chapter});

  @override
  ConsumerState<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends ConsumerState<StoryReaderScreen> {
  final List<types.Message> _messages = [];
  final types.User _systemUser = const types.User(id: 'system');
  int _currentMessageIndex = 0;
  bool _isAutoPlay = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final charactersAsync = ref.read(charactersProvider);

    charactersAsync.whenData((characters) {
      final characterMap = {for (var char in characters) char.id: char};

      if (widget.chapter.messages.isNotEmpty) {
        _addNextMessage(characterMap);
      }
    });
  }

  void _addNextMessage(Map<String, Character> characterMap) {
    if (_currentMessageIndex >= widget.chapter.messages.length) return;

    final storyMessage = widget.chapter.messages[_currentMessageIndex];
    final character = characterMap[storyMessage.characterId];

    final message = types.TextMessage(
      author: character != null
          ? types.User(
              id: character.id,
              firstName: character.name,
              imageUrl: character.avatarPath,
            )
          : _systemUser,
      createdAt: storyMessage.timestamp.millisecondsSinceEpoch,
      id: storyMessage.id,
      text: storyMessage.text,
    );

    setState(() {
      _messages.insert(0, message);
      _currentMessageIndex++;
    });

    // Обновляем прогресс
    ref
        .read(gameProgressProvider.notifier)
        .updateCurrentMessage(widget.chapter.id, storyMessage.id);

    // Показываем выборы, если они есть
    if (storyMessage.choices != null && storyMessage.choices!.isNotEmpty) {
      _showChoices(storyMessage.choices!);
    } else if (_isAutoPlay) {
      // Автоматически показываем следующее сообщение через задержку
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _addNextMessage(characterMap);
        }
      });
    }
  }

  Widget _buildCustomAvatar(types.User user) {
    // Если это системный пользователь, не показываем аватар
    if (user.id == 'system') {
      return const SizedBox.shrink();
    }

    // Если у пользователя есть imageUrl (путь к аватару)
    if (user.imageUrl != null && user.imageUrl!.isNotEmpty) {
      return ImageUtils.buildSafeCircleAvatar(
        imagePath: user.imageUrl!,
        radius: 18,
        placeholder: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    // Fallback - показываем аватар с инициалами или иконкой
    return CircleAvatar(
      radius: 18,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        user.firstName?.isNotEmpty == true
            ? user.firstName![0].toUpperCase()
            : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showChoices(List<Choice> choices) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Выберите ответ:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ...choices.map(
              (choice) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleChoice(choice);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    choice.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChoice(Choice choice) {
    // Сохраняем выбор игрока
    ref.read(gameProgressProvider.notifier).addPlayerChoice(choice.id, {
      'choiceId': choice.id,
      'text': choice.text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Применяем эффекты выбора
    if (choice.effects != null) {
      choice.effects!.forEach((key, value) {
        if (key.startsWith('relationship_')) {
          final characterId = key.replaceFirst('relationship_', '');
          ref
              .read(gameProgressProvider.notifier)
              .updateCharacterRelationship(characterId, value as int);
        }
      });
    }

    // Продолжаем историю
    final characterMap = ref.read(charactersProvider).value;
    if (characterMap != null) {
      final charMap = {for (var char in characterMap) char.id: char};
      _addNextMessage(charMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter.title,
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleAutoPlay,
            icon: Icon(_isAutoPlay ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(
            onPressed: _showOptions,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: (_) {}, // Игрок не может отправлять сообщения
        user: _systemUser,
        showUserAvatars: true,
        showUserNames: true,
        avatarBuilder: _buildCustomAvatar,
        theme: DefaultChatTheme(
          primaryColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          inputBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
      floatingActionButton:
          _currentMessageIndex < widget.chapter.messages.length
          ? FloatingActionButton(
              onPressed: () {
                final characterMap = ref.read(charactersProvider).value;
                if (characterMap != null) {
                  final charMap = {
                    for (var char in characterMap) char.id: char,
                  };
                  _addNextMessage(charMap);
                }
              },
              child: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlay = !_isAutoPlay;
    });
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Перезапустить главу'),
              onTap: () {
                Navigator.of(context).pop();
                _restartChapter();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Сохранить прогресс'),
              onTap: () {
                Navigator.of(context).pop();
                _saveProgress();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выйти в меню'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _restartChapter() {
    setState(() {
      _messages.clear();
      _currentMessageIndex = 0;
    });
    _loadMessages();
  }

  void _saveProgress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Прогресс сохранен'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
