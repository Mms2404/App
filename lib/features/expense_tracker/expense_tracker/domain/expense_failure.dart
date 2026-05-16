// EXPENSE FAILURE
// -----------------------------------------------------------------------------
// Same pattern as AuthFailure. The CRUD operations can fail in these ways.
// Unauthorized is its own variant — when it fires, the gateway should
// kick the user back to login (token expired).
// -----------------------------------------------------------------------------

import 'package:app/core/error/failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_failure.freezed.dart';

@freezed
class ExpenseFailure with _$ExpenseFailure implements Failure {
  const ExpenseFailure._();

  const factory ExpenseFailure.network() = _Network;
  const factory ExpenseFailure.unauthorized() = _Unauthorized;
  const factory ExpenseFailure.notFound() = _NotFound;
  const factory ExpenseFailure.serverError(int statusCode) = _ServerError;
  const factory ExpenseFailure.validation(String details) = _Validation;
  const factory ExpenseFailure.unknown(String details) = _Unknown;

  @override
  String get message => when(
        network: () => 'No internet connection',
        unauthorized: () => 'Session expired. Please log in again.',
        notFound: () => 'Expense not found',
        serverError: (code) => 'Server error ($code). Try again.',
        validation: (details) => 'Invalid data: $details',
        unknown: (details) => 'Something went wrong: $details',
      );
}