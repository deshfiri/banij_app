import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/dashboard_provider.dart';

class PackageSelectionWidget extends StatelessWidget {
  final VoidCallback onContinue;

  const PackageSelectionWidget({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();
    final apiPackages = dashboardProvider.packageResponse?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Your Business Package',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.verticalSpace(6.h),
        Text(
          'Choose the plan that fits your business to complete setup',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w500,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
        UIHelper.verticalSpace(20.h),

        // Package Cards List
        if (apiPackages.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: CircularProgressIndicator(color: primaryOrange),
            ),
          )
        else
          Column(
            children: List.generate(apiPackages.length, (index) {
              final pkg = apiPackages[index];
              final isSelected = dashboardProvider.selectedPackageIndex == index;
              final priceText = pkg.fee?.formatted ??
                  (pkg.fee?.amount != null
                      ? '৳ ${pkg.fee!.amount} / mo'
                      : 'Free');
              final isPopular =
                  pkg.slug?.toLowerCase().contains('professional') == true ||
                      index == 1;

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: InkWell(
                  onTap: () => dashboardProvider.setSelectedPackage(index),
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? const Color(0xFF2E1B0F)
                              : const Color(0xFFFFF7F2))
                          : AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: isSelected
                            ? primaryOrange
                            : AppColorsTheme.borderColor(context),
                        width: isSelected ? 2.w : 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryOrange.withValues(
                                  alpha: isDark ? 0.15 : 0.08)
                              : Colors.black.withValues(
                                  alpha: isDark ? 0.1 : 0.03),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Selection Radio, Title, Price & Popular Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? primaryOrange
                                      : AppColorsTheme.textMutedColor(context),
                                  size: 20.sp,
                                ),
                                UIHelper.horizontalSpace(10.w),
                                Text(
                                  pkg.name ?? 'Package',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorsTheme.textMainColor(
                                        context),
                                  ),
                                ),
                              ],
                            ),
                            if (isPopular)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryOrange,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'MOST POPULAR',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        UIHelper.verticalSpace(10.h),
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: primaryOrange,
                          ),
                        ),
                        if (pkg.shortDescription != null &&
                            pkg.shortDescription!.isNotEmpty) ...[
                          UIHelper.verticalSpace(6.h),
                          Text(
                            pkg.shortDescription!,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: AppColorsTheme.textMutedColor(context),
                            ),
                          ),
                        ],
                        UIHelper.verticalSpace(12.h),
                        Divider(
                            color: AppColorsTheme.borderColor(context)),
                        UIHelper.verticalSpace(10.h),

                        // Features List
                        if (pkg.features != null && pkg.features!.isNotEmpty)
                          Column(
                            children: pkg.features!.map((feature) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 16.sp,
                                      color: primaryOrange,
                                    ),
                                    UIHelper.horizontalSpace(8.w),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColorsTheme
                                              .textMainColor(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        UIHelper.verticalSpace(12.h),

        // Continue Button
        CustomButton(
          onTap: onContinue,
          btnName: 'Continue to Approval',
        ),
      ],
    );
  }
}
