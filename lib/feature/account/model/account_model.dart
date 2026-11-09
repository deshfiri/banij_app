import 'dart:convert';

class AccountModel {
  final UserProfileData? data;
  final bool? mustVerifyEmail;
  final DeletionRequestData? deletionRequest;
  final bool? success;
  final String? message;

  AccountModel({
    this.data,
    this.mustVerifyEmail,
    this.deletionRequest,
    this.success,
    this.message,
  });

  factory AccountModel.fromRawJson(String str) =>
      AccountModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? UserProfileData.fromJson(json["data"])
            : null,
        mustVerifyEmail: json["must_verify_email"] is bool
            ? json["must_verify_email"]
            : null,
        deletionRequest: json["deletion_request"] != null &&
                json["deletion_request"] is Map<String, dynamic>
            ? DeletionRequestData.fromJson(json["deletion_request"])
            : null,
        success: json["success"] is bool ? json["success"] : null,
        message: json["message"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "must_verify_email": mustVerifyEmail,
        "deletion_request": deletionRequest?.toJson(),
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class UserProfileData {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final bool? emailVerified;
  final bool? mobileVerified;
  final String? locale;

  UserProfileData({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.emailVerified,
    this.mobileVerified,
    this.locale,
  });

  factory UserProfileData.fromRawJson(String str) =>
      UserProfileData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserProfileData.fromJson(Map<String, dynamic> json) => UserProfileData(
        id: json["id"] as String?,
        name: json["name"] as String?,
        email: json["email"] as String?,
        mobile: json["mobile"] as String?,
        emailVerified: json["email_verified"] is bool ? json["email_verified"] : null,
        mobileVerified: json["mobile_verified"] is bool ? json["mobile_verified"] : null,
        locale: json["locale"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "email_verified": emailVerified,
        "mobile_verified": mobileVerified,
        "locale": locale,
      };
}

class DeletionRequestData {
  final String? id;
  final String? status;
  final String? reason;
  final String? requestedAt;
  final String? decisionNote;

  DeletionRequestData({
    this.id,
    this.status,
    this.reason,
    this.requestedAt,
    this.decisionNote,
  });

  factory DeletionRequestData.fromRawJson(String str) =>
      DeletionRequestData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeletionRequestData.fromJson(Map<String, dynamic> json) =>
      DeletionRequestData(
        id: json["id"] as String?,
        status: json["status"] as String?,
        reason: json["reason"] as String?,
        requestedAt: json["requested_at"] as String?,
        decisionNote: json["decision_note"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "reason": reason,
        "requested_at": requestedAt,
        "decision_note": decisionNote,
      };
}
