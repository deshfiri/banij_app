import 'dart:convert';

class OnboardingResponseModel {
  final OnboardingDataModel? data;
  final bool? success;
  final String? message;

  OnboardingResponseModel({
    this.data,
    this.success,
    this.message,
  });

  factory OnboardingResponseModel.fromRawJson(String str) =>
      OnboardingResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    OnboardingDataModel? dataModel;
    if (json["data"] != null && json["data"] is Map<String, dynamic>) {
      dataModel = OnboardingDataModel.fromJson(json["data"]);
    } else if (json.containsKey("status") || json.containsKey("step")) {
      dataModel = OnboardingDataModel.fromJson(json);
    }

    return OnboardingResponseModel(
      data: dataModel,
      success: json["success"] is bool ? json["success"] : true,
      message: json["message"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "success": success,
        "message": message,
      };
}

class OnboardingDataModel {
  final int? step;
  final String? status;
  final String? title;
  final String? subtitle;
  final String? approvalStatus;
  final String? message;
  final bool? needsAttention;
  final bool? isApproved;

  OnboardingDataModel({
    this.step,
    this.status,
    this.title,
    this.subtitle,
    this.approvalStatus,
    this.message,
    this.needsAttention,
    this.isApproved,
  });

  factory OnboardingDataModel.fromJson(Map<String, dynamic> json) =>
      OnboardingDataModel(
        step: json["step"] is int
            ? json["step"]
            : int.tryParse(json["step"]?.toString() ?? '5'),
        status: json["status"]?.toString(),
        title: json["title"]?.toString(),
        subtitle: json["subtitle"]?.toString(),
        approvalStatus: json["approval_status"]?.toString() ?? json["badge"]?.toString() ?? 'FINAL STEP',
        message: json["message"]?.toString() ??
            json["description"]?.toString() ??
            'Package Confirmed! Your account is undergoing final workspace verification.',
        needsAttention: json["needs_attention"] is bool ? json["needs_attention"] : false,
        isApproved: json["is_approved"] is bool
            ? json["is_approved"]
            : (json["status"]?.toString().toLowerCase().contains('approved') == true ||
                json["status"]?.toString().toLowerCase().contains('active') == true),
      );

  Map<String, dynamic> toJson() => {
        "step": step,
        "status": status,
        "title": title,
        "subtitle": subtitle,
        "approval_status": approvalStatus,
        "message": message,
        "needs_attention": needsAttention,
        "is_approved": isApproved,
      };
}
