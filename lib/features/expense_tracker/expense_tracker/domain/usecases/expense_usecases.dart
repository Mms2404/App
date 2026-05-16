// EXPENSE USE CASES
// -----------------------------------------------------------------------------
// Four use cases, one per CRUD operation. Each is a thin wrapper around the
// repository.
//
// For a simple CRUD app, you could skip use cases and call repository
// methods directly from controllers. Including them here demonstrates the
// pattern. They become valuable when:
//   - Multiple controllers need the same logic
//   - You add validation/business rules ON TOP of the repository call
//   - You want to swap an HTTP call for a local-cache-first strategy
// -----------------------------------------------------------------------------

import 'package:app/features/expense_tracker/expense_tracker/data/expense_repository.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetExpenses {
  final ExpenseRepository _repo;
  GetExpenses(this._repo);
  Future<List<Expense>> call() => _repo.getExpenses();
}

class AddExpense {
  final ExpenseRepository _repo;
  AddExpense(this._repo);
  Future<Expense> call(Expense expense) => _repo.addExpense(expense);
}

class UpdateExpense {
  final ExpenseRepository _repo;
  UpdateExpense(this._repo);
  Future<Expense> call(Expense expense) => _repo.updateExpense(expense);
}

class DeleteExpense {
  final ExpenseRepository _repo;
  DeleteExpense(this._repo);
  Future<void> call(int id) => _repo.deleteExpense(id);
}

// Providers for each use case — controllers read these.
final getExpensesProvider = Provider<GetExpenses>((ref) {
  return GetExpenses(ref.watch(expenseRepositoryProvider));
});

final addExpenseProvider = Provider<AddExpense>((ref) {
  return AddExpense(ref.watch(expenseRepositoryProvider));
});

final updateExpenseProvider = Provider<UpdateExpense>((ref) {
  return UpdateExpense(ref.watch(expenseRepositoryProvider));
});

final deleteExpenseProvider = Provider<DeleteExpense>((ref) {
  return DeleteExpense(ref.watch(expenseRepositoryProvider));
});