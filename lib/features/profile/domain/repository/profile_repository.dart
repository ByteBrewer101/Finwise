import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile();

  Future<UserProfile> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  });
}
