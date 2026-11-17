import 'dart:convert';

class CatalogResponseModel {
  final List<CatalogProductData>? data;
  final bool? facilityAllowed;
  final CatalogCanOptions? can;
  final CatalogOptions? options;

  CatalogResponseModel({
    this.data,
    this.facilityAllowed,
    this.can,
    this.options,
  });

  factory CatalogResponseModel.fromRawJson(String str) =>
      CatalogResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CatalogResponseModel.fromJson(Map<String, dynamic> json) =>
      CatalogResponseModel(
        data: json["data"] == null || json["data"] is! List
            ? []
            : List<CatalogProductData>.from(
                json["data"].map((x) => CatalogProductData.fromJson(x))),
        facilityAllowed: json["facility_allowed"] is bool ? json["facility_allowed"] : null,
        can: json["can"] == null || json["can"] is! Map<String, dynamic> ? null : CatalogCanOptions.fromJson(json["can"]),
        options:
            json["options"] == null || json["options"] is! Map<String, dynamic> ? null : CatalogOptions.fromJson(json["options"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "facility_allowed": facilityAllowed,
        "can": can?.toJson(),
        "options": options?.toJson(),
      };
}

class CatalogProductData {
  final String? slug;
  final String? name;
  final String? sku;
  final String? category;
  final String? brand;
  final bool? isFeatured;
  final String? purchased;
  final String? ownership;
  final int? variantCount;
  final String? packageScope;
  final ProductImageInfo? image;
  final ProductModes? modes;
  final WholesaleInfo? wholesale;
  final PartnerSellingInfo? partnerSelling;

  CatalogProductData({
    this.slug,
    this.name,
    this.sku,
    this.category,
    this.brand,
    this.isFeatured,
    this.purchased,
    this.ownership,
    this.variantCount,
    this.packageScope,
    this.image,
    this.modes,
    this.wholesale,
    this.partnerSelling,
  });

  factory CatalogProductData.fromJson(Map<String, dynamic> json) =>
      CatalogProductData(
        slug: json["slug"]?.toString(),
        name: json["name"]?.toString(),
        sku: json["sku"]?.toString(),
        category: json["category"]?.toString(),
        brand: json["brand"]?.toString(),
        isFeatured: json["is_featured"] is bool ? json["is_featured"] : null,
        purchased: json["purchased"]?.toString(),
        ownership: json["ownership"]?.toString(),
        variantCount: json["variant_count"] is int
            ? json["variant_count"]
            : int.tryParse(json["variant_count"]?.toString() ?? ''),
        packageScope: json["package_scope"]?.toString(),
        image: json["image"] == null || json["image"] is! Map<String, dynamic>
            ? null
            : ProductImageInfo.fromJson(json["image"]),
        modes: json["modes"] == null || json["modes"] is! Map<String, dynamic>
            ? null
            : ProductModes.fromJson(json["modes"]),
        wholesale: json["wholesale"] == null || json["wholesale"] is! Map<String, dynamic>
            ? null
            : WholesaleInfo.fromJson(json["wholesale"]),
        partnerSelling: json["partner_selling"] == null || json["partner_selling"] is! Map<String, dynamic>
            ? null
            : PartnerSellingInfo.fromJson(json["partner_selling"]),
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
        "package_scope": packageScope,
        "image": image?.toJson(),
        "modes": modes?.toJson(),
        "wholesale": wholesale?.toJson(),
        "partner_selling": partnerSelling?.toJson(),
      };
}

class ProductImageInfo {
  final String? url;
  final String? alt;

  ProductImageInfo({this.url, this.alt});

  factory ProductImageInfo.fromJson(Map<String, dynamic> json) =>
      ProductImageInfo(
        url: json["url"]?.toString(),
        alt: json["alt"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "alt": alt,
      };
}

class ProductModes {
  final String? wholesale;
  final String? partnerSelling;

  ProductModes({this.wholesale, this.partnerSelling});

  factory ProductModes.fromJson(Map<String, dynamic> json) => ProductModes(
        wholesale: json["wholesale"]?.toString(),
        partnerSelling: json["partner_selling"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "wholesale": wholesale,
        "partner_selling": partnerSelling,
      };
}

class WholesaleInfo {
  final PriceAmountInfo? price;
  final int? minOrderQuantity;
  final int? maxOrderQuantity;
  final String? inStock;
  final List<String>? tiers;

  WholesaleInfo({
    this.price,
    this.minOrderQuantity,
    this.maxOrderQuantity,
    this.inStock,
    this.tiers,
  });

  factory WholesaleInfo.fromJson(Map<String, dynamic> json) => WholesaleInfo(
        price: json["price"] == null || json["price"] is! Map<String, dynamic>
            ? null
            : PriceAmountInfo.fromJson(json["price"]),
        minOrderQuantity: json["min_order_quantity"] is int
            ? json["min_order_quantity"]
            : int.tryParse(json["min_order_quantity"]?.toString() ?? '1'),
        maxOrderQuantity: json["max_order_quantity"] is int
            ? json["max_order_quantity"]
            : int.tryParse(json["max_order_quantity"]?.toString() ?? ''),
        inStock: json["in_stock"]?.toString(),
        tiers: json["tiers"] == null || json["tiers"] is! List
            ? []
            : List<String>.from(json["tiers"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "price": price?.toJson(),
        "min_order_quantity": minOrderQuantity,
        "max_order_quantity": maxOrderQuantity,
        "in_stock": inStock,
        "tiers": tiers == null ? [] : List<dynamic>.from(tiers!.map((x) => x)),
      };
}

class PartnerSellingInfo {
  final PriceAmountInfo? suggestedSellingPrice;
  final PriceAmountInfo? minimumSellingPrice;
  final PriceAmountInfo? maximumSellingPrice;

  PartnerSellingInfo({
    this.suggestedSellingPrice,
    this.minimumSellingPrice,
    this.maximumSellingPrice,
  });

  factory PartnerSellingInfo.fromJson(Map<String, dynamic> json) =>
      PartnerSellingInfo(
        suggestedSellingPrice: json["suggested_selling_price"] == null || json["suggested_selling_price"] is! Map<String, dynamic>
            ? null
            : PriceAmountInfo.fromJson(json["suggested_selling_price"]),
        minimumSellingPrice: json["minimum_selling_price"] == null || json["minimum_selling_price"] is! Map<String, dynamic>
            ? null
            : PriceAmountInfo.fromJson(json["minimum_selling_price"]),
        maximumSellingPrice: json["maximum_selling_price"] == null || json["maximum_selling_price"] is! Map<String, dynamic>
            ? null
            : PriceAmountInfo.fromJson(json["maximum_selling_price"]),
      );

  Map<String, dynamic> toJson() => {
        "suggested_selling_price": suggestedSellingPrice?.toJson(),
        "minimum_selling_price": minimumSellingPrice?.toJson(),
        "maximum_selling_price": maximumSellingPrice?.toJson(),
      };
}

class PriceAmountInfo {
  final String? amount;
  final String? currency;
  final String? formatted;

  PriceAmountInfo({this.amount, this.currency, this.formatted});

  factory PriceAmountInfo.fromJson(Map<String, dynamic> json) => PriceAmountInfo(
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

class CatalogCanOptions {
  final bool? wholesale;
  final bool? filterWholesale;

  CatalogCanOptions({this.wholesale, this.filterWholesale});

  factory CatalogCanOptions.fromJson(Map<String, dynamic> json) => CatalogCanOptions(
        wholesale: json["wholesale"] is bool ? json["wholesale"] : null,
        filterWholesale: json["filter_wholesale"] is bool ? json["filter_wholesale"] : null,
      );

  Map<String, dynamic> toJson() => {
        "wholesale": wholesale,
        "filter_wholesale": filterWholesale,
      };
}

class CatalogOptions {
  final List<CatalogOptionItem>? categories;
  final List<CatalogOptionItem>? brands;

  CatalogOptions({this.categories, this.brands});

  factory CatalogOptions.fromJson(Map<String, dynamic> json) => CatalogOptions(
        categories: json["categories"] == null || json["categories"] is! List
            ? []
            : List<CatalogOptionItem>.from(
                json["categories"].map((x) => CatalogOptionItem.fromJson(x))),
        brands: json["brands"] == null || json["brands"] is! List
            ? []
            : List<CatalogOptionItem>.from(
                json["brands"].map((x) => CatalogOptionItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "brands": brands == null
            ? []
            : List<dynamic>.from(brands!.map((x) => x.toJson())),
      };
}

class CatalogOptionItem {
  final String? value;
  final String? label;

  CatalogOptionItem({this.value, this.label});

  factory CatalogOptionItem.fromJson(Map<String, dynamic> json) => CatalogOptionItem(
        value: json["value"]?.toString(),
        label: json["label"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "label": label,
      };
}
