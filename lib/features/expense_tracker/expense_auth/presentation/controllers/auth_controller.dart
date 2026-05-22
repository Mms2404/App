// AUTH CONTROLLER
// -----------------------------------------------------------------------------
// A Riverpod Notifier owns a piece of state and exposes methods to mutate it.
// Compare to Provider's ChangeNotifier:
//   - ChangeNotifier: you mutate fields, call notifyListeners() manually
//   - Notifier:       you replace `state` with a new value, listeners are
//                     notified automatically
//
// Riverpod also auto-disposes notifiers when no UI watches them — no manual
// dispose needed.
//
// On startup, the controller checks for an existing token. If found, the
// user is already authenticated (returning user). If not, they see login.
// -----------------------------------------------------------------------------

import 'package:app/core/utils/logger.dart';
import 'package:app/features/expense_tracker/expense_auth/data/auth_repository.dart';
import 'package:app/features/expense_tracker/expense_auth/domain/auth_failure.dart';
import 'package:app/features/expense_tracker/expense_auth/domain/usecases/login.dart';
import 'package:app/features/expense_tracker/expense_auth/domain/usecases/sign_up.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends Notifier<AuthState> {
  late final Login _login;
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _login = ref.read(loginUseCaseProvider);
    _repo = ref.read(authRepositoryProvider);
    // Check for existing token — auto-login returning users
    _restoreSession();
    return const AuthState.unauthenticated();
  }

  Future<void> _restoreSession() async {
    final token = await _repo.readToken();
    if (token != null) {
      log.i('Restoring auth session');
      state = AuthState.authenticated(token);
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AuthState.authenticating();
    try {
      final token = await _login(username: username, password: password);
      state = AuthState.authenticated(token);
    } on AuthFailure catch (failure) {
      state = AuthState.failed(failure);
    } catch (e, st) {
      log.e('Unexpected auth error', error: e, stackTrace: st);
      state = AuthState.failed(AuthFailure.unknown(e.toString()));
    }
  }


  Future<void> signUp({
  required String username,
  required String email,
  required String password,
  required String passwordConfirm,
}) async {
  state = const AuthState.authenticating();
  try {
    final signUp = ref.read(signUpUseCaseProvider);
    final token = await signUp(
      username: username,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
    log.d('Signup got token: ${token.substring(0, 10)}...');
    state = AuthState.authenticated(token);
    log.d('State is now: $state');  
  } on AuthFailure catch (failure) {
    log.d('Signup failed: ${failure.message}'); 
    state = AuthState.failed(failure);
  } catch (e, st) {
    log.e('Unexpected signup error', error: e, stackTrace: st);
    state = AuthState.failed(AuthFailure.unknown(e.toString()));
  }
}

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState.unauthenticated();
  }

   /// Clear the failure state so user can try again.
  void clearError() {
  state.maybeWhen(
    failed: (_) => state = const AuthState.unauthenticated(),
    orElse: () {},
  );
}

}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);