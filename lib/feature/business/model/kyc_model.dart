import 'dart:convert';

class KycResponseModel {
  final KycDataModel? data;

  KycResponseModel({this.data});

  factory KycResponseModel.fromRawJson(String str) => KycResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory KycResponseModel.fromJson(Map<String, dynamic> json) => KycResponseModel(
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? KycDataModel.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class KycDataModel {
  final KycSubmissionModel? submission;
  final List<KycRequirementModel>? requirements;
  final dynamic feedback;

  KycDataModel({this.submission, this.requirements, this.feedback});

  factory KycDataModel.fromJson(Map<String, dynamic> json) => KycDataModel(
        submission: json["submission"] != null && json["submission"] is Map<String, dynamic>
            ? KycSubmissionModel.fromJson(json["submission"])
            : null,
        requirements: json["requirements"] != null && json["requirements"] is List
            ? List<KycRequirementModel>.from((json["requirements"] as List).map((x) => KycRequirementModel.fromJson(x)))
            : null,
        feedback: json["feedback"],
      );

  Map<String, dynamic> toJson() => {
        "submission": submission?.toJson(),
        "requirements": requirements != null ? List<dynamic>.from(requirements!.map((x) => x.toJson())) : null,
        "feedback": feedback,
      };
}

class KycSubmissionModel {
  final String? id;
  final String? status;
  final String? statusLabel;
  final String? statusTone;
  final bool? isEditable;
  final String? deadlineAt;

  KycSubmissionModel({
    this.id,
    this.status,
    this.statusLabel,
    this.statusTone,
    this.isEditable,
    this.deadlineAt,
  });

  factory KycSubmissionModel.fromJson(Map<String, dynamic> json) => KycSubmissionModel(
        id: json["id"]?.toString(),
        status: json["status"]?.toString(),
        statusLabel: json["status_label"]?.toString(),
        statusTone: json["status_tone"]?.toString(),
        isEditable: json["is_editable"] as bool?,
        deadlineAt: json["deadline_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "status_label": statusLabel,
        "status_tone": statusTone,
        "is_editable": isEditable,
        "deadline_at": deadlineAt,
      };
}

class KycRequirementModel {
  final String? key;
  final String? name;
  final String? instructions;
  final bool? isRequired;
  final bool? requiresFile;
  final bool? requiresValue;
  final String? valueLabel;
  final List<String>? acceptedMimeTypes;
  final int? maxSizeKb;
  final dynamic uploaded;
  final dynamic valuePreview;

  KycRequirementModel({
    this.key,
    this.name,
    this.instructions,
    this.isRequired,
    this.requiresFile,
    this.requiresValue,
    this.valueLabel,
    this.acceptedMimeTypes,
    this.maxSizeKb,
    this.uploaded,
    this.valuePreview,
  });

  factory KycRequirementModel.fromJson(Map<String, dynamic> json) => KycRequirementModel(
        key: json["key"]?.toString(),
        name: json["name"]?.toString(),
        instructions: json["instructions"]?.toString(),
        isRequired: json["is_required"] as bool?,
        requiresFile: json["requires_file"] as bool?,
        requiresValue: json["requires_value"] as bool?,
        valueLabel: json["value_label"]?.toString(),
        acceptedMimeTypes: json["accepted_mime_types"] != null && json["accepted_mime_types"] is List
            ? List<String>.from((json["accepted_mime_types"] as List).map((x) => x.toString()))
            : null,
        maxSizeKb: json["max_size_kb"] is int ? json["max_size_kb"] : int.tryParse(json["max_size_kb"]?.toString() ?? ''),
        uploaded: json["uploaded"],
        valuePreview: json["value_preview"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "name": name,
        "instructions": instructions,
        "is_required": isRequired,
        "requires_file": requiresFile,
        "requires_value": requiresValue,
        "value_label": valueLabel,
        "accepted_mime_types": acceptedMimeTypes,
        "max_size_kb": maxSizeKb,
        "uploaded": uploaded,
        "value_preview": valuePreview,
      };
}
