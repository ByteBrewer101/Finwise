class CurrencyFormatter {
  CurrencyFormatter._();

  static String symbol(String? currency) {
    if (currency == null || currency.isEmpty) return "₹";

    switch (currency.toUpperCase()) {
      case "INR":
        return "₹";
      case "USD":
        return "\$";
      case "IDR":
        return "Rp";
      default:
        return currency; // fallback to raw currency code
    }
  }

  static String format({required double amount, String? currency}) {
    final symbolValue = symbol(currency);
    final formatted = amount.toStringAsFixed(0);
    return "$symbolValue $formatted";
  }
}
