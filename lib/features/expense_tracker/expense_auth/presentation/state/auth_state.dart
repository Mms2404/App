// AUTH STATE
// -----------------------------------------------------------------------------
// Freezed sealed union — the auth flow exists in exactly one of four states.
//
// Compare to the shop app, where we used:
//   bool _isLoading
//   String? _errorMessage
//   bool _hasSearched
//
// Three independent booleans = 8 possible combinations, many impossible
// (loading AND errored AND has data?). The compiler can't help.
//
// With a sealed union, the state is ONE of four things. The UI must handle
// each variant. Impossible states can't exist.
//
// Run `dart run build_runner build` after creating this file.
// -----------------------------------------------------------------------------

import 'package:app/features/expense_tracker/expense_auth/domain/auth_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  /// No user logged in. Initial state and post-logout.
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Login request in flight.
  const factory AuthState.authenticating() = _Authenticating;

  /// Logged in. Token is stored in secure storage.
  const factory AuthState.authenticated(String token) = _Authenticated;

  /// Login attempt failed. UI shows failure.message.
  const factory AuthState.failed(AuthFailure failure) = _Failed;
}