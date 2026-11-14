import 'dart:convert';
import '../../dashboard/model/wholesale_cart_model.dart';

class WithdrawalOptionsModel {
  final WholesalePrice? availableBalance;
  final WholesalePrice? minimum;
  final WholesalePrice? maximum;
  final String? currency;
  final List<WithdrawalMethodItemModel>? methods;

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
        methods: json["methods"] != null && json["methods"] is List
            ? List<WithdrawalMethodItemModel>.from((json["methods"] as List).map((x) => WithdrawalMethodItemModel.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "available_balance": availableBalance?.toJson(),
        "minimum": minimum?.toJson(),
        "maximum": maximum?.toJson(),
        "currency": currency,
        "methods": methods != null ? List<dynamic>.from(methods!.map((x) => x.toJson())) : null,
      };
}

class WithdrawalMethodItemModel {
  final String? id;
  final String? label;
  final String? type;
  final String? typeLabel;
  final String? maskedNumber;
  final bool? isDefault;

  WithdrawalMethodItemModel({
    this.id,
    this.label,
    this.type,
    this.typeLabel,
    this.maskedNumber,
    this.isDefault,
  });

  factory WithdrawalMethodItemModel.fromJson(Map<String, dynamic> json) => WithdrawalMethodItemModel(
        id: json["id"]?.toString(),
        label: json["label"]?.toString(),
        type: json["type"]?.toString(),
        typeLabel: json["type_label"]?.toString(),
        maskedNumber: json["masked_number"]?.toString(),
        isDefault: json["is_default"] as bool?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "type": type,
        "type_label": typeLabel,
        "masked_number": maskedNumber,
        "is_default": isDefault,
      };
}
