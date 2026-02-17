import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/global_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../domain/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedWalletId;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final transaction = Transaction(
      id: '',
      userId: userId,
      walletId: _selectedWalletId,
      categoryId: null,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      type: _type,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await ref
        .read(transactionProvider.notifier)
        .addTransaction(transaction);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Add Transaction',
          style: AppTextStyles.headingMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Transaction Type
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Income'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _type = value!);
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              /// Wallet Dropdown
              walletsAsync.when(
                loading: () =>
                    const CircularProgressIndicator(),
                error: (e, _) => Text(e.toString()),
                data: (wallets) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedWalletId,
                    items: wallets
                        .map(
                          (wallet) => DropdownMenuItem(
                            value: wallet.id,
                            child: Text(wallet.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedWalletId = value);
                    },
                    validator: (value) =>
                        value == null ? 'Select wallet' : null,
                    decoration: const InputDecoration(
                      labelText: 'Wallet',
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              /// Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Amount'),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter amount'
                        : null,
              ),

              const SizedBox(height: AppSpacing.lg),

              /// Description
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description'),
              ),

              const SizedBox(height: AppSpacing.xl),

              /// Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize:
                        const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    'Save',
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
    );
  }
}
