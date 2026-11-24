import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/subscription_model.dart';
import 'subscription_format.dart';

const Color _included = Color(0xFF10B981);

/// "What this includes" — bordered list of package entitlements.
class SubscriptionFeatureList extends StatelessWidget {
  final List<SubscriptionFeatureModel> features;

  const SubscriptionFeatureList({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    final border = AppColorsTheme.borderColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sub_what_includes'.tr,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.verticalSpace(8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColorsTheme.innerCardBg(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Column(
              children: [
                for (var i = 0; i < features.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: border),
                  SubscriptionFeatureTile(feature: features[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One entitlement row: label on the left, value on the right. Included
/// features are highlighted green; excluded / zero values are muted.
class SubscriptionFeatureTile extends StatelessWidget {
  final SubscriptionFeatureModel feature;

  const SubscriptionFeatureTile({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final isIncluded = feature.boolValue == true;
    final isBoolean = feature.type == SubscriptionFeatureType.boolean;
    final isEmptyLimit = feature.type == SubscriptionFeatureType.limit && feature.limitValue == 0;

    final valueColor = isIncluded
        ? _included
        : (isBoolean || isEmptyLimit)
            ? muted
            : AppColorsTheme.textMainColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature.label,
              style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMainColor(context)),
            ),
          ),
          UIHelper.horizontalSpace(10.w),
          if (isBoolean) ...[
            Icon(
              isIncluded ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
              size: 14.sp,
              color: valueColor,
            ),
            UIHelper.horizontalSpace(4.w),
          ],
          Text(
            SubscriptionFormat.featureValue(feature),
            style: TextStyle(
              fontSize: 12.sp,
              color: valueColor,
              fontWeight: isIncluded || (!isBoolean && !isEmptyLimit) ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
