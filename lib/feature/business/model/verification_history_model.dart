import 'dart:convert';

class VerificationHistoryResponseModel {
  final List<VerificationRecordModel>? data;

  VerificationHistoryResponseModel({this.data});

  factory VerificationHistoryResponseModel.fromRawJson(String str) =>
      VerificationHistoryResponseModel.fromJson(json.decode(str));

  factory VerificationHistoryResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is String) {
      return VerificationHistoryResponseModel.fromRawJson(jsonInput);
    }
    if (jsonInput is! Map<String, dynamic>) {
      return VerificationHistoryResponseModel(data: []);
    }

    final rawData = jsonInput['data'];
    List<VerificationRecordModel> items = [];
    if (rawData is List) {
      items = rawData.map((x) => VerificationRecordModel.fromJson(x)).toList();
    }

    return VerificationHistoryResponseModel(data: items);
  }
}

class VerificationRecordModel {
  final String? id;
  final String? status;
  final String? statusLabel;
  final String? statusTone;
  final bool? isEditable;
  final String? openedAt;
  final String? submittedAt;
  final String? reviewedAt;
  final String? deadlineAt;
  final int? daysRemaining;
  final bool? isOverdue;
  final List<RequirementModel>? requirements;

  VerificationRecordModel({
    this.id,
    this.status,
    this.statusLabel,
    this.statusTone,
    this.isEditable,
    this.openedAt,
    this.submittedAt,
    this.reviewedAt,
    this.deadlineAt,
    this.daysRemaining,
    this.isOverdue,
    this.requirements,
  });

  factory VerificationRecordModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return VerificationRecordModel();
    
    final rawReqs = json['requirements'];
    List<RequirementModel> reqList = [];
    if (rawReqs is List) {
      reqList = rawReqs.map((x) => RequirementModel.fromJson(x)).toList();
    }

    return VerificationRecordModel(
      id: json['id']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString() ?? 'Approved',
      statusTone: json['status_tone']?.toString(),
      isEditable: json['is_editable'],
      openedAt: json['opened_at']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      deadlineAt: json['deadline_at']?.toString(),
      daysRemaining: json['days_remaining'],
      isOverdue: json['is_overdue'],
      requirements: reqList,
    );
  }
}

class RequirementModel {
  final String? key;
  final String? name;
  final String? instructions;
  final bool? isRequired;
  final String? status;

  RequirementModel({
    this.key,
    this.name,
    this.instructions,
    this.isRequired,
    this.status,
  });

  factory RequirementModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return RequirementModel();
    return RequirementModel(
      key: json['key']?.toString(),
      name: json['name']?.toString(),
      instructions: json['instructions']?.toString(),
      isRequired: json['is_required'],
      status: json['status']?.toString(),
    );
  }
}
