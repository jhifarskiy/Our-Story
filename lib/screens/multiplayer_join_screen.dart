import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gradient_background.dart';
import '../widgets/animated_button.dart';
import '../models/story_settings.dart';
import '../services/multiplayer_service.dart' as mp;
import 'multiplayer_story_play_screen.dart';

class MultiplayerJoinScreen extends ConsumerStatefulWidget {
  const MultiplayerJoinScreen({super.key});

  @override
  ConsumerState<MultiplayerJoinScreen> createState() =>
      _MultiplayerJoinScreenState();
}

class _MultiplayerJoinScreenState extends ConsumerState<MultiplayerJoinScreen> {
  final TextEditingController _sessionCodeController = TextEditingController();
  final TextEditingController _playerNameController = TextEditingController();
  bool _isConnecting = false;

  @override
  void dispose() {
    _sessionCodeController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }

  Future<void> _joinSession() async {
    if (_sessionCodeController.text.trim().isEmpty ||
        _playerNameController.text.trim().isEmpty) {
      _showError('Заполните все поля');
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final service = ref.read(
        mp.MultiplayerProviders.multiplayerServiceProvider,
      );
      final playerId = DateTime.now().millisecondsSinceEpoch.toString();
      final sessionCode = _sessionCodeController.text.trim().toUpperCase();
      final playerName = _playerNameController.text.trim();

      // Попытка присоединиться к сессии
      final session = await service.joinSession(
        sessionCode,
        playerId,
        playerName,
      );

      if (session == null) {
        throw Exception('Комната не найдена или заполнена');
      }

      // Устанавливаем ID игрока
      ref.read(mp.MultiplayerProviders.currentPlayerIdProvider.notifier).state =
          playerId;
      ref.read(mp.MultiplayerProviders.currentSessionProvider.notifier).state =
          session;

      setState(() {
        _isConnecting = false;
      });

      // Переходим к игре
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerStoryPlayScreen(
            settings: _createSettingsFromSession(session),
            isHost: false,
            sessionCode: sessionCode,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      _showError('Ошибка подключения: ${e.toString()}');
    }
  }

  StorySettings _createSettingsFromSession(mp.MultiplayerSession session) {
    final hostPlayer = session.players.firstWhere((p) => p.isHost);

    return StorySettings(
      genre: StoryGenre
          .adventure, // По умолчанию, в реальном приложении получали бы от хоста
      player1Name: hostPlayer.name,
      player2Name: _playerNameController.text.trim(),
      relationshipType: RelationshipType.friends,
      setting: 'Приключение начинается',
      complexityLevel: 3,
      customPrompt: '',
      storyLength: 5, // Добавляем недостающее поле
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Заголовок
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Присоединиться к игре',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cinzel',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Балансировка для кнопки назад
                  ],
                ),

                const SizedBox(height: 40),

                // Форма подключения
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Инструкция
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Для подключения к игре введите код сессии, который создал ваш партнер, и ваше имя.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Cinzel',
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Код сессии
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: _sessionCodeController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Код сессии',
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(
                                Icons.key,
                                color: Colors.white70,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                            ),
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Имя игрока
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: _playerNameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ваше имя',
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white70,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Кнопка подключения
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: AnimatedButton(
                            onPressed: _isConnecting ? null : _joinSession,
                            child: _isConnecting
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        'Подключение...',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Cinzel',
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Присоединиться',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Cinzel',
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Дополнительная информация
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.orange,
                                size: 24,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Совет: Код сессии обычно состоит из 4-6 символов. Убедитесь, что ваш партнер создал игру и поделился кодом.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: 'Cinzel',
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
