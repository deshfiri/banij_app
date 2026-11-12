import 'dart:convert';

class WalletTopUpModel {
  final String? message;
  final String? redirectUrl;
  final dynamic data;

  WalletTopUpModel({
    this.message,
    this.redirectUrl,
    this.data,
  });

  factory WalletTopUpModel.fromRawJson(String str) => WalletTopUpModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WalletTopUpModel.fromJson(Map<String, dynamic> json) => WalletTopUpModel(
        message: json["message"]?.toString() ?? json["status"]?.toString(),
        redirectUrl: json["redirect_url"]?.toString() ?? json["url"]?.toString(),
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "redirect_url": redirectUrl,
        "data": data,
      };
}
