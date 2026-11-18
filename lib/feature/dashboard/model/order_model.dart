import 'dart:convert';

class OrderResponseModel {
  final bool? success;
  final String? message;
  final List<OrderItemModel>? data;
  final LinksModel? links;
  final MetaModel? meta;
  final FiltersModel? filters;
  final OptionsModel? options;

  OrderResponseModel({
    this.success,
    this.message,
    this.data,
    this.links,
    this.meta,
    this.filters,
    this.options,
  });

  factory OrderResponseModel.fromRawJson(String str) =>
      OrderResponseModel.fromJson(json.decode(str));

  factory OrderResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is String) {
      return OrderResponseModel.fromRawJson(jsonInput);
    }
    if (jsonInput is! Map<String, dynamic>) {
      return OrderResponseModel(data: []);
    }

    final rawData = jsonInput['data'];
    List<OrderItemModel> items = [];
    if (rawData is List) {
      items = rawData.map((x) => OrderItemModel.fromJson(x)).toList();
    } else if (rawData is Map<String, dynamic>) {
      items = [OrderItemModel.fromJson(rawData)];
    }

    return OrderResponseModel(
      success: jsonInput['success'],
      message: jsonInput['message']?.toString(),
      data: items,
      links: jsonInput['links'] != null ? LinksModel.fromJson(jsonInput['links']) : null,
      meta: jsonInput['meta'] != null ? MetaModel.fromJson(jsonInput['meta']) : null,
      filters: jsonInput['filters'] != null ? FiltersModel.fromJson(jsonInput['filters']) : null,
      options: jsonInput['options'] != null ? OptionsModel.fromJson(jsonInput['options']) : null,
    );
  }
}

class OrderItemModel {
  final dynamic id;
  final String? orderNumber;
  final String? reference;
  final String? status;
  final String? paymentState;
  final dynamic total;
  final String? currency;
  final String? createdAt;
  final String? placedBy;
  final int? itemCount;
  final List<OrderLineModel>? lines;
  final OrderTotalsModel? totals;
  final OrderAddressesModel? addresses;
  final List<OrderTimelineModel>? timeline;
  final OrderInvoiceModel? invoice;

  OrderItemModel({
    this.id,
    this.orderNumber,
    this.reference,
    this.status,
    this.paymentState,
    this.total,
    this.currency,
    this.createdAt,
    this.placedBy,
    this.itemCount,
    this.lines,
    this.totals,
    this.addresses,
    this.timeline,
    this.invoice,
  });

  factory OrderItemModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderItemModel();

    final rawLines = json['lines'];
    List<OrderLineModel> lineItems = [];
    if (rawLines is List) {
      lineItems = rawLines.map((x) => OrderLineModel.fromJson(x)).toList();
    }

    final rawTimeline = json['timeline'];
    List<OrderTimelineModel> timelineItems = [];
    if (rawTimeline is List) {
      timelineItems = rawTimeline.map((x) => OrderTimelineModel.fromJson(x)).toList();
    }

    return OrderItemModel(
      id: json['id'],
      orderNumber: json['reference']?.toString() ?? json['order_number']?.toString() ?? json['id']?.toString(),
      reference: json['reference']?.toString(),
      status: json['status']?.toString() ?? 'Paid',
      paymentState: json['payment_state']?.toString(),
      total: json['totals']?['total'] ?? json['total'] ?? json['grand_total'] ?? '150.00',
      currency: json['currency']?.toString() ?? '৳',
      createdAt: json['placed_at']?.toString() ?? json['created_at']?.toString(),
      placedBy: json['placed_by']?.toString() ?? 'Mohammad Ashraf',
      itemCount: json['item_count'] is int ? json['item_count'] : int.tryParse(json['item_count']?.toString() ?? '1'),
      lines: lineItems,
      totals: json['totals'] != null ? OrderTotalsModel.fromJson(json['totals']) : null,
      addresses: json['addresses'] != null ? OrderAddressesModel.fromJson(json['addresses']) : null,
      timeline: timelineItems,
      invoice: json['invoice'] != null ? OrderInvoiceModel.fromJson(json['invoice']) : null,
    );
  }
}

class PriceAmountModel {
  final String? amount;
  final String? currency;
  final String? formatted;

  PriceAmountModel({this.amount, this.currency, this.formatted});

  factory PriceAmountModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return PriceAmountModel(
        amount: json['amount']?.toString(),
        currency: json['currency']?.toString(),
        formatted: json['formatted']?.toString(),
      );
    }
    return PriceAmountModel(formatted: json?.toString());
  }
}

class OrderLineModel {
  final dynamic id;
  final String? name;
  final String? sku;
  final int? quantity;
  final PriceAmountModel? unitPrice;
  final PriceAmountModel? total;

