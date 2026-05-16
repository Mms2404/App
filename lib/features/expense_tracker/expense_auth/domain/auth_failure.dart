// AUTH FAILURE
// -----------------------------------------------------------------------------
// Freezed sealed union — the auth flow can fail in exactly these ways.
//
// Why sealed? Because the compiler enforces that any switch/when statement
// handles every case. Add a new failure type, every consumer breaks until
// it's handled. That's a feature, not a bug — it prevents forgotten cases.
//
// Compare to the shop app, where we used a sealed class manually. Freezed
// generates equality, hashCode, toString, and the `when`/`map` helpers
// automatically. One annotation replaces ~50 lines of boilerplate.
//
// Run `dart run build_runner build` after creating this file.
// -----------------------------------------------------------------------------

import 'package:app/core/error/failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
class AuthFailure with _$AuthFailure implements Failure {
  const AuthFailure._();

  const factory AuthFailure.invalidCredentials() = _InvalidCredentials;
  const factory AuthFailure.network() = _Network;
  const factory AuthFailure.serverError(int statusCode) = _ServerError;
  const factory AuthFailure.unknown(String details) = _Unknown;

  @override
  String get message => when(
        invalidCredentials: () => 'Invalid username or password',
        network: () => 'No internet connection',
        serverError: (code) => 'Server error ($code). Try again.',
        unknown: (details) => 'Something went wrong: $details',
      );
}