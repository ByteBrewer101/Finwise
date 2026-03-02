class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _upperRegex = RegExp(r'[A-Z]');
  static final RegExp _lowerRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'\d');
  static final RegExp _specialRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];+=`~]');

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  static bool isStrongPassword(String password) {
    final value = password.trim();
    return value.length >= 8 &&
        value.length <= 32 &&
        _upperRegex.hasMatch(value) &&
        _lowerRegex.hasMatch(value) &&
        _digitRegex.hasMatch(value) &&
        _specialRegex.hasMatch(value);
  }

  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Enter email';
    if (!isValidEmail(email)) return 'Enter a valid email';
    return null;
  }

  static String? validatePasswordStrength(String? value) {
    final password = (value ?? '').trim();
    if (password.isEmpty) return 'Enter password';
    if (!isStrongPassword(password)) {
      return '8-32 chars with upper, lower, number, special';
    }
    return null;
  }

  static String? validatePasswordRequired(String? value) {
    final password = (value ?? '').trim();
    if (password.isEmpty) return 'Enter password';
    return null;
  }

  static String? validatePositiveAmountInput(String? value, {String emptyMessage = 'Enter amount'}) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return emptyMessage;
    final parsed = double.tryParse(input);
    if (parsed == null || parsed <= 0) return 'Enter a valid number';
    return null;
  }

  static String? validateAmountWithinLimit({
    required double amount,
    required double limit,
    required String message,
  }) {
    if (amount > limit) return message;
    return null;
  }

  static void ensureValidEmail(String email) {
    if (!isValidEmail(email)) {
      throw Exception('Invalid email format');
    }
  }

  static void ensureStrongPassword(String password) {
    if (!isStrongPassword(password)) {
      throw Exception(
        'Password must be 8-32 chars and include upper, lower, number, special',
      );
    }
  }

  static void ensurePositiveAmount(double amount, {String message = 'Amount must be greater than 0'}) {
    if (amount <= 0) {
      throw Exception(message);
    }
  }

  static void ensureAmountNotExceeding({
    required double amount,
    required double maxAllowed,
    required String message,
  }) {
    if (amount > maxAllowed) {
      throw Exception(message);
    }
  }
}
