import 'dart:convert';

class PackageResponseModel {
  final List<PackageItemModel>? data;
  final String? selectedSlug;
  final bool? success;
  final String? message;

  PackageResponseModel({
    this.data,
    this.selectedSlug,
    this.success,
    this.message,
  });

  factory PackageResponseModel.fromRawJson(String str) =>
      PackageResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PackageResponseModel.fromJson(Map<String, dynamic> json) =>
      PackageResponseModel(
        data: json["data"] is List
            ? List<PackageItemModel>.from(
                json["data"].map((x) => PackageItemModel.fromJson(x)))
            : [],
        selectedSlug: json["selected_slug"] as String?,
        success: json["success"] is bool ? json["success"] : true,
        message: json["message"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : [],
        "selected_slug": selectedSlug,
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class PackageItemModel {
  final String? slug;
  final String? name;
  final String? shortDescription;
  final PackageFeeModel? fee;
  final PackageFeeModel? activationTotal;
  final String? validityDays;
  final PackageFeeModel? requiredDeposit;
  final List<String>? features;

  PackageItemModel({
    this.slug,
    this.name,
    this.shortDescription,
    this.fee,
    this.activationTotal,
    this.validityDays,
    this.requiredDeposit,
    this.features,
  });

  factory PackageItemModel.fromRawJson(String str) =>
      PackageItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PackageItemModel.fromJson(Map<String, dynamic> json) =>
      PackageItemModel(
        slug: json["slug"] as String?,
        name: json["name"] as String?,
        shortDescription: json["short_description"] as String?,
        fee: json["fee"] != null && json["fee"] is Map<String, dynamic>
            ? PackageFeeModel.fromJson(json["fee"])
            : null,
        activationTotal: json["activation_total"] != null &&
                json["activation_total"] is Map<String, dynamic>
            ? PackageFeeModel.fromJson(json["activation_total"])
            : null,
        validityDays: json["validity_days"]?.toString(),
        requiredDeposit: json["required_deposit"] != null &&
                json["required_deposit"] is Map<String, dynamic>
            ? PackageFeeModel.fromJson(json["required_deposit"])
            : null,
        features: json["features"] is List
            ? List<String>.from(json["features"].map((x) {
                if (x is Map) {
                  final label = x['label'] ?? x['key'] ?? '';
                  final value = x['value'];
                  if (value != null) {
                    return '$label: $value';
                  }
                  return label.toString();
                }
                return x.toString();
              }))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
        "short_description": shortDescription,
        "fee": fee?.toJson(),
        "activation_total": activationTotal?.toJson(),
        "validity_days": validityDays,
        "required_deposit": requiredDeposit?.toJson(),
        "features": features != null ? List<dynamic>.from(features!.map((x) => x)) : [],
      };
}

class PackageFeeModel {
  final String? amount;
  final String? currency;
  final String? formatted;

  PackageFeeModel({
    this.amount,
    this.currency,
    this.formatted,
  });

  factory PackageFeeModel.fromRawJson(String str) =>
      PackageFeeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PackageFeeModel.fromJson(Map<String, dynamic> json) => PackageFeeModel(
        amount: json["amount"]?.toString(),
        currency: json["currency"] as String?,
        formatted: json["formatted"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "currency": currency,
        "formatted": formatted,
      };
}
