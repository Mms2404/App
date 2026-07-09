import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense_categories.dart';
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
  String _viewType      = 'Total';
  int _selectedMonth    = DateTime.now().month;
  int _selectedYear     = DateTime.now().year;
  String? _filterCategory; // null = All

  double _calculateTotal(List<Expense> expenses) =>
      expenses.fold(0.0, (sum, e) => sum + e.amountAsDouble);

  double _calculateMonthly(List<Expense> expenses, int month, int year) =>
      expenses.where((e) {
        final d = e.dateAsDateTime;
        return d != null && d.month == month && d.year == year;
      }).fold(0.0, (sum, e) => sum + e.amountAsDouble);

  List<Expense> _applyFilter(List<Expense> all) {
    if (_filterCategory == null) return all;
    return all.where((e) => e.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseListControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Your expenses',
            style: TextStyle(fontFamily: 'Manrope',
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(expenseListControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
          ),
          IconButton(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push<bool>(context,
            MaterialPageRoute(builder: (_) => const ExpenseEditScreen())),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.bgBase,
        child: const Icon(Icons.add_rounded),
      ),
      body: OrbBackground(
        child: state.when(
          initial: () => const LoadingState(message: 'Loading expenses…'),
          loading: () => const LoadingState(message: 'Loading expenses…'),
          loaded: (expenses) => _buildContent(expenses, errorBanner: null),
          error: (failure, cached) {
            if (cached != null) return _buildContent(cached, errorBanner: failure.message);
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

  Widget _buildContent(List<Expense> allExpenses, {String? errorBanner}) {
    final filtered = _applyFilter(allExpenses);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),

          if (errorBanner != null) ...[
            _RefreshErrorBanner(message: errorBanner),
            SizedBox(height: 12.h),
          ],

          // Summary card always shows total of filtered set
          _SummaryCard(
            viewType: _viewType,
            amount: _viewType == 'Total'
                ? _calculateTotal(filtered)
                : _calculateMonthly(filtered, _selectedMonth, _selectedYear),
            selectedMonth: _selectedMonth,
            selectedYear: _selectedYear,
            onViewTypeChanged: (v) => setState(() => _viewType = v),
            onMonthChanged: (m) => setState(() => _selectedMonth = m),
            onYearChanged: (y) => setState(() => _selectedYear = y),
          ),
          SizedBox(height: 12.h),

          // ── Category filter chips ──────────────────────────────────────
          _CategoryFilterRow(
            allExpenses: allExpenses,
            selected: _filterCategory,
            onSelected: (v) => setState(() => _filterCategory = v),
          ),
          SizedBox(height: 10.h),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(filtered: _filterCategory != null)
                : ListView.separated(
                    padding: EdgeInsets.only(bottom: 96.h),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (_, i) => _ExpenseTile(
                      expense: filtered[i],
                      onTap: () => Navigator.push<bool>(context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ExpenseEditScreen(expense: filtered[i]))),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Category filter row ───────────────────────────────────────────────────────

class _CategoryFilterRow extends StatelessWidget {
  final List<Expense> allExpenses;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryFilterRow({
    required this.allExpenses,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Only show categories that have at least one expense
    final usedValues = allExpenses.map((e) => e.category).toSet();
    final usedCats = kExpenseCategories
        .where((c) => usedValues.contains(c.value))
        .toList();

    if (usedCats.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          _FilterChip(
            label: 'All',
            icon: Icons.list_rounded,
            color: AppColors.accent,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          SizedBox(width: 8.w),
          ...usedCats.map((cat) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _FilterChip(
                  label: cat.label,
                  icon: cat.icon,
                  color: cat.color,
                  selected: selected == cat.value,
                  onTap: () => onSelected(cat.value),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label, required this.icon, required this.color,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.2.w : 0.8.w),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 13.sp,
              color: selected ? color : AppColors.textTertiary),
          SizedBox(width: 5.w),
          Text(label,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// ── Summary card (unchanged logic) ───────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String viewType;
  final double amount;
  final int selectedMonth, selectedYear;
  final ValueChanged<String> onViewTypeChanged;
  final ValueChanged<int> onMonthChanged, onYearChanged;

  const _SummaryCard({
    required this.viewType, required this.amount,
    required this.selectedMonth, required this.selectedYear,
    required this.onViewTypeChanged, required this.onMonthChanged,
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
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
                label: (m) => _monthName(m)),
            SizedBox(width: 8.w),
            _Dropdown<int>(
                value: selectedYear,
                items: List.generate(5, (i) => DateTime.now().year - i),
                onChanged: onYearChanged,
                label: (y) => '$y'),
          ],
        ]),
        SizedBox(height: 12.h),
        Text('Rs. ${amount.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 28.sp, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, letterSpacing: -0.5.w)),
      ]),
    );
  }

  String _monthName(int m) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m];
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T) label;

  const _Dropdown({required this.value, required this.items,
      required this.onChanged, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8.r)),
      child: DropdownButton<T>(
        value: value,
        dropdownColor: AppColors.bgElevated,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.expand_more_rounded,
            size: 18.sp, color: AppColors.textSecondary),
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        items: items.map((item) =>
            DropdownMenuItem(value: item, child: Text(label(item)))).toList(),
        onChanged: (v) => v == null ? null : onChanged(v),
      ),
    );
  }
}

// ── Expense tile ──────────────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  const _ExpenseTile({required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = categoryFor(expense.category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border, width: 0.5.w),
        ),
        child: Row(children: [
          Container(
            width: 38.w, height: 38.h,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(cat.icon, size: 17.sp, color: cat.color),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.title,
                  style: TextStyle(fontSize: 14.sp,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              SizedBox(height: 2.h),
              Text('${cat.label} · ${expense.date}',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary)),
            ],
          )),
          Text('Rs. ${expense.amount}',
              style: TextStyle(fontSize: 14.sp,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool filtered;
  const _EmptyState({required this.filtered});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(filtered ? Icons.filter_list_off_rounded : Icons.receipt_long_outlined,
          size: 40.sp, color: AppColors.textTertiary),
      SizedBox(height: 12.h),
      Text(filtered ? 'No expenses in this category'
          : 'No expenses yet',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
      SizedBox(height: 4.h),
      Text(filtered ? 'Try a different filter' : 'Tap + to add your first expense',
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary)),
    ]));
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
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.3), width: 0.5.w),
      ),
      child: Row(children: [
        Icon(Icons.cloud_off_outlined, size: 13.sp, color: AppColors.danger),
        SizedBox(width: 8.w),
        Expanded(child: Text(message,
            style: TextStyle(fontSize: 11.sp, color: AppColors.danger))),
      ]),
    );
  }
}
