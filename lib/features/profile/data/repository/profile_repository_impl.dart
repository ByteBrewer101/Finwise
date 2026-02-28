import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/local/local_database.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient client;
  final LocalDatabase localDb;

  ProfileRepositoryImpl(this.client, this.localDb);

  @override
  Future<UserProfile> fetchProfile() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final fullNameFromAuth = user.userMetadata?['full_name'] as String?;
    final email = user.email ?? '';
    final profileMap = localDb.getProfile(user.id);

    if (profileMap == null) {
      return UserProfile(
        id: user.id,
        email: email,
        fullName: (fullNameFromAuth != null && fullNameFromAuth.isNotEmpty)
            ? fullNameFromAuth
            : email.split('@').first,
      );
    }

    final dbFullName = profileMap['full_name'] as String?;

    return UserProfile(
      id: user.id,
      email: email,
      fullName: (dbFullName != null && dbFullName.isNotEmpty)
          ? dbFullName
          : ((fullNameFromAuth != null && fullNameFromAuth.isNotEmpty)
              ? fullNameFromAuth
              : email.split('@').first),
      phone: profileMap['phone'] as String?,
      avatarUrl: profileMap['avatar_url'] as String?,
    );
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id': user.id,
      'user_id': user.id,
      'full_name': fullName.trim(),
      'phone': (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null,
      'avatar_url': (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          ? avatarUrl.trim()
          : null,
      'updated_at': now,
      'created_at': localDb.getProfile(user.id)?['created_at'] ?? now,
    };

    localDb.putProfile(payload);
    await localDb.enqueueChange(
      userId: user.id,
      entity: 'profiles',
      entityId: user.id,
      operation: 'update',
      payload: payload,
    );

    return fetchProfile();
  }
}
