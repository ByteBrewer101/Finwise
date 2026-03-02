import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../home/presentation/providers/wallet_provider.dart';
import '../../domain/models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/budget_transactions_provider.dart';

class SetBudgetScreen extends ConsumerStatefulWidget {
  final Budget? initialBudget;

  const SetBudgetScreen({super.key, this.initialBudget});

  @override
  ConsumerState<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _budgetNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _startDateController = TextEditingController();

  String? _walletId;
  String? _categoryId;
  String? _recurrence;
  final String _currency = 'INR';
  DateTime? _selectedDate;
  bool _submitting = false;
  double _currentSpent = 0;

  bool get _isEditMode => widget.initialBudget != null;
  double? get _parsedAmount => double.tryParse(_amountController.text.trim());
  bool get _isAmountBelowSpent {
    if (!_isEditMode) return false;
    final parsed = _parsedAmount;
    if (parsed == null) return false;
    return parsed < _currentSpent;
  }

  @override
  void initState() {
    super.initState();
    final budget = widget.initialBudget;
    if (budget != null) {
      _budgetNameController.text = budget.name;
      _amountController.text = budget.amount.toStringAsFixed(0);
      _walletId = budget.walletId;
      _categoryId = budget.categoryId;
      _recurrence = budget.recurrence;
      _selectedDate = budget.startDate;
      _startDateController.text = DateFormat('dd MMM yyyy').format(budget.startDate);
    }
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _budgetNameController.dispose();
    _amountController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveBudget() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null ||
        _recurrence == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final repo = ref.read(budgetRepositoryProvider);
      final parsedAmount = double.tryParse(_amountController.text.trim());
      if (parsedAmount == null || parsedAmount <= 0) {
        throw Exception('Enter a valid amount');
      }
      if (_isEditMode && parsedAmount < _currentSpent) {
        throw Exception('New target cannot be less than already invested amount.');
      }

      final budget = Budget(
        id: widget.initialBudget?.id ?? '',
        name: _budgetNameController.text.trim(),
        amount: parsedAmount,
        categoryId: _categoryId,
        walletId: _walletId!,
        recurrence: _recurrence!,
        startDate: _selectedDate!,
        currency: _currency,
      );

      if (_isEditMode) {
        await repo.updateBudget(budget);
      } else {
        await repo.addBudget(budget);
      }
      ref.invalidate(budgetListProvider);
      if (_isEditMode && widget.initialBudget != null) {
        ref.invalidate(budgetTransactionsProvider(widget.initialBudget!.id));
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditMode ? 'Budget updated' : 'Budget created')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletProvider);
    final budgetsAsync = ref.watch(budgetListProvider);

    if (_isEditMode) {
      final budgetId = widget.initialBudget!.id;
      _currentSpent = budgetsAsync.maybeWhen(
        data: (budgets) {
          for (final budget in budgets) {
            if (budget.id == budgetId) return budget.spent;
          }
          return widget.initialBudget!.spent;
        },
        orElse: () => widget.initialBudget!.spent,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Budget' : 'Set New Budget', style: AppTextStyles.headingLarge),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _BudgetTextField(
                controller: _budgetNameController,
                hint: 'Budget Name',
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter budget name' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              _BudgetTextField(
                controller: _amountController,
                hint: 'Amount',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amountError = AppValidators.validatePositiveAmountInput(
                    value,
                    emptyMessage: 'Enter amount',
                  );
                  if (amountError != null) return amountError;
                  if (_isEditMode) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed != null && parsed < _currentSpent) {
                      return 'New target cannot be less than already invested amount.';
                    }
                  }
                  return null;
                },
              ),
              if (_isEditMode && _isAmountBelowSpent)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'New target cannot be less than already invested amount.',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              walletsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString(), style: AppTextStyles.body),
                data: (wallets) {
                  return _BudgetDropdown(
                    value: _walletId,
                    hint: 'Wallet',
                    items: wallets
                        .map(
                          (w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _walletId = val),
                    validator: (value) => value == null ? 'Select wallet' : null,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _BudgetDropdown(
                value: _recurrence,
                hint: 'Recurrence',
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (val) => setState(() => _recurrence = val),
                validator: (value) => value == null ? 'Select recurrence' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                onTap: _pickDate,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Select start date' : null,
                decoration: _fieldDecoration(
                  hint: 'Start Date',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: (_isAmountBelowSpent || _submitting) ? null : _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _BudgetTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _fieldDecoration(hint: hint),
    );
  }
}

class _BudgetDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _BudgetDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final safeInitialValue =
        items.any((item) => item.value == value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: safeInitialValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: _fieldDecoration(hint: hint),
    );
  }
}

InputDecoration _fieldDecoration({
  required String hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}
