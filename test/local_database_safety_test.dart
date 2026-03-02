import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:finwise/services/local/local_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  final db = LocalDatabase.instance;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('finwise_local_db_test_');
    Hive.init(tempDir.path);
    await db.initialize();
  });

  tearDown(() async {
    await db.clearAllData();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Delete merge tombstone: pending delete record is not resurrected', () async {
    const userId = 'u1';
    const txId = 't1';

    final tx = <String, dynamic>{
      'id': txId,
      'user_id': userId,
      'wallet_id': 'w1',
      'type': 'expense',
      'amount': 100,
      'description': 'test',
      'transaction_date': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    db.putTransaction(tx);
    await db.enqueueChange(
      userId: userId,
      entity: 'transactions',
      entityId: txId,
      operation: 'delete',
    );
    db.deleteTransaction(txId);

    db.replaceTransactionsForUser(
      userId,
      [tx],
      mergeOnly: true,
    );

    expect(db.getTransactionById(txId), isNull);
  });

  test('Logout clear semantics: clearUserData removes only current user data', () async {
    const u1 = 'u1';
    const u2 = 'u2';

    db.putProfile({'id': u1, 'full_name': 'A'});
    db.putProfile({'id': u2, 'full_name': 'B'});
    db.putWallet({
      'id': 'w1',
      'user_id': u1,
      'name': 'Cash',
      'type': 'cash',
      'balance': 100,
      'currency': 'INR',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    db.putWallet({
      'id': 'w2',
      'user_id': u2,
      'name': 'Cash',
      'type': 'cash',
      'balance': 100,
      'currency': 'INR',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.clearUserData(u1);

    expect(db.getProfile(u1), isNull);
    expect(db.getProfile(u2), isNotNull);
    expect(db.getWallets(u1), isEmpty);
    expect(db.getWallets(u2), isNotEmpty);
  });
}

