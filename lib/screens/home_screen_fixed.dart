import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/story_provider.dart';
import 'chapters_screen.dart';
import 'settings_screen.dart';
import 'font_test_screen.dart';
import '../widgets/gradient_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameProgress = ref.watch(gameProgressProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Заголовок
                Text(
                  'Our Story',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFamily: 'Cinzel',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Интерактивная визуальная новелла',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Кнопки меню
                _MenuButton(
                  icon: Icons.play_arrow,
                  title: gameProgress.value != null
                      ? 'Продолжить'
                      : 'Новая игра',
                  subtitle: gameProgress.value != null
                      ? 'Последнее сохранение: ${_formatDate(gameProgress.value!.lastPlayed)}'
                      : 'Начать новое приключение',
                  onTap: () => _startGame(context, ref),
                ),

                const SizedBox(height: 16),

                _MenuButton(
                  icon: Icons.library_books,
                  title: 'Главы',
                  subtitle: 'Выберите главу для чтения',
                  onTap: () => _navigateToChapters(context),
                ),

                const SizedBox(height: 16),

                _MenuButton(
                  icon: Icons.settings,
                  title: 'Настройки',
                  subtitle: 'Настройка игры и звука',
                  onTap: () => _navigateToSettings(context),
                ),

                const SizedBox(height: 16),

                _MenuButton(
                  icon: Icons.font_download,
                  title: 'Тест шрифтов',
                  subtitle: 'Проверка загрузки Cinzel',
                  onTap: () => _navigateToFontTest(context),
                ),

                const SizedBox(height: 16),

                _MenuButton(
                  icon: Icons.info,
                  title: 'О игре',
                  subtitle: 'Информация о разработчиках',
                  onTap: () => _showAboutDialog(context),
                ),

                const Spacer(),

                // Версия приложения
                Text(
                  'Версия 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, WidgetRef ref) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ChaptersScreen()));
  }

  void _navigateToChapters(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ChaptersScreen()));
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _navigateToFontTest(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FontTestScreen()));
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О игре'),
        content: const Text(
          'Our Story - это интерактивная визуальная новелла, '
          'созданная с использованием Flutter.\n\n'
          'Разработчик: Ваше имя\n'
          'Версия: 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
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
