// API CLIENT
// -----------------------------------------------------------------------------
// Dio with an authentication interceptor. The interceptor reads the auth
// token from secure storage on every request and attaches it as a header.
//
// Why this matters: previously, every API call had to manually do:
//   headers: {'Authorization': 'Token $token'}
// Now it's automatic. Add a new API endpoint, and auth just works.
//
// This is a Riverpod Provider with `ref.watch(secureStorageProvider)` — that
// means if secureStorageProvider ever changes, this Dio instance is rebuilt.
// In production it won't change, but the pattern is correct.
// -----------------------------------------------------------------------------

import 'package:app/core/constants/api_config.dart';
import 'package:app/core/storage/secure_storage_provider.dart';
import 'package:app/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  dio.interceptors.add(_AuthInterceptor(storage));
  dio.interceptors.add(_LoggingInterceptor());

  return dio;
});

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  _AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for the login endpoint itself
    if (options.path.contains('api-token-auth')) {
      return handler.next(options);
    }

    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Token $token';
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log.w('✗ ${err.requestOptions.uri} — ${err.message}');
    handler.next(err);
  }
}