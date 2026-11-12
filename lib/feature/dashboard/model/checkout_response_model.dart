import 'dart:convert';
import 'wholesale_cart_model.dart';

class CheckoutResponseModel {
  final CheckoutData? data;

  CheckoutResponseModel({this.data});

  factory CheckoutResponseModel.fromRawJson(String str) => CheckoutResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) => CheckoutResponseModel(
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? CheckoutData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class CheckoutData {
  final CheckoutPackage? package;
  final CheckoutQuote? quote;
  final String? coupon;
  final String? deadline;
  final dynamic gateways;

  CheckoutData({
    this.package,
    this.quote,
    this.coupon,
    this.deadline,
    this.gateways,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) => CheckoutData(
        package: json["package"] != null && json["package"] is Map<String, dynamic>
            ? CheckoutPackage.fromJson(json["package"])
            : null,
        quote: json["quote"] != null && json["quote"] is Map<String, dynamic>
            ? CheckoutQuote.fromJson(json["quote"])
            : null,
        coupon: json["coupon"]?.toString(),
        deadline: json["deadline"]?.toString(),
        gateways: json["gateways"],
      );

  Map<String, dynamic> toJson() => {
        "package": package?.toJson(),
        "quote": quote?.toJson(),
        "coupon": coupon,
        "deadline": deadline,
        "gateways": gateways,
      };
}

class CheckoutPackage {
  final String? slug;
  final String? name;
  final String? validityDays;

  CheckoutPackage({
    this.slug,
    this.name,
    this.validityDays,
  });

  factory CheckoutPackage.fromJson(Map<String, dynamic> json) => CheckoutPackage(
        slug: json["slug"]?.toString(),
        name: json["name"]?.toString(),
        validityDays: json["validity_days"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
        "validity_days": validityDays,
      };
}

class CheckoutQuote {
  final List<String>? lines;
  final WholesalePrice? subtotal;
  final WholesalePrice? total;
  final bool? isPayable;
  final List<String>? tax;
  final WholesalePrice? taxIncluded;

  CheckoutQuote({
    this.lines,
    this.subtotal,
    this.total,
    this.isPayable,
    this.tax,
    this.taxIncluded,
  });

  factory CheckoutQuote.fromJson(Map<String, dynamic> json) => CheckoutQuote(
        lines: json["lines"] != null && json["lines"] is List
            ? List<String>.from((json["lines"] as List).map((x) => x.toString()))
            : null,
        subtotal: json["subtotal"] != null && json["subtotal"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["subtotal"])
            : null,
        total: json["total"] != null && json["total"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["total"])
            : null,
        isPayable: json["is_payable"] as bool?,
        tax: json["tax"] != null && json["tax"] is List
            ? List<String>.from((json["tax"] as List).map((x) => x.toString()))
            : null,
        taxIncluded: json["tax_included"] != null && json["tax_included"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["tax_included"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "lines": lines,
        "subtotal": subtotal?.toJson(),
        "total": total?.toJson(),
        "is_payable": isPayable,
        "tax": tax,
        "tax_included": taxIncluded?.toJson(),
      };
}
