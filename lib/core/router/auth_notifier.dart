import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthNotifier() {
    _subscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
