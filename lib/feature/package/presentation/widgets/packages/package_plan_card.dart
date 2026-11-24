import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/package_model.dart';
import '../subscription/subscription_format.dart';

/// One plan in the Packages list: name, change badge, "applies from",
/// package price / payable now, over-limit warning and "Choose this plan".
class PackagePlanCard extends StatelessWidget {
  final PackageItemModel package;
  final bool isCurrent;
  final bool isSelecting;
  final bool isDisabled;
  final VoidCallback onChoose;

  const PackagePlanCard({
    super.key,
    required this.package,
    required this.isCurrent,
    required this.isSelecting,
    required this.isDisabled,
    required this.onChoose,
  });

  /// Badge label + tone from the change type ("Downgraded", "Upgrade", …).
  (String, String)? get _badge {
    if (isCurrent) return ('pkg_current_plan'.tr, 'success');
    final type = package.changeType?.toLowerCase() ?? '';
    final label = package.changeLabel;
    final tone = package.changeTone ??
        (type.contains('up') ? 'info' : type.contains('down') ? 'neutral' : null);
    if (label != null) return (label, tone ?? 'neutral');
    if (type.isEmpty) return null;
    return (type[0].toUpperCase() + type.substring(1), tone ?? 'neutral');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = AppColorsTheme.textMutedColor(context);
    final name = package.name ?? 'Package';
    final badge = _badge;
    final appliesFrom = SubscriptionFormat.date(package.appliesFrom);
    final price = package.fee?.formatted ?? package.activationTotal?.formatted;
    final payable = package.payableNow?.formatted ??
        package.payableNow?.amount ??
        package.activationTotal?.formatted;
    final violations = package.limitViolations;
    final canChoose = !isCurrent && package.canSelect != false;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCurrent ? primaryOrange : AppColorsTheme.borderColor(context),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + badge.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    if (appliesFrom != null) ...[
                      UIHelper.verticalSpace(2.h),
                      Text(
                        '${'pkg_applies_from'.tr} $appliesFrom',
                        style: TextStyle(fontSize: 11.5.sp, color: muted),
                      ),
                    ] else if (package.shortDescription?.isNotEmpty == true) ...[
                      UIHelper.verticalSpace(2.h),
                      Text(
                        package.shortDescription!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5.sp, color: muted, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null) ...[
                UIHelper.horizontalSpace(8.w),
                ToneBadge(label: badge.$1, tone: badge.$2),
              ],
            ],
          ),

          // Price / payable now.
          if (price != null || payable != null) ...[
            UIHelper.verticalSpace(14.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (price != null)
                  Expanded(child: _PriceItem(label: '$name ${'pkg_package'.tr}', value: price)),
                if (price != null && payable != null) UIHelper.horizontalSpace(12.w),
                if (payable != null)
                  Expanded(child: _PriceItem(label: 'pkg_payable_now'.tr, value: payable, highlight: true)),
              ],
            ),
          ],

          if (package.validityDays != null) ...[
            UIHelper.verticalSpace(8.h),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 13.sp, color: muted),
                UIHelper.horizontalSpace(4.w),
                Text(
                  '@days Days'.trParams({'days': '${package.validityDays}'}),
                  style: TextStyle(fontSize: 11.sp, color: muted),
                ),
              ],
            ),
          ],

          // Over-limit warning.
          if (violations.isNotEmpty) ...[
            UIHelper.verticalSpace(14.h),
            _LimitWarning(violations: violations),
          ],
          if (package.blockedReason != null && violations.isEmpty && !isCurrent) ...[
            UIHelper.verticalSpace(12.h),
            Text(package.blockedReason!, style: TextStyle(fontSize: 11.5.sp, color: muted, height: 1.4)),
          ],

          // Action.
          if (canChoose) ...[
            UIHelper.verticalSpace(14.h),
            ElevatedButton(
              onPressed: isDisabled ? null : onChoose,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryOrange.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(0, 38.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: isSelecting
                  ? SizedBox.square(
                      dimension: 16.sp,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('pkg_choose_plan'.tr, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PriceItem({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context)),
        ),
        UIHelper.verticalSpace(2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
            color: highlight ? primaryOrange : AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }
}

/// Amber box: "You are over this plan's limits" + one line per violation.
class _LimitWarning extends StatelessWidget {
  final List<PackageLimitViolation> violations;

  const _LimitWarning({required this.violations});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18.sp, color: amber),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'pkg_over_limits'.tr,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                for (final violation in violations) ...[
                  UIHelper.verticalSpace(4.h),
                  Text(
                    violation.text,
                    style: TextStyle(fontSize: 11.5.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
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
