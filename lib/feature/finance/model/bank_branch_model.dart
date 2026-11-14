import 'dart:convert';

class BankBranchResponseModel {
  final List<BankBranchItemModel>? data;

  BankBranchResponseModel({this.data});

  factory BankBranchResponseModel.fromRawJson(String str) => BankBranchResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BankBranchResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is String) {
      return BankBranchResponseModel.fromRawJson(jsonInput);
    }
    List<BankBranchItemModel> items = [];
    if (jsonInput is Map<String, dynamic>) {
      final rawData = jsonInput["data"] ?? jsonInput["branches"] ?? jsonInput;
      if (rawData is List) {
        items = rawData.map((x) => BankBranchItemModel.fromJson(x)).toList();
      }
    } else if (jsonInput is List) {
      items = jsonInput.map((x) => BankBranchItemModel.fromJson(x)).toList();
    }
    return BankBranchResponseModel(data: items);
  }

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
      };
}

class BankBranchItemModel {
  final String? id;
  final String? bankCode;
  final String? routingNumber;
  final String? branchCode;
  final String? districtId;
  final String? name;
  final String? swiftCode;
  final String? address;
  final String? telephone;
  final String? email;
  final String? fax;

  BankBranchItemModel({
    this.id,
    this.bankCode,
    this.routingNumber,
    this.branchCode,
    this.districtId,
    this.name,
    this.swiftCode,
    this.address,
    this.telephone,
    this.email,
    this.fax,
  });

  factory BankBranchItemModel.fromJson(Map<String, dynamic> json) => BankBranchItemModel(
        id: json["id"]?.toString(),
        bankCode: json["bank_code"]?.toString(),
        routingNumber: json["routing_number"]?.toString(),
        branchCode: json["branch_code"]?.toString(),
        districtId: json["district_id"]?.toString(),
        name: json["name"]?.toString() ?? json["branch_name"]?.toString(),
        swiftCode: json["swift_code"]?.toString(),
        address: json["address"]?.toString(),
        telephone: json["telephone"]?.toString(),
        email: json["email"]?.toString(),
        fax: json["fax"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bank_code": bankCode,
        "routing_number": routingNumber,
        "branch_code": branchCode,
        "district_id": districtId,
        "name": name,
        "swift_code": swiftCode,
        "address": address,
        "telephone": telephone,
        "email": email,
        "fax": fax,
      };
}
