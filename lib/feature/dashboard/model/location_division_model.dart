import 'dart:convert';

class LocationDivisionModel {
  final List<DivisionData>? data;

  LocationDivisionModel({this.data});

  factory LocationDivisionModel.fromRawJson(String str) => LocationDivisionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LocationDivisionModel.fromJson(Map<String, dynamic> json) => LocationDivisionModel(
        data: json["data"] != null && json["data"] is List
            ? List<DivisionData>.from((json["data"] as List).map((x) => DivisionData.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
      };
}

class DivisionData {
  final int? id;
  final String? sourceId;
  final String? nameEn;
  final String? nameBn;

  DivisionData({
    this.id,
    this.sourceId,
    this.nameEn,
    this.nameBn,
  });

  factory DivisionData.fromRawJson(String str) => DivisionData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DivisionData.fromJson(Map<String, dynamic> json) => DivisionData(
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ''),
        sourceId: json["source_id"]?.toString(),
        nameEn: json["name_en"]?.toString() ?? json["name"]?.toString(),
        nameBn: json["name_bn"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "source_id": sourceId,
        "name_en": nameEn,
        "name_bn": nameBn,
      };
}
