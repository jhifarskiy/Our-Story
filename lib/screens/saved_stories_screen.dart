import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../models/story_settings.dart';
import '../services/story_storage_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/animated_button.dart';
import 'solo_story_play_screen.dart';
import 'multiplayer_story_play_screen.dart';

final storageServiceProvider = FutureProvider<StoryStorageService>((ref) {
  return StoryStorageService.getInstance();
});

final savedStoriesProvider = FutureProvider<List<SavedStory>>((ref) async {
  final service = await ref.watch(storageServiceProvider.future);
  return service.getAllStories();
});

class SavedStoriesScreen extends ConsumerStatefulWidget {
  const SavedStoriesScreen({super.key});

  @override
  ConsumerState<SavedStoriesScreen> createState() => _SavedStoriesScreenState();
}

class _SavedStoriesScreenState extends ConsumerState<SavedStoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                        'Сохраненные истории',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _showStatistics,
                      icon: const Icon(Icons.analytics, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Табы
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'В процессе'),
                    Tab(text: 'Завершенные'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Список историй
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStoriesList(false), // Незавершенные
                    _buildStoriesList(true), // Завершенные
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesList(bool showCompleted) {
    return Consumer(
      builder: (context, ref, child) {
        final storiesAsync = ref.watch(savedStoriesProvider);

        return storiesAsync.when(
          data: (allStories) {
            final stories = allStories
                .where((story) => story.isCompleted == showCompleted)
                .toList();

            if (stories.isEmpty) {
              return _buildEmptyState(showCompleted);
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(savedStoriesProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return _buildStoryCard(story);
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки историй',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedButton(
                  onPressed: () => ref.invalidate(savedStoriesProvider),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool showCompleted) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showCompleted ? Icons.check_circle_outline : Icons.history,
            color: Colors.white.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            showCompleted
                ? 'Нет завершенных историй'
                : 'Нет историй в процессе',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showCompleted
                ? 'Завершите хотя бы одну историю'
                : 'Начните новую историю',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(SavedStory story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () => _continueStory(story),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и действия
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getGenreText(story.settings.genre.name)} • ${story.gameMode == 'solo' ? 'Соло' : 'Мультиплеер'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onSelected: (value) => _handleMenuAction(value, story),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Поделиться'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Копировать текст'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Удалить',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Прогресс
              Row(
                children: [
                  Icon(
                    story.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: story.isCompleted ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    story.isCompleted
                        ? 'Завершена'
                        : 'Глава ${story.currentSegmentIndex + 1} из ${story.segments.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(story.lastPlayedAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // Персонажи
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    story.settings.player2Name.isNotEmpty
                        ? Icons.people
                        : Icons.person,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    story.settings.player2Name.isNotEmpty
                        ? '${story.settings.player1Name} и ${story.settings.player2Name}'
                        : story.settings.player1Name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Превью последнего сегмента
              if (story.segments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    story.segments.last.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _continueStory(SavedStory story) {
    if (story.gameMode == 'solo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SoloStoryPlayScreen(settings: story.settings, savedStory: story),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerStoryPlayScreen(
            settings: story.settings,
            isHost: true,
            sessionCode: story.id, // Используем ID как код сессии
            savedStory: story,
          ),
        ),
      );
    }
  }

  void _handleMenuAction(String action, SavedStory story) async {
    switch (action) {
      case 'export':
        await _shareStory(story);
        break;
      case 'copy':
        await _copyStoryText(story);
        break;
      case 'delete':
        await _deleteStory(story);
        break;
    }
  }

  Future<void> _shareStory(SavedStory story) async {
    try {
      final service = await ref.read(storageServiceProvider.future);
      final text = service.exportStoryToText(story);

      await Share.share(text, subject: 'История: ${story.title}');
    } catch (e) {
      _showError('Ошибка при экспорте истории');
    }
  }

  Future<void> _copyStoryText(SavedStory story) async {
    try {
      final service = await ref.read(storageServiceProvider.future);
      final text = service.exportStoryToText(story);

      await Clipboard.setData(ClipboardData(text: text));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Текст истории скопирован'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError('Ошибка при копировании');
    }
  }

  Future<void> _deleteStory(SavedStory story) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление истории'),
        content: Text(
          'Вы уверены, что хотите удалить историю "${story.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final service = await ref.read(storageServiceProvider.future);
        await service.deleteStory(story.id);
        ref.invalidate(savedStoriesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('История удалена'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        _showError('Ошибка при удалении истории');
      }
    }
  }

  Future<void> _showStatistics() async {
    try {
      final service = await ref.read(storageServiceProvider.future);
      final stats = await service.getStatistics();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Статистика'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Всего историй:', '${stats['total']}'),
                _buildStatRow('Завершено:', '${stats['completed']}'),
                _buildStatRow('В процессе:', '${stats['incomplete']}'),
                _buildStatRow('Соло игр:', '${stats['solo']}'),
                _buildStatRow('Мультиплеер:', '${stats['multiplayer']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError('Ошибка загрузки статистики');
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
