import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/multiplayer_service.dart' as mp;
import '../models/story_settings.dart';
import '../widgets/gradient_background.dart';
import '../widgets/animated_button.dart';
import 'multiplayer_story_play_screen.dart';

class MultiplayerHostScreen extends ConsumerStatefulWidget {
  final StorySettings settings;

  const MultiplayerHostScreen({super.key, required this.settings});

  @override
  ConsumerState<MultiplayerHostScreen> createState() =>
      _MultiplayerHostScreenState();
}

class _MultiplayerHostScreenState extends ConsumerState<MultiplayerHostScreen>
    with TickerProviderStateMixin {
  String? _sessionCode;
  bool _isCreatingSession = false;
  bool _isWaitingForPlayer = false;
  mp.MultiplayerSession? _session;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _createSession();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    if (_sessionCode != null) {
      _leaveSession();
    }
    super.dispose();
  }

  Future<void> _createSession() async {
    setState(() {
      _isCreatingSession = true;
    });

    try {
      final service = ref.read(
        mp.MultiplayerProviders.multiplayerServiceProvider,
      );
      final playerId = DateTime.now().millisecondsSinceEpoch.toString();
      final sessionCode = await service.createSession(
        playerId,
        widget.settings.player1Name,
      );

      ref.read(mp.MultiplayerProviders.currentPlayerIdProvider.notifier).state =
          playerId;

      setState(() {
        _sessionCode = sessionCode;
        _isCreatingSession = false;
        _isWaitingForPlayer = true;
      });

      await _slideController.forward();
      _listenForPlayers();
    } catch (e) {
      setState(() {
        _isCreatingSession = false;
      });
      _showError('Ошибка создания комнаты: $e');
    }
  }

  void _listenForPlayers() {
    final service = ref.read(
      mp.MultiplayerProviders.multiplayerServiceProvider,
    );
    final sessionStream = service.getSessionStream(_sessionCode!);

    sessionStream?.listen((message) {
      if (message.type == mp.MultiplayerMessageType.playerJoined &&
          message.playerId !=
              ref.read(mp.MultiplayerProviders.currentPlayerIdProvider)) {
        final session = service.getSession(_sessionCode!);
        if (session != null && session.players.length >= 2) {
          setState(() {
            _session = session;
            _isWaitingForPlayer = false;
          });
          _startGame();
        }
      }
    });
  }

  Future<void> _startGame() async {
    if (_session == null || _sessionCode == null) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerStoryPlayScreen(
          settings: widget.settings,
          isHost: true,
          sessionCode: _sessionCode!,
        ),
      ),
    );
  }

  Future<void> _leaveSession() async {
    if (_sessionCode == null) return;

    final service = ref.read(
      mp.MultiplayerProviders.multiplayerServiceProvider,
    );
    final playerId = ref.read(mp.MultiplayerProviders.currentPlayerIdProvider);

    if (playerId != null) {
      await service.leaveSession(_sessionCode!, playerId);
    }
  }

  void _copySessionCode() {
    if (_sessionCode != null) {
      Clipboard.setData(ClipboardData(text: _sessionCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Код скопирован в буфер обмена'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareSessionCode() {
    if (_sessionCode != null) {
      // В реальном приложении здесь можно использовать share_plus
      _copySessionCode();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Назад'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createSession();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _leaveSession();
        return true;
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Заголовок
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _leaveSession();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'Создание комнаты',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Для центровки
                    ],
                  ),

                  const SizedBox(height: 32),

                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isCreatingSession) {
      return _buildCreatingSession();
    } else if (_isWaitingForPlayer) {
      return _buildWaitingForPlayer();
    } else {
      return _buildStartGame();
    }
  }

  Widget _buildCreatingSession() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.wifi_tethering,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Создание комнаты...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Пожалуйста, подождите',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForPlayer() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutBack,
            ),
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Код комнаты
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Код комнаты',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _sessionCode ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedButton(
                      onPressed: _copySessionCode,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Копировать',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    AnimatedButton(
                      onPressed: _shareSessionCode,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Поделиться',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Индикатор ожидания
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(
                    0.2 + (_pulseController.value * 0.3),
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  color: Colors.orange,
                  size: 30,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Text(
            'Ожидание второго игрока...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Поделитесь кодом комнаты с другом',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Информация об истории
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Настройки истории:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Жанр: ${_getGenreText(widget.settings.genre.name)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Хост: ${widget.settings.player1Name}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Место: ${widget.settings.setting}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartGame() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Игрок присоединился!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (_session != null)
            Text(
              'Второй игрок: ${_session!.players.lastWhere((p) => !p.isHost).name}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 32),
          AnimatedButton(
            onPressed: _startGame,
            child: const Text(
              'Начать игру',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
}
