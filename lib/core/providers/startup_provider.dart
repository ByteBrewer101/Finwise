import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StartupState {
  onboarding,
  login,
  home,
}

final startupProvider = FutureProvider<StartupState>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  final isFirstLaunch = prefs.getBool('first_launch') ?? true;

  final session = Supabase.instance.client.auth.currentSession;

  if (session != null) {
    return StartupState.home;
  }

  if (isFirstLaunch) {
    return StartupState.onboarding;
  }

  return StartupState.login;
});
