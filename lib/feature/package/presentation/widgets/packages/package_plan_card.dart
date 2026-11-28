import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/package_model.dart';
import '../subscription/subscription_format.dart';

/// One plan in the Packages list (also Account › Package), in brand orange:
/// a left-side bar, tinted header, gradient plan icon, large price with
/// validity, "What's included" checklist, payable-now / deposit figures, any
/// over-limit warning and the "Choose this plan" button. The current plan
/// gets an orange outline and glow and shows "You're on this plan" instead
/// of the button.
class PackagePlanCard extends StatefulWidget {
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

  @override
  State<PackagePlanCard> createState() => _PackagePlanCardState();
}

class _PackagePlanCardState extends State<PackagePlanCard> {
  /// Features shown before "Show all".
  static const int _collapsedFeatures = 4;
  static const double _barWidth = 5;

  bool _showAllFeatures = false;

  PackageItemModel get _pkg => widget.package;

  /// Badge label + tone from the change type ("Downgraded", "Upgrade", …).
  (String, String)? get _badge {
    if (widget.isCurrent) return ('pkg_current_plan'.tr, 'success');
    final type = _pkg.changeType?.toLowerCase() ?? '';
    final label = _pkg.changeLabel;
    final tone = _pkg.changeTone ??
        (type.contains('up') ? 'info' : type.contains('down') ? 'neutral' : null);
    if (label != null) return (label, tone ?? 'neutral');
    if (type.isEmpty) return null;
    return (type[0].toUpperCase() + type.substring(1), tone ?? 'neutral');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrent = widget.isCurrent;
    const accent = primaryOrange;
    // Lifted in dark mode so icons and text stay readable on dark cards.
    final accentFg = isDark ? Color.lerp(accent, Colors.white, 0.25)! : accent;
    final price = _pkg.fee?.formatted ?? _pkg.activationTotal?.formatted;
    final payable = _pkg.payableNow?.formatted ?? _pkg.payableNow?.amount ?? _pkg.activationTotal?.formatted;
    final deposit = _pkg.requiredDeposit?.formatted;
    final appliesFrom = SubscriptionFormat.date(_pkg.appliesFrom);
    final features = _pkg.features ?? const <String>[];
    final violations = _pkg.limitViolations;
    final canChoose = !isCurrent && _pkg.canSelect != false;
    final cardBg = AppColorsTheme.cardBg(context);
    final radius = BorderRadius.circular(20.r);

    // Only show "Payable now" when it adds something beyond the price.
    final showPayable = payable != null && payable != price;
    final figures = [
      if (showPayable) _Figure(label: 'pkg_payable_now'.tr, value: payable, highlight: true),
      if (deposit != null) _Figure(label: 'pkg_required_deposit'.tr, value: deposit),
    ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header on a soft accent wash: icon, name, description, badge, price.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent.withValues(alpha: isDark ? 0.14 : 0.08), accent.withValues(alpha: 0)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(_barWidth.w + 14.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PlanIcon(accent: accent),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pkg.name ?? 'Package',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          if (_pkg.shortDescription?.isNotEmpty == true) ...[
                            UIHelper.verticalSpace(2.h),
                            Text(
                              _pkg.shortDescription!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                height: 1.35,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_badge != null) ...[
                      UIHelper.horizontalSpace(8.w),
                      ToneBadge(label: _badge!.$1, tone: _badge!.$2),
                    ],
                  ],
                ),
                if (price != null) ...[
                  UIHelper.verticalSpace(16.h),
                  _PriceLine(price: price, validityDays: _pkg.validityDays),
                ] else if (_pkg.validityDays != null) ...[
                  UIHelper.verticalSpace(12.h),
                  _MetaLine(
                    icon: Icons.schedule_rounded,
                    text: '@days Days'.trParams({'days': '${_pkg.validityDays}'}),
                  ),
                ],
                if (appliesFrom != null) ...[
                  UIHelper.verticalSpace(8.h),
                  _MetaLine(icon: Icons.event_rounded, text: '${'pkg_applies_from'.tr} $appliesFrom'),
                ],
              ],
            ),
          ),
        ),

        // What's included.
        if (features.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: _barWidth.w + 14.w, right: 16.w),
            child: _DashedDivider(color: AppColorsTheme.borderColor(context)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(_barWidth.w + 14.w, 14.h, 16.w, 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'pkg_whats_included'.tr.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: accentFg,
                  ),
                ),
                UIHelper.verticalSpace(10.h),
                for (final feature in _showAllFeatures ? features : features.take(_collapsedFeatures))
                  _FeatureRow(feature: feature, accent: accentFg),
                if (features.length > _collapsedFeatures)
                  TextButton(
                    onPressed: () => setState(() => _showAllFeatures = !_showAllFeatures),
                    style: TextButton.styleFrom(
                      foregroundColor: accentFg,
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 30.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllFeatures
                              ? 'pkg_show_less'.tr
                              : 'pkg_show_all_features'.trParams({'count': '${features.length}'}),
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                        ),
                        Icon(
                          _showAllFeatures ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],

        // Payable now / deposit, over-limit warning, blocked reason, action.
        Padding(
          padding: EdgeInsets.fromLTRB(_barWidth.w + 14.w, features.isEmpty ? 0 : 8.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (figures.isNotEmpty) ...[
                _FiguresBox(figures: figures, accent: accentFg),
                UIHelper.verticalSpace(14.h),
              ],
              if (violations.isNotEmpty) ...[
                _LimitWarning(violations: violations),
                UIHelper.verticalSpace(14.h),
              ],
              if (_pkg.blockedReason != null && violations.isEmpty && !isCurrent) ...[
                _MetaLine(icon: Icons.info_outline_rounded, text: _pkg.blockedReason!),
                UIHelper.verticalSpace(14.h),
              ],
              if (isCurrent)
                const _ActivePlanBar()
              else if (canChoose)
                _ChooseButton(
                  accent: accent,
                  isLoading: widget.isSelecting,
                  isDisabled: widget.isDisabled,
                  onPressed: widget.onChoose,
                ),
            ],
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? Color.alphaBlend(accent.withValues(alpha: isDark ? 0.06 : 0.025), cardBg) : cardBg,
        borderRadius: radius,
        border: Border.all(
          color: isCurrent ? accent : AppColorsTheme.borderColor(context),
          width: isCurrent ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? accent.withValues(alpha: isDark ? 0.28 : 0.18)
                : (isDark ? Colors.black.withValues(alpha: 0.25) : accent.withValues(alpha: 0.08)),
            blurRadius: isCurrent ? 20.r : 14.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // Clipped to the card so the left bar follows the rounded corners.
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            content,
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _barWidth.w,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accent, accent.withValues(alpha: 0.55)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plan icon on a gradient of the card's accent.
class _PlanIcon extends StatelessWidget {
  final Color accent;

  const _PlanIcon({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(accent, Colors.white, 0.18)!, accent],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 10.r, offset: const Offset(0, 4))],
      ),
      child: Icon(Icons.workspace_premium_rounded, size: 23.sp, color: Colors.white),
    );
  }
}

