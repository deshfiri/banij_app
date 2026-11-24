import 'dart:convert';

class MyProductResponseModel {
  final List<ProductItemModel>? data;
  final ProductOptionsModel? options;
  final bool? facilityAllowed;
  final bool? success;
  final String? message;

  MyProductResponseModel({
    this.data,
    this.options,
    this.facilityAllowed,
    this.success,
    this.message,
  });

  factory MyProductResponseModel.fromRawJson(String str) =>
      MyProductResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyProductResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is Map<String, dynamic>) {
      final rawData = jsonInput["data"];
      final optionsModel =
          jsonInput["options"] != null &&
              jsonInput["options"] is Map<String, dynamic>
          ? ProductOptionsModel.fromJson(jsonInput["options"])
          : null;

      List<ProductItemModel> items = [];

      if (rawData is List && rawData.isNotEmpty) {
        items = List<ProductItemModel>.from(
          rawData.map((x) => ProductItemModel.fromJson(x)),
        );
      }

      return MyProductResponseModel(
        data: items,
        options: optionsModel,
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
    "data": data != null
        ? List<dynamic>.from(data!.map((x) => x.toJson()))
        : [],
    "options": options?.toJson(),
    "facility_allowed": facilityAllowed,
    if (success != null) "success": success,
    if (message != null) "message": message,
  };
}

class ProductOptionsModel {
  final List<CategoryOptionModel>? categories;
  final List<CategoryOptionModel>? brands;

  ProductOptionsModel({this.categories, this.brands});

  factory ProductOptionsModel.fromJson(Map<String, dynamic> json) =>
      ProductOptionsModel(
        categories: json["categories"] is List
            ? List<CategoryOptionModel>.from(
                json["categories"].map((x) => CategoryOptionModel.fromJson(x)),
              )
            : [],
        brands: json["brands"] is List
            ? List<CategoryOptionModel>.from(
                json["brands"].map((x) => CategoryOptionModel.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
    "categories": categories != null
        ? List<dynamic>.from(categories!.map((x) => x.toJson()))
        : [],
    "brands": brands != null
        ? List<dynamic>.from(brands!.map((x) => x.toJson()))
        : [],
  };
}

class CategoryOptionModel {
  final String? value;
  final String? label;

  CategoryOptionModel({this.value, this.label});

  factory CategoryOptionModel.fromJson(Map<String, dynamic> json) =>
      CategoryOptionModel(
        value: json["value"]?.toString(),
        label: json["label"]?.toString(),
      );

  Map<String, dynamic> toJson() => {"value": value, "label": label};
}

class ProductItemModel {
  final String? slug;
  final String? name;
  final String? sku;
  final String? category;
  final String? brand;
  final String? shortDescription;
  final String? packageScope;
  final bool? isFeatured;
  final String? purchased;
  final String? ownership;
  final ProductOwnershipModel? ownershipDetails;
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
    this.shortDescription,
    this.packageScope,
    this.isFeatured,
    this.purchased,
    this.ownership,
    this.ownershipDetails,
    this.variantCount,
    this.image,
    this.wholesale,
    this.partnerSelling,
  });

  factory ProductItemModel.fromRawJson(String str) =>
      ProductItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    final ownershipMap = _asJsonMap(json["ownership"]);

