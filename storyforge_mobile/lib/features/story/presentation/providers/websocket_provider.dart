import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storyforge_mobile/core/network/websocket_service.dart';

part 'websocket_provider.g.dart';

@riverpod
WebSocketService webSocket(WebSocketRef ref) {
  final service = WebSocketService();
  // TODO: implement initialization/disposal
  return service;
}
