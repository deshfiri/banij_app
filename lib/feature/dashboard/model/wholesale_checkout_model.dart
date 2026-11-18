import 'dart:convert';

import 'address_model.dart';
import 'wholesale_cart_model.dart';

class WholesaleCheckoutResponseModel {
  final WholesaleCheckoutDataModel? data;
  final bool? success;
  final String? message;

  WholesaleCheckoutResponseModel({
    this.data,
    this.success,
    this.message,
  });

  factory WholesaleCheckoutResponseModel.fromRawJson(String str) =>
      WholesaleCheckoutResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WholesaleCheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    WholesaleCheckoutDataModel? dataModel;
    if (json["data"] != null && json["data"] is Map<String, dynamic>) {
      dataModel = WholesaleCheckoutDataModel.fromJson(json["data"]);
    } else if (json.containsKey("lines")) {
      dataModel = WholesaleCheckoutDataModel.fromJson(json);
    }

    return WholesaleCheckoutResponseModel(
      data: dataModel,
      success: json["success"] is bool ? json["success"] : true,
      message: json["message"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "success": success,
        "message": message,
      };
}

class WholesaleCheckoutDataModel {
  final WholesalePrice? subtotal;
  final WholesalePrice? shipping;
  final WholesalePrice? discount;
  final WholesalePrice? tax;
  final WholesalePrice? total;
  final AddressItemModel? shippingAddress;
  final AddressItemModel? billingAddress;
  final String? appliedCoupon;
  final bool? isConfirmed;
  final List<WholesaleCartLine>? lines;

  WholesaleCheckoutDataModel({
    this.subtotal,
    this.shipping,
    this.discount,
    this.tax,
    this.total,
    this.shippingAddress,
    this.billingAddress,
    this.appliedCoupon,
    this.isConfirmed,
    this.lines,
  });

  factory WholesaleCheckoutDataModel.fromJson(Map<String, dynamic> json) =>
      WholesaleCheckoutDataModel(
        subtotal: json["subtotal"] != null && json["subtotal"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["subtotal"])
            : null,
        shipping: json["shipping"] != null && json["shipping"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["shipping"])
            : null,
        discount: json["discount"] != null && json["discount"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["discount"])
            : null,
        tax: json["tax"] != null && json["tax"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["tax"])
            : null,
        total: json["total"] != null && json["total"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["total"])
            : null,
        shippingAddress: json["shipping_address"] != null &&
                json["shipping_address"] is Map<String, dynamic>
            ? AddressItemModel.fromJson(json["shipping_address"])
            : null,
        billingAddress: json["billing_address"] != null &&
                json["billing_address"] is Map<String, dynamic>
            ? AddressItemModel.fromJson(json["billing_address"])
            : null,
        appliedCoupon: json["applied_coupon"]?.toString() ?? json["coupon"]?.toString(),
        isConfirmed: json["is_confirmed"] is bool ? json["is_confirmed"] : null,
        lines: json["lines"] is List
            ? List<WholesaleCartLine>.from(
                json["lines"].map((x) => WholesaleCartLine.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "subtotal": subtotal?.toJson(),
        "shipping": shipping?.toJson(),
        "discount": discount?.toJson(),
        "tax": tax?.toJson(),
        "total": total?.toJson(),
        "shipping_address": shippingAddress?.id,
        "billing_address": billingAddress?.id,
        "applied_coupon": appliedCoupon,
        "is_confirmed": isConfirmed,
        "lines": lines != null ? List<dynamic>.from(lines!.map((x) => x.toJson())) : [],
      };
}
