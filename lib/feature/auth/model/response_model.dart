import 'dart:convert';

class LoginResponse {
  final bool? twoFactorRequired;
  final String? token;
  final String? tokenType;
  final String? expiresAt;
  final UserModel? user;
  final bool? success;
  final String? message;

  LoginResponse({
    this.twoFactorRequired,
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

  UserModel({
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
        id: json["id"] as String?,
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
