import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient client;

  ProfileRepositoryImpl(this.client);

  @override
  Future<UserProfile> fetchProfile() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final profileMap = await client
        .from('profiles')
        .select('id, full_name, phone, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final fullNameFromAuth = user.userMetadata?['full_name'] as String?;
    final email = user.email ?? '';

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

    final payload = {
      'full_name': fullName.trim(),
      'phone': (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null,
      'avatar_url': (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          ? avatarUrl.trim()
          : null,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Update existing row first (common path, does not require insert permission).
    final updatedRows = await client
        .from('profiles')
        .update(payload)
        .eq('id', user.id)
        .select('id')
        .maybeSingle();

    // If profile row is missing (legacy users), create it.
    if (updatedRows == null) {
      await client.from('profiles').insert({
        'id': user.id,
        ...payload,
      });
    }

    await client.auth.updateUser(
      UserAttributes(
        data: {'full_name': fullName.trim()},
      ),
    );

    return fetchProfile();
  }
}
