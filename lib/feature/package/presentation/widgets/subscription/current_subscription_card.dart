import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/accent_bar_card.dart';
import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/subscription_model.dart';
import 'subscription_feature_list.dart';
import 'subscription_format.dart';

/// The package the account is on now, as three blocks: an orange plan
/// banner (name, status, time left, start / end), a "Plan details" card
/// (paid, renewal, source, Change package) and "What this includes", then
/// the renew / cancel actions.
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
    final isBusy = isRenewing || isCancelling;
    final canCancel = term.isActive && !term.isCancelled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlanBanner(term: term),
        UIHelper.verticalSpace(16.h),
        _PlanDetailsCard(
          term: term,
          canRenew: canRenew,
          renewalBlocker: renewalBlocker,
          onChangePackage: isBusy ? null : onChangePackage,
        ),
        if (term.features.isNotEmpty) ...[
          UIHelper.verticalSpace(16.h),
          AccentBarCard(
            padding: EdgeInsets.fromLTRB(14.w, 16.h, 16.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccentCardTitle(
                  icon: Icons.checklist_rounded,
                  title: 'sub_what_includes'.tr,
                  trailing: CountPill(label: '${term.features.length}'),
                ),
                UIHelper.verticalSpace(8.h),
                SubscriptionFeatureList(features: term.features),
              ],
            ),
          ),
        ],
        if (canRenew) ...[
          UIHelper.verticalSpace(18.h),
          _RenewButton(isLoading: isRenewing, onPressed: isBusy ? null : onRenew),
        ],
        if (canCancel) ...[
          UIHelper.verticalSpace(canRenew ? 6.h : 14.h),
          Center(
            child: TextButton.icon(
              onPressed: isBusy ? null : onCancel,
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
              icon: isCancelling
                  ? SizedBox.square(
                      dimension: 14.sp,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)),
                    )
                  : Icon(Icons.cancel_outlined, size: 16.sp),
              label: Text(
                'sub_cancel_package'.tr,
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Orange banner: plan name and status, time left in the term, start / end.
class _PlanBanner extends StatelessWidget {
  final SubscriptionTermModel term;

  const _PlanBanner({required this.term});

  /// Share of the term already used (0–1), when both ends are known.
  double? get _usedFraction {
    final start = DateTime.tryParse(term.startedAt ?? '');
    final end = DateTime.tryParse(term.expiresAt ?? '');
    if (start == null || end == null) return null;
    final total = end.difference(start).inDays;
    final left = term.daysRemaining;
    if (total <= 0 || left == null) return null;
    return (1 - left / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final (toneColor, _) = ToneBadge.styleFor(term.statusTone);
    final started = SubscriptionFormat.date(term.startedAt);
    final ends = SubscriptionFormat.date(term.expiresAt);
    final used = _usedFraction;
    final daysLeft = term.daysRemaining;

    return BrandHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.workspace_premium_rounded, size: 25.sp, color: Colors.white),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sub_current_package'.tr,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      term.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(color: toneColor, shape: BoxShape.circle),
                    ),
                    UIHelper.horizontalSpace(5.w),
                    Text(
                      term.displayStatus,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: Color.lerp(toneColor, Colors.black, 0.25),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (used != null && daysLeft != null) ...[
            UIHelper.verticalSpace(16.h),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14.sp, color: Colors.white),
                UIHelper.horizontalSpace(5.w),
                Text(
                  SubscriptionFormat.daysLeft(daysLeft),
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  '${(used * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: used,
                minHeight: 6.h,
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ],
          if (started != null || ends != null || term.doesNotExpire) ...[
            UIHelper.verticalSpace(14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (started != null) _GlassChip(icon: Icons.play_circle_outline_rounded, text: '${'sub_started'.tr} $started'),
                if (term.doesNotExpire)
                  _GlassChip(icon: Icons.all_inclusive_rounded, text: 'sub_does_not_expire'.tr)
                else if (ends != null)
                  _GlassChip(icon: Icons.event_rounded, text: '${'sub_ends'.tr} $ends'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: Colors.white),
          UIHelper.horizontalSpace(5.w),
          Text(text, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

/// Paid / renewal / source, grace-period and renewal notes, Change package.
class _PlanDetailsCard extends StatelessWidget {
  final SubscriptionTermModel term;
  final bool canRenew;
  final String? renewalBlocker;
  final VoidCallback? onChangePackage;

  const _PlanDetailsCard({
    required this.term,
    required this.canRenew,
    required this.renewalBlocker,
    required this.onChangePackage,
  });

  @override
  Widget build(BuildContext context) {
    final frequency = SubscriptionFormat.frequency(term.renewalFrequency);
    final renewsAt = [
      term.renewalFee?.display,
      if (frequency.isNotEmpty) frequency,
    ].whereType<String>().join(' · ');
    final graceUntil = SubscriptionFormat.date(term.graceEndsAt);

    return AccentBarCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccentCardTitle(
            icon: Icons.receipt_long_rounded,
            title: 'sub_plan_details'.tr,
            trailing: _ChangePackageButton(onPressed: onChangePackage),
          ),
          if (term.inGracePeriod && graceUntil != null) ...[
            UIHelper.verticalSpace(14.h),
            _NoteBanner(
              icon: Icons.warning_amber_rounded,
              color: primaryOrange,
              text: '${'sub_grace_until'.tr} $graceUntil',
            ),
          ],
          UIHelper.verticalSpace(14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColorsTheme.innerCardBg(context),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _Figure(label: 'sub_paid'.tr, value: term.paid?.display ?? '—', highlight: true)),
                  VerticalDivider(width: 24.w, thickness: 1, color: AppColorsTheme.borderColor(context)),
                  Expanded(child: _Figure(label: 'sub_renews_at'.tr, value: renewsAt.isEmpty ? '—' : renewsAt)),
                ],
              ),
            ),
          ),
          if (term.sourceLabel != null) ...[
            UIHelper.verticalSpace(12.h),
            Row(
              children: [
                Icon(Icons.card_giftcard_rounded, size: 16.sp, color: AppColorsTheme.textMutedColor(context)),
                UIHelper.horizontalSpace(8.w),
                Text(
                  '${'sub_how_you_got_it'.tr}: ',
                  style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
                Expanded(
                  child: Text(
                    term.sourceLabel!,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!canRenew && renewalBlocker != null) ...[
            UIHelper.verticalSpace(12.h),
            _NoteBanner(icon: Icons.info_outline_rounded, color: AppColorsTheme.textMutedColor(context), text: renewalBlocker!),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Figure({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context))),
        UIHelper.verticalSpace(3.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: highlight ? primaryOrange : AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }
}

class _ChangePackageButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _ChangePackageButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.swap_horiz_rounded, size: 15.sp),
      label: Text('sub_change_package'.tr, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        backgroundColor: primaryOrange.withValues(alpha: 0.06),
        side: BorderSide(color: primaryOrange.withValues(alpha: 0.5)),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        minimumSize: Size(0, 32.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }
}

/// Full-width "Renew package" on the orange gradient.
class _RenewButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _RenewButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28.r);
    return Opacity(
      opacity: onPressed == null && !isLoading ? 0.55 : 1,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 14.r, offset: const Offset(0, 5)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Center(
              child: isLoading
                  ? SizedBox.square(
                      dimension: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.autorenew_rounded, size: 18.sp, color: Colors.white),
                        UIHelper.horizontalSpace(8.w),
                        Text(
                          'sub_renew_package'.tr,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
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
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 11.5.sp, color: color, fontWeight: FontWeight.w600, height: 1.35)),
          ),
        ],
      ),
    );
  }
}
