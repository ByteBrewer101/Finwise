import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/sync/sync_service.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repository/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = Supabase.instance.client;
  final localDb = ref.read(localDatabaseProvider);
  return ProfileRepositoryImpl(client, localDb);
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>(
      (ref) => ProfileNotifier(ref),
    );

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(const AsyncLoading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final profile = await repo.fetchProfile();
      if (!mounted) return;
      state = AsyncData(profile);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final previous = state.valueOrNull;

    try {
      if (previous != null) {
        state = AsyncData(
          previous.copyWith(
            fullName: fullName,
            phone: phone,
            avatarUrl: avatarUrl,
          ),
        );
      } else {
        state = const AsyncLoading();
      }

      final repo = ref.read(profileRepositoryProvider);
      final updated = await repo.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      if (!mounted) return;
      state = AsyncData(updated);
    } catch (_) {
      if (!mounted) return;
      // Keep previous UI data visible; surface error via caller snackbar.
      if (previous != null) {
        state = AsyncData(previous);
      }
      rethrow;
    }
  }
}
