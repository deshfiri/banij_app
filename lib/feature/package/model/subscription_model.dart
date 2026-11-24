import 'dart:convert';

/// Response of `GET /subscription`: the current term, every past term, what
/// the user is allowed to do and why renewal is blocked (if it is).
class SubscriptionResponseModel {
  final SubscriptionTermModel? current;
  final List<SubscriptionTermModel> history;
  final bool canRenew;
  final String? renewalBlocker;

  const SubscriptionResponseModel({
    this.current,
    this.history = const [],
    this.canRenew = false,
    this.renewalBlocker,
  });

  factory SubscriptionResponseModel.fromRawJson(String str) =>
      SubscriptionResponseModel.fromJson(json.decode(str));

  factory SubscriptionResponseModel.fromJson(dynamic input) {
    var map = _asMap(input);
    // Some endpoints wrap the payload in `data`.
    if (!map.containsKey('current') && map['data'] is Map) map = _asMap(map['data']);

    final can = _asMap(map['can']);
    final rawHistory = map['history'];
    return SubscriptionResponseModel(
      current: map['current'] is Map ? SubscriptionTermModel.fromJson(map['current']) : null,
      history: rawHistory is List ? rawHistory.whereType<Map>().map(SubscriptionTermModel.fromJson).toList() : const [],
      canRenew: _asBool(can['renew']) ?? false,
      renewalBlocker: _nonEmpty(map['renewal_blocker']),
    );
  }

  /// Past terms only (the current one is shown separately).
  List<SubscriptionTermModel> get previousTerms =>
      current == null ? history : history.where((term) => term.id != current!.id).toList();

  Map<String, dynamic> toJson() => {
        'current': current?.toJson(),
        'history': history.map((e) => e.toJson()).toList(),
        'can': {'renew': canRenew},
        'renewal_blocker': renewalBlocker,
      };
}

/// One subscription term (current or historical).
class SubscriptionTermModel {
  final String? id;
  final String? package;
  final String? status;
  final String? statusLabel;
  final String? statusTone;
  final bool entitles;
  final String? source;
  final String? sourceLabel;
  final String? startedAt;
  final String? expiresAt;
  final String? graceEndsAt;
  final String? cancelledAt;
  final int? daysRemaining;
  final bool inGracePeriod;
  final MoneyModel? paid;
  final MoneyModel? renewalFee;
  final String? renewalFrequency;
  final List<SubscriptionFeatureModel> features;

  const SubscriptionTermModel({
    this.id,
    this.package,
    this.status,
    this.statusLabel,
    this.statusTone,
    this.entitles = false,
    this.source,
    this.sourceLabel,
    this.startedAt,
    this.expiresAt,
    this.graceEndsAt,
    this.cancelledAt,
    this.daysRemaining,
    this.inGracePeriod = false,
    this.paid,
    this.renewalFee,
    this.renewalFrequency,
    this.features = const [],
  });

  factory SubscriptionTermModel.fromJson(dynamic input) {
    final json = _asMap(input);
    final rawFeatures = json['features'];
    return SubscriptionTermModel(
      id: _nonEmpty(json['id']),
      package: _nonEmpty(json['package'] is Map ? json['package']['name'] : json['package']),
      status: _nonEmpty(json['status']),
      statusLabel: _nonEmpty(json['status_label']),
      statusTone: _nonEmpty(json['status_tone']),
      entitles: _asBool(json['entitles']) ?? false,
      source: _nonEmpty(json['source']),
      sourceLabel: _nonEmpty(json['source_label']),
      startedAt: _nonEmpty(json['started_at']),
      expiresAt: _nonEmpty(json['expires_at']),
      graceEndsAt: _nonEmpty(json['grace_ends_at']),
      cancelledAt: _nonEmpty(json['cancelled_at']),
      daysRemaining: _asInt(json['days_remaining']),
      inGracePeriod: _asBool(json['in_grace_period']) ?? false,
      paid: json['paid'] == null ? null : MoneyModel.fromJson(json['paid']),
      renewalFee: json['renewal_fee'] == null ? null : MoneyModel.fromJson(json['renewal_fee']),
      renewalFrequency: _nonEmpty(json['renewal_frequency']),
      features: rawFeatures is List
          ? rawFeatures.whereType<Map>().map(SubscriptionFeatureModel.fromJson).toList()
          : const [],
    );
  }

