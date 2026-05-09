class ApiConstants {
  static const String baseUrl = 'http://192.168.18.53:8000';
  static const String wsBaseUrl = 'ws://192.168.18.53:8000';

  // Endpoints
  static const String login = '/api/auth/token';
  static const String register = '/api/auth/register';
  static const String tokenRefresh = '/api/auth/token/refresh';
  static const String stories = '/api/stories';
  static const String storyDetail = '/api/stories/{id}';
  static const String storyWebSocket = '/ws/story/{id}/';

  // Helper to replace placeholders
  static String getStoryDetail(String id) => storyDetail.replaceAll('{id}', id);
  static String getStoryWebSocket(String id) => storyWebSocket.replaceAll('{id}', id);
}
