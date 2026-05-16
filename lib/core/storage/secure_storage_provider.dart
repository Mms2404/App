// SECURE STORAGE PROVIDER
// -----------------------------------------------------------------------------
// Wraps FlutterSecureStorage as a Riverpod Provider. This is dependency
// injection — instead of every file creating its own FlutterSecureStorage()
// instance, they all read this provider. Makes testing trivial: override
// the provider in tests, all callers get the mock.
//
// `Provider<T>` is the simplest Riverpod provider — read-only, computed once.
// Use it for services and singletons.
// -----------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});