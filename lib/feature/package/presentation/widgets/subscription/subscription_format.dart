import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../model/subscription_model.dart';

/// Text helpers shared by the subscription widgets.
abstract final class SubscriptionFormat {
  /// "Nov 21, 2026". Uses the calendar date the API sent (no timezone shift).
  static String? date(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw.length >= 10 ? raw.substring(0, 10) : raw);
    return parsed == null ? raw : DateFormat('MMM d, yyyy').format(parsed);
  }

  static String frequency(String? value) => switch (value?.toLowerCase()) {
        'yearly' || 'annual' || 'annually' => 'sub_yearly'.tr,
        'monthly' => 'sub_monthly'.tr,
        'weekly' => 'sub_weekly'.tr,
        null || '' => '',
        final other => other[0].toUpperCase() + other.substring(1),
      };

  static String daysLeft(int days) => days == 1 ? '1 ${'sub_day_left'.tr}' : '$days ${'sub_days_left'.tr}';

  /// "Started Nov 21, 2026 · Does not expire" / "… · Ends Dec 3, 2026 · 8 days left".
  static String termLine(SubscriptionTermModel term) {
    final parts = <String>[
      if (date(term.startedAt) case final d?) '${'sub_started'.tr} $d',
      if (term.doesNotExpire)
        'sub_does_not_expire'.tr
      else if (date(term.expiresAt) case final d?)
        '${'sub_ends'.tr} $d',
      if (!term.doesNotExpire && term.daysRemaining != null && term.daysRemaining! >= 0)
        daysLeft(term.daysRemaining!),
    ];
    return parts.join(' · ');
  }

  /// Right-hand value of a feature row.
  static String featureValue(SubscriptionFeatureModel feature) {
    switch (feature.type) {
      case SubscriptionFeatureType.boolean:
        return feature.boolValue == true ? 'sub_included'.tr : 'sub_not_included'.tr;
      case SubscriptionFeatureType.limit:
        final limit = feature.limitValue;
        if (limit == null) return feature.value?.toString() ?? '—';
        if (limit < 0) return 'sub_unlimited'.tr;
        if (limit == 0) return 'sub_none'.tr;
        return NumberFormat.decimalPattern().format(limit);
      case SubscriptionFeatureType.text:
        final text = feature.value?.toString().trim() ?? '';
        if (text.isEmpty) return '—';
        return text[0].toUpperCase() + text.substring(1);
    }
  }
}
