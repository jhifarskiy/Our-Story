import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import '../models/story_settings.dart';
import 'solo_story_play_screen.dart';

class SoloGameScreen extends StatefulWidget {
  const SoloGameScreen({super.key});

  @override
  State<SoloGameScreen> createState() => _SoloGameScreenState();
}

class _SoloGameScreenState extends State<SoloGameScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей
  final _playerNameController = TextEditingController(text: 'Игрок');
  final _storyPromptController = TextEditingController();

  // Настройки
  StoryGenre _selectedGenre = StoryGenre.adventure;
  RelationshipType _relationshipType = RelationshipType.friends;
  String _selectedSetting = '🏙️ Современный город';
  int _storyLength = 3; // количество глав
  int _complexityLevel = 2; // 1-5

  @override
  void dispose() {
    _playerNameController.dispose();
    _storyPromptController.dispose();
    super.dispose();
  }

  Future<void> _startSoloGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final settings = StorySettings(
        player1Name: _playerNameController.text.trim(),
        player2Name: 'ИИ Персонаж', // ИИ будет создавать персонажей
        genre: _selectedGenre,
        relationshipType: _relationshipType,
        setting: _selectedSetting,
        storyLength: _storyLength,
        complexityLevel: _complexityLevel,
        customPrompt: _storyPromptController.text.trim().isEmpty
            ? 'Создай увлекательную историю с неожиданными поворотами и интересными персонажами для взаимодействия.'
            : _storyPromptController.text.trim(),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SoloStoryPlayScreen(settings: settings),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка запуска: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                      'Соло Режим',
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
                      // Имя игрока
                      _buildSection(
                        title: '👤 Ваш персонаж',
                        children: [
                          _buildTextField(
                            controller: _playerNameController,
                            label: 'Ваше имя',
                            hint: 'Например: Лео',
                            icon: Icons.person,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Тип отношений с ИИ персонажами
                      _buildSection(
                        title: '🤖 Отношения с ИИ персонажами',
                        children: [_buildRelationshipSelector()],
                      ),

                      const SizedBox(height: 24),

                      // Жанр истории
                      _buildSection(
                        title: '🎭 Жанр истории',
                        children: [_buildGenreSelector()],
                      ),

                      const SizedBox(height: 24),

                      // Место действия
                      _buildSection(
                        title: '🌍 Место действия',
                        children: [_buildSettingSelector()],
                      ),

                      const SizedBox(height: 24),

                      // Длина и сложность
                      _buildSection(
                        title: '⚙️ Настройки игры',
                        children: [
                          _buildSlider(
                            label: 'Количество глав',
                            value: _storyLength.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            onChanged: (value) {
                              setState(() {
                                _storyLength = value.round();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSlider(
                            label: 'Сложность сюжета',
                            value: _complexityLevel.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (value) {
                              setState(() {
                                _complexityLevel = value.round();
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Дополнительные пожелания
                      _buildSection(
                        title: '✍️ Дополнительные пожелания',
                        children: [
                          _buildTextField(
                            controller: _storyPromptController,
                            label:
                                'Опишите, какую историю хотите (необязательно)',
                            hint:
                                'Например: С элементами мистики и неожиданными поворотами...',
                            icon: Icons.edit,
                            maxLines: 3,
                            required: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Кнопка запуска
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startSoloGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            '🚀 Начать Соло Приключение',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cinzel',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Подсказка
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ИИ создаст для вас уникальных персонажей и интерактивную историю по вашим настройкам!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontFamily: 'Cinzel',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
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
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
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
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontFamily: 'Cinzel'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Это поле обязательно для заполнения';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildRelationshipSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RelationshipType>(
          value: _relationshipType,
          isExpanded: true,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white, fontFamily: 'Cinzel'),
          items: RelationshipType.values.map((type) {
            String label;
            String emoji;
            switch (type) {
              case RelationshipType.lovers:
                label = 'Романтические партнеры';
                emoji = '💕';
                break;
              case RelationshipType.friends:
                label = 'Друзья';
                emoji = '👫';
                break;
              case RelationshipType.colleagues:
                label = 'Коллеги';
                emoji = '👔';
                break;
              case RelationshipType.rivals:
                label = 'Соперники';
                emoji = '🥊';
                break;
              case RelationshipType.strangers:
                label = 'Незнакомцы';
                emoji = '❓';
                break;
              case RelationshipType.enemies:
                label = 'Враги';
                emoji = '⚔️';
                break;
            }
            return DropdownMenuItem(value: type, child: Text('$emoji $label'));
          }).toList(),
          onChanged: (RelationshipType? newValue) {
            if (newValue != null) {
              setState(() {
                _relationshipType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildGenreSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StoryGenre>(
          value: _selectedGenre,
          isExpanded: true,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white, fontFamily: 'Cinzel'),
          items: StoryGenre.values.map((genre) {
            String label;
            String emoji;
            switch (genre) {
              case StoryGenre.romance:
                label = 'Романтика';
                emoji = '💕';
                break;
              case StoryGenre.adventure:
                label = 'Приключения';
                emoji = '🗺️';
                break;
              case StoryGenre.mystery:
                label = 'Мистика';
                emoji = '🔍';
                break;
              case StoryGenre.fantasy:
                label = 'Фэнтези';
                emoji = '🧙‍♀️';
                break;
              case StoryGenre.scifi:
                label = 'Научная фантастика';
                emoji = '🚀';
                break;
              case StoryGenre.drama:
                label = 'Драма';
                emoji = '🎭';
                break;
              case StoryGenre.comedy:
                label = 'Комедия';
                emoji = '😄';
                break;
              case StoryGenre.horror:
                label = 'Ужасы';
                emoji = '👻';
                break;
            }
            return DropdownMenuItem(value: genre, child: Text('$emoji $label'));
          }).toList(),
          onChanged: (StoryGenre? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedGenre = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSettingSelector() {
    final settings = [
      '🏙️ Современный город',
      '🏰 Средневековый замок',
      '🌲 Загадочный лес',
      '🏖️ Тропический остров',
      '🚀 Космическая станция',
      '🏛️ Древний Рим',
      '🏢 Корпоративный офис',
      '🎓 Университет',
      '🏔️ Горная деревня',
      '🎪 Цирк',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSetting,
          isExpanded: true,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white, fontFamily: 'Cinzel'),
          items: settings.map((setting) {
            return DropdownMenuItem(value: setting, child: Text(setting));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSetting = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.round()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Cinzel',
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            valueIndicatorColor: Colors.white,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.black,
              fontFamily: 'Cinzel',
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
