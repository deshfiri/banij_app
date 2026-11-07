import 'dart:convert';

class BusinessModel {
  final bool? success;
  final String? message;
  final Map<String, dynamic>? data;

  BusinessModel({
    this.success,
    this.message,
    this.data,
  });

  factory BusinessModel.fromRawJson(String str) =>
      BusinessModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessModel.fromJson(Map<String, dynamic> json) => BusinessModel(
        success: json["success"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
      };
}
