import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/storage/token_storage.dart';
import '../../../core/utils/validators.dart';
import '../../../services/local/local_database.dart';
import '../../../services/sync/sync_service.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._client, {
    required LocalDatabase localDb,
    required TokenStorage tokenStorage,
    required SyncService syncService,
  })  : _localDb = localDb,
        _tokenStorage = tokenStorage,
        _syncService = syncService;

  final SupabaseClient _client;
  final LocalDatabase _localDb;
  final TokenStorage _tokenStorage;
  final SyncService _syncService;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    AppValidators.ensureValidEmail(email);
    if (password.trim().isEmpty) {
      throw Exception('Password is required');
    }
    await _client.auth
        .signInWithPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 20));
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    AppValidators.ensureValidEmail(email);
    AppValidators.ensureStrongPassword(password);
    await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  @override
  Future<void> signOut() async {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      await _localDb.clearUserData(userId);
    } else {
      await _localDb.clearAllData();
    }
    await _tokenStorage.clear();
    _syncService.resetSession();
    await _client.auth.signOut();
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _client.auth.currentUser;
    final email = user?.email;

    if (user == null || email == null || email.isEmpty) {
      throw Exception('User not authenticated');
    }
    if (currentPassword.trim().isEmpty) {
      throw Exception('Current password is required');
    }
    AppValidators.ensureStrongPassword(newPassword);

    // Verify current password first.
    await _client.auth
        .signInWithPassword(
          email: email,
          password: currentPassword,
        )
        .timeout(const Duration(seconds: 20));

    await updatePassword(newPassword: newPassword);
  }

  @override
  bool get isAuthenticated =>
      _client.auth.currentSession != null;
}
