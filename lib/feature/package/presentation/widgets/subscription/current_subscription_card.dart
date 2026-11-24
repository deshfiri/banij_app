import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/subscription_model.dart';
import 'subscription_feature_list.dart';
import 'subscription_format.dart';

/// The package the account is on now: name, status, dates, payment info,
/// entitlements and the change / renew / cancel actions.
class CurrentSubscriptionCard extends StatelessWidget {
  final SubscriptionTermModel term;
  final bool canRenew;
  final String? renewalBlocker;
  final bool isRenewing;
  final bool isCancelling;
  final VoidCallback onChangePackage;
  final VoidCallback onRenew;
  final VoidCallback onCancel;

  const CurrentSubscriptionCard({
    super.key,
    required this.term,
    required this.canRenew,
    required this.renewalBlocker,
    required this.isRenewing,
    required this.isCancelling,
    required this.onChangePackage,
    required this.onRenew,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = AppColorsTheme.textMutedColor(context);
    final isBusy = isRenewing || isCancelling;
    final frequency = SubscriptionFormat.frequency(term.renewalFrequency);
    final renewsAt = [
      term.renewalFee?.display,
      if (frequency.isNotEmpty) frequency,
    ].whereType<String>().join(' · ');
    final canCancel = term.isActive && !term.isCancelled;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
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
          // Name, status and "Change package".
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      term.displayName,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      SubscriptionFormat.termLine(term),
                      style: TextStyle(fontSize: 11.5.sp, color: muted, height: 1.4),
                    ),
                  ],
                ),
              ),
              UIHelper.horizontalSpace(8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ToneBadge(label: term.displayStatus, tone: term.statusTone),
                  UIHelper.verticalSpace(8.h),
                  _ChangePackageButton(onPressed: isBusy ? null : onChangePackage),
                ],
              ),
            ],
          ),

          if (term.inGracePeriod && SubscriptionFormat.date(term.graceEndsAt) != null) ...[
            UIHelper.verticalSpace(12.h),
            _NoteBanner(
              icon: Icons.warning_amber_rounded,
              color: primaryOrange,
              text: '${'sub_grace_until'.tr} ${SubscriptionFormat.date(term.graceEndsAt)}',
            ),
          ],
          if (!canRenew && renewalBlocker != null) ...[
            UIHelper.verticalSpace(12.h),
            Text(renewalBlocker!, style: TextStyle(fontSize: 12.sp, color: muted, height: 1.4)),
          ],

          // Paid / renewal fee / source.
          UIHelper.verticalSpace(14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _InfoItem(label: 'sub_paid'.tr, value: term.paid?.display ?? '—')),
              UIHelper.horizontalSpace(12.w),
              Expanded(child: _InfoItem(label: 'sub_renews_at'.tr, value: renewsAt.isEmpty ? '—' : renewsAt)),
            ],
          ),
          if (term.sourceLabel != null) ...[
            UIHelper.verticalSpace(12.h),
            _InfoItem(label: 'sub_how_you_got_it'.tr, value: term.sourceLabel!),
          ],

          if (term.features.isNotEmpty) ...[
            UIHelper.verticalSpace(16.h),
            SubscriptionFeatureList(features: term.features),
          ],

          if (canRenew) ...[
            UIHelper.verticalSpace(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isBusy ? null : onRenew,
                icon: isRenewing
                    ? SizedBox.square(
                        dimension: 16.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.autorenew_rounded, size: 18.sp),
                label: Text(
                  'sub_renew_package'.tr,
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, 46.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],

          if (canCancel) ...[
            UIHelper.verticalSpace(10.h),
            TextButton.icon(
              onPressed: isBusy ? null : onCancel,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
              ),
              icon: isCancelling
                  ? SizedBox.square(
                      dimension: 14.sp,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)),
                    )
                  : Icon(Icons.cancel_outlined, size: 16.sp),
              label: Text('sub_cancel_package'.tr, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChangePackageButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _ChangePackageButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        side: BorderSide(color: primaryOrange.withValues(alpha: 0.6)),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        minimumSize: Size(0, 32.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      child: Text('sub_change_package'.tr, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context))),
        UIHelper.verticalSpace(2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }
}

class _NoteBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _NoteBanner({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          UIHelper.horizontalSpace(8.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 11.5.sp, color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
