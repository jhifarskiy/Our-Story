import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../widgets/gradient_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

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
                      'Настройки',
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

              // Настройки
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Секция игрового процесса
                    _buildSectionHeader(context, 'Игровой процесс'),

                    _buildSliderTile(
                      context,
                      title: 'Скорость текста',
                      value: settings.textSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      onChanged: (value) => ref
                          .read(settingsProvider.notifier)
                          .updateTextSpeed(value),
                      formatValue: (value) => '${(value * 100).round()}%',
                    ),

                    _buildSwitchTile(
                      context,
                      title: 'Автопроигрывание',
                      subtitle: 'Автоматическое продолжение диалогов',
                      value: settings.autoPlay,
                      onChanged: (value) =>
                          ref.read(settingsProvider.notifier).toggleAutoPlay(),
                    ),

                    _buildSwitchTile(
                      context,
                      title: 'Показывать имена персонажей',
                      subtitle: 'Отображение имен в диалогах',
                      value: settings.showCharacterNames,
                      onChanged: (value) => ref
                          .read(settingsProvider.notifier)
                          .toggleCharacterNames(),
                    ),

                    const SizedBox(height: 24),

                    // Секция аудио
                    _buildSectionHeader(context, 'Аудио'),

                    _buildSliderTile(
                      context,
                      title: 'Громкость музыки',
                      value: settings.musicVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) => ref
                          .read(settingsProvider.notifier)
                          .updateMusicVolume(value),
                      formatValue: (value) => '${(value * 100).round()}%',
                    ),

                    _buildSliderTile(
                      context,
                      title: 'Громкость звуков',
                      value: settings.soundVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) => ref
                          .read(settingsProvider.notifier)
                          .updateSoundVolume(value),
                      formatValue: (value) => '${(value * 100).round()}%',
                    ),

                    const SizedBox(height: 24),

                    // Секция интерфейса
                    _buildSectionHeader(context, 'Интерфейс'),

                    _buildSwitchTile(
                      context,
                      title: 'Темная тема',
                      subtitle: 'Использовать темное оформление',
                      value: settings.darkMode,
                      onChanged: (value) =>
                          ref.read(settingsProvider.notifier).toggleDarkMode(),
                    ),

                    _buildLanguageTile(
                      context,
                      currentLanguage: settings.language,
                      onLanguageChanged: (language) => ref
                          .read(settingsProvider.notifier)
                          .updateLanguage(language),
                    ),

                    const SizedBox(height: 24),

                    // Секция данных
                    _buildSectionHeader(context, 'Данные'),

                    _buildActionTile(
                      context,
                      title: 'Сброс прогресса',
                      subtitle: 'Удалить все сохраненные данные',
                      icon: Icons.delete,
                      onTap: () => _showResetDialog(context, ref),
                      isDestructive: true,
                    ),

                    _buildActionTile(
                      context,
                      title: 'Экспорт данных',
                      subtitle: 'Сохранить прогресс в файл',
                      icon: Icons.file_download,
                      onTap: () => _exportData(context, ref),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) formatValue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.white),
                ),
                Text(
                  formatValue(value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withOpacity(0.2),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7)),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.white.withOpacity(0.5),
        inactiveThumbColor: Colors.white.withOpacity(0.7),
        inactiveTrackColor: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String currentLanguage,
    required ValueChanged<String> onLanguageChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ListTile(
        title: Text(
          'Язык',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
        subtitle: Text(
          _getLanguageName(currentLanguage),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7)),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.5),
          size: 16,
        ),
        onTap: () =>
            _showLanguageDialog(context, currentLanguage, onLanguageChanged),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDestructive ? Colors.red : Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDestructive
                ? Colors.red.withOpacity(0.7)
                : Colors.white.withOpacity(0.7),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return 'Русский';
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    String currentLanguage,
    ValueChanged<String> onLanguageChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Русский'),
              value: 'ru',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сброс прогресса'),
        content: const Text(
          'Вы уверены, что хотите сбросить весь прогресс? '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Здесь можно добавить логику сброса прогресса
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Прогресс сброшен')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) {
    // Здесь можно добавить логику экспорта данных
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция экспорта будет добавлена позже')),
    );
  }
}
