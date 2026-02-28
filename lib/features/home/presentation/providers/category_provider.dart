import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/sync/sync_service.dart';
import '../../domain/models/category.dart';

final categoryProvider =
    FutureProvider<List<Category>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final localDb = ref.read(localDatabaseProvider);
  var rows = localDb.getCategories(user.id);
  if (rows.isEmpty) {
    await ref.read(syncServiceProvider).syncNow();
    rows = localDb.getCategories(user.id);
  }
  return rows.map(Category.fromJson).toList();
});
