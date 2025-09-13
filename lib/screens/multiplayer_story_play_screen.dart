import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_segment.dart';
import '../services/multiplayer_service.dart' as mp;
import '../widgets/gradient_background.dart';
import '../services/story_service.dart';
import '../services/story_storage_service.dart';
import '../models/story_settings.dart';

class MultiplayerStoryPlayScreen extends ConsumerStatefulWidget {
  final StorySettings settings;
  final bool isHost;
  final String sessionCode;
  final SavedStory? savedStory;

  const MultiplayerStoryPlayScreen({
    super.key,
    required this.settings,
    required this.isHost,
    required this.sessionCode,
    this.savedStory,
  });

  @override
  ConsumerState<MultiplayerStoryPlayScreen> createState() =>
      _MultiplayerStoryPlayScreenState();
}

class _MultiplayerStoryPlayScreenState
    extends ConsumerState<MultiplayerStoryPlayScreen>
    with TickerProviderStateMixin {
  final StoryService _storyService = StoryService();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.isHost) {
      _generateFirstSegment();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _generateFirstSegment() async {
    // This should only be called by the host
    final service = ref.read(mp.MultiplayerProviders.multiplayerServiceProvider);
    final story = await _storyService.generateFullStory(widget.settings);
    final segments = story.chapters
        .map((c) => StorySegment(
            text: c.messages.first.text,
            choices: c.messages.first.choices
                    ?.map((e) => Choice(text: e.text, effects: e.effects))
                    .toList() ??
                [],
            index: c.order))
        .toList();

    final storyData = {
      'segments': segments.map((s) => s.toJson()).toList(),
      'currentSegmentIndex': 0,
      'isGameComplete': false,
      'playerChoices': <String, int>{},
      'relationshipScore': 50,
    };

    await service.updateStoryData(widget.sessionCode, storyData);
  }

  Future<void> _makeChoice(int choiceIndex) async {
    final service = ref.read(mp.MultiplayerProviders.multiplayerServiceProvider);
    final playerId = ref.read(mp.MultiplayerProviders.currentPlayerIdProvider);
    final session = service.getSession(widget.sessionCode);

    if (playerId == null || session == null || session.storyData == null) return;

    final storyData = session.storyData!;
    final playerChoices = Map<String, int>.from(storyData['playerChoices']);
    playerChoices[playerId] = choiceIndex;
    storyData['playerChoices'] = playerChoices;

    final segments = (storyData['segments'] as List).map((s) => StorySegment.fromJson(s)).toList();
    final currentSegment = segments[storyData['currentSegmentIndex']];
    final choice = currentSegment.choices[choiceIndex];
    if (choice.effects != null && choice.effects!.containsKey('relationship')) {
      storyData['relationshipScore'] += (choice.effects!['relationship'] as int?) ?? 0;
    }

    await service.updateStoryData(widget.sessionCode, storyData);

    // If all players have made a choice, generate the next segment
    if (playerChoices.length == session.players.length) {
      _generateNextSegment();
    }
  }

  Future<void> _generateNextSegment() async {
    final service = ref.read(mp.MultiplayerProviders.multiplayerServiceProvider);
    final session = service.getSession(widget.sessionCode);
    if (session == null || session.storyData == null) return;

    final storyData = session.storyData!;
    final segments = (storyData['segments'] as List).map((s) => StorySegment.fromJson(s)).toList();
    final storyContext = segments.map((s) => s.text).join('\n\n');

    final nextChapter = await _storyService.generateNextChapter(widget.settings, storyContext, storyData['currentSegmentIndex'] + 1);
    final newSegment = StorySegment(
        text: nextChapter.messages.first.text,
        choices: nextChapter.messages.first.choices
                ?.map((e) => Choice(text: e.text, effects: e.effects))
                .toList() ??
            [],
        index: nextChapter.order);

    segments.add(newSegment);
    storyData['segments'] = segments.map((s) => s.toJson()).toList();
    storyData['currentSegmentIndex']++;
    storyData['playerChoices'] = <String, int>{};

    if (newSegment.choices.isEmpty || storyData['currentSegmentIndex'] >= widget.settings.storyLength) {
      storyData['isGameComplete'] = true;
    }

    await service.updateStoryData(widget.sessionCode, storyData);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<mp.MultiplayerMessage>(
      stream: ref.watch(mp.MultiplayerProviders.multiplayerServiceProvider).getSessionStream(widget.sessionCode),
      builder: (context, snapshot) {
        final session = ref.watch(mp.MultiplayerProviders.multiplayerServiceProvider).getSession(widget.sessionCode);
        final storyData = session?.storyData;

        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  // ... (header code remains the same)

                  // Body
                  Expanded(
                    child: storyData == null
                        ? _buildLoadingScreen()
                        : _buildStoryContent(storyData, session),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(widget.isHost ? 'Генерируем историю...' : 'Ожидание хоста...'),
        ],
      ),
    );
  }

  Widget _buildStoryContent(Map<String, dynamic> storyData, mp.MultiplayerSession? session) {
    final segments = (storyData['segments'] as List).map((s) => StorySegment.fromJson(s)).toList();
    final currentSegment = segments[storyData['currentSegmentIndex']];
    final playerId = ref.watch(mp.MultiplayerProviders.currentPlayerIdProvider);
    final playerChoices = Map<String, int>.from(storyData['playerChoices']);
    final myChoice = playerChoices[playerId];
    final allPlayersVoted = session != null && playerChoices.length == session.players.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Story Text
          // ... (story text container remains the same)

          // Choices
          if (!storyData['isGameComplete'] && myChoice == null)
            ...currentSegment.choices.asMap().entries.map((entry) {
              return ElevatedButton(
                onPressed: () => _makeChoice(entry.key),
                child: Text(entry.value.text),
              );
            }),

          // Waiting for other players
          if (myChoice != null && !allPlayersVoted)
            const Text("Ожидание других игроков..."),

          // Game complete
          if (storyData['isGameComplete']) ...[
            const Text("История завершена!"),
            _buildGameCompleteButtons(),
          ]
        ],
      ),
    );
  }

  Widget _buildGameCompleteButtons() {
    return Row(
      children: [
        ElevatedButton(onPressed: widget.isHost ? _restartGame : null, child: const Text("Начать заново")),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text("В меню")),
      ],
    );
  }

  void _restartGame() {
    if (widget.isHost) {
      _generateFirstSegment();
    }
  }

  String _getGenreText(StoryGenre genre) {
    // ...
    return "";
  }

  String _getRelationshipText(RelationshipType type) {
    // ...
    return "";
  }

  void _showError(String message) {
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
