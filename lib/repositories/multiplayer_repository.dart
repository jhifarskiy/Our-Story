import 'dart:async';
import 'dart:math';

class MultiplayerPlayer {
  final String id;
  final String name;
  final DateTime joinedAt;
  final bool isHost;

  const MultiplayerPlayer({
    required this.id,
    required this.name,
    required this.joinedAt,
    required this.isHost,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'joinedAt': joinedAt.toIso8601String(),
      'isHost': isHost,
    };
  }

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: json['id'],
      name: json['name'],
      joinedAt: DateTime.parse(json['joinedAt']),
      isHost: json['isHost'],
    );
  }
}

class MultiplayerSession {
  final String id;
  final String hostId;
  final List<MultiplayerPlayer> players;
  final Map<String, dynamic>? storyData;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;

  const MultiplayerSession({
    required this.id,
    required this.hostId,
    required this.players,
    this.storyData,
    required this.createdAt,
    required this.lastActivity,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'players': players.map((p) => p.toJson()).toList(),
      'storyData': storyData,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory MultiplayerSession.fromJson(Map<String, dynamic> json) {
    return MultiplayerSession(
      id: json['id'],
      hostId: json['hostId'],
      players: (json['players'] as List)
          .map((p) => MultiplayerPlayer.fromJson(p))
          .toList(),
      storyData: json['storyData'],
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
      isActive: json['isActive'],
    );
  }
}

enum MultiplayerMessageType {
  playerJoined,
  playerLeft,
  storySegment,
  choiceMade,
  gameComplete,
  ping,
  error,
}

class MultiplayerMessage {
  final MultiplayerMessageType type;
  final String? playerId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const MultiplayerMessage({
    required this.type,
    this.playerId,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'playerId': playerId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MultiplayerMessage.fromJson(Map<String, dynamic> json) {
    return MultiplayerMessage(
      type: MultiplayerMessageType.values.firstWhere(
        (t) => t.name == json['type'],
      ),
      playerId: json['playerId'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

abstract class MultiplayerRepository {
  Future<String> createSession(String hostId, String hostName);
  Future<MultiplayerSession?> joinSession(
    String sessionId,
    String playerId,
    String playerName,
  );
  Future<void> leaveSession(String sessionId, String playerId);
  Future<void> sendMessage(String sessionId, MultiplayerMessage message);
  Stream<MultiplayerMessage>? getSessionStream(String sessionId);
  MultiplayerSession? getSession(String sessionId);
  Future<void> updateStoryData(
    String sessionId,
    Map<String, dynamic> storyData,
  );
  bool sessionExists(String sessionId);
  List<MultiplayerSession> getActiveSessions();
  void dispose();
}

class InMemoryMultiplayerRepository implements MultiplayerRepository {
  final Map<String, MultiplayerSession> _sessions = {};
  final Map<String, StreamController<MultiplayerMessage>> _sessionStreams = {};
  final Map<String, Timer> _sessionTimers = {};

  static const int _maxSessionDuration = 3600; // 1 час в секундах
  static const int _sessionCleanupInterval = 300; // 5 минут

  InMemoryMultiplayerRepository() {
    Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupInactiveSessions(),
    );
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

    _sessions[sessionId] = session;
    _sessionStreams[sessionId] =
        StreamController<MultiplayerMessage>.broadcast();

    _sessionTimers[sessionId] = Timer(
      const Duration(seconds: _maxSessionDuration),
      () => _closeSession(sessionId),
    );

    return sessionId;
  }

  @override
  Future<MultiplayerSession?> joinSession(
    String sessionId,
    String playerId,
    String playerName,
  ) async {
    final session = _sessions[sessionId];
    if (session == null || !session.isActive) {
      return null;
    }

    if (session.players.any((p) => p.id == playerId)) {
      return session;
    }

    if (session.players.length >= 2) {
      return null;
    }

    final player = MultiplayerPlayer(
      id: playerId,
      name: playerName,
      joinedAt: DateTime.now(),
      isHost: false,
    );

    final updatedSession = MultiplayerSession(
      id: session.id,
      hostId: session.hostId,
      players: [...session.players, player],
      storyData: session.storyData,
      createdAt: session.createdAt,
      lastActivity: DateTime.now(),
      isActive: session.isActive,
    );

    _sessions[sessionId] = updatedSession;

    _sendMessage(
      sessionId,
      MultiplayerMessage(
        type: MultiplayerMessageType.playerJoined,
        playerId: playerId,
        data: {'player': player.toJson()},
        timestamp: DateTime.now(),
      ),
    );

    return updatedSession;
  }

  @override
  Future<void> leaveSession(String sessionId, String playerId) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final updatedPlayers = session.players
        .where((p) => p.id != playerId)
        .toList();

    if (updatedPlayers.isEmpty) {
      await _closeSession(sessionId);
      return;
    }

    String newHostId = session.hostId;
    if (session.hostId == playerId && updatedPlayers.isNotEmpty) {
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

    _sessions[sessionId] = updatedSession;

    _sendMessage(
      sessionId,
      MultiplayerMessage(
        type: MultiplayerMessageType.playerLeft,
        playerId: playerId,
        data: {'newHostId': newHostId},
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> sendMessage(String sessionId, MultiplayerMessage message) async {
    final session = _sessions[sessionId];
    if (session == null || !session.isActive) return;

    _updateSessionActivity(sessionId);
    _sendMessage(sessionId, message);
  }

  @override
  Stream<MultiplayerMessage>? getSessionStream(String sessionId) {
    return _sessionStreams[sessionId]?.stream;
  }

  @override
  MultiplayerSession? getSession(String sessionId) {
    return _sessions[sessionId];
  }

  @override
  Future<void> updateStoryData(
    String sessionId,
    Map<String, dynamic> storyData,
  ) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    final updatedSession = MultiplayerSession(
      id: session.id,
      hostId: session.hostId,
      players: session.players,
      storyData: storyData,
      createdAt: session.createdAt,
      lastActivity: DateTime.now(),
      isActive: session.isActive,
    );

    _sessions[sessionId] = updatedSession;
  }

  @override
  bool sessionExists(String sessionId) {
    final session = _sessions[sessionId];
    return session != null && session.isActive;
  }

  @override
  List<MultiplayerSession> getActiveSessions() {
    return _sessions.values.where((s) => s.isActive).toList();
  }

  void _sendMessage(String sessionId, MultiplayerMessage message) {
    final stream = _sessionStreams[sessionId];
    if (stream != null && !stream.isClosed) {
      stream.add(message);
    }
  }

  void _updateSessionActivity(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) return;

    final updatedSession = MultiplayerSession(
      id: session.id,
      hostId: session.hostId,
      players: session.players,
      storyData: session.storyData,
      createdAt: session.createdAt,
      lastActivity: DateTime.now(),
      isActive: session.isActive,
    );

    _sessions[sessionId] = updatedSession;
  }

  Future<void> _closeSession(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) return;

    _sendMessage(
      sessionId,
      MultiplayerMessage(
        type: MultiplayerMessageType.gameComplete,
        data: {'reason': 'session_closed'},
        timestamp: DateTime.now(),
      ),
    );

    final stream = _sessionStreams[sessionId];
    if (stream != null && !stream.isClosed) {
      await stream.close();
    }

    _sessionTimers[sessionId]?.cancel();
    _sessions.remove(sessionId);
    _sessionStreams.remove(sessionId);
    _sessionTimers.remove(sessionId);
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

  void _cleanupInactiveSessions() {
    final now = DateTime.now();
    final expiredSessions = <String>[];

    for (final entry in _sessions.entries) {
      final sessionId = entry.key;
      final session = entry.value;

      final inactiveTime = now.difference(session.lastActivity).inSeconds;
      if (inactiveTime > _sessionCleanupInterval) {
        expiredSessions.add(sessionId);
      }
    }

    for (final sessionId in expiredSessions) {
      _closeSession(sessionId);
    }
  }

  @override
  void dispose() {
    for (final sessionId in _sessions.keys.toList()) {
      _closeSession(sessionId);
    }
    for (final timer in _sessionTimers.values) {
      timer.cancel();
    }
    _sessions.clear();
    _sessionStreams.clear();
    _sessionTimers.clear();
  }
}
