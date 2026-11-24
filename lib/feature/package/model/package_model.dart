import 'dart:convert';

class PackageResponseModel {
  final List<PackageItemModel>? data;
  final String? selectedSlug;
  final bool? success;
  final String? message;

  /// Name of the plan the account is on now (when the API sends it).
  final String? currentPackageName;

  PackageResponseModel({
    this.data,
    this.selectedSlug,
    this.success,
    this.message,
    this.currentPackageName,
  });

  factory PackageResponseModel.fromRawJson(String str) =>
      PackageResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PackageResponseModel.fromJson(Map<String, dynamic> json) =>
      PackageResponseModel(
        data: json["data"] is List
            ? List<PackageItemModel>.from(
                json["data"].map((x) => PackageItemModel.fromJson(x)))
            : [],
        selectedSlug: json["selected_slug"]?.toString() ?? _currentSlug(json),
        success: json["success"] is bool ? json["success"] : true,
        message: json["message"] as String?,
        currentPackageName: _currentName(json),
      );

  /// The current plan entry, wherever the API puts it.
  static dynamic _currentEntry(Map<String, dynamic> json) =>
      json["current"] ?? json["current_package"] ?? json["current_plan"] ?? json["subscription"];

  static String? _currentSlug(Map<String, dynamic> json) {
    final current = _currentEntry(json);
    if (current is Map) return (current["slug"] ?? current["package_slug"])?.toString();
    return json["current_slug"]?.toString();
  }

  static String? _currentName(Map<String, dynamic> json) {
    final current = _currentEntry(json);
    if (current is Map) {
      final pkg = current["package"];
      return (pkg is Map ? pkg["name"] : pkg ?? current["name"])?.toString();
    }
    if (current is String && current.isNotEmpty) return current;
    return json["current_package_name"]?.toString();
  }

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : [],
        "selected_slug": selectedSlug,
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class PackageItemModel {
  final String? slug;
  final String? name;
  final String? shortDescription;
  final PackageFeeModel? fee;
  final PackageFeeModel? activationTotal;
  final String? validityDays;
  final PackageFeeModel? requiredDeposit;
  final List<String>? features;

  // Plan-change details (only present when the account already has a plan).
  /// e.g. `upgrade`, `downgrade`, `current`.
  final String? changeType;
  /// Human label for [changeType], e.g. "Downgraded".
  final String? changeLabel;
  final String? changeTone;
  /// Date the plan would start applying from.
  final String? appliesFrom;
  /// Amount to pay now to switch.
  final PackageFeeModel? payableNow;
  /// Limits the account is over on this plan.
  final List<PackageLimitViolation> limitViolations;
  final bool? isCurrent;
  final bool? canSelect;
  final String? blockedReason;

  PackageItemModel({
    this.slug,
    this.name,
    this.shortDescription,
    this.fee,
    this.activationTotal,
    this.validityDays,
    this.requiredDeposit,
    this.features,
    this.changeType,
    this.changeLabel,
    this.changeTone,
    this.appliesFrom,
    this.payableNow,
    this.limitViolations = const [],
    this.isCurrent,
    this.canSelect,
    this.blockedReason,
  });

  factory PackageItemModel.fromRawJson(String str) =>
      PackageItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PackageItemModel.fromJson(Map<String, dynamic> json) {
    // Plan-change info may sit at the top level or inside a nested object.
    final change = [json["change"], json["switch"], json["preview"], json["transition"]]
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .firstOrNull ?? const <String, dynamic>{};
    dynamic pick(List<String> keys) {
      for (final key in keys) {
        if (json[key] != null) return json[key];
        if (change[key] != null) return change[key];
      }
      return null;
    }

    final rawChange = json["change"] is String ? json["change"] : pick(["change_type", "direction", "type", "kind"]);
    final rawViolations = pick(["limit_violations", "violations", "over_limits", "limits_exceeded", "blockers"]);

    return PackageItemModel(
        slug: json["slug"] as String?,
        name: json["name"] as String?,
        shortDescription: json["short_description"] as String?,
        fee: json["fee"] != null && json["fee"] is Map<String, dynamic>
            ? PackageFeeModel.fromJson(json["fee"])
            : null,
        activationTotal: json["activation_total"] != null &&
                json["activation_total"] is Map<String, dynamic>
            ? PackageFeeModel.fromJson(json["activation_total"])
            : null,
        validityDays: json["validity_days"]?.toString(),
        requiredDeposit: json["required_deposit"] != null &&
                json["required_deposit"] is Map<String, dynamic>
            ? PackageFeeModel.fromJson(json["required_deposit"])
            : null,
        features: json["features"] is List
            ? List<String>.from(json["features"].map((x) {
                if (x is Map) {
                  final label = x['label'] ?? x['key'] ?? '';
                  final value = x['value'];
                  if (value != null) {
                    return '$label: $value';
                  }
                  return label.toString();
                }
                return x.toString();
              }))
            : [],
        changeType: rawChange?.toString(),
        changeLabel: pick(["change_label", "direction_label", "type_label", "label"])?.toString(),
        changeTone: pick(["change_tone", "tone", "status_tone"])?.toString(),
        appliesFrom: pick(["applies_from", "applies_at", "effective_at", "effective_from", "starts_at", "start_date"])?.toString(),
        payableNow: _fee(pick(["payable_now", "amount_due", "due_now", "payable", "prorated_amount", "charge"])),
        limitViolations: rawViolations is List
            ? rawViolations.map(PackageLimitViolation.fromJson).toList()
            : const [],
        isCurrent: _bool(json["is_current"] ?? json["current"] ?? json["is_selected"]),
        canSelect: _bool(pick(["can_select", "selectable", "is_selectable", "can_choose", "allowed"])),
        blockedReason: pick(["blocked_reason", "blocker", "reason", "unavailable_reason"])?.toString(),
      );
  }

  static PackageFeeModel? _fee(dynamic value) {
    if (value is Map<String, dynamic>) return PackageFeeModel.fromJson(value);
    if (value is Map) return PackageFeeModel.fromJson(value.map((k, v) => MapEntry(k.toString(), v)));
    if (value == null) return null;
    return PackageFeeModel(amount: value.toString());
  }

  static bool? _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return switch (value?.toString().toLowerCase()) {
      'true' || '1' || 'yes' => true,
      'false' || '0' || 'no' => false,
      _ => null,
    };
  }

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
        "short_description": shortDescription,
        "fee": fee?.toJson(),
        "activation_total": activationTotal?.toJson(),
        "validity_days": validityDays,
        "required_deposit": requiredDeposit?.toJson(),
        "features": features != null ? List<dynamic>.from(features!.map((x) => x)) : [],
      };
}

