import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/multiplayer_repository.dart';
import '../repositories/file_multiplayer_repository.dart';

class MultiplayerService {
  final MultiplayerRepository _repository;

  MultiplayerService(this._repository);

  Future<String> createSession(String hostId, String hostName) {
    return _repository.createSession(hostId, hostName);
  }

  Future<MultiplayerSession?> joinSession(
    String sessionId,
    String playerId,
    String playerName,
  ) {
    return _repository.joinSession(sessionId, playerId, playerName);
  }

  Future<void> leaveSession(String sessionId, String playerId) {
    return _repository.leaveSession(sessionId, playerId);
  }

  Future<void> sendMessage(String sessionId, MultiplayerMessage message) {
    return _repository.sendMessage(sessionId, message);
  }

  Stream<MultiplayerMessage>? getSessionStream(String sessionId) {
    return _repository.getSessionStream(sessionId);
  }

  MultiplayerSession? getSession(String sessionId) {
    return _repository.getSession(sessionId);
  }

  Future<void> updateStoryData(
    String sessionId,
    Map<String, dynamic> storyData,
  ) {
    return _repository.updateStoryData(sessionId, storyData);
  }

  bool sessionExists(String sessionId) {
    return _repository.sessionExists(sessionId);
  }

  List<MultiplayerSession> getActiveSessions() {
    return _repository.getActiveSessions();
  }

  void dispose() {
    _repository.dispose();
  }
}

class MultiplayerProviders {
  static final multiplayerRepositoryProvider =
      Provider<MultiplayerRepository>((ref) {
    return FileMultiplayerRepository();
  });

  static final multiplayerServiceProvider = Provider<MultiplayerService>((ref) {
    final repository = ref.watch(multiplayerRepositoryProvider);
    return MultiplayerService(repository);
  });

  static final currentSessionProvider = StateProvider<MultiplayerSession?>((
    ref,
  ) {
    return null;
  });

  static final currentPlayerIdProvider = StateProvider<String?>((ref) {
    return null;
  });

  static final sessionMessagesProvider =
      StreamProvider.family<MultiplayerMessage, String>((ref, sessionId) {
    final service = ref.watch(multiplayerServiceProvider);
    return service.getSessionStream(sessionId) ?? const Stream.empty();
  });
}
