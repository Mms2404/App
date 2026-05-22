// SIGN UP USE CASE
// -----------------------------------------------------------------------------
// Wraps the signup operation. Same pattern as Login — thin class, future-
// proofs against business rules (validation, terms acceptance, analytics).
// -----------------------------------------------------------------------------

import 'package:app/features/expense_tracker/expense_auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUp {
  final AuthRepository _repo;
  SignUp(this._repo);

  Future<String> call({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) {
    return _repo.signUp(
      username: username,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
  }
}

final signUpUseCaseProvider = Provider<SignUp>((ref) {
  return SignUp(ref.watch(authRepositoryProvider));
});