class PackageFeeModel {
  final String? amount;
  final String? currency;
  final String? formatted;

  PackageFeeModel({
    this.amount,
    this.currency,
    this.formatted,
  });

  factory PackageFeeModel.fromRawJson(String str) =>
      PackageFeeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PackageFeeModel.fromJson(Map<String, dynamic> json) => PackageFeeModel(
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

/// One limit the account is over on a plan, e.g.
/// "Staff members — you have 1, this plan allows 0. Remove 1."
class PackageLimitViolation {
  final String? label;
  final String? current;
  final String? allowed;
  final String? excess;
  final String? message;

  const PackageLimitViolation({this.label, this.current, this.allowed, this.excess, this.message});

  factory PackageLimitViolation.fromJson(dynamic input) {
    if (input is! Map) return PackageLimitViolation(message: input?.toString());
    String? s(List<String> keys) {
      for (final k in keys) {
        final v = input[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    return PackageLimitViolation(
      label: s(["label", "name", "feature", "key"]),
      current: s(["current", "used", "usage", "have", "count"]),
      allowed: s(["allowed", "limit", "max", "plan_limit"]),
      excess: s(["excess", "over", "over_by", "remove"]),
      message: s(["message", "text", "description"]),
    );
  }

  /// Display text; builds the sentence from the parts when there is no message.
  String get text {
    if (message != null) return message!;
    final parts = <String>[
      if (current != null) 'you have $current',
      if (allowed != null) 'this plan allows $allowed',
    ];
    var sentence = [label, parts.join(', ')].where((e) => e != null && e.isNotEmpty).join(' — ');
    if (excess != null) sentence += '. Remove $excess.';
    return sentence.isEmpty ? 'Over the limit' : sentence;
  }
}

/// Response of `POST /packages/{slug}/select`.
class PackageSelectResultModel {
  /// Slug of the plan that is now selected.
  final String? selectedSlug;

  /// What the app should do next, as sent by the API.
  final String? next;

  const PackageSelectResultModel({this.selectedSlug, this.next});

  factory PackageSelectResultModel.fromJson(dynamic input) {
    var json = input is Map ? input : const {};
    if (json['data'] is Map) json = json['data'] as Map;
    String? text(dynamic v) {
      final t = v?.toString().trim();
      return t == null || t.isEmpty || t == 'null' ? null : t;
    }

    return PackageSelectResultModel(selectedSlug: text(json['selected_slug']), next: text(json['next']));
  }
}
