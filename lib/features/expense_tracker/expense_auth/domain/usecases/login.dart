// LOGIN USE CASE
// -----------------------------------------------------------------------------
// A "use case" is a class that wraps ONE business operation. It's effectively
// a function — call it, it does the thing. So why a class?
//
// 1. Testable: easy to mock in controller tests
// 2. Discoverable: opening features/expense_auth/usecases/ tells you exactly
//    what operations exist in this feature
// 3. Composable: a use case can call other use cases without controllers
//    knowing
// 4. Single responsibility: this file does ONE thing — log in.
//
// Honest take: for simple CRUD apps, use cases add ceremony. For complex apps
// with validation, business rules, and orchestration, they pay off. We're
// including them here as a teaching demonstration of the full clean-arch
// pattern.
// -----------------------------------------------------------------------------

import 'package:app/features/expense_tracker/expense_auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Login {
  final AuthRepository _repo;
  Login(this._repo);

  Future<String> call({
    required String username,
    required String password,
  }) {
    return _repo.login(username: username, password: password);
  }
}

final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});