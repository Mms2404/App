import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:app/features/expense_tracker/expense_tracker/presentation/controllers/expense_list_controller.dart';
import 'package:app/features/expense_tracker/expense_tracker/presentation/screens/expense_edit_screen.dart';
import 'package:app/features/search/presentation/widgets/ui_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String _viewType = 'Total';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  double _calculateTotal(List<Expense> expenses) =>
      expenses.fold(0.0, (sum, e) => sum + e.amountAsDouble);

  double _calculateMonthly(List<Expense> expenses, int month, int year) {
    return expenses
        .where((e) {
          final d = e.dateAsDateTime;
          return d != null && d.month == month && d.year == year;
        })
        .fold(0.0, (sum, e) => sum + e.amountAsDouble);
  }

  void _openAdd() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseEditScreen()),
    );
  }

  void _openEdit(Expense expense) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ExpenseEditScreen(expense: expense)),
    );
  }

  void _logout() {
    ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Your expenses',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(expenseListControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.textSecondary,
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.bgBase,
        tooltip: 'Add expense',
        child: const Icon(Icons.add_rounded),
      ),
      body: OrbBackground(
        child: state.when(
          initial: () => const LoadingState(message: 'Loading expenses…'),
          loading: () => const LoadingState(message: 'Loading expenses…'),
          loaded: (expenses) => _buildList(expenses, errorBanner: null),
          error: (failure, cachedExpenses) {
            if (cachedExpenses != null) {
              return _buildList(cachedExpenses, errorBanner: failure.message);
            }
            return ErrorStateView(
              message: failure.message,
              onRetry: () =>
                  ref.read(expenseListControllerProvider.notifier).fetch(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Expense> expenses, {String? errorBanner}) {
    if (expenses.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 40.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 12.h),
              Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Tap + to add your first expense',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final amount = _viewType == 'Total'
        ? _calculateTotal(expenses)
        : _calculateMonthly(expenses, _selectedMonth, _selectedYear);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errorBanner != null) ...[
            _RefreshErrorBanner(message: errorBanner),
            SizedBox(height: 12.h),
          ],
          _SummaryCard(
            viewType: _viewType,
            amount: amount,
            selectedMonth: _selectedMonth,
            selectedYear: _selectedYear,
            onViewTypeChanged: (v) => setState(() => _viewType = v),
            onMonthChanged: (m) => setState(() => _selectedMonth = m),
            onYearChanged: (y) => setState(() => _selectedYear = y),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.separated(
              itemCount: expenses.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (_, i) => _ExpenseTile(
                expense: expenses[i],
                onTap: () => _openEdit(expenses[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String viewType;
  final double amount;
  final int selectedMonth;
  final int selectedYear;
  final ValueChanged<String> onViewTypeChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const _SummaryCard({
    required this.viewType,
    required this.amount,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onViewTypeChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 0.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Dropdown<String>(
                value: viewType,
                items: const ['Total', 'Monthly'],
                onChanged: onViewTypeChanged,
                label: (v) => '$v expenses',
              ),
              if (viewType == 'Monthly') ...[
                SizedBox(width: 8.w),
                _Dropdown<int>(
                  value: selectedMonth,
                  items: List.generate(12, (i) => i + 1),
                  onChanged: onMonthChanged,
                  label: (m) => _monthName(m),
                ),
                SizedBox(width: 8.w),
                _Dropdown<int>(
                  value: selectedYear,
                  items: List.generate(5, (i) => DateTime.now().year - i),
                  onChanged: onYearChanged,
                  label: (y) => '$y',
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5.w,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m];
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T) label;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButton<T>(
        value: value,
        dropdownColor: AppColors.bgElevated,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.expand_more_rounded, size: 18.sp, color: AppColors.textSecondary),
        style:  TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(label(item))))
            .toList(),
        onChanged: (v) => v == null ? null : onChanged(v),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const _ExpenseTile({required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border, width: 0.5.w),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.receipt_outlined,
                size: 16.sp,
                color: AppColors.accent,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style:TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${expense.category} · ${expense.date}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Rs. ${expense.amount}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshErrorBanner extends StatelessWidget {
  final String message;
  const _RefreshErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 0.5.w),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 13.sp, color: AppColors.danger),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}