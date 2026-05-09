import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/websocket_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/story_message.dart';

class WebSocketState {
  final List<StoryMessage> messages;
  final List<Map<String, dynamic>> branches;
  final bool isConnected;
  final bool isAiTyping;
  final bool isVoting;
  final String? turnUsername;
  final int? turnUserId;

  WebSocketState({
    this.messages = const [],
    this.branches = const [],
    this.isConnected = false,
    this.isAiTyping = false,
    this.isVoting = false,
    this.turnUsername,
    this.turnUserId,
  });

  WebSocketState copyWith({
    List<StoryMessage>? messages,
    List<Map<String, dynamic>>? branches,
    bool? isConnected,
    bool? isAiTyping,
    bool? isVoting,
    String? turnUsername,
    int? turnUserId,
  }) {
    return WebSocketState(
      messages: messages ?? this.messages,
      branches: branches ?? this.branches,
      isConnected: isConnected ?? this.isConnected,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      isVoting: isVoting ?? this.isVoting,
      turnUsername: turnUsername ?? this.turnUsername,
      turnUserId: turnUserId ?? this.turnUserId,
    );
  }
}

final websocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
  final wsService = ref.watch(websocketServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return WebSocketNotifier(wsService, secureStorage);
});

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  final WebSocketService _wsService;
  final SecureStorage _secureStorage;
  StreamSubscription? _subscription;

  WebSocketNotifier(this._wsService, this._secureStorage) : super(WebSocketState());

  Future<void> connect(int storyId, {
    List<StoryMessage>? history,
    int? initialTurnUserId,
    String? initialTurnUsername,
  }) async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) return;

    // Normalize history roles (convert 'human' to 'user' if needed)
    final normalizedHistory = history?.map((m) => m.copyWith(
      role: m.role == 'human' ? 'user' : m.role
    )).toList();

    state = state.copyWith(
      isConnected: false,
      messages: normalizedHistory ?? [],
      turnUserId: initialTurnUserId,
      turnUsername: initialTurnUsername,
      isAiTyping: initialTurnUserId == null && (normalizedHistory?.isNotEmpty ?? false),
    );

    await _wsService.connect(storyId.toString(), token);
    
    _subscription?.cancel();
    _subscription = _wsService.messages.listen((data) {
      _handleMessage(data);
    });

    state = state.copyWith(isConnected: true);
  }

  void _handleMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return;

    final type = data['type'];
    
    switch (type) {
      case 'new_segment':
      case 'voting_result':
        final segment = data['segment'];
        final message = StoryMessage(
          role: segment['author_type'] == 'human' ? 'user' : 'ai',
          content: segment['content'],
          timestamp: DateTime.parse(segment['created_at']),
        );
        state = state.copyWith(
          messages: [...state.messages, message],
          isAiTyping: false,
          isVoting: false,
          branches: [],
        );
        break;

      case 'ai_branches_start':
        state = state.copyWith(isAiTyping: true, isVoting: false);
        break;

      case 'ai_branches_final':
        final List<dynamic> branchesList = data['branches'] ?? [];
        state = state.copyWith(
          branches: branchesList.cast<Map<String, dynamic>>(),
          isAiTyping: false,
          isVoting: true,
        );
        break;

      case 'turn_changed':
        state = state.copyWith(
          turnUserId: data['user_id'],
          turnUsername: data['username'],
          isAiTyping: data['user_id'] == null, // AI turn means thinking/typing
        );
        break;

      case 'ai_thinking':
        state = state.copyWith(isAiTyping: true);
        break;

      case 'ai_done':
        state = state.copyWith(isAiTyping: false);
        break;

      case 'error':
        // Handle error (could add a transient error state)
        break;
    }
  }

  void sendTurn(String userInput) {
    if (userInput.trim().isEmpty) return;
    
    _wsService.sendMessage({
      'type': 'submit_paragraph',
      'content': userInput,
    });
  }

  void selectBranch(int branchId) {
    _wsService.sendMessage({
      'type': 'select_branch',
      'branch_id': branchId,
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _wsService.disconnect();
    super.dispose();
  }
}
