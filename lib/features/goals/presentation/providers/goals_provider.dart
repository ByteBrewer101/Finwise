import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/sync/sync_service.dart';
import '../../data/repository/goal_repository_impl.dart';
import '../../domain/models/goal.dart';

final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final repository = ref.read(goalRepositoryProvider);
  var goals = await repository.fetchGoals();
  if (goals.isEmpty && Supabase.instance.client.auth.currentUser != null) {
    await ref.read(syncServiceProvider).syncNow();
    goals = await repository.fetchGoals();
  }
  return goals;
});


