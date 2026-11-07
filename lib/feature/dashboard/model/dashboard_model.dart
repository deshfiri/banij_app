import 'dart:convert';

class DashboardModel {
  final bool? success;
  final String? message;
  final Map<String, dynamic>? data;

  DashboardModel({
    this.success,
    this.message,
    this.data,
  });

  factory DashboardModel.fromRawJson(String str) =>
      DashboardModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
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
