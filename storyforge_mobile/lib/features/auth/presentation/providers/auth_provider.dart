import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  FutureOr<UserModel?> build() async {
    final secureStorage = ref.watch(secureStorageProvider);
    final userJson = await secureStorage.getUser();
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final secureStorage = ref.read(secureStorageProvider);

      final (user, access, refresh) = await repository.login(username, password);
      
      await secureStorage.saveTokens(access: access, refresh: refresh);
      await secureStorage.saveUser(jsonEncode(user.toJson()));
      
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(username, email, password);
      
      // After registration, we usually ask user to login or auto-login
      // For now, let's just keep state as is or auto-login if backend returns tokens
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.clearTokens();
    // Also clear user data
    // Assuming SecureStorage has a clearUser or similar, or just delete key
    state = const AsyncValue.data(null);
  }
}
