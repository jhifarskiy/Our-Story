import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'multiplayer_repository.dart';

class FileMultiplayerRepository implements MultiplayerRepository {
  final String _dbPath = 'db.json';
  Timer? _pollingTimer;

  FileMultiplayerRepository() {
    // Start polling for changes in the db.json file
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // In a real app, this would be handled by a real-time database or websockets.
      // Here, we're just simulating it by polling the file.
    });
  }

  Future<Map<String, dynamic>> _readDb() async {
    try {
      final file = File(_dbPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Error reading db.json: $e");
    }
    return {};
  }

  Future<void> _writeDb(Map<String, dynamic> data) async {
    try {
      final file = File(_dbPath);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print("Error writing to db.json: $e");
    }
  }

  @override
  Future<String> createSession(String hostId, String hostName) async {
    final sessionId = _generateSessionCode();
    final host = MultiplayerPlayer(
      id: hostId,
      name: hostName,
      joinedAt: DateTime.now(),
      isHost: true,
    );

    final session = MultiplayerSession(
      id: sessionId,
      hostId: hostId,
      players: [host],
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
      isActive: true,
    );

    final db = await _readDb();
    db[sessionId] = session.toJson();
    await _writeDb(db);

    return sessionId;
  }

  @override
  Future<MultiplayerSession?> joinSession(
    String sessionId,
    String playerId,
    String playerName,
  ) async {
    final db = await _readDb();
    if (!db.containsKey(sessionId)) {
      return null;
    }

    final session = MultiplayerSession.fromJson(db[sessionId]);
    if (!session.isActive || session.players.length >= 2) {
      return null;
    }

    if (session.players.any((p) => p.id == playerId)) {
      return session;
    }

    final player = MultiplayerPlayer(
      id: playerId,
      name: playerName,
      joinedAt: DateTime.now(),
      isHost: false,
    );

    final updatedPlayers = [...session.players, player];
    final updatedSession = MultiplayerSession(
      id: session.id,
      hostId: session.hostId,
      players: updatedPlayers,
      storyData: session.storyData,
      createdAt: session.createdAt,
      lastActivity: DateTime.now(),
      isActive: session.isActive,
    );

    db[sessionId] = updatedSession.toJson();
    await _writeDb(db);

    return updatedSession;
  }

  @override
  Future<void> leaveSession(String sessionId, String playerId) async {
    final db = await _readDb();
    if (!db.containsKey(sessionId)) {
      return;
    }

    final session = MultiplayerSession.fromJson(db[sessionId]);
    final updatedPlayers = session.players.where((p) => p.id != playerId).toList();

    if (updatedPlayers.isEmpty) {
      db.remove(sessionId);
    } else {
      String newHostId = session.hostId;
      if (session.hostId == playerId) {
        newHostId = updatedPlayers.first.id;
      }
      final updatedSession = MultiplayerSession(
        id: session.id,
        hostId: newHostId,
        players: updatedPlayers,
        storyData: session.storyData,
        createdAt: session.createdAt,
        lastActivity: DateTime.now(),
        isActive: session.isActive,
      );
      db[sessionId] = updatedSession.toJson();
    }
    await _writeDb(db);
  }

  @override
  Future<void> sendMessage(String sessionId, MultiplayerMessage message) async {
    // This is where the simulation gets tricky. In a real app, this would send a message
    // to a server, which would then push it to the other clients.
    // Here, we'll just update the session data.
    final db = await _readDb();
    if (!db.containsKey(sessionId)) {
      return;
    }
    // We are not storing messages in this simulation, just updating the session.
    await _updateSessionActivity(sessionId);
  }

  @override
  Stream<MultiplayerMessage>? getSessionStream(String sessionId) {
    final controller = StreamController<MultiplayerMessage>.broadcast();
    MultiplayerSession? lastSession;

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final db = await _readDb();
      if (db.containsKey(sessionId)) {
        final newSession = MultiplayerSession.fromJson(db[sessionId]);

        if (lastSession == null) {
          lastSession = newSession;
        }

        // Check for new players
        if (newSession.players.length > lastSession!.players.length) {
          final newPlayer = newSession.players.last;
          controller.add(MultiplayerMessage(
            type: MultiplayerMessageType.playerJoined,
            playerId: newPlayer.id,
            data: {'player': newPlayer.toJson()},
            timestamp: DateTime.now(),
          ));
        }

        // Check for story updates
        if (newSession.storyData != lastSession!.storyData) {
          controller.add(MultiplayerMessage(
            type: MultiplayerMessageType.storySegment,
            data: newSession.storyData!,
            timestamp: DateTime.now(),
          ));
        }

        lastSession = newSession;
      }
    });

    return controller.stream;
  }

  @override
  MultiplayerSession? getSession(String sessionId) {
    // This method is synchronous, which is not ideal for a file-based repository.
    // In a real app, this would be an async method.
    // For this simulation, we will read the file synchronously.
    try {
      final file = File(_dbPath);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.isNotEmpty) {
          final db = jsonDecode(content) as Map<String, dynamic>;
          if (db.containsKey(sessionId)) {
            return MultiplayerSession.fromJson(db[sessionId]);
          }
        }
      }
    } catch (e) {
      print("Error reading db.json synchronously: $e");
    }
    return null;
  }

  @override
  Future<void> updateStoryData(
    String sessionId,
    Map<String, dynamic> storyData,
  ) async {
    final db = await _readDb();
    if (!db.containsKey(sessionId)) {
      return;
    }
    final session = MultiplayerSession.fromJson(db[sessionId]);
    final updatedSession = MultiplayerSession(
      id: session.id,
      hostId: session.hostId,
      players: session.players,
      storyData: storyData,
      createdAt: session.createdAt,
      lastActivity: DateTime.now(),
      isActive: session.isActive,
    );
    db[sessionId] = updatedSession.toJson();
    await _writeDb(db);
  }

  @override
  bool sessionExists(String sessionId) {
    // Synchronous implementation for simplicity
    return getSession(sessionId) != null;
  }

  @override
  List<MultiplayerSession> getActiveSessions() {
    // Synchronous implementation for simplicity
    try {
      final file = File(_dbPath);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.isNotEmpty) {
          final db = jsonDecode(content) as Map<String, dynamic>;
          return db.values
              .map((data) => MultiplayerSession.fromJson(data))
              .where((s) => s.isActive)
              .toList();
        }
      }
    } catch (e) {
      print("Error reading db.json synchronously: $e");
    }
    return [];
  }

  Future<void> _updateSessionActivity(String sessionId) async {
    final db = await _readDb();
    if (!db.containsKey(sessionId)) {
      return;
    }
    final session = MultiplayerSession.fromJson(db[sessionId]);
    final updatedSession = MultiplayerSession(
      id: session.id,
      hostId: session.hostId,
      players: session.players,
      storyData: session.storyData,
      createdAt: session.createdAt,
      lastActivity: DateTime.now(),
      isActive: session.isActive,
    );
    db[sessionId] = updatedSession.toJson();
    await _writeDb(db);
  }

  String _generateSessionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
  }
}
