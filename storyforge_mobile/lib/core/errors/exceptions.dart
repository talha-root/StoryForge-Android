class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No internet connection', super.code]);
}

class AuthException extends AppException {
  AuthException([super.message = 'Authentication failed', super.code]);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred', super.code]);
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache error occurred', super.code]);
}
