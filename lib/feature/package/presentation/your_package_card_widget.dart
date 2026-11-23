import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../model/package_model.dart';

class YourPackageCardWidget extends StatelessWidget {
  final PackageItemModel? package;
  final VoidCallback? onChangePackage;
  final VoidCallback? onRenewSubscription;

  const YourPackageCardWidget({
    super.key,
    this.package,
    this.onChangePackage,
    this.onRenewSubscription,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final packageName = package?.name ?? 'Starter';
    final shortDesc = package?.shortDescription ?? 'Starter plan';
    final feeText = package?.fee?.formatted ?? '৳1,500.00';
    final activationText = package?.activationTotal?.formatted ?? '৳1,500.00';
    final validityText = package?.validityDays != null ? '${package!.validityDays} Days' : '365 Days';
    final featuresList = package?.features ?? [
      'Dedicated website: false',
      'Wholesale ordering: true',
      'Inventory sync: true',
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section Title
          Text(
            'Your package'.tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            'Which package you are on, what it offers, and when it renews.'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // White Main Card Container
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppColorsTheme.borderColor(context),
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 14.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package Title & Subtitle
                Text(
                  packageName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(3.h),
                Text(
                  shortDesc,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                _PackageStat(label: 'Fee:'.tr, value: feeText, valueSize: 18.sp),
                UIHelper.verticalSpace(12.h),
                _PackageStat(label: 'Activation Total'.tr, value: activationText, valueSize: 18.sp),
                UIHelper.verticalSpace(12.h),
                _PackageStat(label: 'Validity'.tr, value: validityText, valueSize: 16.sp),
                UIHelper.verticalSpace(16.h),

                Divider(color: AppColorsTheme.borderColor(context), height: 1.h),
                UIHelper.verticalSpace(16.h),

                // "What this includes" Section Header
                Text(
                  'What this includes'.tr,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(12.h),

                // Feature List Item Chips with Orange Checkmark
                Column(
                  children: [for (final feature in featuresList) _FeatureChip(text: feature)],
                ),

                // Action Buttons (Change Package / Renew)
                if (onChangePackage != null || onRenewSubscription != null) ...[
                  UIHelper.verticalSpace(16.h),
                  Row(
                    children: [
                      if (onChangePackage != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onChangePackage,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryOrange,
                              side: const BorderSide(color: primaryOrange),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                            ),
                            child: Text('Change Package'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (onRenewSubscription != null) UIHelper.horizontalSpace(10.w),
                      ],
                      if (onRenewSubscription != null) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onRenewSubscription,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              elevation: 0,
                            ),
                            child: Text('Renew Plan'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Muted label above a bold value (fee, activation total, validity).
class _PackageStat extends StatelessWidget {
  final String label;
  final String value;
  final double valueSize;

  const _PackageStat({required this.label, required this.value, required this.valueSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
        UIHelper.verticalSpace(2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.w900,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }
}

/// Warm-tinted chip with an orange check for one package feature.
class _FeatureChip extends StatelessWidget {
  final String text;

  const _FeatureChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E221E) : const Color(0xFFFFF8F4),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? const Color(0xFF49362E) : const Color(0xFFFFE1D0),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(color: primaryOrange, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 11.sp),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
