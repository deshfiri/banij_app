import 'dart:convert';
import '../../dashboard/model/wholesale_cart_model.dart';

class WalletBalanceResponseModel {
  final WalletBalanceDataModel? data;
  final List<dynamic>? restrictions;

  WalletBalanceResponseModel({this.data, this.restrictions});

  factory WalletBalanceResponseModel.fromRawJson(String str) =>
      WalletBalanceResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WalletBalanceResponseModel.fromJson(Map<String, dynamic> json) =>
      WalletBalanceResponseModel(
        data: json["data"] != null && json["data"] is Map<String, dynamic>
            ? WalletBalanceDataModel.fromJson(json["data"])
            : null,
        restrictions: json["restrictions"] as List<dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "restrictions": restrictions,
      };
}

class WalletBalanceDataModel {
  final String? currency;
  final WholesalePrice? total;
  final WholesalePrice? usable;
  final WholesalePrice? platformCredit;
  final WholesalePrice? withdrawable;
  final WholesalePrice? platformCreditHeld;
  final WholesalePrice? withdrawableHeld;
  final WholesalePrice? reservedPlatformCredit;
  final WholesalePrice? reservedWithdrawable;
  final WholesalePrice? requiredDeposit;
  final WholesalePrice? minimumBalance;
  final WholesalePrice? reserved;
  final WholesalePrice? pending;
  final WholesalePrice? hold;
  final WholesalePrice? codReceivable;
  final bool? depositUsableForCharges;
  final bool? meetsRequiredDeposit;
  final bool? meetsObligation;
  final WholesalePrice? shortfall;
  final WholesalePrice? obligationShortfall;
  final String? depositDueAt;
  final String? state;
  final String? stateLabel;
  final String? stateTone;
  final String? graceEndsAt;
  final String? shortfallSince;

  WalletBalanceDataModel({
    this.currency,
    this.total,
    this.usable,
    this.platformCredit,
    this.withdrawable,
    this.platformCreditHeld,
    this.withdrawableHeld,
    this.reservedPlatformCredit,
    this.reservedWithdrawable,
    this.requiredDeposit,
    this.minimumBalance,
    this.reserved,
    this.pending,
    this.hold,
    this.codReceivable,
    this.depositUsableForCharges,
    this.meetsRequiredDeposit,
    this.meetsObligation,
    this.shortfall,
    this.obligationShortfall,
    this.depositDueAt,
    this.state,
    this.stateLabel,
    this.stateTone,
    this.graceEndsAt,
    this.shortfallSince,
  });

  factory WalletBalanceDataModel.fromJson(Map<String, dynamic> json) =>
      WalletBalanceDataModel(
        currency: json["currency"]?.toString(),
        total: json["total"] != null && json["total"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["total"]) : null,
        usable: json["usable"] != null && json["usable"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["usable"]) : null,
        platformCredit: json["platform_credit"] != null && json["platform_credit"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["platform_credit"]) : null,
        withdrawable: json["withdrawable"] != null && json["withdrawable"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["withdrawable"]) : null,
        platformCreditHeld: json["platform_credit_held"] != null && json["platform_credit_held"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["platform_credit_held"]) : null,
        withdrawableHeld: json["withdrawable_held"] != null && json["withdrawable_held"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["withdrawable_held"]) : null,
        reservedPlatformCredit: json["reserved_platform_credit"] != null && json["reserved_platform_credit"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["reserved_platform_credit"]) : null,
        reservedWithdrawable: json["reserved_withdrawable"] != null && json["reserved_withdrawable"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["reserved_withdrawable"]) : null,
        requiredDeposit: json["required_deposit"] != null && json["required_deposit"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["required_deposit"]) : null,
        minimumBalance: json["minimum_balance"] != null && json["minimum_balance"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["minimum_balance"]) : null,
        reserved: json["reserved"] != null && json["reserved"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["reserved"]) : null,
        pending: json["pending"] != null && json["pending"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["pending"]) : null,
        hold: json["hold"] != null && json["hold"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["hold"]) : null,
        codReceivable: json["cod_receivable"] != null && json["cod_receivable"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["cod_receivable"]) : null,
        depositUsableForCharges: json["deposit_usable_for_charges"] as bool?,
        meetsRequiredDeposit: json["meets_required_deposit"] as bool?,
        meetsObligation: json["meets_obligation"] as bool?,
        shortfall: json["shortfall"] != null && json["shortfall"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["shortfall"]) : null,
        obligationShortfall: json["obligation_shortfall"] != null && json["obligation_shortfall"] is Map<String, dynamic> ? WholesalePrice.fromJson(json["obligation_shortfall"]) : null,
        depositDueAt: json["deposit_due_at"]?.toString(),
        state: json["state"]?.toString(),
        stateLabel: json["state_label"]?.toString(),
        stateTone: json["state_tone"]?.toString(),
        graceEndsAt: json["grace_ends_at"]?.toString(),
        shortfallSince: json["shortfall_since"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "currency": currency,
        "total": total?.toJson(),
        "usable": usable?.toJson(),
        "platform_credit": platformCredit?.toJson(),
        "withdrawable": withdrawable?.toJson(),
        "platform_credit_held": platformCreditHeld?.toJson(),
        "withdrawable_held": withdrawableHeld?.toJson(),
        "reserved_platform_credit": reservedPlatformCredit?.toJson(),
        "reserved_withdrawable": reservedWithdrawable?.toJson(),
        "required_deposit": requiredDeposit?.toJson(),
        "minimum_balance": minimumBalance?.toJson(),
        "reserved": reserved?.toJson(),
        "pending": pending?.toJson(),
        "hold": hold?.toJson(),
        "cod_receivable": codReceivable?.toJson(),
        "deposit_usable_for_charges": depositUsableForCharges,
        "meets_required_deposit": meetsRequiredDeposit,
        "meets_obligation": meetsObligation,
        "shortfall": shortfall?.toJson(),
        "obligation_shortfall": obligationShortfall?.toJson(),
        "deposit_due_at": depositDueAt,
        "state": state,
        "state_label": stateLabel,
        "state_tone": stateTone,
        "grace_ends_at": graceEndsAt,
        "shortfall_since": shortfallSince,
      };
}
