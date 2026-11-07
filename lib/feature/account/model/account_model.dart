import 'dart:convert';

class AccountModel {
  final bool? success;
  final String? message;
  final Map<String, dynamic>? data;

  AccountModel({
    this.success,
    this.message,
    this.data,
  });

  factory AccountModel.fromRawJson(String str) =>
      AccountModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
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
