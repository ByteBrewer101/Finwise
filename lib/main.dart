import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/shared_prefs_provider.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/env.dart';
import 'core/router/app_router.dart';
import 'services/data/supabase_client_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Load env
  await Env.load(envFile: '.env.dev');

  // Initialize Supabase
  await SupabaseInitializer.initialize();

  // Initialize SharedPreferences ONCE
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FinWiseApp(),
    ),
  );
}

class FinWiseApp extends ConsumerWidget {
  const FinWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