    return ProductItemModel(
      slug: json["slug"] as String?,
      name: json["name"] as String?,
      sku: json["sku"] as String?,
      category: json["category"] as String?,
      brand: json["brand"] as String?,
      shortDescription:
          json["short_description"]?.toString() ??
          json["description"]?.toString(),
      packageScope: json["package_scope"]?.toString(),
      isFeatured: json["is_featured"] is bool ? json["is_featured"] : null,
      purchased: json["purchased"]?.toString(),
      ownership: json["ownership"] is String
          ? json["ownership"] as String
          : null,
      ownershipDetails: ownershipMap == null
          ? null
          : ProductOwnershipModel.fromJson(ownershipMap),
      variantCount: json["variant_count"] is int
          ? json["variant_count"]
          : int.tryParse(json["variant_count"]?.toString() ?? ''),
      image: json["image"] != null && json["image"] is Map<String, dynamic>
          ? ProductImageModel.fromJson(json["image"])
          : null,
      wholesale:
          json["wholesale"] != null && json["wholesale"] is Map<String, dynamic>
          ? WholesaleModel.fromJson(json["wholesale"])
          : null,
      partnerSelling:
          json["partner_selling"] != null &&
              json["partner_selling"] is Map<String, dynamic>
          ? PartnerSellingModel.fromJson(json["partner_selling"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "slug": slug,
    "name": name,
    "sku": sku,
    "category": category,
    "brand": brand,
    "short_description": shortDescription,
    "package_scope": packageScope,
    "is_featured": isFeatured,
    "purchased": purchased,
    "ownership": ownershipDetails?.toJson() ?? ownership,
    "variant_count": variantCount,
    "image": image?.toJson(),
    "wholesale": wholesale?.toJson(),
    "partner_selling": partnerSelling?.toJson(),
  };
}

class ProductOwnershipModel {
  final List<ProductOwnershipUnitModel> units;
  final ProductOwnershipTotalsModel? totals;
  final List<Map<String, dynamic>> storefronts;

  const ProductOwnershipModel({
    this.units = const [],
    this.totals,
    this.storefronts = const [],
  });

  factory ProductOwnershipModel.fromJson(Map<String, dynamic> json) {
    final rawUnits = json["units"];
    final rawStorefronts = json["storefronts"];
    final totals = _asJsonMap(json["totals"]);

    return ProductOwnershipModel(
      units: rawUnits is List
          ? rawUnits
                .map(_asJsonMap)
                .whereType<Map<String, dynamic>>()
                .map(ProductOwnershipUnitModel.fromJson)
                .toList()
          : const [],
      totals: totals == null
          ? null
          : ProductOwnershipTotalsModel.fromJson(totals),
      storefronts: rawStorefronts is List
          ? rawStorefronts
                .map(_asJsonMap)
                .whereType<Map<String, dynamic>>()
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    "units": units.map((unit) => unit.toJson()).toList(),
    "totals": totals?.toJson(),
    "storefronts": storefronts,
  };
}

class ProductOwnershipUnitModel {
  final String? sku;
  final Object? variant;
  final int? purchased;
  final int? available;
  final int? reserved;
  final int? sold;
  final int? unavailable;

  const ProductOwnershipUnitModel({
    this.sku,
    this.variant,
    this.purchased,
    this.available,
    this.reserved,
    this.sold,
    this.unavailable,
  });

  factory ProductOwnershipUnitModel.fromJson(Map<String, dynamic> json) =>
      ProductOwnershipUnitModel(
        sku: json["sku"]?.toString(),
        variant: json["variant"],
        purchased: _asInt(json["purchased"]),
        available: _asInt(json["available"]),
        reserved: _asInt(json["reserved"]),
        sold: _asInt(json["sold"]),
        unavailable: _asInt(json["unavailable"]),
      );

  Map<String, dynamic> toJson() => {
    "sku": sku,
    "variant": variant,
    "purchased": purchased,
    "available": available,
    "reserved": reserved,
    "sold": sold,
    "unavailable": unavailable,
  };
}

class ProductOwnershipTotalsModel {
  final int? purchased;
  final int? available;
  final int? reserved;
  final int? sold;
  final int? unavailable;

  const ProductOwnershipTotalsModel({
    this.purchased,
    this.available,
    this.reserved,
    this.sold,
    this.unavailable,
  });

  factory ProductOwnershipTotalsModel.fromJson(Map<String, dynamic> json) =>
      ProductOwnershipTotalsModel(
        purchased: _asInt(json["purchased"]),
        available: _asInt(json["available"]),
        reserved: _asInt(json["reserved"]),
        sold: _asInt(json["sold"]),
        unavailable: _asInt(json["unavailable"]),
      );

  Map<String, dynamic> toJson() => {
    "purchased": purchased,
    "available": available,
    "reserved": reserved,
    "sold": sold,
    "unavailable": unavailable,
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

  Map<String, dynamic> toJson() => {"url": url, "alt": alt};
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
        : int.tryParse(json["min_order_quantity"]?.toString() ?? ''),
    maxOrderQuantity: json["max_order_quantity"] is int
        ? json["max_order_quantity"]
        : int.tryParse(json["max_order_quantity"]?.toString() ?? ''),
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
        suggestedSellingPrice:
            json["suggested_selling_price"] != null &&
                json["suggested_selling_price"] is Map<String, dynamic>
            ? PriceModel.fromJson(json["suggested_selling_price"])
            : null,
        minimumSellingPrice:
            json["minimum_selling_price"] != null &&
                json["minimum_selling_price"] is Map<String, dynamic>
            ? PriceModel.fromJson(json["minimum_selling_price"])
            : null,
        maximumSellingPrice:
            json["maximum_selling_price"] != null &&
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

Map<String, dynamic>? _asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
