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
  final String? status;
  final dynamic total;
  final String? currency;
  final String? createdAt;

  OrderItemModel({
    this.id,
    this.orderNumber,
    this.status,
    this.total,
    this.currency,
    this.createdAt,
  });

  factory OrderItemModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return OrderItemModel();
    return OrderItemModel(
      id: json['id'],
      orderNumber: json['order_number']?.toString() ?? json['id']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      total: json['total'] ?? json['grand_total'] ?? '0.00',
      currency: json['currency']?.toString() ?? '৳',
      createdAt: json['created_at']?.toString() ?? json['placed_at']?.toString(),
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
