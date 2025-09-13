import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';
import '../models/story_settings.dart';
import 'solo_story_play_screen.dart';
import 'multiplayer_host_screen.dart';

class StoryBuilderScreen extends ConsumerStatefulWidget {
  const StoryBuilderScreen({super.key});

  @override
  ConsumerState<StoryBuilderScreen> createState() => _StoryBuilderScreenState();
}

class _StoryBuilderScreenState extends ConsumerState<StoryBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей
  final _player1NameController = TextEditingController();
  final _player2NameController = TextEditingController();
  final _storyPromptController = TextEditingController();

  // Настройки
  StoryGenre _selectedGenre = StoryGenre.romance;
  RelationshipType _relationshipType = RelationshipType.lovers;
  String _selectedSetting = '🏙️ Современный город';
  int _storyLength = 5; // количество глав
  int _complexityLevel = 3; // 1-5

  @override
  void dispose() {
    _player1NameController.dispose();
    _player2NameController.dispose();
    _storyPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                // Заголовок
                SliverAppBar(
                  expandedHeight: 120,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Создать историю',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cinzel',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                // Основной контент
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Имена игроков
                      _buildSection(
                        title: '👫 Персонажи',
                        children: [
                          _buildTextField(
                            controller: _player1NameController,
                            label: 'Имя первого игрока',
                            hint: 'Например: Лео',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _player2NameController,
                            label: 'Имя второго игрока',
                            hint: 'Например: Мария',
                            icon: Icons.person_outline,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Тип отношений
                      _buildSection(
                        title: '💝 Отношения персонажей',
                        children: [_buildRelationshipSelector()],
                      ),

                      const SizedBox(height: 24),

                      // Жанр
                      _buildSection(
                        title: '🎭 Жанр истории',
                        children: [_buildGenreSelector()],
                      ),

                      const SizedBox(height: 24),

                      // Сеттинг
                      _buildSection(
                        title: '🌍 Место действия',
                        children: [_buildSettingSelector()],
                      ),

                      const SizedBox(height: 24),

                      // Дополнительные настройки
                      _buildSection(
                        title: '⚙️ Настройки истории',
                        children: [
                          _buildSlider(
                            title: 'Длина истории',
                            subtitle: '$_storyLength глав',
                            value: _storyLength.toDouble(),
                            min: 3,
                            max: 10,
                            onChanged: (value) {
                              setState(() {
                                _storyLength = value.round();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSlider(
                            title: 'Сложность выборов',
                            subtitle: _getComplexityText(_complexityLevel),
                            value: _complexityLevel.toDouble(),
                            min: 1,
                            max: 5,
                            onChanged: (value) {
                              setState(() {
                                _complexityLevel = value.round();
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Дополнительный промпт
                      _buildSection(
                        title: '✨ Особые пожелания (необязательно)',
                        children: [
                          _buildTextField(
                            controller: _storyPromptController,
                            label: 'Что бы вы хотели видеть в истории?',
                            hint:
                                'Например: добавить элементы мистики, больше юмора...',
                            icon: Icons.lightbulb_outline,
                            maxLines: 3,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Кнопка генерации
                      _buildGenerateButton(),

                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cinzel',
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: maxLines == 1
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Поле обязательно для заполнения';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildRelationshipSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: RelationshipType.values.map((type) {
        final isSelected = _relationshipType == type;
        return GestureDetector(
          onTap: () => setState(() => _relationshipType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getRelationshipText(type),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenreSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: StoryGenre.values.map((genre) {
        final isSelected = _selectedGenre == genre;
        return GestureDetector(
          onTap: () => setState(() => _selectedGenre = genre),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getGenreText(genre),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingSelector() {
    final settings = [
      '🏙️ Современный город',
      '🏫 Университет',
      '🏰 Средневековье',
      '🌌 Космос',
      '🏝️ Тропический остров',
      '🏔️ Горы',
      '🌲 Лес',
      '🏠 Маленький городок',
    ];

    // Защита от старых значений без эмодзи
    if (!settings.contains(_selectedSetting)) {
      _selectedSetting = settings.first;
    }

    return DropdownButtonFormField<String>(
      value: _selectedSetting,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
      style: const TextStyle(color: Colors.white),
      items: settings.map((setting) {
        return DropdownMenuItem(value: setting, child: Text(setting));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedSetting = value);
        }
      },
    );
  }

  Widget _buildSlider({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Column(
      children: [
        // Кнопка соло игры
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: _generateSoloStory,
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Играть соло',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Кнопка мультиплеера
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: _generateMultiplayerStory,
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Создать для мультиплеера',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _generateSoloStory() {
    if (_formKey.currentState!.validate()) {
      final settings = StorySettings(
        player1Name: _player1NameController.text.trim(),
        player2Name: _player2NameController.text.trim(),
        genre: _selectedGenre,
        relationshipType: _relationshipType,
        setting: _selectedSetting,
        storyLength: _storyLength,
        complexityLevel: _complexityLevel,
        customPrompt: _storyPromptController.text.trim(),
      );

      // Переходим к соло игре
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SoloStoryPlayScreen(settings: settings),
        ),
      );
    }
  }

  void _generateMultiplayerStory() {
    if (_formKey.currentState!.validate()) {
      final settings = StorySettings(
        player1Name: _player1NameController.text.trim(),
        player2Name: _player2NameController.text.trim(),
        genre: _selectedGenre,
        relationshipType: _relationshipType,
        setting: _selectedSetting,
        storyLength: _storyLength,
        complexityLevel: _complexityLevel,
        customPrompt: _storyPromptController.text.trim(),
      );

      // Переходим к хостингу мультиплеер игры
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MultiplayerHostScreen(settings: settings),
        ),
      );
    }
  }

  String _getRelationshipText(RelationshipType type) {
    switch (type) {
      case RelationshipType.lovers:
        return '💕 Влюбленные';
      case RelationshipType.friends:
        return '👫 Друзья';
      case RelationshipType.rivals:
        return '⚔️ Соперники';
      case RelationshipType.enemies:
        return '💀 Враги';
      case RelationshipType.strangers:
        return '❓ Незнакомцы';
      case RelationshipType.colleagues:
        return '💼 Коллеги';
    }
  }

  String _getGenreText(StoryGenre genre) {
    switch (genre) {
      case StoryGenre.romance:
        return '💕 Романтика';
      case StoryGenre.adventure:
        return '🗺️ Приключения';
      case StoryGenre.fantasy:
        return '🔮 Фэнтези';
      case StoryGenre.scifi:
        return '🚀 Фантастика';
      case StoryGenre.mystery:
        return '🔍 Детектив';
      case StoryGenre.horror:
        return '👻 Хоррор';
      case StoryGenre.comedy:
        return '😄 Комедия';
      case StoryGenre.drama:
        return '🎭 Драма';
    }
  }

  String _getComplexityText(int level) {
    switch (level) {
      case 1:
        return 'Очень простые';
      case 2:
        return 'Простые';
      case 3:
        return 'Средние';
      case 4:
        return 'Сложные';
      case 5:
        return 'Очень сложные';
      default:
        return 'Средние';
    }
  }
}
