import '../models/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<AuthTokens> refreshToken(String refreshToken);

  Future<void> logout();

  Future<bool> isLoggedIn();
}
