import '../../domain/models/auth_tokens.dart';
import '../../domain/usecases/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) {
    return remote.login(email: email, password: password);
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) {
    return remote.refreshToken(refreshToken);
  }

  @override
  Future<void> logout() async {
    // Will clear Hive later
  }

  @override
  Future<bool> isLoggedIn() async {
    // Will check token presence later
    return false;
  }
}
