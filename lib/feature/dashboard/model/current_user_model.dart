import 'dart:convert';

class CurrentUserModel {
  final CurrentUserData? data;

  CurrentUserModel({this.data});

  factory CurrentUserModel.fromRawJson(String str) => CurrentUserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) => CurrentUserModel(
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? CurrentUserData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class CurrentUserData {
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
  final BusinessAccount? businessAccount;

  CurrentUserData({
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

  factory CurrentUserData.fromRawJson(String str) => CurrentUserData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CurrentUserData.fromJson(Map<String, dynamic> json) => CurrentUserData(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        email: json["email"]?.toString(),
        mobile: json["mobile"]?.toString(),
        locale: json["locale"]?.toString(),
        emailVerified: json["email_verified"] as bool?,
        mobileVerified: json["mobile_verified"] as bool?,
        twoFactorEnabled: json["two_factor_enabled"] as bool?,
        identityStatus: json["identity_status"]?.toString(),
        platformRoles: json["platform_roles"] as List?,
        businessAccount: json["business_account"] != null && json["business_account"] is Map<String, dynamic>
            ? BusinessAccount.fromJson(json["business_account"])
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
        "platform_roles": platformRoles,
        "business_account": businessAccount?.toJson(),
      };
}

class BusinessAccount {
  final String? id;
  final String? name;
  final String? status;
  final bool? isActivated;

  BusinessAccount({
    this.id,
    this.name,
    this.status,
    this.isActivated,
  });

  factory BusinessAccount.fromRawJson(String str) => BusinessAccount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessAccount.fromJson(Map<String, dynamic> json) => BusinessAccount(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        status: json["status"]?.toString(),
        isActivated: json["is_activated"] as bool?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "is_activated": isActivated,
      };
}
