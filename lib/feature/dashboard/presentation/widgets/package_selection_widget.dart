import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../common_widget/gradient_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/dashboard_provider.dart';
import 'dashboard_card_decoration.dart';

/// Account setup step 4: pick a package, then continue to approval.
class PackageSelectionWidget extends StatelessWidget {
  final VoidCallback onContinue;

  const PackageSelectionWidget({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final apiPackages = dashboardProvider.packageResponse?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Your Business Package'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.verticalSpace(4.h),
        Text(
          'Choose the plan that fits your business to complete setup'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w500, color: AppColorsTheme.textMutedColor(context)),
        ),
        UIHelper.verticalSpace(18.h),
        if (apiPackages.isEmpty)
          _buildPackageShimmer(context)
        else
          for (int index = 0; index < apiPackages.length; index++)
            Builder(builder: (context) {
              final pkg = apiPackages[index];
              return _PackageCard(
                name: pkg.name ?? 'Package'.tr,
                priceText: pkg.fee?.formatted ?? (pkg.fee?.amount != null ? '৳ ${pkg.fee!.amount} / mo' : 'Free'.tr),
                description: pkg.shortDescription,
                features: pkg.features ?? const [],
                isSelected: dashboardProvider.selectedPackageIndex == index,
                isPopular: pkg.slug?.toLowerCase().contains('professional') == true || index == 1,
                onTap: () => dashboardProvider.setSelectedPackage(index),
              );
            }),
        UIHelper.verticalSpace(8.h),
        GradientButton(
          label: 'Continue to Approval'.tr,
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: onContinue,
        ),
      ],
    );
  }

  Widget _buildPackageShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        children: List.generate(
          2,
          (_) => Container(
            margin: EdgeInsets.only(bottom: 14.h),
            height: 140.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
          ),
        ),
      ),
    );
  }
}

/// Selectable package card; selected = orange border + tinted surface.
class _PackageCard extends StatelessWidget {
  final String name;
  final String priceText;
  final String? description;
  final List<String> features;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback onTap;

  const _PackageCard({
    required this.name,
    required this.priceText,
    required this.description,
    required this.features,
    required this.isSelected,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = DashboardCardDecoration.of(context);
    final decoration = isSelected
        ? base.copyWith(
            color: isDark ? AppColorsTheme.cardBg(context) : lightBackground,
            border: Border.all(color: primaryOrange, width: 2.w),
            boxShadow: [
              BoxShadow(color: primaryOrange.withValues(alpha: 0.18), blurRadius: 14.r, offset: const Offset(0, 5)),
            ],
          )
        : base;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.w),
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? primaryOrange : AppColorsTheme.textMutedColor(context),
                      size: 20.sp,
                    ),
                    UIHelper.horizontalSpace(10.w),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                    ),
                    if (isPopular)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 11.sp, color: Colors.white),
                            UIHelper.horizontalSpace(3.w),
                            Text(
                              'MOST POPULAR'.tr,
                              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                UIHelper.verticalSpace(10.h),
                Text(priceText, style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: primaryOrange)),
                if (description != null && description!.isNotEmpty) ...[
                  UIHelper.verticalSpace(4.h),
                  Text(
                    description!,
                    style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                  ),
                ],
                if (features.isNotEmpty) ...[
                  UIHelper.verticalSpace(10.h),
                  Divider(color: AppColorsTheme.borderColor(context), height: 1),
                  UIHelper.verticalSpace(10.h),
                  for (final feature in features)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16.sp, color: successGreen),
                          UIHelper.horizontalSpace(8.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
