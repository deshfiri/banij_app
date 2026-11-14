import 'dart:convert';

class TwoFactorChallengeModel {
  final bool? success;
  final String? message;
  final String? accessToken;
  final String? tokenType;
  final dynamic user;

  TwoFactorChallengeModel({
    this.success,
    this.message,
    this.accessToken,
    this.tokenType,
    this.user,
  });

  factory TwoFactorChallengeModel.fromRawJson(String str) => TwoFactorChallengeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TwoFactorChallengeModel.fromJson(Map<String, dynamic> json) => TwoFactorChallengeModel(
        success: json["success"] is bool ? json["success"] : true,
        message: json["message"]?.toString() ?? json["status"]?.toString(),
        accessToken: json["access_token"]?.toString() ?? json["token"]?.toString(),
        tokenType: json["token_type"]?.toString(),
        user: json["user"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "access_token": accessToken,
        "token_type": tokenType,
        "user": user,
      };
}
