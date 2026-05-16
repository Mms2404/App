// EXPENSE REPOSITORY
// -----------------------------------------------------------------------------
// All HTTP for the expense tracker lives here. Maps Dio errors to typed
// ExpenseFailures. Returns parsed Expense entities, not raw maps.
//
// Note: the auth token is attached automatically by the Dio interceptor.
// This file never sees the token. That's clean separation — the repository
// describes WHAT to fetch, the interceptor handles HOW to authenticate.
// -----------------------------------------------------------------------------

import 'package:app/core/network/api_client.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/expense_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseRepository {
  final Dio _dio;
  ExpenseRepository(this._dio);

  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _dio.get('/expenses/');
      final List data = response.data as List;
      return data
          .map((j) => Expense.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ExpenseFailure.unknown(e.toString());
    }
  }

  Future<Expense> addExpense(Expense expense) async {
    try {
      final response = await _dio.post(
        '/expenses/',
        data: expense.toJson(),
      );
      return Expense.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ExpenseFailure.unknown(e.toString());
    }
  }

  Future<Expense> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw const ExpenseFailure.validation('Expense ID is required for update');
    }
    try {
      final response = await _dio.put(
        '/expenses/${expense.id}/',
        data: expense.toJson(),
      );
      return Expense.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ExpenseFailure.unknown(e.toString());
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _dio.delete('/expenses/$id/');
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ExpenseFailure.unknown(e.toString());
    }
  }

  ExpenseFailure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ExpenseFailure.network();
    }
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return const ExpenseFailure.unauthorized();
    }
    if (status == 404) {
      return const ExpenseFailure.notFound();
    }
    if (status == 400) {
      log.w('Validation error: ${e.response?.data}');
      return ExpenseFailure.validation(e.response?.data?.toString() ?? 'Bad request');
    }
    if (status != null) {
      return ExpenseFailure.serverError(status);
    }
    return ExpenseFailure.unknown(e.message ?? 'Unknown Dio error');
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(dioProvider));
});