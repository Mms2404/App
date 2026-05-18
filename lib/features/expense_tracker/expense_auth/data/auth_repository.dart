// AUTH REPOSITORY
// -----------------------------------------------------------------------------
// The repository sits between the controller and the network. Its job:
//   1. Call the API via Dio
//   2. Catch DioException and translate to typed AuthFailure
//   3. Save/clear the auth token in secure storage
//
// The controller (next layer up) never sees DioException, never sees
// HTTP status codes. It just gets either a token string or a Failure.
//
// This is the SINGLE PLACE where Django HTTP details live. If you swap
// Django for Firebase tomorrow, only this file changes — the use cases,
// controller, and UI are untouched. That's the value of clean architecture.
// -----------------------------------------------------------------------------

import 'package:app/core/constants/api_config.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/secure_storage_provider.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/features/expense_tracker/expense_auth/domain/auth_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  /// Returns the auth token on success.
  /// Throws AuthFailure on any failure.
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.api_token_auth,
        data: {'username': username, 'password': password},
      );

      final token = response.data['token'] as String?;
      if (token == null) {
        throw const AuthFailure.unknown('Token missing from response');
      }

      await _storage.write(key: 'auth_token', value: token);
      log.i('Auth token saved');
      return token;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure.unknown(e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    log.i('Auth token cleared');
  }

  Future<String?> readToken() async {
    return _storage.read(key: 'auth_token');
  }

  AuthFailure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const AuthFailure.network();
    }
    final status = e.response?.statusCode;
    if (status == 400 || status == 401) {
      return const AuthFailure.invalidCredentials();
    }
    if (status != null) {
      return AuthFailure.serverError(status);
    }
    return AuthFailure.unknown(e.message ?? 'Unknown Dio error');
  }
}

// Provider — wires Dio + storage into the repository.
// Anyone who needs auth reads this provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});