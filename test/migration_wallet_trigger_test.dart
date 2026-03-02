import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Wallet trigger migration includes UPDATE reverse/apply logic', () async {
    final file = File('supabase/migrations/14_wallet_trigger_update_support.sql');
    expect(await file.exists(), isTrue);

    final sql = await file.readAsString();

    expect(sql.contains("elsif tg_op = 'UPDATE'"), isTrue);
    expect(sql.contains('-- Reverse OLD effect first.'), isTrue);
    expect(sql.contains('-- Apply NEW effect.'), isTrue);
    expect(sql.contains('after insert or update or delete'), isTrue);
  });
}

