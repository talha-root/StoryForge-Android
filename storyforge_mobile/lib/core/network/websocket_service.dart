import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../constants/api_constants.dart';

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<dynamic>? _messageController;
  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;
  
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  bool _isManuallyClosed = false;
  String? _currentStoryId;
  String? _currentToken;

  Stream<dynamic> get messages => _messageController?.stream ?? const Stream.empty();
  bool get isConnected => _channel != null;

  Future<void> connect(String storyId, String token) async {
    _currentStoryId = storyId;
    _currentToken = token;
    _isManuallyClosed = false;
    _reconnectAttempts = 0;
    
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    if (_currentStoryId == null || _currentToken == null) return;

    final wsUrl = Uri.parse('${ApiConstants.wsBaseUrl}${ApiConstants.getStoryWebSocket(_currentStoryId!)}?token=$_currentToken');
    
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _messageController ??= StreamController<dynamic>.broadcast();
      
      _startKeepAlive();
      
      _channel!.stream.listen(
        (message) {
          _reconnectAttempts = 0;
          _messageController?.add(jsonDecode(message));
        },
        onError: (error) {
          _handleConnectionError();
        },
        onDone: () {
          _handleConnectionClosed();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleConnectionError();
    }
  }

  void _handleConnectionError() {
    _channel = null;
    _stopKeepAlive();
    if (!_isManuallyClosed && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _handleConnectionClosed() {
    _channel = null;
    _stopKeepAlive();
    if (!_isManuallyClosed && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _establishConnection();
    });
  }

  void _startKeepAlive() {
    _stopKeepAlive();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void disconnect() {
    _isManuallyClosed = true;
    _reconnectTimer?.cancel();
    _stopKeepAlive();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _currentStoryId = null;
    _currentToken = null;
  }
}
