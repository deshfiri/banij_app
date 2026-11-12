import 'dart:convert';

class WholesaleCartModel {
  final bool? facilityAllowed;
  final WholesaleCartData? data;

  WholesaleCartModel({
    this.facilityAllowed,
    this.data,
  });

  factory WholesaleCartModel.fromRawJson(String str) => WholesaleCartModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WholesaleCartModel.fromJson(Map<String, dynamic> json) => WholesaleCartModel(
        facilityAllowed: json["facility_allowed"] as bool?,
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? WholesaleCartData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "facility_allowed": facilityAllowed,
        "data": data?.toJson(),
      };
}

class WholesaleCartData {
  final List<WholesaleCartLine>? lines;
  final WholesalePrice? subtotal;
  final int? lineCount;
  final bool? hasProblems;
  final bool? hasPriceChanges;
  final bool? readyForCheckout;

  WholesaleCartData({
    this.lines,
    this.subtotal,
    this.lineCount,
    this.hasProblems,
    this.hasPriceChanges,
    this.readyForCheckout,
  });

  factory WholesaleCartData.fromJson(Map<String, dynamic> json) => WholesaleCartData(
        lines: json["lines"] != null && json["lines"] is List
            ? List<WholesaleCartLine>.from((json["lines"] as List).map((x) => WholesaleCartLine.fromJson(x)))
            : null,
        subtotal: json["subtotal"] != null && json["subtotal"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["subtotal"])
            : null,
        lineCount: json["line_count"] as int?,
        hasProblems: json["has_problems"] as bool?,
        hasPriceChanges: json["has_price_changes"] as bool?,
        readyForCheckout: json["ready_for_checkout"] as bool?,
      );

  Map<String, dynamic> toJson() => {
        "lines": lines != null ? List<dynamic>.from(lines!.map((x) => x.toJson())) : null,
        "subtotal": subtotal?.toJson(),
        "line_count": lineCount,
        "has_problems": hasProblems,
        "has_price_changes": hasPriceChanges,
        "ready_for_checkout": readyForCheckout,
      };
}

class WholesaleCartLine {
  final String? id;
  final WholesaleCartProduct? product;
  final WholesaleCartVariant? variant;
  final int? quantity;
  final int? minOrderQuantity;
  final int? maxOrderQuantity;
  final int? available;
  final WholesalePrice? unitPrice;
  final WholesalePrice? basePrice;
  final WholesalePrice? lineTotal;
  final WholesalePrice? unitPriceSeen;
  final bool? priceChanged;
  final List<String>? problems;
  final bool? purchasable;

  WholesaleCartLine({
    this.id,
    this.product,
    this.variant,
    this.quantity,
    this.minOrderQuantity,
    this.maxOrderQuantity,
    this.available,
    this.unitPrice,
    this.basePrice,
    this.lineTotal,
    this.unitPriceSeen,
    this.priceChanged,
    this.problems,
    this.purchasable,
  });

  factory WholesaleCartLine.fromJson(Map<String, dynamic> json) => WholesaleCartLine(
        id: json["id"]?.toString(),
        product: json["product"] != null && json["product"] is Map<String, dynamic>
            ? WholesaleCartProduct.fromJson(json["product"])
            : null,
        variant: json["variant"] != null && json["variant"] is Map<String, dynamic>
            ? WholesaleCartVariant.fromJson(json["variant"])
            : null,
        quantity: json["quantity"] as int?,
        minOrderQuantity: json["min_order_quantity"] as int?,
        maxOrderQuantity: json["max_order_quantity"] as int?,
        available: json["available"] as int?,
        unitPrice: json["unit_price"] != null && json["unit_price"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["unit_price"])
            : null,
        basePrice: json["base_price"] != null && json["base_price"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["base_price"])
            : null,
        lineTotal: json["line_total"] != null && json["line_total"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["line_total"])
            : null,
        unitPriceSeen: json["unit_price_seen"] != null && json["unit_price_seen"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["unit_price_seen"])
            : null,
        priceChanged: json["price_changed"] as bool?,
        problems: json["problems"] != null && json["problems"] is List
            ? List<String>.from((json["problems"] as List).map((x) => x.toString()))
            : null,
        purchasable: json["purchasable"] as bool?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product": product?.toJson(),
        "variant": variant?.toJson(),
        "quantity": quantity,
        "min_order_quantity": minOrderQuantity,
        "max_order_quantity": maxOrderQuantity,
        "available": available,
        "unit_price": unitPrice?.toJson(),
        "base_price": basePrice?.toJson(),
        "line_total": lineTotal?.toJson(),
        "unit_price_seen": unitPriceSeen?.toJson(),
        "price_changed": priceChanged,
        "problems": problems,
        "purchasable": purchasable,
      };
}

class WholesaleCartProduct {
  final String? slug;
  final String? name;
  final String? sku;
  final WholesaleCartImage? image;

  WholesaleCartProduct({
    this.slug,
    this.name,
    this.sku,
    this.image,
  });

  factory WholesaleCartProduct.fromJson(Map<String, dynamic> json) => WholesaleCartProduct(
        slug: json["slug"]?.toString(),
        name: json["name"]?.toString(),
        sku: json["sku"]?.toString(),
        image: json["image"] != null && json["image"] is Map<String, dynamic>
            ? WholesaleCartImage.fromJson(json["image"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
        "sku": sku,
        "image": image?.toJson(),
      };
}

class WholesaleCartVariant {
  final String? sku;
  final String? label;

  WholesaleCartVariant({
    this.sku,
    this.label,
  });

  factory WholesaleCartVariant.fromJson(Map<String, dynamic> json) => WholesaleCartVariant(
        sku: json["sku"]?.toString(),
        label: json["label"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "sku": sku,
        "label": label,
      };
}

class WholesaleCartImage {
  final String? url;
  final String? alt;

  WholesaleCartImage({
    this.url,
    this.alt,
  });

  factory WholesaleCartImage.fromJson(Map<String, dynamic> json) => WholesaleCartImage(
        url: json["url"]?.toString(),
        alt: json["alt"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "alt": alt,
      };
}

class WholesalePrice {
  final String? amount;
  final String? currency;
  final String? formatted;

  WholesalePrice({
    this.amount,
    this.currency,
    this.formatted,
  });

  factory WholesalePrice.fromJson(Map<String, dynamic> json) => WholesalePrice(
        amount: json["amount"]?.toString(),
        currency: json["currency"]?.toString(),
        formatted: json["formatted"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "currency": currency,
        "formatted": formatted,
      };
}
