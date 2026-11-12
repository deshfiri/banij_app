import 'dart:convert';
import '../../dashboard/model/wholesale_cart_model.dart';

class WithdrawalOptionsModel {
  final WholesalePrice? availableBalance;
  final WholesalePrice? minimum;
  final WholesalePrice? maximum;
  final String? currency;
  final List<dynamic>? methods;

  WithdrawalOptionsModel({
    this.availableBalance,
    this.minimum,
    this.maximum,
    this.currency,
    this.methods,
  });

  factory WithdrawalOptionsModel.fromRawJson(String str) => WithdrawalOptionsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WithdrawalOptionsModel.fromJson(Map<String, dynamic> json) => WithdrawalOptionsModel(
        availableBalance: json["available_balance"] != null && json["available_balance"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["available_balance"])
            : null,
        minimum: json["minimum"] != null && json["minimum"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["minimum"])
            : null,
        maximum: json["maximum"] != null && json["maximum"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["maximum"])
            : null,
        currency: json["currency"]?.toString(),
        methods: json["methods"] as List<dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        "available_balance": availableBalance?.toJson(),
        "minimum": minimum?.toJson(),
        "maximum": maximum?.toJson(),
        "currency": currency,
        "methods": methods,
      };
}
