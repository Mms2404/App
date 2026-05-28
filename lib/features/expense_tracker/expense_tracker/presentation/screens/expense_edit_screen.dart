import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/expense_tracker/expense_tracker/domain/entities/expense.dart';
import 'package:app/features/expense_tracker/expense_tracker/presentation/controllers/expense_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _descriptionCtrl;

  bool _isSaving = false;
  String? _formError;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _amountCtrl = TextEditingController(text: e?.amount ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _dateCtrl = TextEditingController(text: e?.date ?? '');
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    final expense = Expense(
      id: widget.expense?.id,
      title: _titleCtrl.text.trim(),
      amount: _amountCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      date: _dateCtrl.text.trim(),
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
        title: const Text(
          'Delete expense?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isSaving = true);
    final controller = ref.read(expenseListControllerProvider.notifier);
    final success = await controller.deleteExpense(widget.expense!.id!);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _formError = 'Failed to delete expense.');
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
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          color: AppColors.textPrimary,
        ),
        title: Text(
          _isEdit ? 'Edit expense' : 'New expense',
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _amountCtrl,
                    labelText: 'Amount (Rs.)',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (v) => AppValidators.amount(v),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _categoryCtrl,
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) => AppValidators.required(v, 'Category'),  
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _dateCtrl,
                    labelText: 'Date (YYYY-MM-DD)',
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) => AppValidators.dateYmd(v),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _descriptionCtrl,
                    labelText: 'Description (optional)',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    textInputAction: TextInputAction.done,
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 14, color: AppColors.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formError!,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
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