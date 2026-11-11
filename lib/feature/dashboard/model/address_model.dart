import 'dart:convert';

class AddressResponseModel {
  final List<AddressItemModel>? data;
  final bool? success;
  final String? message;

  AddressResponseModel({
    this.data,
    this.success,
    this.message,
  });

  factory AddressResponseModel.fromRawJson(String str) =>
      AddressResponseModel.fromJson(json.decode(str));

  factory AddressResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is String) {
      return AddressResponseModel.fromRawJson(jsonInput);
    }
    if (jsonInput is! Map<String, dynamic>) {
      return AddressResponseModel(data: []);
    }

    final rawData = jsonInput['data'];
    List<AddressItemModel> items = [];
    if (rawData is List) {
      items = rawData.map((x) => AddressItemModel.fromJson(x)).toList();
    }

    return AddressResponseModel(
      success: jsonInput['success'] is bool ? jsonInput['success'] : true,
      message: jsonInput['message']?.toString(),
      data: items,
    );
  }
}

class AddressItemModel {
  final dynamic id;
  final String? name;
  final String? recipientName;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? area;
  final String? zipCode;
  final String? country;
  final bool? isDefault;

  AddressItemModel({
    this.id,
    this.name,
    this.recipientName,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.area,
    this.zipCode,
    this.country,
    this.isDefault,
  });

  factory AddressItemModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return AddressItemModel();
    return AddressItemModel(
      id: json['id'],
      name: json['name']?.toString() ?? json['label']?.toString(),
      recipientName: json['recipient_name']?.toString() ?? json['name']?.toString() ?? json['full_name']?.toString(),
      phone: json['phone']?.toString() ?? json['mobile']?.toString(),
      addressLine1: json['address_line_1']?.toString() ?? json['address']?.toString() ?? json['street']?.toString(),
      addressLine2: json['address_line_2']?.toString(),
      city: json['city']?.toString(),
      area: json['area']?.toString() ?? json['district']?.toString(),
      zipCode: json['zip_code']?.toString() ?? json['postcode']?.toString(),
      country: json['country']?.toString() ?? 'Bangladesh',
      isDefault: json['is_default'] is bool ? json['is_default'] : false,
    );
  }

  String get fullAddressFormatted {
    final parts = [
      if (addressLine1 != null && addressLine1!.isNotEmpty) addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      if (area != null && area!.isNotEmpty) area,
      if (city != null && city!.isNotEmpty) city,
      if (zipCode != null && zipCode!.isNotEmpty) zipCode,
    ];
    return parts.join(', ');
  }
}
