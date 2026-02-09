import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.unauthenticated());

  void setAuthenticated() {
    state = const AuthState.authenticated();
  }

  void logout() {
    state = const AuthState.unauthenticated();
  }
}
