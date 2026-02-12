import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:finwise/core/theme/app_spacing.dart';
import 'package:finwise/core/theme/app_radius.dart';
import 'package:finwise/core/theme/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

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

  String? _currency;
  String? _wallet;
  String? _category;
  String? _recurrence;

  DateTime? _selectedDate;

  @override
  void dispose() {
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

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  void _createBudget() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(budgetProvider.notifier)
        .addBudget(
          name: _budgetNameController.text,
          amount: double.parse(_amountController.text),
          category: _category!,
          wallet: _wallet!,
          recurrence: _recurrence!,
          startDate: _selectedDate!,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Budget', style: AppTextStyles.headingMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
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
                _buildDropdown(
                  label: 'Currency',
                  value: _currency,
                  items: const ['INR'],
                  onChanged: (val) => setState(() => _currency = val),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildDropdown(
                  label: 'Wallet',
                  value: _wallet,
                  items: const ['Cash', 'Cashless'],
                  onChanged: (val) => setState(() => _wallet = val),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildDropdown(
                  label: 'Category',
                  value: _category,
                  items: const ['Food', 'Pets', 'Fashion'],
                  onChanged: (val) => setState(() => _category = val),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildDropdown(
                  label: 'Recurrence',
                  value: _recurrence,
                  items: const ['Monthly', 'Weekly'],
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
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
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
