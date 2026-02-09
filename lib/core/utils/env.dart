import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { dev, staging, prod }

class Env {
  Env._();

  static late final AppEnvironment environment;
  static late final String baseUrl;
  static late final String logLevel;

  static Future<void> load({required String envFile}) async {
    await dotenv.load(fileName: envFile);

    final env = dotenv.env['APP_ENV'];

    environment = switch (env) {
      'prod' => AppEnvironment.prod,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    };

    baseUrl = dotenv.env['BASE_URL'] ?? '';
    logLevel = dotenv.env['LOG_LEVEL'] ?? 'debug';
  }
}
