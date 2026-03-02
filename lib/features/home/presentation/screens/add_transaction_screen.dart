import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/global_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../budget/domain/models/budget.dart';
import '../../domain/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? preselectedBudgetId;

  const AddTransactionScreen({super.key, this.preselectedBudgetId});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedWalletId;
  String? _selectedBudgetId;

  @override
  void initState() {
    super.initState();

    _selectedBudgetId = widget.preselectedBudgetId;

    if (_selectedBudgetId != null) {
      final budgets = ref.read(budgetListProvider).value ?? [];

      try {
        final selectedBudget = budgets.firstWhere(
          (b) => b.id == _selectedBudgetId,
        );

        _selectedWalletId = selectedBudget.walletId;
      } catch (_) {
        // Budget may not be loaded yet.
      }
    }
  }

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
    final wallets = ref.read(walletProvider).valueOrNull ?? const [];
    if (wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No wallets available. Please create a wallet first.')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    String? categoryId;

    if (_type == TransactionType.expense && _selectedBudgetId != null) {
      final budgets = ref.read(budgetListProvider).value ?? [];
      Budget? selectedBudget;
      for (final b in budgets) {
        if (b.id == _selectedBudgetId) {
          selectedBudget = b;
          break;
        }
      }
      if (selectedBudget == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected budget not found')),
        );
        return;
      }

      if (amount > selectedBudget.remaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount exceeds remaining budget (\u20B9 ${selectedBudget.remaining.toStringAsFixed(2)})',
            ),
          ),
        );
        return;
      }

      final selectedWallet = wallets.firstWhere(
        (w) => w.id == (_selectedWalletId ?? ''),
        orElse: () => wallets.first,
      );
      final balanceError = AppValidators.validateAmountWithinLimit(
        amount: amount,
        limit: selectedWallet.balance,
        message: 'Insufficient wallet balance',
      );
      if (balanceError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(balanceError)),
        );
        return;
      }

      categoryId = selectedBudget.categoryId;
    }

    final transaction = Transaction(
      id: '',
      userId: userId,
      walletId: _selectedWalletId,
      categoryId: categoryId,
      budgetId: _selectedBudgetId,
      amount: amount,
      description: _descriptionController.text.trim(),
      type: _type,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await ref.read(transactionProvider.notifier).addTransaction(transaction);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletProvider);
    final budgetsAsync = ref.watch(budgetListProvider);
    final hasWallets = walletsAsync.maybeWhen(
      data: (wallets) => wallets.isNotEmpty,
      orElse: () => false,
    );
    final walletsLoading = walletsAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction', style: AppTextStyles.headingMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                  setState(() {
                    _type = value!;
                    if (_type != TransactionType.expense) {
                      _selectedBudgetId = null;
                    }
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              walletsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
                data: (wallets) {
                  if (wallets.isEmpty) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No wallets available. Please create a wallet first.',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    );
                  }

                  final selectedWallet = wallets.firstWhere(
                    (w) => w.id == _selectedWalletId,
                    orElse: () => wallets.first,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedWalletId,
                        items: wallets
                            .map(
                              (wallet) => DropdownMenuItem(
                                value: wallet.id,
                                child: Text(wallet.name),
                              ),
                            )
                            .toList(),
                        onChanged: (_selectedBudgetId != null)
                            ? null
                            : (value) {
                                setState(() => _selectedWalletId = value);
                              },
                        validator: (value) => value == null ? 'Select wallet' : null,
                        decoration: const InputDecoration(labelText: 'Wallet'),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedWalletId != null)
                        Text(
                          'Available Balance: ${CurrencyFormatter.format(amount: selectedWallet.balance, currency: selectedWallet.currency)}',
                          style: AppTextStyles.bodyMuted,
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_type == TransactionType.expense)
                budgetsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(e.toString()),
                  data: (budgets) {
                    if (budgets.isEmpty) return const SizedBox();

                    Budget? selectedBudget;
                    if (_selectedBudgetId != null) {
                      for (final b in budgets) {
                        if (b.id == _selectedBudgetId) {
                          selectedBudget = b;
                          break;
                        }
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String?>(
                          value: _selectedBudgetId,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('No Budget'),
                            ),
                            ...budgets.map(
                              (budget) => DropdownMenuItem<String?>(
                                value: budget.id,
                                child: Text(budget.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedBudgetId = value;

                              if (value != null) {
                                final b = budgets.firstWhere((budget) => budget.id == value);
                                _selectedWalletId = b.walletId;
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Select Budget (Optional)',
                          ),
                        ),
                        if (selectedBudget != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Remaining Budget: ${CurrencyFormatter.format(amount: selectedBudget.remaining, currency: selectedBudget.currency)}',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    );
                  },
                ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  final amountError = AppValidators.validatePositiveAmountInput(value);
                  if (amountError != null) return amountError;
                  final parsed = double.tryParse((value ?? '').trim())!;

                  if (_type != TransactionType.income && _selectedWalletId != null) {
                    final wallets = walletsAsync.valueOrNull ?? const [];
                    for (final wallet in wallets) {
                      if (wallet.id == _selectedWalletId) {
                        final walletErr = AppValidators.validateAmountWithinLimit(
                          amount: parsed,
                          limit: wallet.balance,
                          message: 'Insufficient wallet balance',
                        );
                        if (walletErr != null) return walletErr;
                        break;
                      }
                    }
                  }

                  if (_type == TransactionType.expense && _selectedBudgetId != null) {
                    final budgets = budgetsAsync.valueOrNull ?? const <Budget>[];
                    for (final b in budgets) {
                      if (b.id == _selectedBudgetId) {
                        final budgetErr = AppValidators.validateAmountWithinLimit(
                          amount: parsed,
                          limit: b.remaining,
                          message: 'Amount exceeds remaining budget',
                        );
                        if (budgetErr != null) return budgetErr;
                        break;
                      }
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  final requiresDescription =
                      _type == TransactionType.expense && _selectedBudgetId != null;
                  if (requiresDescription &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Description is required for budget transactions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: walletsLoading || !hasWallets ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
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
