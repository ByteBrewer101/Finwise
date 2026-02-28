import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          await _client.rpc('delete_goal_atomic', params: {'p_goal_id': entityId});
          await _localDb.removePendingChange(queueId);
          continue;
        }

        if (operation == 'delete') {
          await _client.from(entity).delete().eq('id', entityId);
          await _localDb.removePendingChange(queueId);
          continue;
        }

        if (payload == null) {
          await _localDb.removePendingChange(queueId);
          continue;
        }

        if (operation == 'create') {
          await _client.from(entity).insert(payload);
        } else {
          await _client.from(entity).upsert(payload, onConflict: 'id');
        }
        await _localDb.removePendingChange(queueId);
      } catch (e) {
        await _localDb.markPendingChangeError(queueId);
        debugPrint('Sync push failed for $entity/$entityId: $e');
      }
    }
  }

  Future<void> _pullRemoteSnapshot(String userId, {required bool mergeOnly}) async {
    try {
      final profile = await _client
          .from('profiles')
          .select('id, full_name, phone, avatar_url, created_at, updated_at')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        final profileRow = Map<String, dynamic>.from(profile);
        profileRow['id'] = userId;
        _localDb.replaceProfilesForUser(userId, [profileRow]);
      }
    } catch (e) {
      debugPrint('Sync pull profile failed: $e');
    }

    try {
      final walletsRaw = await _client.from('wallets').select().eq('user_id', userId);
      _localDb.replaceWalletsForUser(
        userId,
        List<Map<String, dynamic>>.from(walletsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      debugPrint('Sync pull wallets failed: $e');
    }

    try {
      final categoriesRaw = await _client
          .from('categories')
          .select()
          .or('user_id.eq.$userId,is_default.eq.true');
      _localDb.replaceCategoriesForUser(
        userId,
        List<Map<String, dynamic>>.from(categoriesRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      debugPrint('Sync pull categories failed: $e');
    }

    try {
      final transactionsRaw = await _client.from('transactions').select().eq('user_id', userId);
      _localDb.replaceTransactionsForUser(
        userId,
        List<Map<String, dynamic>>.from(transactionsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      debugPrint('Sync pull transactions failed: $e');
    }

    try {
      final budgetsRaw = await _client
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
          .eq('user_id', userId);
      _localDb.replaceBudgetsForUser(
        userId,
        List<Map<String, dynamic>>.from(budgetsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      debugPrint('Sync pull budgets failed: $e');
    }

    try {
      final goalsRaw = await _client.from('goals').select().eq('user_id', userId);
      _localDb.replaceGoalsForUser(
        userId,
        List<Map<String, dynamic>>.from(goalsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      debugPrint('Sync pull goals failed: $e');
    }

    try {
      final contributionsRaw = await _client
          .from('goal_contributions')
          .select()
          .eq('user_id', userId);
      _localDb.replaceGoalContributionsForUser(
        userId,
        List<Map<String, dynamic>>.from(contributionsRaw),
        mergeOnly: mergeOnly,
      );
    } catch (e) {
      debugPrint('Sync pull goal_contributions failed: $e');
    }
  }
}
