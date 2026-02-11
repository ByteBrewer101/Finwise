import 'package:hive/hive.dart';

class TokenStorage {
  static const _boxName = 'auth_tokens';
  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';

  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final box = await _openBox();
    await box.put(_accessKey, accessToken);
    await box.put(_refreshKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final box = await _openBox();
    return box.get(_accessKey);
  }

  Future<String?> getRefreshToken() async {
    final box = await _openBox();
    return box.get(_refreshKey);
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
