import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/goals_notifier.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _contributionController = TextEditingController();

  bool _loading = false;

  final String _targetFor = "General";
  
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(goalsNotifierProvider.notifier)
          .createGoal(
            name: _nameController.text.trim(),
            targetFor: _targetFor,
            targetAmount: double.parse(_targetController.text.trim()),
            contribution: double.parse(_contributionController.text.trim()),
            currency: "INR",
            startDate: _startDate,
            endDate: _endDate,
          );

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to create goal")));
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Add Goal"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppInputField(
                controller: _nameController,
                label: "Goal Name",
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter goal name" : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              AppInputField(
                controller: _targetController,
                label: "Target Fund",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter target amount";
                  }
                  if (double.tryParse(value) == null) {
                    return "Invalid number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              AppInputField(
                controller: _contributionController,
                label: "Contribution",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter contribution amount";
                  }
                  if (double.tryParse(value) == null) {
                    return "Invalid number";
                  }
                  return null;
                },
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
  }
}