  String get displayName => package ?? 'Package';
  String get displayStatus => statusLabel ?? _humanize(status ?? 'unknown');
  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled' || cancelledAt != null;
  bool get doesNotExpire => expiresAt == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'package': package,
        'status': status,
        'status_label': statusLabel,
        'status_tone': statusTone,
        'entitles': entitles,
        'source': source,
        'source_label': sourceLabel,
        'started_at': startedAt,
        'expires_at': expiresAt,
        'grace_ends_at': graceEndsAt,
        'cancelled_at': cancelledAt,
        'days_remaining': daysRemaining,
        'in_grace_period': inGracePeriod,
        'paid': paid?.toJson(),
        'renewal_fee': renewalFee?.toJson(),
        'renewal_frequency': renewalFrequency,
        'features': features.map((e) => e.toJson()).toList(),
      };
}

class MoneyModel {
  final String? amount;
  final String? currency;
  final String? formatted;

  const MoneyModel({this.amount, this.currency, this.formatted});

  factory MoneyModel.fromJson(dynamic input) {
    if (input is! Map) return MoneyModel(amount: input?.toString());
    return MoneyModel(
      amount: _nonEmpty(input['amount']),
      currency: _nonEmpty(input['currency']),
      formatted: _nonEmpty(input['formatted']),
    );
  }

  String get display {
    if (formatted != null) return formatted!;
    if (amount == null) return '—';
    return currency == 'BDT' ? '৳$amount' : [currency, amount].whereType<String>().join(' ');
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'currency': currency, 'formatted': formatted};
}

enum SubscriptionFeatureType { boolean, limit, text }

/// A single entitlement of a package ("Websites: 1", "API access: true" …).
class SubscriptionFeatureModel {
  final String? key;
  final String label;
  final SubscriptionFeatureType type;
  final dynamic value;

  const SubscriptionFeatureModel({
    this.key,
    required this.label,
    required this.type,
    this.value,
  });

  factory SubscriptionFeatureModel.fromJson(dynamic input) {
    final json = _asMap(input);
    final type = switch (json['type']?.toString()) {
      'boolean' => SubscriptionFeatureType.boolean,
      'limit' => SubscriptionFeatureType.limit,
      _ => SubscriptionFeatureType.text,
    };
    return SubscriptionFeatureModel(
      key: _nonEmpty(json['key']),
      label: _nonEmpty(json['label']) ?? _humanize(json['key']?.toString() ?? ''),
      type: type,
      value: json['value'],
    );
  }

  bool? get boolValue => type == SubscriptionFeatureType.boolean ? _asBool(value) : null;
  int? get limitValue => type == SubscriptionFeatureType.limit ? _asInt(value) : null;

  Map<String, dynamic> toJson() => {'key': key, 'label': label, 'type': type.name, 'value': value};
}

// -----------------------------------------------------------------------------
// Parsing helpers
// -----------------------------------------------------------------------------

Map<String, dynamic> _asMap(dynamic input) {
  final decoded = input is String && input.isNotEmpty ? json.decode(input) : input;
  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) return decoded.map((key, value) => MapEntry(key.toString(), value));
  return <String, dynamic>{};
}

String? _nonEmpty(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty || text == 'null' ? null : text;
}

int? _asInt(dynamic value) {
  if (value is num) return value.round();
  return value == null ? null : num.tryParse(value.toString())?.round();
}

bool? _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return switch (value?.toString().toLowerCase()) {
    'true' || '1' || 'yes' => true,
    'false' || '0' || 'no' => false,
    _ => null,
  };
}

String _humanize(String value) {
  final text = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
