// EXPENSE LIST STATE
// -----------------------------------------------------------------------------
// Sealed union for the list screen. Four states:
//   - initial: first frame before anything has loaded
//   - loading: actively fetching
//   - loaded: have data, can show the list
//   - error: fetch failed, show retry
//
// Note: `loaded` carries the data. `error` optionally carries the previously-
// loaded data so we don't blank the screen on refresh failure — user keeps
// seeing their list while we surface the error inline.
//
// Compare to the shop's manual `isLoading`/`error`/`data` fields — here, the
// state literally cannot be both loading AND have an error. The compiler
// makes invalid combinations unrepresentable.
// -----------------------------------------------------------------------------


import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/expense_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_list_state.freezed.dart';

@freezed
class ExpenseListState with _$ExpenseListState {
  const factory ExpenseListState.initial() = _Initial;
  const factory ExpenseListState.loading() = _Loading;
  const factory ExpenseListState.loaded(List<Expense> expenses) = _Loaded;
  const factory ExpenseListState.error(
    ExpenseFailure failure, {
    List<Expense>? cachedExpenses,
  }) = _Error;
}