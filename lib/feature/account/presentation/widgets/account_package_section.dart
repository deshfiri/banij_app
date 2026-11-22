import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_decoration.dart';
import '../../../package/model/package_model.dart';
import 'account_ui.dart';

/// Package list; the selected package gets an orange border and badge.
/// Shows a shimmer while the list is empty (as before).
class AccountPackageSection extends StatelessWidget {
  final List<PackageItemModel> packages;
  final String? selectedSlug;

  const AccountPackageSection({super.key, required this.packages, required this.selectedSlug});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccountSectionTitle(title: 'your_package'.tr, subtitle: 'package_desc'.tr),
        UIHelper.verticalSpace(16.h),
        if (packages.isEmpty)
          const _PackageShimmer()
        else
          for (final pkg in packages) _PackageCard(pkg: pkg, isSelected: pkg.slug == selectedSlug),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageItemModel pkg;
  final bool isSelected;

  const _PackageCard({required this.pkg, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final base = DashboardCardDecoration.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: isSelected ? base.copyWith(border: Border.all(color: primaryOrange, width: 2.w)) : base,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pkg.name ?? '',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
              if (isSelected) AccountStatusChip(label: 'Selected'.tr, color: primaryOrange, filled: true),
            ],
          ),
          if (pkg.shortDescription != null && pkg.shortDescription!.isNotEmpty) ...[
            UIHelper.verticalSpace(6.h),
            Text(
              pkg.shortDescription!,
              style: TextStyle(fontSize: 12.5.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
            ),
          ],
          UIHelper.verticalSpace(14.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              if (pkg.fee?.formatted != null) _StatBox(label: 'Fee'.tr, value: pkg.fee!.formatted!),
              if (pkg.activationTotal?.formatted != null)
                _StatBox(label: 'Activation Total'.tr, value: pkg.activationTotal!.formatted!),
              if (pkg.validityDays != null)
                _StatBox(label: 'Validity'.tr, value: '@days Days'.trParams({'days': '${pkg.validityDays}'})),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          Divider(color: AppColorsTheme.borderColor(context), height: 1),
          UIHelper.verticalSpace(12.h),
          Text(
            'what_this_includes'.tr,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
          ),
          UIHelper.verticalSpace(10.h),
          if (pkg.features == null || pkg.features!.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'Data not found'.tr,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontStyle: FontStyle.italic,
                  color: AppColorsTheme.textMutedColor(context),
                ),
              ),
            )
          else
            for (final feature in pkg.features!) _FeatureRow(text: feature),
        ],
      ),
    );
  }
}

/// Label + bold value tile (fee, activation total, validity).
class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context))),
          UIHelper.verticalSpace(2.h),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;

  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: 13.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context))),
          ),
        ],
      ),
    );
  }
}

class _PackageShimmer extends StatelessWidget {
  const _PackageShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        children: List.generate(
          2,
          (_) => Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 120.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
          ),
        ),
      ),
    );
  }
}