/// "৳1,500.00 / 180 Days" with the price large.
class _PriceLine extends StatelessWidget {
  final String price;
  final String? validityDays;

  const _PriceLine({required this.price, required this.validityDays});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 6.w,
      children: [
        Text(
          price,
          style: TextStyle(
            fontSize: 27.sp,
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        if (validityDays != null)
          Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: Text(
              '/ ${'@days Days'.trParams({'days': validityDays!})}',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Icon(icon, size: 14.sp, color: muted),
        ),
        UIHelper.horizontalSpace(6.w),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 11.5.sp, height: 1.35, color: muted)),
        ),
      ],
    );
  }
}

/// Thin dashed rule between the header and the feature list.
class _DashedDivider extends StatelessWidget {
  final Color color;

  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dash = 5.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dash + gap)).floor();
        return Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              Container(width: dash, height: 1, color: color),
              if (i < count - 1) const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}

/// One feature. "Label: value" strings become a label with the value on the
/// right; true/false values become included / not-included rows.
class _FeatureRow extends StatelessWidget {
  final String feature;
  final Color accent;

  const _FeatureRow({required this.feature, required this.accent});

  @override
  Widget build(BuildContext context) {
    final split = feature.indexOf(': ');
    final label = split > 0 ? feature.substring(0, split) : feature;
    final value = split > 0 ? feature.substring(split + 2).trim() : null;
    final lower = value?.toLowerCase();
    final included = !const ['false', 'no', '0'].contains(lower);
    final isFlag = const ['true', 'yes', 'false', 'no'].contains(lower);
    final muted = AppColorsTheme.textMutedColor(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              color: included ? accent.withValues(alpha: 0.14) : muted.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: 12.sp,
              color: included ? accent : muted.withValues(alpha: 0.7),
            ),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.3,
                color: included ? AppColorsTheme.textMainColor(context) : muted,
                decoration: included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
          if (value != null && !isFlag && value.isNotEmpty) ...[
            UIHelper.horizontalSpace(8.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure {
  final String label;
  final String value;
  final bool highlight;

  const _Figure({required this.label, required this.value, this.highlight = false});
}

/// Payable now / required deposit side by side in a soft inner box.
class _FiguresBox extends StatelessWidget {
  final List<_Figure> figures;
  final Color accent;

  const _FiguresBox({required this.figures, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < figures.length; i++) ...[
              if (i > 0) VerticalDivider(width: 24.w, thickness: 1, color: AppColorsTheme.borderColor(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      figures[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context)),
                    ),
                    UIHelper.verticalSpace(3.h),
                    Text(
                      figures[i].value,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                        color: figures[i].highlight ? accent : AppColorsTheme.textMainColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width "Choose this plan →" on the card's accent gradient.
class _ChooseButton extends StatelessWidget {
  final Color accent;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const _ChooseButton({
    required this.accent,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28.r);
    return Opacity(
      opacity: isDisabled && !isLoading ? 0.5 : 1,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent, Color.lerp(accent, Colors.white, 0.2)!]),
          borderRadius: radius,
          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.32), blurRadius: 14.r, offset: const Offset(0, 5))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled || isLoading ? null : onPressed,
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
                        Text(
                          'pkg_choose_plan'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                        UIHelper.horizontalSpace(8.w),
                        Icon(Icons.arrow_forward_rounded, size: 17.sp, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Replaces the button on the current plan.
class _ActivePlanBar extends StatelessWidget {
  const _ActivePlanBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = isDark ? const Color(0xFF34D399) : successGreenDark;
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: successGreen.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: successGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_rounded, size: 18.sp, color: green),
          UIHelper.horizontalSpace(8.w),
          Text(
            'pkg_active_plan'.tr,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: green),
          ),
        ],
      ),
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
