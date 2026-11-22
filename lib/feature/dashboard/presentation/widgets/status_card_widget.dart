import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import 'dashboard_card_decoration.dart';

/// KYC step card: "Current status: KYC pending", a progress banner and the
/// list of required documents. Default texts are translation keys.
class StatusCardWidget extends StatelessWidget {
  final String statusTitle;
  final String statusHighlight;
  final String progressLabel;
  final List<StatusItemModel> items;

  StatusCardWidget({
    super.key,
    String? statusTitle,
    String? statusHighlight,
    String? progressLabel,
    List<StatusItemModel>? items,
  })  : statusTitle = statusTitle ?? 'Current status: ',
        statusHighlight = statusHighlight ?? 'KYC pending',
        progressLabel = progressLabel ?? 'Documents Pending',
        items = items ??
            [
              const StatusItemModel(title: 'Government ID', iconData: Icons.badge_outlined),
              const StatusItemModel(title: 'Proof of Address', iconData: Icons.location_on_outlined),
              const StatusItemModel(
                title: 'Self-Declaration Form',
                statusTag: '(Pending)',
                iconData: Icons.description_outlined,
              ),
            ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: DashboardCardDecoration.of(context, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: statusTitle.tr,
                  style: TextStyle(color: AppColorsTheme.textMainColor(context), fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: statusHighlight.tr,
                  style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          UIHelper.verticalSpace(14.h),

          // Progress banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.14 : 0.07),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: primaryOrange.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [primaryOrange, secondaryOrange]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sync_rounded, size: 16.sp, color: Colors.white),
                ),
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: Text(
                    progressLabel.tr,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          for (final item in items) _DocumentRow(item: item),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final StatusItemModel item;

  const _DocumentRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.iconData, size: 18.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Text(
              item.title.tr,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
          if (item.statusTag != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: warningYellow.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                item.statusTag!.tr,
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: warningYellow),
              ),
            ),
        ],
      ),
    );
  }
}

class StatusItemModel {
  final String title;
  final String? statusTag;
  final IconData iconData;

  const StatusItemModel({
    required this.title,
    this.statusTag,
    required this.iconData,
  });
}
