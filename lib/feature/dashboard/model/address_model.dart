import 'dart:convert';
import 'location_division_model.dart';

class AddressResponseModel {
  final List<AddressItemModel>? data;
  final List<String>? types;
  final bool? success;
  final String? message;

  AddressResponseModel({
    this.data,
    this.types,
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

    final rawTypes = jsonInput['types'];
    List<String> typeItems = [];
    if (rawTypes is List) {
      typeItems = rawTypes.map((x) => x.toString()).toList();
    }

    return AddressResponseModel(
      success: jsonInput['success'] is bool ? jsonInput['success'] : true,
      message: jsonInput['message']?.toString(),
      data: items,
      types: typeItems,
    );
  }
}

class AddressItemModel {
  final dynamic id;
  final String? type;
  final bool? isActive;
  final bool? isDefault;
  final String? contactName;
  final String? contactMobile;
  final String? detailedAddress;
  final String? landmark;
  final String? postcode;
  final LocationInfoModel? location;

  AddressItemModel({
    this.id,
    this.type,
    this.isActive,
    this.isDefault,
    this.contactName,
    this.contactMobile,
    this.detailedAddress,
    this.landmark,
    this.postcode,
    this.location,
  });

  factory AddressItemModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return AddressItemModel();
    return AddressItemModel(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      isActive: json['is_active'] as bool?,
      isDefault: json['is_default'] is bool ? json['is_default'] : false,
      contactName: json['contact_name']?.toString() ?? json['recipient_name']?.toString() ?? json['name']?.toString(),
      contactMobile: json['contact_mobile']?.toString() ?? json['phone']?.toString() ?? json['mobile']?.toString(),
      detailedAddress: json['detailed_address']?.toString() ?? json['address_line_1']?.toString() ?? json['address']?.toString(),
      landmark: json['landmark']?.toString(),
      postcode: json['postcode']?.toString() ?? json['zip_code']?.toString(),
      location: json['location'] != null && json['location'] is Map<String, dynamic>
          ? LocationInfoModel.fromJson(json['location'])
          : null,
    );
  }

  String get recipientName => contactName ?? 'Address';
  String get phone => contactMobile ?? '';

  String get fullAddressFormatted {
    final parts = [
      if (detailedAddress != null && detailedAddress!.isNotEmpty) detailedAddress,
      if (location?.upazila?.nameEn != null && location!.upazila!.nameEn!.isNotEmpty) location!.upazila!.nameEn,
      if (location?.district?.nameEn != null && location!.district!.nameEn!.isNotEmpty) location!.district!.nameEn,
      if (location?.division?.nameEn != null && location!.division!.nameEn!.isNotEmpty) location!.division!.nameEn,
      if (postcode != null && postcode!.isNotEmpty) postcode,
    ];
    return parts.join(', ');
  }
}

class LocationInfoModel {
  final DivisionData? division;
  final DivisionData? district;
  final DivisionData? upazila;
  final DivisionData? union;

  LocationInfoModel({
    this.division,
    this.district,
    this.upazila,
    this.union,
  });

  factory LocationInfoModel.fromJson(Map<String, dynamic> json) => LocationInfoModel(
        division: json["division"] != null && json["division"] is Map<String, dynamic>
            ? DivisionData.fromJson(json["division"])
            : null,
        district: json["district"] != null && json["district"] is Map<String, dynamic>
            ? DivisionData.fromJson(json["district"])
            : null,
        upazila: json["upazila"] != null && json["upazila"] is Map<String, dynamic>
            ? DivisionData.fromJson(json["upazila"])
            : null,
        union: json["union"] != null && json["union"] is Map<String, dynamic>
            ? DivisionData.fromJson(json["union"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "division": division?.toJson(),
        "district": district?.toJson(),
        "upazila": upazila?.toJson(),
        "union": union?.toJson(),
      };
}
