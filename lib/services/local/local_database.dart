import 'dart:math' as math;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  static const _uuid = Uuid();

  static const profilesBoxName = 'profiles_box';
  static const walletsBoxName = 'wallets_box';
  static const categoriesBoxName = 'categories_box';
  static const transactionsBoxName = 'transactions_box';
  static const budgetsBoxName = 'budgets_box';
  static const goalsBoxName = 'goals_box';
  static const goalContributionsBoxName = 'goal_contributions_box';
  static const syncQueueBoxName = 'sync_queue_box';
  static const syncMetaBoxName = 'sync_meta_box';

  late final Box<dynamic> _profilesBox;
  late final Box<dynamic> _walletsBox;
  late final Box<dynamic> _categoriesBox;
  late final Box<dynamic> _transactionsBox;
  late final Box<dynamic> _budgetsBox;
  late final Box<dynamic> _goalsBox;
  late final Box<dynamic> _goalContributionsBox;
  late final Box<dynamic> _syncQueueBox;
  late final Box<dynamic> _syncMetaBox;

  Future<void> initialize() async {
    _profilesBox = await Hive.openBox<dynamic>(profilesBoxName);
    _walletsBox = await Hive.openBox<dynamic>(walletsBoxName);
    _categoriesBox = await Hive.openBox<dynamic>(categoriesBoxName);
    _transactionsBox = await Hive.openBox<dynamic>(transactionsBoxName);
    _budgetsBox = await Hive.openBox<dynamic>(budgetsBoxName);
    _goalsBox = await Hive.openBox<dynamic>(goalsBoxName);
    _goalContributionsBox = await Hive.openBox<dynamic>(goalContributionsBoxName);
    _syncQueueBox = await Hive.openBox<dynamic>(syncQueueBoxName);
    _syncMetaBox = await Hive.openBox<dynamic>(syncMetaBoxName);
  }

  String? getLastSyncAt(String userId) {
    return _syncMetaBox.get('last_sync_$userId') as String?;
  }

  Future<void> setLastSyncAt(String userId, String timestampIso) async {
    await _syncMetaBox.put('last_sync_$userId', timestampIso);
  }

  Future<void> clearLastSyncAt(String userId) async {
    await _syncMetaBox.delete('last_sync_$userId');
  }

  bool hasAnyDataForUser(String userId) {
    bool hasData(Box<dynamic> box) => box.values.any((raw) {
          final row = _asMap(raw);
          return (row['user_id'] ?? row['id']) == userId;
        });

    return hasData(_profilesBox) ||
        hasData(_walletsBox) ||
        hasData(_categoriesBox) ||
        hasData(_transactionsBox) ||
        hasData(_budgetsBox) ||
        hasData(_goalsBox) ||
        hasData(_goalContributionsBox);
  }

  Map<String, dynamic>? getProfile(String userId) {
    final raw = _profilesBox.get(userId);
    if (raw == null) return null;
    return _asMap(raw);
  }

  void putProfile(Map<String, dynamic> profile) {
    _profilesBox.put(profile['id'] as String, _normalizeMap(profile));
  }

  List<Map<String, dynamic>> getWallets(String userId) {
    final rows = _getRowsForUser(_walletsBox, userId);
    rows.sort((a, b) => _compareAsc(
          _parseDate(a['created_at']),
          _parseDate(b['created_at']),
          a['id'],
          b['id'],
        ));
    return rows;
  }

  Map<String, dynamic>? getWalletById(String walletId) {
    final raw = _walletsBox.get(walletId);
    if (raw == null) return null;
    return _asMap(raw);
  }

  void putWallet(Map<String, dynamic> wallet) {
    _walletsBox.put(wallet['id'] as String, _normalizeMap(wallet));
  }

  void deleteWallet(String walletId) {
    _walletsBox.delete(walletId);
  }

  List<Map<String, dynamic>> getCategories(String userId) {
    final rows = _categoriesBox.values
        .map(_asMap)
        .where((row) => row['user_id'] == userId)
        .toList(growable: false);
    rows.sort((a, b) => _compareAsc(
          _parseDate(a['created_at']),
          _parseDate(b['created_at']),
          a['id'],
          b['id'],
        ));
    return rows;
  }

  void putCategory(Map<String, dynamic> category) {
    _categoriesBox.put(category['id'] as String, _normalizeMap(category));
  }

  List<Map<String, dynamic>> getTransactions(String userId) {
    final rows = _getRowsForUser(_transactionsBox, userId);
    rows.sort((a, b) => _compareDesc(
          _parseDate(a['transaction_date']),
          _parseDate(b['transaction_date']),
          _parseDate(a['created_at']),
          _parseDate(b['created_at']),
        ));
    return rows;
  }

  Map<String, dynamic>? getTransactionById(String transactionId) {
    final raw = _transactionsBox.get(transactionId);
    if (raw == null) return null;
    return _asMap(raw);
  }

  void putTransaction(Map<String, dynamic> transaction) {
    _transactionsBox.put(transaction['id'] as String, _normalizeMap(transaction));
  }

  void deleteTransaction(String transactionId) {
    _transactionsBox.delete(transactionId);
  }

  List<Map<String, dynamic>> getTransactionsForBudget({
    required String userId,
    required String budgetId,
  }) {
    final rows = getTransactions(userId)
        .where((tx) => tx['budget_id'] == budgetId)
        .toList(growable: false);
    return rows;
  }

  List<Map<String, dynamic>> getBudgets(String userId) {
    final rows = _getRowsForUser(_budgetsBox, userId);
    rows.sort((a, b) => _compareDesc(
          _parseDate(a['created_at']),
          _parseDate(b['created_at']),
          a['id'],
          b['id'],
        ));
    return rows;
  }

  Map<String, dynamic>? getBudgetById(String budgetId) {
    final raw = _budgetsBox.get(budgetId);
    if (raw == null) return null;
    return _asMap(raw);
  }

  void putBudget(Map<String, dynamic> budget) {
    _budgetsBox.put(budget['id'] as String, _normalizeMap(budget));
  }

  List<Map<String, dynamic>> getGoals(String userId) {
    final rows = _getRowsForUser(_goalsBox, userId);
    rows.sort((a, b) => _compareDesc(
          _parseDate(a['created_at']),
          _parseDate(b['created_at']),
          a['id'],
          b['id'],
        ));
    return rows;
  }

  Map<String, dynamic>? getGoalById(String goalId) {
    final raw = _goalsBox.get(goalId);
    if (raw == null) return null;
    return _asMap(raw);
  }

  void putGoal(Map<String, dynamic> goal) {
    _goalsBox.put(goal['id'] as String, _normalizeMap(goal));
  }

  void deleteGoal(String goalId) {
    _goalsBox.delete(goalId);
  }

  List<Map<String, dynamic>> getGoalContributions({
    required String userId,
    required String goalId,
  }) {
    final rows = _getRowsForUser(_goalContributionsBox, userId)
        .where((row) => row['goal_id'] == goalId)
        .toList();
    rows.sort((a, b) => _compareDesc(
          _parseDate(a['contributed_at']),
          _parseDate(b['contributed_at']),
          _parseDate(a['created_at']),
          _parseDate(b['created_at']),
        ));
    return rows;
  }

  List<Map<String, dynamic>> getGoalContributionsByGoal(String goalId) {
    return _goalContributionsBox.values
        .map(_asMap)
        .where((row) => row['goal_id'] == goalId)
        .toList();
  }

  void putGoalContribution(Map<String, dynamic> contribution) {
    _goalContributionsBox.put(
      contribution['id'] as String,
      _normalizeMap(contribution),
    );
  }

  void deleteGoalContribution(String contributionId) {
    _goalContributionsBox.delete(contributionId);
  }

  void deleteGoalContributionsByGoal(String goalId) {
    final keysToDelete = _goalContributionsBox.toMap().entries
        .where((entry) => _asMap(entry.value)['goal_id'] == goalId)
        .map((entry) => entry.key)
        .toList();
    _goalContributionsBox.deleteAll(keysToDelete);
  }

  double computeBudgetSpent(String budgetId, String userId) {
    final budget = getBudgetById(budgetId);
    if (budget == null) return 0;

    final walletId = budget['wallet_id'] as String?;

    final transactions = getTransactions(userId);
    double spent = 0;

    for (final tx in transactions) {
      if ((tx['type'] as String?) != 'expense') continue;

      final txWalletId = tx['wallet_id'] as String?;
      if (walletId != null && txWalletId != walletId) continue;

      final txBudgetId = tx['budget_id'] as String?;
      if (txBudgetId != budgetId) continue;

      spent += _toDouble(tx['amount']);
    }
    return spent;
  }

  void applyWalletImpactForTransaction(Map<String, dynamic> transaction, {required bool isInsert}) {
    final sign = isInsert ? 1.0 : -1.0;
    final type = transaction['type'] as String?;
    final amount = _toDouble(transaction['amount']);
    final sourceWalletId = transaction['wallet_id'] as String?;
    final targetWalletId = transaction['target_wallet_id'] as String?;

    if (amount <= 0) return;

    if (type == 'income' && sourceWalletId != null) {
      _adjustWalletBalance(sourceWalletId, sign * amount);
    } else if (type == 'expense' && sourceWalletId != null) {
      _adjustWalletBalance(sourceWalletId, sign * -amount);
    } else if (type == 'transfer' && sourceWalletId != null && targetWalletId != null) {
      _adjustWalletBalance(sourceWalletId, sign * -amount);
      _adjustWalletBalance(targetWalletId, sign * amount);
    }
  }

  void applyLocalGoalContribution({
    required String goalId,
    required double amount,
  }) {
    final goal = getGoalById(goalId);
    if (goal == null) return;
    final updated = Map<String, dynamic>.from(goal);
    updated['current_amount'] = _toDouble(goal['current_amount']) + amount;
    updated['updated_at'] = DateTime.now().toIso8601String();
    putGoal(updated);
  }

  void rollbackLocalGoalContribution({
    required String goalId,
    required double amount,
  }) {
    final goal = getGoalById(goalId);
    if (goal == null) return;
    final updated = Map<String, dynamic>.from(goal);
    final next = _toDouble(goal['current_amount']) - amount;
    updated['current_amount'] = math.max(0, next);
    updated['updated_at'] = DateTime.now().toIso8601String();
    putGoal(updated);
  }

  Future<void> enqueueChange({
    required String userId,
    required String entity,
    required String entityId,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    final now = DateTime.now().toIso8601String();
    final row = {
      'id': _uuid.v4(),
      'user_id': userId,
      'entity': entity,
      'entity_id': entityId,
      'operation': operation,
      'payload': payload == null ? null : _normalizeMap(payload),
      'queued_at': now,
      'updated_at': now,
      'retries': 0,
    };
    await _syncQueueBox.put(row['id'] as String, row);
  }

  bool hasPendingChanges(String userId) {
    return _syncQueueBox.values
        .map(_asMap)
        .any((row) => row['user_id'] == userId);
  }

  bool hasPendingChangeForRecord({
    required String userId,
    required String entity,
    required String entityId,
  }) {
    return _syncQueueBox.values.map(_asMap).any((row) {
      return row['user_id'] == userId &&
          row['entity'] == entity &&
          row['entity_id'] == entityId;
    });
  }

  String? getPendingOperationForRecord({
    required String userId,
    required String entity,
    required String entityId,
  }) {
    DateTime latestQueuedAt = DateTime.fromMillisecondsSinceEpoch(0);
    String? latestOperation;

    for (final raw in _syncQueueBox.values) {
      final row = _asMap(raw);
      if (row['user_id'] != userId ||
          row['entity'] != entity ||
          row['entity_id'] != entityId) {
        continue;
      }
      final queuedAt = _parseDate(row['queued_at']);
      if (queuedAt.isAfter(latestQueuedAt) || latestOperation == null) {
        latestQueuedAt = queuedAt;
        latestOperation = row['operation'] as String?;
      }
    }

    return latestOperation;
  }

  List<Map<String, dynamic>> getPendingChanges(String userId) {
    final rows = _syncQueueBox.values
        .map(_asMap)
        .where((row) => row['user_id'] == userId)
        .toList();
    rows.sort((a, b) => _parseDate(a['queued_at']).compareTo(_parseDate(b['queued_at'])));
    return rows;
  }

  Future<void> removePendingChange(String queueId) async {
    await _syncQueueBox.delete(queueId);
  }

  Future<String?> findPendingChangeId({
    required String userId,
    required String entity,
    required String entityId,
  }) async {
    for (final raw in _syncQueueBox.values) {
      final row = _asMap(raw);
      if (row['user_id'] == userId &&
          row['entity'] == entity &&
          row['entity_id'] == entityId) {
        return row['id'] as String;
      }
    }
    return null;
  }

  Future<void> markPendingChangeError(String queueId) async {
    final row = _syncQueueBox.get(queueId);
    if (row == null) return;
    final mapped = _asMap(row);
    mapped['retries'] = (mapped['retries'] as int? ?? 0) + 1;
    mapped['updated_at'] = DateTime.now().toIso8601String();
    await _syncQueueBox.put(queueId, mapped);
  }

  void replaceProfilesForUser(String userId, List<Map<String, dynamic>> rows) {
    final keep = rows.isNotEmpty ? rows.first : null;
    if (keep == null) {
      _profilesBox.delete(userId);
      return;
    }
    _profilesBox.put(userId, _normalizeMap(keep));
  }

  void replaceWalletsForUser(String userId, List<Map<String, dynamic>> rows, {required bool mergeOnly}) {
    _replaceTableForUser(
      box: _walletsBox,
      userId: userId,
      entity: 'wallets',
      rows: rows,
      mergeOnly: mergeOnly,
    );
  }

  void replaceCategoriesForUser(String userId, List<Map<String, dynamic>> rows, {required bool mergeOnly}) {
    _replaceTableForUser(
      box: _categoriesBox,
      userId: userId,
      entity: 'categories',
      rows: rows,
      mergeOnly: mergeOnly,
    );
  }

  void replaceTransactionsForUser(String userId, List<Map<String, dynamic>> rows, {required bool mergeOnly}) {
    _replaceTableForUser(
      box: _transactionsBox,
      userId: userId,
      entity: 'transactions',
      rows: rows,
      mergeOnly: mergeOnly,
    );
  }

  void replaceBudgetsForUser(String userId, List<Map<String, dynamic>> rows, {required bool mergeOnly}) {
    _replaceTableForUser(
      box: _budgetsBox,
      userId: userId,
      entity: 'budgets',
      rows: rows,
      mergeOnly: mergeOnly,
    );
  }

  void replaceGoalsForUser(String userId, List<Map<String, dynamic>> rows, {required bool mergeOnly}) {
    _replaceTableForUser(
      box: _goalsBox,
      userId: userId,
      entity: 'goals',
      rows: rows,
      mergeOnly: mergeOnly,
    );
  }

  void replaceGoalContributionsForUser(String userId, List<Map<String, dynamic>> rows, {required bool mergeOnly}) {
    _replaceTableForUser(
      box: _goalContributionsBox,
      userId: userId,
      entity: 'goal_contributions',
      rows: rows,
      mergeOnly: mergeOnly,
    );
  }

  void _replaceTableForUser({
    required Box<dynamic> box,
    required String userId,
    required String entity,
    required List<Map<String, dynamic>> rows,
    required bool mergeOnly,
  }) {
    final normalizedRows = rows.map(_normalizeMap).toList();
    final remoteIds = normalizedRows.map((row) => row['id'] as String).toSet();

    if (!mergeOnly) {
      final keysToDelete = box.toMap().entries
          .where((entry) => _asMap(entry.value)['user_id'] == userId)
          .map((entry) => entry.key)
          .toList();
      box.deleteAll(keysToDelete);
    }

    for (final row in normalizedRows) {
      final id = row['id'] as String;
      final pendingOperation = getPendingOperationForRecord(
        userId: userId,
        entity: entity,
        entityId: id,
      );
      if (pendingOperation == 'delete') {
        // Tombstone behavior: never resurrect locally deleted records.
        continue;
      }

      if (pendingOperation != null) {
        final local = box.get(id);
        if (local != null) {
          final localMap = _asMap(local);
          final localUpdatedAt = _parseDate(localMap['updated_at'] ?? localMap['created_at']);
          final remoteUpdatedAt = _parseDate(row['updated_at'] ?? row['created_at']);
          if (localUpdatedAt.isAfter(remoteUpdatedAt) ||
              localUpdatedAt.isAtSameMomentAs(remoteUpdatedAt)) {
            continue;
          }
        }
      }
      box.put(id, row);
    }

    if (mergeOnly) return;

    final toDelete = box.toMap().entries.where((entry) {
      final map = _asMap(entry.value);
      if (map['user_id'] != userId) return false;
      final id = map['id'] as String;
      if (remoteIds.contains(id)) return false;
      final pendingOperation = getPendingOperationForRecord(
        userId: userId,
        entity: entity,
        entityId: id,
      );
      if (pendingOperation == 'delete') {
        return true;
      }
      if (pendingOperation != null) {
        return false;
      }
      return true;
    }).map((entry) => entry.key).toList();

    box.deleteAll(toDelete);
  }

  List<Map<String, dynamic>> _getRowsForUser(Box<dynamic> box, String userId) {
    return box.values
        .map(_asMap)
        .where((row) => row['user_id'] == userId)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  void _adjustWalletBalance(String walletId, double delta) {
    final wallet = getWalletById(walletId);
    if (wallet == null) return;
    final nextBalance = math.max(0, _toDouble(wallet['balance']) + delta);
    final updated = Map<String, dynamic>.from(wallet);
    updated['balance'] = nextBalance;
    updated['updated_at'] = DateTime.now().toIso8601String();
    putWallet(updated);
  }

  static Map<String, dynamic> _normalizeMap(Map<String, dynamic> row) {
    final mapped = <String, dynamic>{};
    row.forEach((key, value) {
      if (value is DateTime) {
        mapped[key] = value.toIso8601String();
      } else if (value is Map) {
        mapped[key] = Map<String, dynamic>.from(value);
      } else {
        mapped[key] = value;
      }
    });
    return mapped;
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    return Map<String, dynamic>.from(raw as Map);
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static int _compareAsc(DateTime aPrimary, DateTime bPrimary, dynamic aSecondary, dynamic bSecondary) {
    final primary = aPrimary.compareTo(bPrimary);
    if (primary != 0) return primary;
    return (aSecondary ?? '').toString().compareTo((bSecondary ?? '').toString());
  }

  static int _compareDesc(
    dynamic aPrimary,
    dynamic bPrimary,
    dynamic aSecondary,
    dynamic bSecondary,
  ) {
    final primary = _compareDynamicDesc(aPrimary, bPrimary);
    if (primary != 0) return primary;
    return _compareDynamicDesc(aSecondary, bSecondary);
  }

  static int _compareDynamicDesc(dynamic left, dynamic right) {
    final leftDate = left is DateTime ? left : DateTime.tryParse((left ?? '').toString());
    final rightDate = right is DateTime ? right : DateTime.tryParse((right ?? '').toString());
    if (leftDate != null && rightDate != null) {
      return rightDate.compareTo(leftDate);
    }
    return (right ?? '').toString().compareTo((left ?? '').toString());
  }

  Future<void> clearUserData(String userId) async {
    void deleteWhere(Box<dynamic> box, bool Function(Map<String, dynamic>) predicate) {
      final keys = box.toMap().entries
          .where((entry) => predicate(_asMap(entry.value)))
          .map((entry) => entry.key)
          .toList();
      box.deleteAll(keys);
    }

    deleteWhere(_profilesBox, (row) => (row['id'] ?? row['user_id']) == userId);
    deleteWhere(_walletsBox, (row) => row['user_id'] == userId);
    deleteWhere(_categoriesBox, (row) => row['user_id'] == userId);
    deleteWhere(_transactionsBox, (row) => row['user_id'] == userId);
    deleteWhere(_budgetsBox, (row) => row['user_id'] == userId);
    deleteWhere(_goalsBox, (row) => row['user_id'] == userId);
    deleteWhere(_goalContributionsBox, (row) => row['user_id'] == userId);
    deleteWhere(_syncQueueBox, (row) => row['user_id'] == userId);
    await clearLastSyncAt(userId);
  }

  Future<void> clearAllData() async {
    await _profilesBox.clear();
    await _walletsBox.clear();
    await _categoriesBox.clear();
    await _transactionsBox.clear();
    await _budgetsBox.clear();
    await _goalsBox.clear();
    await _goalContributionsBox.clear();
    await _syncQueueBox.clear();
    await _syncMetaBox.clear();
  }
}
