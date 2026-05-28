// VALIDATORS
// -----------------------------------------------------------------------------
// Reusable form validators. Each returns null when valid, or an error string
// when invalid — the signature TextFormField expects.
//
// Usage:
//   validator: Validators.phone
//   validator: (v) => Validators.minLength(v, 10, 'Address')
//   validator: (v) => Validators.required(v, 'Username')
// -----------------------------------------------------------------------------

class AppValidators {
  AppValidators._(); // prevent instantiation — this is a static-only utility

  /// Non-empty check. [field] is used in the message, e.g. "Email is required".
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  /// Indian 10-digit phone. Assumes the +91 prefix is shown separately.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final digits = value.trim();
    if (digits.length != 10) return 'Enter a 10-digit number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  /// Standard email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Password with a minimum length. Default 8 to match Django's default.
  static String? password(String? value, {int min = 8}) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < min) return 'At least $min characters';
    return null;
  }

  /// Confirm-password match. Pass the other field's current value.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Minimum length with a custom field name.
  static String? minLength(String? value, int min, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    if (value.trim().length < min) return '$field must be at least $min characters';
    return null;
  }

  /// Username: required, min 3 chars, alphanumeric + underscore only.
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    final v = value.trim();
    if (v.length < 3) return 'At least 3 characters';
    if (!RegExp(r'^\w+$').hasMatch(v)) {
      return 'Only letters, numbers, and underscores';
    }
    return null;
  }

  /// Date in YYYY-MM-DD format (used by the expense tracker).
  static String? dateYmd(String? value) {
    if (value == null || value.trim().isEmpty) return 'Date is required';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())) {
      return 'Format: YYYY-MM-DD';
    }
    return null;
  }

  /// Positive number (used for expense amount).
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than 0';
    return null;
  }
}