import 'dart:convert';

import 'package:bbnij/feature/package/model/package_model.dart';

class SubscriptionResponseModel {
  final PackageItemModel? package;
  final String? status;
  final String? expiresAt;
  final String? renewAt;
  final bool? canCancel;
  final bool? canChange;
  final bool? canRenew;
  final bool? success;
  final String? message;

  SubscriptionResponseModel({
    this.package,
    this.status,
    this.expiresAt,
    this.renewAt,
    this.canCancel,
    this.canChange,
    this.canRenew,
    this.success,
    this.message,
  });

  factory SubscriptionResponseModel.fromRawJson(String str) =>
      SubscriptionResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    PackageItemModel? packageModel;
    if (json["package"] != null && json["package"] is Map<String, dynamic>) {
      packageModel = PackageItemModel.fromJson(json["package"]);
    } else if (json["data"] != null && json["data"] is Map<String, dynamic>) {
      packageModel = PackageItemModel.fromJson(json["data"]);
    }

    return SubscriptionResponseModel(
      package: packageModel,
      status: json["status"]?.toString(),
      expiresAt: json["expires_at"]?.toString(),
      renewAt: json["renew_at"]?.toString(),
      canCancel: json["can_cancel"] is bool ? json["can_cancel"] : true,
      canChange: json["can_change"] is bool ? json["can_change"] : true,
      canRenew: json["can_renew"] is bool ? json["can_renew"] : true,
      success: json["success"] is bool ? json["success"] : true,
      message: json["message"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "package": package?.toJson(),
        "status": status,
        "expires_at": expiresAt,
        "renew_at": renewAt,
        "can_cancel": canCancel,
        "can_change": canChange,
        "can_renew": canRenew,
        "success": success,
        "message": message,
      };
}
