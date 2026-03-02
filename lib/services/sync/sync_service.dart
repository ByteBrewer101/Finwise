import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/app_logger.dart';
import '../local/local_database.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase.instance;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final client = Supabase.instance.client;
  final localDb = ref.read(localDatabaseProvider);
  return SyncService(client: client, localDb: localDb);
});

class SyncService {
  SyncService({
    required SupabaseClient client,
    required LocalDatabase localDb,
  })  : _client = client,
        _localDb = localDb;

  final SupabaseClient _client;
  final LocalDatabase _localDb;

  bool _syncing = false;
  String? _initializedUserId;

  Future<void> initializeForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final isFirstInitForUser = _initializedUserId != user.id;
    _initializedUserId = user.id;

    if (isFirstInitForUser || !_localDb.hasAnyDataForUser(user.id)) {
      await _pullRemoteSnapshot(user.id, mergeOnly: false);
    }

    await syncNow();
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    final user = _client.auth.currentUser;
    if (user == null) return;

    _syncing = true;
    try {
      await _pushPendingChanges(user.id);
      await _pullRemoteSnapshot(
        user.id,
        mergeOnly: _localDb.hasPendingChanges(user.id),
      );
    } finally {
      _syncing = false;
    }
  }

  void resetSession() {
    _initializedUserId = null;
  }

  Future<void> _pushPendingChanges(String userId) async {
    final queue = _localDb.getPendingChanges(userId);
    for (final item in queue) {
      final queueId = item['id'] as String;
      final entity = item['entity'] as String;
      final entityId = item['entity_id'] as String;
      final operation = item['operation'] as String;
      final payload = item['payload'] == null
          ? null
          : Map<String, dynamic>.from(item['payload'] as Map);

      try {
        if (entity == 'goals' && operation == 'delete') {
          await _withRetry(
            () => _client
                .rpc('delete_goal_atomic', params: {'p_goal_id': entityId})
                .timeout(const Duration(seconds: 15)),
          );
          await _localDb.removePendingChange(queueId);
          continue;
        }

        if (operation == 'delete') {
          await _withRetry(
            () => _client
                .from(entity)
                .delete()
                .eq('id', entityId)
                .timeout(const Duration(seconds: 15)),
          );
          await _localDb.removePendingChange(queueId);
          continue;
        }

        if (payload == null) {
          await _localDb.removePendingChange(queueId);
          continue;
        }

        if (operation == 'create') {
          await _withRetry(
            () => _client
                .from(entity)
                .insert(payload)
                .timeout(const Duration(seconds: 15)),
          );
        } else {
          await _withRetry(
            () => _client
                .from(entity)
                .upsert(payload, onConflict: 'id')
                .timeout(const Duration(seconds: 15)),
          );
        }
        await _localDb.removePendingChange(queueId);
      } catch (e) {
        final errorText = e.toString().toLowerCase();
        final isBusinessValidationFailure =
            (entity == 'goal_contributions' && operation == 'create') &&
                (errorText.contains('exceeds goal target amount') ||
                    errorText.contains('insufficient wallet balance') ||
                    errorText.contains('violates') ||
                    errorText.contains('constraint'));

        if (isBusinessValidationFailure) {
          final contributionPayload = payload;
          final contributionAmount =
              (contributionPayload?['amount'] as num?)?.toDouble() ?? 0;
          final goalId = contributionPayload?['goal_id'] as String?;
          final linkedTransactionId =
              contributionPayload?['transaction_id'] as String?;

          // Rollback local optimistic contribution effects.
          if (contributionAmount > 0 && goalId != null) {
            _localDb.rollbackLocalGoalContribution(
              goalId: goalId,
              amount: contributionAmount,
            );
          }
          _localDb.deleteGoalContribution(entityId);
          await _localDb.removePendingChange(queueId);

          if (linkedTransactionId != null) {
            // Remove pending transaction queue if it exists.
            final txQueueId = await _localDb.findPendingChangeId(
              userId: userId,
              entity: 'transactions',
              entityId: linkedTransactionId,
            );
            if (txQueueId != null) {
              await _localDb.removePendingChange(txQueueId);
            }

            // Best-effort remote cleanup in case transaction already got pushed.
            try {
              await _withRetry(
                () => _client
                    .from('transactions')
                    .delete()
                    .eq('id', linkedTransactionId)
                    .timeout(const Duration(seconds: 15)),
              );
            } catch (_) {
              // Ignore cleanup failures; periodic sync will reconcile.
            }

            final localTx = _localDb.getTransactionById(linkedTransactionId);
            if (localTx != null) {
              _localDb.applyWalletImpactForTransaction(localTx, isInsert: false);
            }
            _localDb.deleteTransaction(linkedTransactionId);
          }

          AppLogger.warning(
            'Discarded invalid goal contribution $entityId due to server validation: $e',
          );
          continue;
        }

        await _localDb.markPendingChangeError(queueId);
        AppLogger.warning('Sync push failed for $entity/$entityId: $e');
      }
    }
  }

  Future<void> _pullRemoteSnapshot(String userId, {required bool mergeOnly}) async {
    try {
      final profile = await _withRetry(
        () => _client
            .from('profiles')
            .select('id, full_name, phone, avatar_url, created_at, updated_at')
            .eq('id', userId)
            .maybeSingle()
            .timeout(const Duration(seconds: 15)),
      );
      if (profile != null) {
        final profileRow = Map<String, dynamic>.from(profile);
        profileRow['id'] = userId;
        _localDb.replaceProfilesForUser(userId, [profileRow]);
      }
    } catch (e) {
      AppLogger.warning('Sync pull profile failed: $e');
    }

    try {
      final walletsRaw = await _withRetry(
        () => _client
            .from('wallets')
            .select()
            .eq('user_id', userId)
            .timeout(const Duration(seconds: 15)),
      );
      _localDb.replaceWalletsForUser(
        userId,
        List<Map<String, dynamic>>.from(walletsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      AppLogger.warning('Sync pull wallets failed: $e');
    }

    try {
      final categoriesRaw = await _withRetry(
        () => _client
            .from('categories')
            .select()
            .eq('user_id', userId)
            .timeout(const Duration(seconds: 15)),
      );
      _localDb.replaceCategoriesForUser(
        userId,
        List<Map<String, dynamic>>.from(categoriesRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      AppLogger.warning('Sync pull categories failed: $e');
    }

    try {
      final transactionsRaw = await _withRetry(
        () => _client
            .from('transactions')
            .select()
            .eq('user_id', userId)
            .timeout(const Duration(seconds: 15)),
      );
      _localDb.replaceTransactionsForUser(
        userId,
        List<Map<String, dynamic>>.from(transactionsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      AppLogger.warning('Sync pull transactions failed: $e');
    }

    try {
      final budgetsRaw = await _withRetry(
        () => _client
            .from('budgets')
            .select('''
              id,
              user_id,
              name,
              amount,
              recurrence,
              start_date,
              end_date,
              currency,
              category_id,
              wallet_id,
              created_at,
              updated_at,
              categories(name),
              wallets(name)
            ''')
            .eq('user_id', userId)
            .timeout(const Duration(seconds: 15)),
      );
      _localDb.replaceBudgetsForUser(
        userId,
        List<Map<String, dynamic>>.from(budgetsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      AppLogger.warning('Sync pull budgets failed: $e');
    }

    try {
      final goalsRaw = await _withRetry(
        () => _client
            .from('goals')
            .select()
            .eq('user_id', userId)
            .timeout(const Duration(seconds: 15)),
      );
      _localDb.replaceGoalsForUser(
        userId,
        List<Map<String, dynamic>>.from(goalsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      AppLogger.warning('Sync pull goals failed: $e');
    }

    try {
      final contributionsRaw = await _withRetry(
        () => _client
            .from('goal_contributions')
            .select()
            .eq('user_id', userId)
            .timeout(const Duration(seconds: 15)),
      );
      _localDb.replaceGoalContributionsForUser(
        userId,
        List<Map<String, dynamic>>.from(contributionsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      AppLogger.warning('Sync pull goal_contributions failed: $e');
    }
  }

  Future<T> _withRetry<T>(
    Future<T> Function() action, {
    int retries = 2,
    Duration retryDelay = const Duration(milliseconds: 400),
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await action();
      } catch (e) {
        lastError = e;
        if (attempt == retries) {
          rethrow;
        }
        await Future.delayed(retryDelay * (attempt + 1));
      }
    }
    throw lastError ?? Exception('Retry failed');
  }
}
