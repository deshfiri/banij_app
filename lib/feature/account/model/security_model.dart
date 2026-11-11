import 'dart:convert';

class SecurityModel {
  final SecurityData? data;

  SecurityModel({this.data});

  factory SecurityModel.fromRawJson(String str) => SecurityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SecurityModel.fromJson(Map<String, dynamic> json) => SecurityModel(
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? SecurityData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class SecurityData {
  final bool? twoFactorEnabled;
  final bool? twoFactorPendingConfirmation;
  final bool? twoFactorRequiresConfirmation;
  final bool? twoFactorRequired;
  final String? passwordRules;

  SecurityData({
    this.twoFactorEnabled,
    this.twoFactorPendingConfirmation,
    this.twoFactorRequiresConfirmation,
    this.twoFactorRequired,
    this.passwordRules,
  });

  factory SecurityData.fromRawJson(String str) => SecurityData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SecurityData.fromJson(Map<String, dynamic> json) => SecurityData(
        twoFactorEnabled: json["two_factor_enabled"] as bool?,
        twoFactorPendingConfirmation: json["two_factor_pending_confirmation"] as bool?,
        twoFactorRequiresConfirmation: json["two_factor_requires_confirmation"] as bool?,
        twoFactorRequired: json["two_factor_required"] as bool?,
        passwordRules: json["password_rules"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "two_factor_enabled": twoFactorEnabled,
        "two_factor_pending_confirmation": twoFactorPendingConfirmation,
        "two_factor_requires_confirmation": twoFactorRequiresConfirmation,
        "two_factor_required": twoFactorRequired,
        "password_rules": passwordRules,
      };
}
