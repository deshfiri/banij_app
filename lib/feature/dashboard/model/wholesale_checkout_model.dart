import 'dart:convert';

import 'address_model.dart';
import 'checkout_response_model.dart' show CheckoutGateway;
import 'wholesale_cart_model.dart';

class WholesaleCheckoutResponseModel {
  final WholesaleCheckoutDataModel? data;
  final bool? success;
  final String? message;

  /// Quote fingerprint at the top level (some responses put it next to `data`).
  final String? rootFingerprint;

  /// Payment methods at the top level.
  final List<CheckoutGateway> rootPaymentMethods;

  /// Gateway page (e.g. SSLCommerz) returned by the order confirmation when
  /// the order must be paid online.
  final String? redirectUrl;

  WholesaleCheckoutResponseModel({
    this.data,
    this.success,
    this.message,
    this.rootFingerprint,
    this.rootPaymentMethods = const [],
    this.redirectUrl,
  });

  /// Fingerprint of the quote being confirmed — required by
  /// `POST /wholesale/checkout/confirmation` so a changed cart is rejected.
  String? get fingerprint => data?.fingerprint ?? rootFingerprint;

  /// Payment methods the wholesale checkout accepts (`payment_method` values).
  List<CheckoutGateway> get paymentMethods =>
      (data?.paymentMethods.isNotEmpty ?? false) ? data!.paymentMethods : rootPaymentMethods;

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
      rootFingerprint: _fingerprintFrom(json),
      rootPaymentMethods: CheckoutGateway.listFrom(_paymentMethodsFrom(json)),
      redirectUrl: _redirectUrlFrom(json),
    );
  }

  /// `redirect_url` / `payment_url` at the top level, in `data`, in
  /// `payment` or in `order.payment`.
  static String? _redirectUrlFrom(Map<String, dynamic> json) {
    final data = json["data"] is Map ? json["data"] as Map : const {};
    final order = (data["order"] ?? json["order"]) is Map ? (data["order"] ?? json["order"]) as Map : const {};
    final payment = (data["payment"] ?? json["payment"] ?? order["payment"]) is Map
        ? (data["payment"] ?? json["payment"] ?? order["payment"]) as Map
        : const {};
    for (final source in [json, data, payment, order]) {
      for (final key in const ["redirect_url", "payment_url", "gateway_url", "url"]) {
        final value = source[key]?.toString().trim();
        if (value != null && value.startsWith('http')) return value;
      }
    }
    return null;
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

  /// Fingerprint of this quote (sent back when confirming).
  final String? fingerprint;

  /// Accepted payment methods (sent back as `payment_method`).
  final List<CheckoutGateway> paymentMethods;

  WholesaleCheckoutDataModel({
    this.fingerprint,
    this.paymentMethods = const [],
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
        fingerprint: _fingerprintFrom(json),
        paymentMethods: CheckoutGateway.listFrom(_paymentMethodsFrom(json)),
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
        "fingerprint": fingerprint,
        "lines": lines != null ? List<dynamic>.from(lines!.map((x) => x.toJson())) : [],
      };
}

/// Fingerprint from `fingerprint`, `quote_fingerprint` or `quote.fingerprint`.
String? _fingerprintFrom(Map<String, dynamic> json) {
  final quote = json["quote"];
  final value = json["fingerprint"] ??
      json["quote_fingerprint"] ??
      json["checkout_fingerprint"] ??
      (quote is Map ? quote["fingerprint"] : null);
  final text = value?.toString().trim();
  return text == null || text.isEmpty || text == 'null' ? null : text;
}

/// Payment-method list under the usual keys.
dynamic _paymentMethodsFrom(Map<String, dynamic> json) =>
    json["payment_methods"] ?? json["payment_options"] ?? json["methods"] ?? json["gateways"];
