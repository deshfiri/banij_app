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
    } else if (json.containsKey("status") || json.containsKey("is_complete")) {
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
  final bool? isComplete;
  final String? currentStep;
  final List<OnboardingStepModel>? steps;
  final OnboardingStatusModel? status;
  final String? approvalStatus;
  final String? message;
  final bool? needsAttention;

  OnboardingDataModel({
    this.isComplete,
    this.currentStep,
    this.steps,
    this.status,
    this.approvalStatus,
    this.message,
    this.needsAttention,
  });

  bool get isApproved =>
      isComplete == true ||
      status?.value?.toLowerCase() == 'active' ||
      status?.value?.toLowerCase() == 'approved';

  factory OnboardingDataModel.fromJson(Map<String, dynamic> json) =>
      OnboardingDataModel(
        isComplete: json["is_complete"] is bool ? json["is_complete"] : false,
        currentStep: json["current_step"]?.toString() ?? 'approval',
        steps: json["steps"] is List
            ? List<OnboardingStepModel>.from(
                json["steps"].map((x) => OnboardingStepModel.fromJson(x)))
            : [],
        status: json["status"] != null && json["status"] is Map<String, dynamic>
            ? OnboardingStatusModel.fromJson(json["status"])
            : (json["status"] is String
                ? OnboardingStatusModel(value: json["status"], label: json["status"])
                : null),
        approvalStatus: json["approval_status"]?.toString() ?? 'FINAL STEP',
        message: json["message"]?.toString() ??
            json["description"]?.toString() ??
            'Package Confirmed! Your account is undergoing final workspace verification.',
        needsAttention: json["needs_attention"] is bool ? json["needs_attention"] : false,
      );

  Map<String, dynamic> toJson() => {
        "is_complete": isComplete,
        "current_step": currentStep,
        "steps": steps != null ? List<dynamic>.from(steps!.map((x) => x.toJson())) : [],
        "status": status?.toJson(),
        "approval_status": approvalStatus,
        "message": message,
        "needs_attention": needsAttention,
      };
}

class OnboardingStepModel {
  final String? key;
  final String? label;
  final int? position;
  final String? state; // 'done', 'active', 'pending'

  OnboardingStepModel({
    this.key,
    this.label,
    this.position,
    this.state,
  });

  bool get isDone => state?.toLowerCase() == 'done';
  bool get isActive => state?.toLowerCase() == 'active';

  factory OnboardingStepModel.fromJson(Map<String, dynamic> json) =>
      OnboardingStepModel(
        key: json["key"]?.toString(),
        label: json["label"]?.toString(),
        position: json["position"] is int
            ? json["position"]
            : int.tryParse(json["position"]?.toString() ?? '1'),
        state: json["state"]?.toString() ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "label": label,
        "position": position,
        "state": state,
      };
}

class OnboardingStatusModel {
  final String? value;
  final String? label;
  final String? tone;

  OnboardingStatusModel({
    this.value,
    this.label,
    this.tone,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) =>
      OnboardingStatusModel(
        value: json["value"]?.toString(),
        label: json["label"]?.toString(),
        tone: json["tone"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "label": label,
        "tone": tone,
      };
}
