import 'dart:convert';

class BankResponseModel {
  final List<BankItemModel>? data;

  BankResponseModel({this.data});

  factory BankResponseModel.fromRawJson(String str) => BankResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BankResponseModel.fromJson(Map<String, dynamic> json) => BankResponseModel(
        data: json["data"] != null && json["data"] is List
            ? List<BankItemModel>.from((json["data"] as List).map((x) => BankItemModel.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
      };
}

class BankItemModel {
  final String? bankCode;
  final String? name;
  final String? slug;

  BankItemModel({
    this.bankCode,
    this.name,
    this.slug,
  });

  factory BankItemModel.fromJson(Map<String, dynamic> json) => BankItemModel(
        bankCode: json["bank_code"]?.toString(),
        name: json["name"]?.toString(),
        slug: json["slug"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "bank_code": bankCode,
        "name": name,
        "slug": slug,
      };
}
