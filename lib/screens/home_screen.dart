import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'story_builder_screen.dart';
import 'multiplayer_join_screen.dart';
import 'solo_game_screen.dart';
import 'usage_stats_screen.dart';
import 'saved_stories_screen.dart';
import '../widgets/gradient_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Заголовок
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Our Story',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cinzel',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Интерактивная история с ИИ',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Cinzel',
                      color: Colors.white.withOpacity(0.8),
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Главное меню
                Expanded(
                  child: ListView(
                    children: [
                      _MenuButton(
                        title: 'Играть соло',
                        subtitle: 'Быстрый старт для тестирования',
                        icon: Icons.play_arrow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SoloGameScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        title: 'Создать историю ИИ',
                        subtitle: 'Новое приключение вдвоем',
                        icon: Icons.auto_awesome,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StoryBuilderScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        title: 'Присоединиться к игре',
                        subtitle: 'Введите код комнаты',
                        icon: Icons.group_add,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MultiplayerJoinScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        title: 'Сохраненные истории',
                        subtitle: 'Продолжить или просмотреть',
                        icon: Icons.bookmark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedStoriesScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        title: 'Статистика ИИ',
                        subtitle: 'Использование и лимиты',
                        icon: Icons.analytics,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UsageStatsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        title: 'Настройки',
                        subtitle: 'Конфигурация приложения',
                        icon: Icons.settings,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
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
}

class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cinzel',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Cinzel',
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