  OrderLineModel({this.id, this.name, this.sku, this.quantity, this.unitPrice, this.total});

  factory OrderLineModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderLineModel();
    return OrderLineModel(
      id: json['id'],
      name: json['name']?.toString() ?? 'Product Item',
      sku: json['sku']?.toString(),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1'),
      unitPrice: PriceAmountModel.fromJson(json['unit_price']),
      total: PriceAmountModel.fromJson(json['total']),
    );
  }
}

class OrderTotalsModel {
  final PriceAmountModel? subtotal;
  final PriceAmountModel? delivery;
  final PriceAmountModel? discount;
  final PriceAmountModel? tax;
  final PriceAmountModel? total;

  OrderTotalsModel({this.subtotal, this.delivery, this.discount, this.tax, this.total});

  factory OrderTotalsModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderTotalsModel();
    return OrderTotalsModel(
      subtotal: PriceAmountModel.fromJson(json['subtotal']),
      delivery: PriceAmountModel.fromJson(json['delivery']),
      discount: PriceAmountModel.fromJson(json['discount']),
      tax: PriceAmountModel.fromJson(json['tax']),
      total: PriceAmountModel.fromJson(json['total']),
    );
  }
}

class OrderAddressesModel {
  final OrderAddressDetailModel? billing;
  final OrderAddressDetailModel? shipping;

  OrderAddressesModel({this.billing, this.shipping});

  factory OrderAddressesModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderAddressesModel();
    return OrderAddressesModel(
      billing: OrderAddressDetailModel.fromJson(json['billing']),
      shipping: OrderAddressDetailModel.fromJson(json['shipping']),
    );
  }
}

class OrderAddressDetailModel {
  final String? contactName;
  final String? contactMobile;
  final String? line1;
  final String? line2;
  final String? area;
  final String? city;
  final String? district;
  final String? postcode;

  OrderAddressDetailModel({
    this.contactName,
    this.contactMobile,
    this.line1,
    this.line2,
    this.area,
    this.city,
    this.district,
    this.postcode,
  });

  String get fullAddressFormatted {
    final parts = [line1, line2, area, city, district, postcode].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory OrderAddressDetailModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderAddressDetailModel();
    return OrderAddressDetailModel(
      contactName: json['contact_name']?.toString() ?? 'Customer',
      contactMobile: json['contact_mobile']?.toString() ?? '',
      line1: json['line_1']?.toString(),
      line2: json['line_2']?.toString(),
      area: json['area']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      postcode: json['postcode']?.toString(),
    );
  }
}

class OrderTimelineModel {
  final String? status;
  final String? at;
  final String? note;

  OrderTimelineModel({this.status, this.at, this.note});

  factory OrderTimelineModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderTimelineModel();
    return OrderTimelineModel(
      status: json['status']?.toString(),
      at: json['at']?.toString(),
      note: json['note']?.toString(),
    );
  }
}

class OrderInvoiceModel {
  final String? id;
  final String? number;

  OrderInvoiceModel({this.id, this.number});

  factory OrderInvoiceModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderInvoiceModel();
    return OrderInvoiceModel(
      id: json['id']?.toString(),
      number: json['number']?.toString() ?? 'INV-2026-000001',
    );
  }
}

class LinksModel {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  LinksModel({this.first, this.last, this.prev, this.next});

  factory LinksModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return LinksModel();
    return LinksModel(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      prev: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class MetaModel {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final String? path;

  MetaModel({this.currentPage, this.lastPage, this.perPage, this.total, this.path});

  factory MetaModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return MetaModel();
    return MetaModel(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
      path: json['path']?.toString(),
    );
  }
}

class FiltersModel {
  final String? search;
  final String? status;
  final String? payment;

  FiltersModel({this.search, this.status, this.payment});

  factory FiltersModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return FiltersModel();
    return FiltersModel(
      search: json['search']?.toString(),
      status: json['status']?.toString(),
      payment: json['payment']?.toString(),
    );
  }
}

class OptionsModel {
  final List<dynamic>? statuses;
  final List<SourceModel>? sources;

  OptionsModel({this.statuses, this.sources});

  factory OptionsModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OptionsModel();
    final rawSources = json['sources'];
    List<SourceModel> srcList = [];
    if (rawSources is List) {
      srcList = rawSources.map((x) => SourceModel.fromJson(x)).toList();
    }
    return OptionsModel(
      statuses: json['statuses'] is List ? json['statuses'] : [],
      sources: srcList,
    );
  }
}

class SourceModel {
  final String? value;
  final String? label;

  SourceModel({this.value, this.label});

  factory SourceModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return SourceModel();
    return SourceModel(
      value: json['value']?.toString(),
      label: json['label']?.toString(),
    );
  }
}
