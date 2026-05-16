// EXPENSE LIST CONTROLLER
// -----------------------------------------------------------------------------
// Owns the list state. The screen reads this provider and renders based on
// the state variant.
//
// `refresh()` is separate from `_fetch()` so the UI can show "refreshing"
// without blanking the existing list — we keep showing the cached data
// while a new fetch is in flight.
//
// Observe: this controller doesn't know about Dio, HTTP, JSON, or Django.
// All it knows is "call the use case, get a list or a failure." That's
// the clean-architecture payoff — the controller is testable with a mock
// use case, no network involved.
// -----------------------------------------------------------------------------

import 'package:app/core/utils/logger.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/expense_failure.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/usecases/expense_usecases.dart';
import 'package:app/features/expense_tracker/expense_tracker/presentation/state/expense_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseListController extends Notifier<ExpenseListState> {
  late final GetExpenses _getExpenses;
  late final AddExpense _addExpense;
  late final UpdateExpense _updateExpense;
  late final DeleteExpense _deleteExpense;

  @override
  ExpenseListState build() {
    _getExpenses = ref.read(getExpensesProvider);
    _addExpense = ref.read(addExpenseProvider);
    _updateExpense = ref.read(updateExpenseProvider);
    _deleteExpense = ref.read(deleteExpenseProvider);
    // Fetch on first build
    Future.microtask(fetch);
    return const ExpenseListState.initial();
  }

  Future<void> fetch() async {
    state = const ExpenseListState.loading();
    try {
      final expenses = await _getExpenses();
      state = ExpenseListState.loaded(expenses);
    } on ExpenseFailure catch (failure) {
      state = ExpenseListState.error(failure);
    } catch (e, st) {
      log.e('Unexpected error fetching expenses', error: e, stackTrace: st);
      state = ExpenseListState.error(ExpenseFailure.unknown(e.toString()));
    }
  }

  /// Re-fetches without blanking the list. UI can show a subtle spinner.
  Future<void> refresh() async {
    final cached = state.maybeWhen<List<Expense>?>(
      loaded: (List<Expense> list) => list,
      orElse: () => null,
    );
    try {
      final expenses = await _getExpenses();
      state = ExpenseListState.loaded(expenses);
    } on ExpenseFailure catch (failure) {
      state = ExpenseListState.error(failure, cachedExpenses: cached);
    } catch (e, st) {
      log.e('Unexpected error refreshing expenses', error: e, stackTrace: st);
      state = ExpenseListState.error(
        ExpenseFailure.unknown(e.toString()),
        cachedExpenses: cached,
      );
    }
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      await _addExpense(expense);
      await fetch();
      return true;
    } on ExpenseFailure catch (failure) {
      log.w('Add expense failed: ${failure.message}');
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      await _updateExpense(expense);
      await fetch();
      return true;
    } on ExpenseFailure catch (failure) {
      log.w('Update expense failed: ${failure.message}');
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _deleteExpense(id);
      await fetch();
      return true;
    } on ExpenseFailure catch (failure) {
      log.w('Delete expense failed: ${failure.message}');
      return false;
    }
  }
}

final expenseListControllerProvider =
    NotifierProvider<ExpenseListController, ExpenseListState>(
  ExpenseListController.new,
);