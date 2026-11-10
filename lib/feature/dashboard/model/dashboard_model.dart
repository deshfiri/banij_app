import 'dart:convert';

class DashboardModel {
  final DashboardDataModel? data;
  final bool? success;
  final String? message;

  DashboardModel({
    this.data,
    this.success,
    this.message,
  });

  factory DashboardModel.fromRawJson(String str) =>
      DashboardModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashboardModel.fromJson(dynamic jsonInput) {
    if (jsonInput is Map<String, dynamic>) {
      return DashboardModel(
        data: jsonInput["data"] != null && jsonInput["data"] is Map<String, dynamic>
            ? DashboardDataModel.fromJson(jsonInput["data"])
            : null,
        success: jsonInput["success"] is bool ? jsonInput["success"] : true,
        message: jsonInput["message"] as String?,
      );
    }
    return DashboardModel(success: true);
  }

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class DashboardDataModel {
  final GreetingModel? greeting;
  final StandingModel? standing;
  final WalletUsableModel? walletUsable;
  final SpendModel? spend;

  DashboardDataModel({
    this.greeting,
    this.standing,
    this.walletUsable,
    this.spend,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) =>
      DashboardDataModel(
        greeting: json["greeting"] != null && json["greeting"] is Map<String, dynamic>
            ? GreetingModel.fromJson(json["greeting"])
            : null,
        standing: json["standing"] != null && json["standing"] is Map<String, dynamic>
            ? StandingModel.fromJson(json["standing"])
            : null,
        walletUsable: json["wallet_usable"] != null && json["wallet_usable"] is Map<String, dynamic>
            ? WalletUsableModel.fromJson(json["wallet_usable"])
            : null,
        spend: json["spend"] != null && json["spend"] is Map<String, dynamic>
            ? SpendModel.fromJson(json["spend"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "greeting": greeting?.toJson(),
        "standing": standing?.toJson(),
        "wallet_usable": walletUsable?.toJson(),
        "spend": spend?.toJson(),
      };
}

class GreetingModel {
  final String? name;
  final String? period;

  GreetingModel({this.name, this.period});

  factory GreetingModel.fromJson(Map<String, dynamic> json) => GreetingModel(
        name: json["name"] as String?,
        period: json["period"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "period": period,
      };
}

class StandingModel {
  final String? status;
  final String? label;
  final String? tone;
  final bool? needsAttention;
  final ActionModel? action;

  StandingModel({
    this.status,
    this.label,
    this.tone,
    this.needsAttention,
    this.action,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) => StandingModel(
        status: json["status"] as String?,
        label: json["label"] as String?,
        tone: json["tone"] as String?,
        needsAttention: json["needs_attention"] is bool ? json["needs_attention"] : null,
        action: json["action"] != null && json["action"] is Map<String, dynamic>
            ? ActionModel.fromJson(json["action"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "label": label,
        "tone": tone,
        "needs_attention": needsAttention,
        "action": action?.toJson(),
      };
}

class ActionModel {
  final String? label;
  final String? screen;

  ActionModel({this.label, this.screen});

  factory ActionModel.fromJson(Map<String, dynamic> json) => ActionModel(
        label: json["label"] as String?,
        screen: json["screen"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "screen": screen,
      };
}

class WalletUsableModel {
  final String? amount;
  final String? currency;
  final String? formatted;

  WalletUsableModel({this.amount, this.currency, this.formatted});

  factory WalletUsableModel.fromJson(Map<String, dynamic> json) =>
      WalletUsableModel(
        amount: json["amount"]?.toString(),
        currency: json["currency"] as String?,
        formatted: json["formatted"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "currency": currency,
        "formatted": formatted,
      };
}

class SpendModel {
  final dynamic total;
  final String? months;
  final List<dynamic>? series;
  final List<dynamic>? breakdown;

  SpendModel({this.total, this.months, this.series, this.breakdown});

  factory SpendModel.fromJson(Map<String, dynamic> json) => SpendModel(
        total: json["total"],
        months: json["months"]?.toString(),
        series: json["series"] is List ? List<dynamic>.from(json["series"]) : [],
        breakdown: json["breakdown"] is List ? List<dynamic>.from(json["breakdown"]) : [],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "months": months,
        "series": series,
        "breakdown": breakdown,
      };
}
