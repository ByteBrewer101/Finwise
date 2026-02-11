import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../../../../services/data/supabase_client_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});

final authStateProvider = StateProvider<bool>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.isAuthenticated;
});
