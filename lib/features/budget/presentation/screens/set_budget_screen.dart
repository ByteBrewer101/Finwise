import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../home/presentation/providers/wallet_provider.dart';
import '../../../home/presentation/providers/category_provider.dart';

import '../../domain/models/budget.dart';
import '../providers/budget_provider.dart';

class SetBudgetScreen extends ConsumerStatefulWidget {
  const SetBudgetScreen({super.key});

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _createBudget() async {
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null ||
        _categoryId == null ||
        _recurrence == null ||
        _selectedDate == null) {
      return;
    }

    final repo = ref.read(budgetRepositoryProvider);

    final budget = Budget(
      id: '',
      name: _budgetNameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      categoryId: _categoryId!,
      walletId: _walletId!,
      recurrence: _recurrence!,
      startDate: _selectedDate!,
      currency: _currency,
    );

    await repo.addBudget(budget);

    ref.invalidate(budgetListProvider);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Set New Budget', style: AppTextStyles.headingMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _budgetNameController,
                  label: 'Budget Name',
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildTextField(
                  controller: _amountController,
                  label: 'Amount',
                  keyboardType: TextInputType.number,
                  prefix: '₹ ',
                ),
                const SizedBox(height: AppSpacing.lg),

                walletsAsync.when(
                  data: (wallets) {
                    return _buildDropdown(
                      label: 'Wallet',
                      value: _walletId,
                      items: wallets
                          .map(
                            (w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(w.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _walletId = val),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading wallets'),
                ),
                const SizedBox(height: AppSpacing.lg),

                categoriesAsync.when(
                  data: (categories) {
                    return _buildDropdown(
                      label: 'Budget For',
                      value: _categoryId,
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _categoryId = val),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading categories'),
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildDropdown(
                  label: 'Recurrence',
                  value: _recurrence,
                  items: const [
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  onChanged: (val) => setState(() => _recurrence = val),
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: _inputDecoration(
                    'Start Date',
                  ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Select start date'
                      : null,
                  onTap: _pickDate,
                ),
                const SizedBox(height: AppSpacing.xl),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: const Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label).copyWith(prefixText: prefix),
      validator: (value) =>
          value == null || value.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _inputDecoration(label),
      items: items,
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select $label' : null,
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: AppTextStyles.body,
    filled: true,
    fillColor: AppColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}
