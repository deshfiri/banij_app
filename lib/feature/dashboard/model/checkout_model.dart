import 'dart:convert';

class CheckoutModel {
  final bool? success;
  final String? message;
  final Map<String, dynamic>? data;

  CheckoutModel({
    this.success,
    this.message,
    this.data,
  });

  factory CheckoutModel.fromRawJson(String str) => CheckoutModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckoutModel.fromJson(Map<String, dynamic> json) => CheckoutModel(
        success: json["success"] as bool?,
        message: json["message"]?.toString(),
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? json["data"] as Map<String, dynamic>
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
      };
}
