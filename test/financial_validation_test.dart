import 'package:flutter_test/flutter_test.dart';

import 'package:finwise/core/utils/validators.dart';

void main() {
  group('Financial validation', () {
    test('Goal overflow prevention: throws when amount exceeds remaining', () {
      expect(
        () => AppValidators.ensureAmountNotExceeding(
          amount: 7000,
          maxAllowed: 600,
          message: 'Amount exceeds remaining goal',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Budget overspend prevention: throws when amount exceeds budget remaining', () {
      expect(
        () => AppValidators.ensureAmountNotExceeding(
          amount: 1200,
          maxAllowed: 500,
          message: 'Amount exceeds remaining budget',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

