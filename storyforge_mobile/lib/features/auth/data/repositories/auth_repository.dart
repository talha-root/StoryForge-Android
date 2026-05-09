import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<(UserModel, String accessToken, String refreshToken)> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final user = UserModel.fromJson(response.data['user']);
      final access = response.data['access'] as String;
      final refresh = response.data['refresh'] as String;

      return (user, access, refresh);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(e.message ?? 'Login failed');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<UserModel> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw ServerException(e.message ?? 'Registration failed');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> logout() async {
    // Optional: Call logout endpoint if backend requires
    // For now, we mainly handle local token clearing in the provider
  }
}
