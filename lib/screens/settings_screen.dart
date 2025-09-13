import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'ai_debug_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Настройки по умолчанию
  double _textSize = 16.0;
  bool _isDarkMode = false;
  double _animationSpeed = 1.0;
  bool _autoSave = true;
  String _language = 'ru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Настройки',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                  ],
                ),
              ),

              // Список настроек
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _SettingsSection(
                      title: 'Отображение',
                      children: [
                        _SettingsTile(
                          title: 'Размер текста',
                          subtitle: '${_textSize.round()}',
                          child: Slider(
                            value: _textSize,
                            min: 12.0,
                            max: 24.0,
                            divisions: 12,
                            onChanged: (value) {
                              setState(() {
                                _textSize = value;
                              });
                            },
                          ),
                        ),
                        _SettingsTile(
                          title: 'Темная тема',
                          subtitle: _isDarkMode ? 'Включена' : 'Выключена',
                          child: Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _SettingsSection(
                      title: 'Игровой процесс',
                      children: [
                        _SettingsTile(
                          title: 'Скорость анимации',
                          subtitle: '${(_animationSpeed * 100).round()}%',
                          child: Slider(
                            value: _animationSpeed,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            onChanged: (value) {
                              setState(() {
                                _animationSpeed = value;
                              });
                            },
                          ),
                        ),
                        _SettingsTile(
                          title: 'Автосохранение',
                          subtitle: _autoSave ? 'Включено' : 'Выключено',
                          child: Switch(
                            value: _autoSave,
                            onChanged: (value) {
                              setState(() {
                                _autoSave = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _SettingsSection(
                      title: 'Язык',
                      children: [
                        _SettingsTile(
                          title: 'Язык интерфейса',
                          subtitle: _language == 'ru' ? 'Русский' : 'English',
                          child: DropdownButton<String>(
                            value: _language,
                            dropdownColor: Colors.grey[800],
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(
                                value: 'ru',
                                child: Text('Русский'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _language = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _SettingsSection(
                      title: 'Отладка и тестирование',
                      children: [
                        _DebugTile(
                          title: 'Тест ИИ подключения',
                          subtitle: 'Проверить работу Google AI API',
                          icon: Icons.psychology,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AiDebugScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _DebugTile(
                          title: 'Информация о приложении',
                          subtitle: 'Версия, сборка, конфигурация',
                          icon: Icons.info_outline,
                          onTap: () {
                            _showAppInfo(context);
                          },
                        ),
                      ],
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

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our Story - Interactive AI Narratives'),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            Text('Сборка: Debug'),
            SizedBox(height: 8),
            Text('Функции:'),
            Text('• Solo режим с Google AI'),
            Text('• Локальный мультиплеер'),
            Text('• Сохранение прогресса'),
            Text('• Статистика использования ИИ'),
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
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cinzel',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _DebugTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DebugTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cinzel',
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
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
                  ],
                ),
              ),
              child,
            ],
          ),
        ],
      ),
    );
  }
}
