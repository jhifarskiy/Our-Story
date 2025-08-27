import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/story_provider.dart';
import '../models/chapter.dart';
import '../widgets/gradient_background.dart';
import 'story_reader_screen.dart';

class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок с кнопкой назад
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Главы',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontFamily: 'Cinzel',
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              // Список глав
              Expanded(
                child: chaptersAsync.when(
                  data: (chapters) =>
                      _buildChaptersList(context, ref, chapters),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.white.withOpacity(0.7),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка загрузки глав',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChaptersList(
    BuildContext context,
    WidgetRef ref,
    List<Chapter> chapters,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ChapterCard(
            chapter: chapter,
            onTap: () => _openChapter(context, ref, chapter),
          ),
        );
      },
    );
  }

  void _openChapter(BuildContext context, WidgetRef ref, Chapter chapter) {
    if (!chapter.isUnlocked) {
      _showLockedChapterDialog(context);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryReaderScreen(chapter: chapter),
      ),
    );
  }

  void _showLockedChapterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Глава заблокирована'),
        content: const Text(
          'Эта глава будет доступна после прохождения предыдущих глав.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: chapter.isUnlocked ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Миниатюра главы
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: chapter.isUnlocked
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                  ),
                  child: chapter.isUnlocked
                      ? Icon(Icons.auto_stories, color: Colors.white, size: 32)
                      : Icon(Icons.lock, color: Colors.grey, size: 32),
                ),

                const SizedBox(width: 16),

                // Информация о главе
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Глава ${chapter.order}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        chapter.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: chapter.isUnlocked
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        chapter.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: chapter.isUnlocked
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Индикатор статуса
                if (chapter.isUnlocked)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  )
                else
                  Icon(
                    Icons.lock,
                    color: Colors.grey.withOpacity(0.7),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
