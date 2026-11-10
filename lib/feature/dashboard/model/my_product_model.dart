import 'dart:convert';

class MyProductResponseModel {
  final List<ProductItemModel>? data;
  final bool? facilityAllowed;
  final bool? success;
  final String? message;

  MyProductResponseModel({
    this.data,
    this.facilityAllowed,
    this.success,
    this.message,
  });

  factory MyProductResponseModel.fromRawJson(String str) =>
      MyProductResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyProductResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is Map<String, dynamic>) {
      final dataList = jsonInput["data"] ?? [];
      return MyProductResponseModel(
        data: dataList is List
            ? List<ProductItemModel>.from(
                dataList.map((x) => ProductItemModel.fromJson(x)))
            : [],
        facilityAllowed: jsonInput["facility_allowed"] is bool
            ? jsonInput["facility_allowed"]
            : null,
        success: jsonInput["success"] is bool ? jsonInput["success"] : true,
        message: jsonInput["message"] as String?,
      );
    }
    return MyProductResponseModel(data: []);
  }

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : [],
        "facility_allowed": facilityAllowed,
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class ProductItemModel {
  final String? slug;
  final String? name;
  final String? sku;
  final String? category;
  final String? brand;
  final bool? isFeatured;
  final String? purchased;
  final String? ownership;
  final int? variantCount;
  final ProductImageModel? image;
  final WholesaleModel? wholesale;
  final PartnerSellingModel? partnerSelling;

  ProductItemModel({
    this.slug,
    this.name,
    this.sku,
    this.category,
    this.brand,
    this.isFeatured,
    this.purchased,
    this.ownership,
    this.variantCount,
    this.image,
    this.wholesale,
    this.partnerSelling,
  });

  factory ProductItemModel.fromRawJson(String str) =>
      ProductItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductItemModel.fromJson(Map<String, dynamic> json) =>
      ProductItemModel(
        slug: json["slug"] as String?,
        name: json["name"] as String?,
        sku: json["sku"] as String?,
        category: json["category"] as String?,
        brand: json["brand"] as String?,
        isFeatured: json["is_featured"] is bool ? json["is_featured"] : null,
        purchased: json["purchased"]?.toString(),
        ownership: json["ownership"] as String?,
        variantCount: json["variant_count"] is int ? json["variant_count"] : null,
        image: json["image"] != null && json["image"] is Map<String, dynamic>
            ? ProductImageModel.fromJson(json["image"])
            : null,
        wholesale: json["wholesale"] != null && json["wholesale"] is Map<String, dynamic>
            ? WholesaleModel.fromJson(json["wholesale"])
            : null,
        partnerSelling: json["partner_selling"] != null &&
                json["partner_selling"] is Map<String, dynamic>
            ? PartnerSellingModel.fromJson(json["partner_selling"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
        "sku": sku,
        "category": category,
        "brand": brand,
        "is_featured": isFeatured,
        "purchased": purchased,
        "ownership": ownership,
        "variant_count": variantCount,
        "image": image?.toJson(),
        "wholesale": wholesale?.toJson(),
        "partner_selling": partnerSelling?.toJson(),
      };
}

class ProductImageModel {
  final String? url;
  final String? alt;

  ProductImageModel({this.url, this.alt});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      ProductImageModel(
        url: json["url"] as String?,
        alt: json["alt"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "alt": alt,
      };
}

class WholesaleModel {
  final PriceModel? price;
  final int? minOrderQuantity;
  final int? maxOrderQuantity;
  final String? inStock;

  WholesaleModel({
    this.price,
    this.minOrderQuantity,
    this.maxOrderQuantity,
    this.inStock,
  });

  factory WholesaleModel.fromJson(Map<String, dynamic> json) => WholesaleModel(
        price: json["price"] != null && json["price"] is Map<String, dynamic>
            ? PriceModel.fromJson(json["price"])
            : null,
        minOrderQuantity: json["min_order_quantity"] is int
            ? json["min_order_quantity"]
            : null,
        maxOrderQuantity: json["max_order_quantity"] is int
            ? json["max_order_quantity"]
            : null,
        inStock: json["in_stock"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "price": price?.toJson(),
        "min_order_quantity": minOrderQuantity,
        "max_order_quantity": maxOrderQuantity,
        "in_stock": inStock,
      };
}

class PartnerSellingModel {
  final PriceModel? suggestedSellingPrice;
  final PriceModel? minimumSellingPrice;
  final PriceModel? maximumSellingPrice;

  PartnerSellingModel({
    this.suggestedSellingPrice,
    this.minimumSellingPrice,
    this.maximumSellingPrice,
  });

  factory PartnerSellingModel.fromJson(Map<String, dynamic> json) =>
      PartnerSellingModel(
        suggestedSellingPrice: json["suggested_selling_price"] != null &&
                json["suggested_selling_price"] is Map<String, dynamic>
            ? PriceModel.fromJson(json["suggested_selling_price"])
            : null,
        minimumSellingPrice: json["minimum_selling_price"] != null &&
                json["minimum_selling_price"] is Map<String, dynamic>
            ? PriceModel.fromJson(json["minimum_selling_price"])
            : null,
        maximumSellingPrice: json["maximum_selling_price"] != null &&
                json["maximum_selling_price"] is Map<String, dynamic>
            ? PriceModel.fromJson(json["maximum_selling_price"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "suggested_selling_price": suggestedSellingPrice?.toJson(),
        "minimum_selling_price": minimumSellingPrice?.toJson(),
        "maximum_selling_price": maximumSellingPrice?.toJson(),
      };
}

class PriceModel {
  final String? amount;
  final String? currency;
  final String? formatted;

  PriceModel({this.amount, this.currency, this.formatted});

  factory PriceModel.fromJson(Map<String, dynamic> json) => PriceModel(
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
