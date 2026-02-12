import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/budget.dart';

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, List<Budget>>(
  (ref) => BudgetNotifier(),
);

class BudgetNotifier extends StateNotifier<List<Budget>> {
  BudgetNotifier() : super(const []);

  final _uuid = const Uuid();

  void addBudget({
    required String name,
    required double amount,
    required String category,
    required String wallet,
    required String recurrence,
    required DateTime startDate,
  }) {
    final newBudget = Budget(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      category: category,
      wallet: wallet,
      recurrence: recurrence,
      startDate: startDate,
    );

    state = [...state, newBudget];
  }

  void removeBudget(String id) {
    state = state.where((b) => b.id != id).toList();
  }
}
