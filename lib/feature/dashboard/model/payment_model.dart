import 'dart:convert';

class PaymentMethodResponseModel {
  final List<PaymentMethodModel>? data;
  final List<PaymentTypeModel>? types;
  final bool? success;
  final String? message;

  PaymentMethodResponseModel({
    this.data,
    this.types,
    this.success,
    this.message,
  });

  factory PaymentMethodResponseModel.fromRawJson(String str) =>
      PaymentMethodResponseModel.fromJson(json.decode(str));

  factory PaymentMethodResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is String) {
      return PaymentMethodResponseModel.fromRawJson(jsonInput);
    }
    if (jsonInput is! Map<String, dynamic>) {
      return PaymentMethodResponseModel(data: [], types: []);
    }

    final rawData = jsonInput['data'];
    List<PaymentMethodModel> items = [];
    if (rawData is List) {
      items = rawData.map((x) => PaymentMethodModel.fromJson(x)).toList();
    }

    final rawTypes = jsonInput['types'];
    List<PaymentTypeModel> typeItems = [];
    if (rawTypes is List) {
      typeItems = rawTypes.map((x) => PaymentTypeModel.fromJson(x)).toList();
    }

    return PaymentMethodResponseModel(
      success: jsonInput['success'] is bool ? jsonInput['success'] : true,
      message: jsonInput['message']?.toString(),
      data: items,
      types: typeItems,
    );
  }
}

class PaymentTypeModel {
  final String? value;
  final String? label;
  final List<String>? fields;

  PaymentTypeModel({this.value, this.label, this.fields});

  factory PaymentTypeModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return PaymentTypeModel();
    final rawFields = json['fields'];
    List<String> fList = [];
    if (rawFields is List) {
      fList = rawFields.map((e) => e.toString()).toList();
    }
    return PaymentTypeModel(
      value: json['value']?.toString(),
      label: json['label']?.toString(),
      fields: fList,
    );
  }
}

class PaymentMethodModel {
  final String? id;
  final String? name;
  final String? code;
  final String? description;
  final String? icon;

  PaymentMethodModel({
    this.id,
    this.name,
    this.code,
    this.description,
    this.icon,
  });

  factory PaymentMethodModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return PaymentMethodModel();
    return PaymentMethodModel(
      id: json['id']?.toString() ?? json['code']?.toString(),
      name: json['name']?.toString() ?? json['title']?.toString() ?? json['label']?.toString(),
      code: json['code']?.toString(),
      description: json['description']?.toString() ?? json['subtitle']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}
