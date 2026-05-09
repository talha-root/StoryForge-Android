import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';
import '../router/app_router.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final secureStorage = ref.watch(secureStorageProvider);

  dio.interceptors.add(AuthInterceptor(dio, secureStorage, ref));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorage _secureStorage;
  final Ref _ref;

  AuthInterceptor(this._dio, this._secureStorage, this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt to refresh token using a dedicated Dio instance to avoid interceptor loop
          final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
          final response = await refreshDio.post(
            '/api/accounts/token/refresh/',
            data: {'refresh': refreshToken},
          );

          final newAccessToken = response.data['access'];
          await _secureStorage.saveTokens(
            access: newAccessToken,
            refresh: refreshToken,
          );

          // Retry the original request
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final retryResponse = await _dio.fetch(options);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh failed
          await _secureStorage.clearTokens();
          _ref.read(appRouterPrvdr).go('/login');
        }
      } else {
        // No refresh token available
        await _secureStorage.clearTokens();
        _ref.read(appRouterPrvdr).go('/login');
      }
    }

    // Wrap into typed AppException
    final appException = _mapDioErrorToAppException(err);
    return handler.next(DioException(
      requestOptions: err.requestOptions,
      error: appException,
      type: err.type,
      response: err.response,
    ));
  }

  AppException _mapDioErrorToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return AuthException('Unauthorized access');
        }
        return ServerException('Server error: $statusCode');
      default:
        return AppException('Something went wrong');
    }
  }
}
