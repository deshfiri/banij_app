import 'dart:convert';
import '../../dashboard/model/wholesale_cart_model.dart';

class WithdrawalListResponseModel {
  final List<WithdrawalItemModel>? data;
  final List<WithdrawalStatusOption>? statuses;

  WithdrawalListResponseModel({this.data, this.statuses});

  factory WithdrawalListResponseModel.fromRawJson(String str) =>
      WithdrawalListResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WithdrawalListResponseModel.fromJson(Map<String, dynamic> json) =>
      WithdrawalListResponseModel(
        data: json["data"] != null && json["data"] is List
            ? List<WithdrawalItemModel>.from(
                (json["data"] as List).map((x) => WithdrawalItemModel.fromJson(x)))
            : null,
        statuses: json["statuses"] != null && json["statuses"] is List
            ? List<WithdrawalStatusOption>.from(
                (json["statuses"] as List).map((x) => WithdrawalStatusOption.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
        "statuses": statuses != null ? List<dynamic>.from(statuses!.map((x) => x.toJson())) : null,
      };
}

class WithdrawalItemModel {
  final String? id;
  final String? reference;
  final WholesalePrice? amount;
  final String? status;
  final String? statusLabel;
  final String? statusTone;
  final WithdrawalPayoutModel? payout;
  final String? requestedAt;
  final String? decidedAt;
  final String? paidAt;

  WithdrawalItemModel({
    this.id,
    this.reference,
    this.amount,
    this.status,
    this.statusLabel,
    this.statusTone,
    this.payout,
    this.requestedAt,
    this.decidedAt,
    this.paidAt,
  });

  factory WithdrawalItemModel.fromJson(Map<String, dynamic> json) => WithdrawalItemModel(
        id: json["id"]?.toString(),
        reference: json["reference"]?.toString(),
        amount: json["amount"] != null && json["amount"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["amount"])
            : null,
        status: json["status"]?.toString(),
        statusLabel: json["status_label"]?.toString(),
        statusTone: json["status_tone"]?.toString(),
        payout: json["payout"] != null && json["payout"] is Map<String, dynamic>
            ? WithdrawalPayoutModel.fromJson(json["payout"])
            : null,
        requestedAt: json["requested_at"]?.toString(),
        decidedAt: json["decided_at"]?.toString(),
        paidAt: json["paid_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reference": reference,
        "amount": amount?.toJson(),
        "status": status,
        "status_label": statusLabel,
        "status_tone": statusTone,
        "payout": payout?.toJson(),
        "requested_at": requestedAt,
        "decided_at": decidedAt,
        "paid_at": paidAt,
      };
}

class WithdrawalPayoutModel {
  final String? typeLabel;
  final String? label;
  final String? maskedNumber;

  WithdrawalPayoutModel({
    this.typeLabel,
    this.label,
    this.maskedNumber,
  });

  factory WithdrawalPayoutModel.fromJson(Map<String, dynamic> json) => WithdrawalPayoutModel(
        typeLabel: json["type_label"]?.toString(),
        label: json["label"]?.toString(),
        maskedNumber: json["masked_number"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "type_label": typeLabel,
        "label": label,
        "masked_number": maskedNumber,
      };
}

class WithdrawalStatusOption {
  final String? value;
  final String? label;

  WithdrawalStatusOption({
    this.value,
    this.label,
  });

  factory WithdrawalStatusOption.fromJson(Map<String, dynamic> json) => WithdrawalStatusOption(
        value: json["value"]?.toString(),
        label: json["label"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "label": label,
      };
}
