import 'dart:convert';
import '../../dashboard/model/wholesale_cart_model.dart';

class ReferralsModel {
  final String? code;
  final String? link;
  final ReferralSummaryModel? summary;
  final ReferralDirectListModel? direct;
  final ReferralEarningsListModel? earnings;

  ReferralsModel({
    this.code,
    this.link,
    this.summary,
    this.direct,
    this.earnings,
  });

  factory ReferralsModel.fromRawJson(String str) => ReferralsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReferralsModel.fromJson(Map<String, dynamic> json) => ReferralsModel(
        code: json["code"]?.toString(),
        link: json["link"]?.toString(),
        summary: json["summary"] != null && json["summary"] is Map<String, dynamic>
            ? ReferralSummaryModel.fromJson(json["summary"])
            : null,
        direct: json["direct"] != null && json["direct"] is Map<String, dynamic>
            ? ReferralDirectListModel.fromJson(json["direct"])
            : null,
        earnings: json["earnings"] != null && json["earnings"] is Map<String, dynamic>
            ? ReferralEarningsListModel.fromJson(json["earnings"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "link": link,
        "summary": summary?.toJson(),
        "direct": direct?.toJson(),
        "earnings": earnings?.toJson(),
      };
}

class ReferralSummaryModel {
  final int? direct;
  final int? directActive;
  final WholesalePrice? paid;
  final WholesalePrice? pending;
  final WholesalePrice? reversed;

  ReferralSummaryModel({
    this.direct,
    this.directActive,
    this.paid,
    this.pending,
    this.reversed,
  });

  factory ReferralSummaryModel.fromJson(Map<String, dynamic> json) => ReferralSummaryModel(
        direct: json["direct"] is int ? json["direct"] : int.tryParse(json["direct"]?.toString() ?? ''),
        directActive: json["direct_active"] is int ? json["direct_active"] : int.tryParse(json["direct_active"]?.toString() ?? ''),
        paid: json["paid"] != null && json["paid"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["paid"]) : null,
        pending: json["pending"] != null && json["pending"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["pending"]) : null,
        reversed: json["reversed"] != null && json["reversed"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["reversed"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "direct": direct,
        "direct_active": directActive,
        "paid": paid?.toJson(),
        "pending": pending?.toJson(),
        "reversed": reversed?.toJson(),
      };
}

class ReferralDirectListModel {
  final List<ReferralDirectItemModel>? data;
  final dynamic meta;

  ReferralDirectListModel({this.data, this.meta});

  factory ReferralDirectListModel.fromJson(Map<String, dynamic> json) => ReferralDirectListModel(
        data: json["data"] != null && json["data"] is List
            ? List<ReferralDirectItemModel>.from((json["data"] as List).map((x) => ReferralDirectItemModel.fromJson(x)))
            : null,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
        "meta": meta,
      };
}

class ReferralDirectItemModel {
  final String? id;
  final String? name;
  final String? state;
  final String? since;

  ReferralDirectItemModel({this.id, this.name, this.state, this.since});

  factory ReferralDirectItemModel.fromJson(Map<String, dynamic> json) => ReferralDirectItemModel(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
        state: json["state"]?.toString(),
        since: json["since"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "state": state,
        "since": since,
      };
}

class ReferralEarningsListModel {
  final List<dynamic>? data;
  final dynamic meta;

  ReferralEarningsListModel({this.data, this.meta});

  factory ReferralEarningsListModel.fromJson(Map<String, dynamic> json) => ReferralEarningsListModel(
        data: json["data"] as List<dynamic>?,
        meta: json["meta"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "meta": meta,
      };
}
