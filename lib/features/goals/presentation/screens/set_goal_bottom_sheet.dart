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
  final _contributionController = TextEditingController();
  final _targetFundController = TextEditingController();

  String? _targetFor;
  String? _currency;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = false;

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
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
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
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
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
    );

    return result ?? false;
  }

  // ============================
  // SUBMIT
  // ============================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 1️⃣ Show confirmation
    final confirm = await showDialog<bool>(
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
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
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
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      // 2️⃣ Create goal
      await ref
          .read(goalsNotifierProvider.notifier)
          .createGoal(
            name: _nameController.text.trim(),
            targetFor: _targetFor!,
            contribution: double.parse(_contributionController.text.trim()),
            targetAmount: double.parse(_targetFundController.text.trim()),
            currency: _currency!,
            startDate: _startDate,
            endDate: _endDate,
          );

      if (!mounted) return;

      // 3️⃣ Close bottom sheet FIRST
      Navigator.of(context).pop();

      // 4️⃣ Show success dialog on root navigator
      await showDialog(
        context: Navigator.of(context, rootNavigator: true).context,
        barrierDismissible: false,
        builder: (successContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Success Goals Created",
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () => Navigator.of(successContext).pop(),
                    child: const Text(
                      "Back to Goals",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
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

                  DropdownButtonFormField<String>(
                    initialValue: _targetFor,
                    decoration: const InputDecoration(labelText: "Target For"),
                    items: const [
                      DropdownMenuItem(
                        value: "Married",
                        child: Text("Married"),
                      ),
                      DropdownMenuItem(value: "House", child: Text("House")),
                      DropdownMenuItem(
                        value: "Vacation",
                        child: Text("Vacation"),
                      ),
                    ],
                    onChanged: (val) => setState(() => _targetFor = val),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    controller: _contributionController,
                    label: "Contribution",
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppInputField(
                    controller: _targetFundController,
                    label: "Target Fund",
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(labelText: "Currency"),
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
