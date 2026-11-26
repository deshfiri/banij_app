import 'dart:convert';

class LoginResponse {
  final bool? twoFactorRequired;

  /// Sent with `two_factor_required`; passed to the 2FA challenge screen.
  final String? challengeToken;

  /// The account is a supplier (see [accountIsSupplier]).
  final bool isSupplier;

  /// `supplier` from `POST /supplier/auth/login` (null for a user login).
  final SupplierAccountModel? supplier;
  final String? token;
  final String? tokenType;
  final String? expiresAt;
  final UserModel? user;
  final bool? success;
  final String? message;

  LoginResponse({
    this.twoFactorRequired,
    this.challengeToken,
    this.isSupplier = false,
    this.supplier,
    this.token,
    this.tokenType,
    this.expiresAt,
    this.user,
    this.success,
    this.message,
  });

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        twoFactorRequired: json["two_factor_required"] is bool
            ? json["two_factor_required"]
            : null,
        challengeToken: json["challenge_token"]?.toString(),
        isSupplier: accountIsSupplier(json),
        supplier: json["supplier"] is Map
            ? SupplierAccountModel.fromJson(Map<String, dynamic>.from(json["supplier"] as Map))
            : null,
        token: json["token"]?.toString(),
        tokenType: json["token_type"] as String?,
        expiresAt: json["expires_at"] as String?,
        user: json["user"] != null && json["user"] is Map<String, dynamic>
            ? UserModel.fromJson(json["user"])
            : null,
        success: json["success"] is bool ? json["success"] : null,
        message: json["message"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "two_factor_required": twoFactorRequired,
        "token": token,
        "token_type": tokenType,
        "expires_at": expiresAt,
        "user": user?.toJson(),
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class RegisterResponse {
  final bool? twoFactorRequired;
  final String? token;
  final String? tokenType;
  final String? expiresAt;
  final UserModel? user;
  final bool? success;
  final String? message;

  RegisterResponse({
    this.twoFactorRequired,
    this.token,
    this.tokenType,
    this.expiresAt,
    this.user,
    this.success,
    this.message,
  });

  factory RegisterResponse.fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        twoFactorRequired: json["two_factor_required"] is bool
            ? json["two_factor_required"]
            : null,
        token: json["token"] as String?,
        tokenType: json["token_type"] as String?,
        expiresAt: json["expires_at"] as String?,
        user: json["user"] != null && json["user"] is Map<String, dynamic>
            ? UserModel.fromJson(json["user"])
            : null,
        success: json["success"] is bool ? json["success"] : null,
        message: json["message"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "two_factor_required": twoFactorRequired,
        "token": token,
        "token_type": tokenType,
        "expires_at": expiresAt,
        "user": user?.toJson(),
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? locale;
  final bool? emailVerified;
  final bool? mobileVerified;
  final bool? twoFactorEnabled;
  final String? identityStatus;
  final List<dynamic>? platformRoles;
  final BusinessAccountModel? businessAccount;

  /// The user is a supplier (role / type / platform roles say so).
  final bool isSupplier;

  UserModel({
    this.isSupplier = false,
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.locale,
    this.emailVerified,
    this.mobileVerified,
    this.twoFactorEnabled,
    this.identityStatus,
    this.platformRoles,
    this.businessAccount,
  });

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        isSupplier: accountIsSupplier({'user': json}),
        id: json["id"]?.toString(),
        name: json["name"] as String?,
        email: json["email"] as String?,
        mobile: json["mobile"] as String?,
        locale: json["locale"] as String?,
        emailVerified: json["email_verified"] is bool ? json["email_verified"] : null,
        mobileVerified: json["mobile_verified"] is bool ? json["mobile_verified"] : null,
        twoFactorEnabled: json["two_factor_enabled"] is bool ? json["two_factor_enabled"] : null,
        identityStatus: json["identity_status"] as String?,
        platformRoles: json["platform_roles"] is List
            ? List<dynamic>.from(json["platform_roles"].map((x) => x))
            : [],
        businessAccount: json["business_account"] != null && json["business_account"] is Map<String, dynamic>
            ? BusinessAccountModel.fromJson(json["business_account"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "locale": locale,
        "email_verified": emailVerified,
        "mobile_verified": mobileVerified,
        "two_factor_enabled": twoFactorEnabled,
        "identity_status": identityStatus,
        "platform_roles": platformRoles != null ? List<dynamic>.from(platformRoles!.map((x) => x)) : [],
        "business_account": businessAccount?.toJson(),
      };
}

class BusinessAccountModel {
  final String? id;
  final String? name;
  final String? status;
  final bool? isActivated;

  BusinessAccountModel({
    this.id,
    this.name,
    this.status,
    this.isActivated,
  });

  factory BusinessAccountModel.fromRawJson(String str) =>
      BusinessAccountModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessAccountModel.fromJson(Map<String, dynamic> json) =>
      BusinessAccountModel(
        id: json["id"] as String?,
        name: json["name"] as String?,
        status: json["status"] as String?,
        isActivated: json["is_activated"] is bool ? json["is_activated"] : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "is_activated": isActivated,
      };
}

class ForgotPasswordResponse {
  final String? message;
  final bool? success;

  ForgotPasswordResponse({
    this.message,
    this.success,
  });

  factory ForgotPasswordResponse.fromRawJson(String str) =>
      ForgotPasswordResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponse(
        message: json["message"] as String?,
        success: json["success"] is bool ? json["success"] : true,
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        if (success != null) "success": success,
      };
}

/// Whether a login / 2FA / profile response describes a supplier account.
///
/// Looks for "supplier" where backends usually put the role, at the top level
/// and inside `user` and `user.business_account`: `is_supplier`, `role`,
/// `roles`, `type`, `kind`, `account_type`, `user_type`, `guard`,
/// `platform_roles` (strings or `{name|slug|key|...}` objects), and a
/// `supplier` / `supplier_account` object.
bool accountIsSupplier(Map<String, dynamic> json) {
  final user = json['user'] is Map ? json['user'] as Map : const {};
  final business = user['business_account'] is Map ? user['business_account'] as Map : const {};
  for (final source in [json, user, business]) {
    if (source['is_supplier'] == true || source['is_supplier'] == 1) return true;
    if (source['supplier'] is Map || source['supplier_account'] is Map || source['supplier_profile'] is Map) {
      return true;
    }
    for (final key in const ['role', 'roles', 'type', 'kind', 'account_type', 'user_type', 'guard', 'platform_roles']) {
      if (_mentionsSupplier(source[key])) return true;
    }
  }
  return false;
}

bool _mentionsSupplier(dynamic value) {
  if (value is String) return value.toLowerCase().contains('supplier');
  if (value is List) return value.any(_mentionsSupplier);
  if (value is Map) {
    return const ['name', 'slug', 'key', 'code', 'role', 'type', 'value', 'label'].any((k) => _mentionsSupplier(value[k]));
  }
  return false;
}

/// The `supplier` object of `POST /supplier/auth/login` (SupplierResource).
class SupplierAccountModel {
  final String? id;
  final String? reference;
  final String? businessName;
  final String? contactPersonName;
  final String? email;
  final String? mobile;

  /// Approval funnel: draft, kyc_pending, under_review, approved, …
  final String? status;
  final String? statusLabel;

  /// Only an approved, un-suspended supplier may use listings, offers, stock
  /// and withdrawals.
  final bool isOperational;

  const SupplierAccountModel({
    this.id,
    this.reference,
    this.businessName,
    this.contactPersonName,
    this.email,
    this.mobile,
    this.status,
    this.statusLabel,
    this.isOperational = false,
  });

  factory SupplierAccountModel.fromJson(Map<String, dynamic> json) => SupplierAccountModel(
        id: json["id"]?.toString(),
        reference: json["reference"]?.toString(),
        businessName: json["business_name"]?.toString(),
        contactPersonName: json["contact_person_name"]?.toString(),
        email: json["email"]?.toString(),
        mobile: json["mobile"]?.toString(),
        status: json["status"]?.toString(),
        statusLabel: json["status_label"]?.toString(),
        isOperational: json["is_operational"] == true,
      );

  /// Name to greet the supplier with.
  String? get displayName => (contactPersonName?.isNotEmpty ?? false) ? contactPersonName : businessName;
}

/// A rejected login, with the HTTP status so the caller can tell wrong
/// credentials (401 / 422) from throttling (429) or a server error.
class LoginFailure implements Exception {
  final String message;
  final int? statusCode;

  const LoginFailure(this.message, {this.statusCode});

  /// The server did not accept these credentials on this login.
  bool get isRejectedCredentials => statusCode == 401 || statusCode == 422;

  @override
  String toString() => message;
}

/// Why a login response must NOT become a session, or null when it can.
///
/// A sign-in succeeds only when everything matches:
/// * a bearer token was issued;
/// * the response carries the account (`user` or `supplier`);
/// * that account is the one whose email was typed ([enteredEmail], when
///   given — the 2FA step has none);
/// * a user login is `identity_status: active` ("whether this login may use
///   the platform").
String? loginResponseProblem(LoginResponse response, {String? enteredEmail}) {
  final token = response.token?.trim();
  if (token == null || token.isEmpty) {
    return response.message ?? 'Login failed. Please check your email and password.';
  }
  if (response.user == null && response.supplier == null) {
    return 'The server did not return your account. Please try again.';
  }
  final returnedEmail = (response.user?.email ?? response.supplier?.email)?.trim().toLowerCase();
  final typedEmail = enteredEmail?.trim().toLowerCase();
  if (typedEmail != null && typedEmail.isNotEmpty && returnedEmail != null && returnedEmail.isNotEmpty) {
    if (returnedEmail != typedEmail) return 'The signed-in account does not match this email. Please try again.';
  }
  final identity = response.user?.identityStatus?.trim().toLowerCase();
  if (identity != null && identity.isNotEmpty && identity != 'active') {
    return 'This account is $identity and cannot sign in. Please contact support.';
  }
  return null;
}
