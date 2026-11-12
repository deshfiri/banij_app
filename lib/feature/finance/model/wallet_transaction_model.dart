import 'dart:convert';
import '../../dashboard/model/wholesale_cart_model.dart';

class WalletTransactionListModel {
  final List<WalletTransactionItemModel>? data;

  WalletTransactionListModel({this.data});

  factory WalletTransactionListModel.fromRawJson(String str) =>
      WalletTransactionListModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WalletTransactionListModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionListModel(
        data: json["data"] != null && json["data"] is List
            ? List<WalletTransactionItemModel>.from(
                (json["data"] as List).map((x) => WalletTransactionItemModel.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
      };
}

class WalletTransactionItemModel {
  final String? id;
  final String? reference;
  final String? type;
  final String? typeLabel;
  final String? direction;
  final String? description;
  final String? source;
  final WholesalePrice? amount;
  final WholesalePrice? debit;
  final WholesalePrice? credit;
  final WholesalePrice? balanceAfter;
  final String? entryReference;
  final String? status;
  final String? statusLabel;
  final String? statusTone;
  final bool? isCorrection;
  final String? reason;
  final String? at;

  WalletTransactionItemModel({
    this.id,
    this.reference,
    this.type,
    this.typeLabel,
    this.direction,
    this.description,
    this.source,
    this.amount,
    this.debit,
    this.credit,
    this.balanceAfter,
    this.entryReference,
    this.status,
    this.statusLabel,
    this.statusTone,
    this.isCorrection,
    this.reason,
    this.at,
  });

  factory WalletTransactionItemModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionItemModel(
        id: json["id"]?.toString(),
        reference: json["reference"]?.toString(),
        type: json["type"]?.toString(),
        typeLabel: json["type_label"]?.toString(),
        direction: json["direction"]?.toString(),
        description: json["description"]?.toString(),
        source: json["source"]?.toString(),
        amount: json["amount"] != null && json["amount"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["amount"])
            : null,
        debit: json["debit"] != null && json["debit"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["debit"])
            : null,
        credit: json["credit"] != null && json["credit"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["credit"])
            : null,
        balanceAfter: json["balance_after"] != null && json["balance_after"] is Map<String, dynamic>
            ? WholesalePrice.fromJson(json["balance_after"])
            : null,
        entryReference: json["entry_reference"]?.toString(),
        status: json["status"]?.toString(),
        statusLabel: json["status_label"]?.toString(),
        statusTone: json["status_tone"]?.toString(),
        isCorrection: json["is_correction"] as bool?,
        reason: json["reason"]?.toString(),
        at: json["at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reference": reference,
        "type": type,
        "type_label": typeLabel,
        "direction": direction,
        "description": description,
        "source": source,
        "amount": amount?.toJson(),
        "debit": debit?.toJson(),
        "credit": credit?.toJson(),
        "balance_after": balanceAfter?.toJson(),
        "entry_reference": entryReference,
        "status": status,
        "status_label": statusLabel,
        "status_tone": statusTone,
        "is_correction": isCorrection,
        "reason": reason,
        "at": at,
      };
}
