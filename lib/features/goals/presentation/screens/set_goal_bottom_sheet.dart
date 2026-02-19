import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/goals_notifier.dart';

class SetGoalBottomSheet extends ConsumerStatefulWidget {
  const SetGoalBottomSheet({super.key});

  @override
  ConsumerState<SetGoalBottomSheet> createState() => _SetGoalBottomSheetState();
}

class _SetGoalBottomSheetState extends ConsumerState<SetGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _targetForController = TextEditingController();
  final _contributionController = TextEditingController();
  final _targetFundController = TextEditingController();

  String? _currency;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = false;

  // ============================
  // CLEANUP (Production Safe)
  // ============================

  @override
  void dispose() {
    _nameController.dispose();
    _targetForController.dispose();
    _contributionController.dispose();
    _targetFundController.dispose();
    super.dispose();
  }

  // ============================
  // DATE PICKER
  // ============================

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // ============================
  // CONFIRMATION MODAL
  // ============================

  Future<bool> _showConfirmation() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Confirmation", style: AppTextStyles.headingMedium),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Are you sure you want to make these goals?",
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text(
                              "No",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text(
                              "Yes",
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  // ============================
  // SUBMIT
  // ============================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currency == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date must be after start date")),
      );
      return;
    }

    final confirm = await _showConfirmation();
    if (!confirm) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(goalsNotifierProvider.notifier)
          .createGoal(
            name: _nameController.text.trim(),
            targetFor: _targetForController.text.trim(),
            targetAmount: double.parse(_targetFundController.text.trim()),
            contribution: double.parse(_contributionController.text.trim()),
            currency: _currency!,
            startDate: _startDate,
            endDate: _endDate,
          );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goal created successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ============================
  // UI
  // ============================

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: controller,
                children: [
                  Text("Set New Goals", style: AppTextStyles.headingLarge),

                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    controller: _nameController,
                    label: "Goals Name",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter goal name" : null,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    controller: _targetForController,
                    label: "Target For",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter target purpose" : null,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    controller: _contributionController,
                    label: "Contribution",
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Enter contribution";
                      }
                      final value = double.tryParse(v);
                      if (value == null || value <= 0) {
                        return "Enter valid amount";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    controller: _targetFundController,
                    label: "Target Fund",
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Enter target amount";
                      }
                      final value = double.tryParse(v);
                      if (value == null || value <= 0) {
                        return "Enter valid amount";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: InputDecoration(
                      labelText: "Currency",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "INR", child: Text("INR")),
                      DropdownMenuItem(value: "IDR", child: Text("IDR")),
                      DropdownMenuItem(value: "USD", child: Text("USD")),
                    ],
                    onChanged: (val) => setState(() => _currency = val),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  ListTile(
                    title: Text(
                      _startDate == null
                          ? "Start Date"
                          : _startDate!.toLocal().toString().split(" ")[0],
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(true),
                  ),

                  ListTile(
                    title: Text(
                      _endDate == null
                          ? "End Date"
                          : _endDate!.toLocal().toString().split(" ")[0],
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(false),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  PrimaryButton(
                    label: _loading ? "Creating..." : "Create",
                    onPressed: _loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
