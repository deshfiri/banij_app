import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/subscription_model.dart';
import 'subscription_format.dart';

/// Package entitlements as rows separated by hairlines. The card around it
/// carries the "What this includes" title.
class SubscriptionFeatureList extends StatelessWidget {
  final List<SubscriptionFeatureModel> features;

  const SubscriptionFeatureList({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    final border = AppColorsTheme.borderColor(context);
    return Column(
      children: [
        for (var i = 0; i < features.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, indent: 32.w, color: border.withValues(alpha: 0.7)),
          SubscriptionFeatureTile(feature: features[i]),
        ],
      ],
    );
  }
}

/// One entitlement: orange check (or grey cross) circle, label and value.
/// Excluded features and zero limits are muted.
class SubscriptionFeatureTile extends StatelessWidget {
  final SubscriptionFeatureModel feature;

  const SubscriptionFeatureTile({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final isBoolean = feature.type == SubscriptionFeatureType.boolean;
    final isEmptyLimit = feature.type == SubscriptionFeatureType.limit && feature.limitValue == 0;
    final included = isBoolean ? feature.boolValue == true : !isEmptyLimit;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: included ? primaryOrange.withValues(alpha: 0.14) : muted.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: 13.sp,
              color: included ? primaryOrange : muted.withValues(alpha: 0.7),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Text(
              feature.label,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: included ? AppColorsTheme.textMainColor(context) : muted,
              ),
            ),
          ),
          UIHelper.horizontalSpace(10.w),
          Text(
            SubscriptionFormat.featureValue(feature),
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: included ? FontWeight.w800 : FontWeight.w500,
              color: included ? AppColorsTheme.textMainColor(context) : muted,
            ),
          ),
        ],
      ),
    );
  }
}
