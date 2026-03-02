import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_storage.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../../../../services/data/supabase_client_provider.dart';
import '../../../../services/sync/sync_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final localDb = ref.watch(localDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  return AuthRepositoryImpl(
    client,
    localDb: localDb,
    tokenStorage: TokenStorage(),
    syncService: syncService,
  );
});

final authStateProvider = StateProvider<bool>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.isAuthenticated;
});
