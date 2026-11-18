import 'dart:convert';

class PaymentMethodResponseModel {
  final List<PaymentMethodModel>? data;
  final List<PaymentTypeModel>? types;
  final PaymentCanModel? can;
  final bool? success;
  final String? message;

  PaymentMethodResponseModel({
    this.data,
    this.types,
    this.can,
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

    final rawCan = jsonInput['can'];
    PaymentCanModel? canModel;
    if (rawCan is Map<String, dynamic>) {
      canModel = PaymentCanModel.fromJson(rawCan);
    }

    return PaymentMethodResponseModel(
      success: jsonInput['success'] is bool ? jsonInput['success'] : true,
      message: jsonInput['message']?.toString(),
      data: items,
      types: typeItems,
      can: canModel,
    );
  }
}

class PaymentCanModel {
  final bool? create;

  PaymentCanModel({this.create});

  factory PaymentCanModel.fromJson(Map<String, dynamic> json) => PaymentCanModel(
        create: json['create'] is bool ? json['create'] : true,
      );
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
  final String? type;
  final String? typeLabel;
  final String? label;
  final String? maskedNumber;
  final String? bankName;
  final String? branchName;
  final bool? isDefault;
  final bool? isActive;
  final String? statusLabel;
  final String? verifiedAt;
  final String? createdAt;
  final String? name;
  final String? code;
  final String? description;

  PaymentMethodModel({
    this.id,
    this.type,
    this.typeLabel,
    this.label,
    this.maskedNumber,
    this.bankName,
    this.branchName,
    this.isDefault,
    this.isActive,
    this.statusLabel,
    this.verifiedAt,
    this.createdAt,
    this.name,
    this.code,
    this.description,
  });

  factory PaymentMethodModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return PaymentMethodModel();
    final typeLabelStr = json['type_label']?.toString() ?? json['name']?.toString() ?? json['label']?.toString() ?? 'Payment Method';
    final labelStr = json['label']?.toString();
    final maskedStr = json['masked_number']?.toString();
    final descStr = json['description']?.toString() ??
        (maskedStr != null ? '$maskedStr (${json['status_label'] ?? ''})' : labelStr);

    return PaymentMethodModel(
      id: json['id']?.toString() ?? json['code']?.toString(),
      type: json['type']?.toString(),
      typeLabel: typeLabelStr,
      label: labelStr,
      maskedNumber: maskedStr,
      bankName: json['bank_name']?.toString(),
      branchName: json['branch_name']?.toString(),
      isDefault: json['is_default'] is bool ? json['is_default'] : null,
      isActive: json['is_active'] is bool ? json['is_active'] : null,
      statusLabel: json['status_label']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      name: typeLabelStr,
      code: json['code']?.toString() ?? json['type']?.toString() ?? json['id']?.toString(),
      description: descStr,
    );
  }
}
