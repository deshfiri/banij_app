import 'package:get/get.dart';

/// Form validators shared by the auth screens. Messages are translation
/// keys; each screen keeps the exact rules and messages it used before.
class AuthValidators {
  AuthValidators._();

  /// Local part with the usual characters (incl. `+` and `'`), a domain of
  /// dot-separated labels and a letters-only top-level domain of 2+ letters
  /// (so `.online`, `.agency` … are accepted). No leading / trailing / double
  /// dots.
  static final RegExp _emailRegex = RegExp(
    r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*"
    r'@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$',
  );
  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _lower = RegExp(r'[a-z]');
  static final RegExp _digit = RegExp(r'[0-9]');

  /// Required + email format. [emptyKey]/[invalidKey] let a screen keep its own wording.
  static String? email(
    String? value, {
    String emptyKey = 'err_enter_email',
    String invalidKey = 'err_valid_email',
  }) {
    if (value == null || value.trim().isEmpty) return emptyKey.tr;
    final email = value.trim();
    // 254 is the longest address mail systems accept.
    if (email.length > 254 || !_emailRegex.hasMatch(email)) return invalidKey.tr;
    return null;
  }

  /// Non-empty trimmed value.
  static String? required(String? value, String messageKey) =>
      (value == null || value.trim().isEmpty) ? messageKey.tr : null;

  /// Sign-in password: required, at least 6 characters, at most 128 (the
  /// server decides whether it is right — it is never trimmed).
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'err_enter_password'.tr;
    if (value.length < 6) return 'err_password_length'.tr;
    if (value.length > 128) return 'Password is too long'.tr;
    return null;
  }

  /// New-account password: 12+ chars with upper, lower and a digit.
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'err_enter_password'.tr;
    if (value.length < 12) return 'Password must be at least 12 characters long'.tr;
    if (!_upper.hasMatch(value)) return 'Password must contain at least one capital letter'.tr;
    if (!_lower.hasMatch(value)) return 'Password must contain at least one small letter'.tr;
    if (!_digit.hasMatch(value)) return 'Password must contain at least one number'.tr;
    return null;
  }

  /// Confirm password must be filled and equal [password].
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'err_confirm_password'.tr;
    if (value != password) return 'err_passwords_match'.tr;
    return null;
  }
}
