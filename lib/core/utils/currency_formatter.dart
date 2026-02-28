class CurrencyFormatter {
  CurrencyFormatter._();

  static String symbol(String? currency) {
    if (currency == null || currency.isEmpty) return "\u20B9";

    switch (currency.toUpperCase()) {
      case "INR":
        return "\u20B9";
      case "USD":
        return "\$";
      case "IDR":
        return "Rp";
      default:
        return currency;
    }
  }

  static String format({required double amount, String? currency}) {
    final symbolValue = symbol(currency);
    final formatted = amount.toStringAsFixed(0);
    return "$symbolValue $formatted";
  }
}
