import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense_categories.dart';
import 'package:app/features/expense_tracker/expense_tracker/presentation/controllers/expense_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpenseEditScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  const ExpenseEditScreen({super.key, this.expense});

  @override
  ConsumerState<ExpenseEditScreen> createState() => _ExpenseEditScreenState();
}

class _ExpenseEditScreenState extends ConsumerState<ExpenseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _descriptionCtrl;

  late String _selectedCategory;
  bool _isSaving = false;
  String? _formError;
  bool _categoryError = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleCtrl       = TextEditingController(text: e?.title ?? '');
    _amountCtrl      = TextEditingController(text: e?.amount ?? '');
    _dateCtrl        = TextEditingController(text: e?.date ?? '');
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
    // Resolve through categoryFor — handles legacy free-text values
    // (e.g. 'Study', 'Food') that don't exist in kExpenseCategories by
    // falling back to 'other'. Without this, the dropdown crashes if the
    // stored string isn't a valid item value.
    _selectedCategory = (e?.category.isNotEmpty == true)
        ? categoryFor(e!.category).value
        : kExpenseCategories.first.value;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    if (!formOk) return;

    setState(() { _isSaving = true; _formError = null; });

    final expense = Expense(
      id:          widget.expense?.id,
      title:       _titleCtrl.text.trim(),
      amount:      _amountCtrl.text.trim(),
      category:    _selectedCategory,
      date:        _dateCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
    );

    final controller = ref.read(expenseListControllerProvider.notifier);
    final success = _isEdit
        ? await controller.updateExpense(expense)
        : await controller.addExpense(expense);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _formError = 'Failed to save expense. Please try again.');
    }
  }

  Future<void> _delete() async {
    if (widget.expense?.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: const Text('Delete expense?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    final success = await ref
        .read(expenseListControllerProvider.notifier)
        .deleteExpense(widget.expense!.id!);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _formError = 'Failed to delete expense.');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateCtrl.text) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.bgElevated,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, size: 18.sp),
          color: AppColors.textPrimary,
        ),
        title: Text(
          _isEdit ? 'Edit expense' : 'New expense',
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _isSaving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.danger,
            ),
        ],
      ),
      body: OrbBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _titleCtrl,
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.title_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) => AppValidators.required(v, 'Title'),
                  ),
                  SizedBox(height: 18.h),
                  AppTextField(
                    controller: _amountCtrl,
                    labelText: 'Amount (Rs.)',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (v) => AppValidators.amount(v),
                  ),
                  SizedBox(height: 18.h),

                  // ── Category dropdown ────────────────────────────────────
                  _CategoryDropdown(
                    selected: _selectedCategory,
                    onChanged: (v) => setState(() {
                      _selectedCategory = v;
                      _categoryError = false;
                    }),
                    hasError: _categoryError,
                  ),
                  SizedBox(height: 18.h),

                  // ── Date field with picker ───────────────────────────────
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: _dateCtrl,
                        labelText: 'Date',
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        textInputAction: TextInputAction.next,
                        validator: (v) => AppValidators.dateYmd(v),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  AppTextField(
                    controller: _descriptionCtrl,
                    labelText: 'Description (optional)',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    textInputAction: TextInputAction.done,
                  ),

                  if (_formError != null) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.3),
                            width: 0.5.w),
                      ),
                      child: Row(children: [
                        Icon(Icons.error_outline_rounded,
                            size: 14.sp, color: AppColors.danger),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(_formError!,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.danger)),
                        ),
                      ]),
                    ),
                  ],
                  SizedBox(height: 32.h),
                  AppButton(
                    label: _isEdit ? 'Update' : 'Add expense',
                    loading: _isSaving,
                    onPressed: _isSaving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Category dropdown widget ─────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final bool hasError;

  const _CategoryDropdown({
    required this.selected,
    required this.onChanged,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final cat = categoryFor(selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError
                  ? AppColors.danger
                  : AppColors.border,
              width: hasError ? 1.2.w : 0.8.w,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              dropdownColor: AppColors.bgElevated,
              icon: Icon(Icons.expand_more_rounded,
                  size: 20.sp, color: AppColors.textSecondary),
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope'),
              selectedItemBuilder: (_) => kExpenseCategories
                  .map((c) => Row(children: [
                        Container(
                          width: 28.w, height: 28.h,
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Icon(cat.icon, size: 14.sp, color: cat.color),
                        ),
                        SizedBox(width: 10.w),
                        Text(c.label),
                      ]))
                  .toList(),
              items: kExpenseCategories
                  .map((c) => DropdownMenuItem(
                        value: c.value,
                        child: Row(children: [
                          Container(
                            width: 28.w, height: 28.h,
                            decoration: BoxDecoration(
                              color: c.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: Icon(c.icon, size: 14.sp, color: c.color),
                          ),
                          SizedBox(width: 10.w),
                          Text(c.label,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5.sp)),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ],
    );
  }
}