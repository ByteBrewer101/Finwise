import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/data/supabase_client_provider.dart';

/// Global Supabase Client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return ref.watch(supabaseClientProvider);
});

/// Current Logged In User
final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseProvider);
  return client.auth.currentUser;
});

/// Current User Id (safe)
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});
