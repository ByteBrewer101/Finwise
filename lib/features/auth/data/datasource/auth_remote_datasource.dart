import '../../domain/models/auth_tokens.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<AuthTokens> refreshToken(String refreshToken);
}
