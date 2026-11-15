import 'dart:convert';

class LanguageLocaleResponseModel {
  final LanguageLocaleDataModel? data;

  LanguageLocaleResponseModel({this.data});

  factory LanguageLocaleResponseModel.fromRawJson(String str) =>
      LanguageLocaleResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LanguageLocaleResponseModel.fromJson(Map<String, dynamic> json) =>
      LanguageLocaleResponseModel(
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? LanguageLocaleDataModel.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class LanguageLocaleDataModel {
  final String? locale;
  final List<LanguageOptionModel>? options;

  LanguageLocaleDataModel({this.locale, this.options});

  factory LanguageLocaleDataModel.fromJson(Map<String, dynamic> json) =>
      LanguageLocaleDataModel(
        locale: json["locale"]?.toString(),
        options: json["options"] != null && json["options"] is List
            ? List<LanguageOptionModel>.from(
                (json["options"] as List).map((x) => LanguageOptionModel.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "locale": locale,
        "options": options != null ? List<dynamic>.from(options!.map((x) => x.toJson())) : null,
      };
}

class LanguageOptionModel {
  final String? value;
  final String? label;

  LanguageOptionModel({this.value, this.label});

  factory LanguageOptionModel.fromJson(Map<String, dynamic> json) => LanguageOptionModel(
        value: json["value"]?.toString(),
        label: json["label"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "label": label,
      };
}
