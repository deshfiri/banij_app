import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

/// Brand card used across the business tools screens: card surface, soft
/// orange outline and glow, and an orange bar down the left side (clipped to
/// the rounded corners). [highlighted] gives a solid orange outline and a
/// stronger glow (e.g. the default address or the latest verification).
class AccentBarCard extends StatelessWidget {
  static const double barWidth = 5;

  final Widget child;

  /// Content padding; the bar's width is added to the left side.
  final EdgeInsets? padding;
  final bool highlighted;
  final double radius;

  /// Bar colour; defaults to orange. A muted colour suits inactive items.
  final Color? barColor;

  const AccentBarCard({
    super.key,
    required this.child,
    this.padding,
    this.highlighted = false,
    this.radius = 18,
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bar = barColor ?? primaryOrange;
    final inner = padding ?? EdgeInsets.all(14.w);
    final shape = BorderRadius.circular(radius.r);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: highlighted
            ? Color.alphaBlend(primaryOrange.withValues(alpha: isDark ? 0.06 : 0.025), AppColorsTheme.cardBg(context))
            : AppColorsTheme.cardBg(context),
        borderRadius: shape,
        border: Border.all(
          color: highlighted
              ? primaryOrange
              : (isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.18)),
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : primaryOrange.withValues(alpha: highlighted ? 0.16 : 0.07),
            blurRadius: highlighted ? 18.r : 12.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: Stack(
          children: [
            Padding(
              padding: inner.copyWith(left: inner.left + barWidth.w),
              child: child,
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: barWidth.w,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bar, bar.withValues(alpha: 0.55)],
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

/// Orange gradient rounded square with a white icon.
class GradientIconTile extends StatelessWidget {
  final IconData icon;
  final double size;

  const GradientIconTile({super.key, required this.icon, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [secondaryOrange, primaryOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular((size * 0.3).r),
        boxShadow: [
          BoxShadow(color: primaryOrange.withValues(alpha: 0.28), blurRadius: 8.r, offset: const Offset(0, 3)),
        ],
      ),
      child: Icon(icon, size: (size * 0.5).sp, color: Colors.white),
    );
  }
}

/// Card heading: gradient icon tile, bold title, optional subtitle and an
/// optional trailing widget (count badge, button…).
class AccentCardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AccentCardTitle({super.key, required this.icon, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GradientIconTile(icon: icon, size: 36),
        UIHelper.horizontalSpace(10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              if (subtitle != null) ...[
                UIHelper.verticalSpace(1.h),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[UIHelper.horizontalSpace(8.w), trailing!],
      ],
    );
  }
}

/// Small neutral pill with a count ("3").
class CountPill extends StatelessWidget {
  final String label;

  const CountPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: primaryOrange),
      ),
    );
  }
}

/// Orange gradient banner with soft decorative circles, for the summary at
/// the top of a screen. Text on it should be white.
class BrandHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const BrandHeroCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : primaryOrange).withValues(alpha: isDark ? 0.35 : 0.25),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Positioned(top: -40.h, right: -30.w, child: _circle(130.w, 0.1)),
            Positioned(bottom: -34.h, right: 70.w, child: _circle(70.w, 0.07)),
            Padding(padding: padding ?? EdgeInsets.all(16.w), child: child),
          ],
        ),
      ),
    );
  }

  static Widget _circle(double size, double alpha) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
        ),
      );
}
