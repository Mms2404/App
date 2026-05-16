// EXPENSE ENTITY
// -----------------------------------------------------------------------------
// A Freezed entity. Compare to the shop app's models — there we had plain
// Dart classes with manual constructors and no equality. Freezed gives us:
//
//   1. Immutability — all fields are final, no setters
//   2. Value equality — two Expenses with same fields are ==
//   3. copyWith — `expense.copyWith(title: 'New')` returns a new Expense
//   4. toString — readable debug output
//   5. fromJson/toJson — JSON parsing generated, no manual code
//
// `@JsonKey(includeIfNull: false)` on `id` — when creating a new expense
// (POST), id is null and we don't send it. Django generates it server-side.
// On responses (GET/PUT), id is always present.
//
// Run `dart run build_runner build` after creating this file.
// -----------------------------------------------------------------------------

import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const Expense._();

  const factory Expense({
    @JsonKey(includeIfNull: false) int? id,
    required String title,
    required String amount,
    required String category,
    required String date,
    @Default('') String description,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  /// Parse the amount string to a double for math.
  /// Returns 0.0 if parsing fails.
  double get amountAsDouble => double.tryParse(amount) ?? 0.0;

  /// Parse the date string to DateTime.
  /// Returns null if parsing fails.
  DateTime? get dateAsDateTime => DateTime.tryParse(date);
}