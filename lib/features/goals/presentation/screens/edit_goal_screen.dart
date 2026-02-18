import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/models/goal.dart';
import '../providers/goals_notifier.dart';

class EditGoalScreen extends ConsumerStatefulWidget {
  final Goal goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  ConsumerState<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends ConsumerState<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _targetController;

  String? _targetFor;
  String? _currency;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.goal.name);

    _targetController = TextEditingController(
      text: widget.goal.targetAmount.toString(),
    );

    _targetFor = widget.goal.targetFor;
    _currency = widget.goal.currency;
    _startDate = widget.goal.startDate;
    _endDate = widget.goal.endDate;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_targetFor == null || _currency == null) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(goalsNotifierProvider.notifier)
          .updateGoal(
            goalId: widget.goal.id,
            name: _nameController.text.trim(),
            targetFor: _targetFor!,
            targetAmount: double.parse(_targetController.text.trim()),
            currency: _currency!,
            startDate: _startDate,
            endDate: _endDate,
          );

      if (mounted) Navigator.pop(context);
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Goal"),
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
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter goal name" : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              AppInputField(
                controller: _targetController,
                label: "Target Amount",
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter amount";
                  if (double.tryParse(v) == null) return "Invalid number";
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              DropdownButtonFormField<String>(
                initialValue: _targetFor,
                decoration: const InputDecoration(labelText: "Target For"),
                items: const [
                  DropdownMenuItem(value: "Married", child: Text("Married")),
                  DropdownMenuItem(value: "House", child: Text("House")),
                  DropdownMenuItem(value: "Vacation", child: Text("Vacation")),
                ],
                onChanged: (val) => setState(() => _targetFor = val),
                validator: (v) => v == null ? "Select target category" : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(labelText: "Currency"),
                items: const [
                  DropdownMenuItem(value: "INR", child: Text("INR")),
                  DropdownMenuItem(value: "USD", child: Text("USD")),
                  DropdownMenuItem(value: "IDR", child: Text("IDR")),
                ],
                onChanged: (val) => setState(() => _currency = val),
                validator: (v) => v == null ? "Select currency" : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              ListTile(
                title: Text(
                  _startDate == null
                      ? "Start Date"
                      : _startDate.toString().split(" ").first,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(true),
              ),

              ListTile(
                title: Text(
                  _endDate == null
                      ? "End Date"
                      : _endDate.toString().split(" ").first,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(false),
              ),

              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: _loading ? "Updating..." : "Update Goal",
                onPressed: _loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
