import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../home/presentation/providers/wallet_provider.dart';
import '../../domain/models/goal.dart';
import '../providers/goals_notifier.dart';

class AddContributionBottomSheet extends ConsumerStatefulWidget {
  final Goal goal;

  const AddContributionBottomSheet({super.key, required this.goal});

  @override
  ConsumerState<AddContributionBottomSheet> createState() =>
      _AddContributionBottomSheetState();
}

class _AddContributionBottomSheetState
    extends ConsumerState<AddContributionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedWalletId;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWalletId == null) return;

    if (_loading) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(goalsNotifierProvider.notifier)
          .addContribution(
            goalId: widget.goal.id,
            walletId: _selectedWalletId!,
            amount: double.parse(_amountController.text.trim()),
          );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: walletsAsync.when(
        data: (wallets) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Contribution", style: AppTextStyles.headingMedium),

                const SizedBox(height: AppSpacing.lg),

                DropdownButtonFormField<String>(
                  initialValue: _selectedWalletId,
                  decoration: const InputDecoration(labelText: "Select Wallet"),
                  items: wallets
                      .map(
                        (w) => DropdownMenuItem(
                          value: w.id,
                          child: Text(
                            "${w.name} (₹${w.balance.toStringAsFixed(0)})",
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedWalletId = val),
                  validator: (value) => value == null ? "Select wallet" : null,
                ),

                const SizedBox(height: AppSpacing.lg),

                AppInputField(
                  controller: _amountController,
                  label: "Amount",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter amount";
                    }
                    if (double.tryParse(value) == null) {
                      return "Invalid amount";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                PrimaryButton(
                  label: _loading ? "Processing..." : "Confirm",
                  onPressed: _loading ? null : _submit,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Failed to load wallets")),
      ),
    );
  }
}
