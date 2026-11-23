import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Semantic colours for an order status string (paid/delivered → green,
/// cancelled → red, processing → blue, anything else → amber).
class OrderStatusStyle {
  final Color foreground;
  final Color lightBackground;
  final IconData icon;

  const OrderStatusStyle._(this.foreground, this.lightBackground, this.icon);

  factory OrderStatusStyle.of(String status) {
    final s = status.toLowerCase();
    if (s.contains('deliver') ||
        s.contains('complet') ||
        s.contains('active') ||
        s.contains('paid')) {
      return const OrderStatusStyle._(
        successGreenDark,
        successGreenLight,
        Icons.check_circle_rounded,
      );
    }
    if (s.contains('cancel')) {
      return const OrderStatusStyle._(
        errorRed,
        errorRedLight,
        Icons.cancel_rounded,
      );
    }
    if (s.contains('overdue')) {
      return const OrderStatusStyle._(
        errorRed,
        errorRedLight,
        Icons.schedule_rounded,
      );
    }
    if (s.contains('pending')) {
      return const OrderStatusStyle._(
        primaryOrange,
        Color(0xFFFFE8D8),
        Icons.schedule_rounded,
      );
    }
    if (s.contains('process')) {
      return const OrderStatusStyle._(
        infoBlue,
        infoBlueLight,
        Icons.autorenew_rounded,
      );
    }
    return const OrderStatusStyle._(
      warningYellow,
      warningYellowLight,
      Icons.schedule_rounded,
    );
  }

  /// Pill background: the light tint in light mode, a translucent tint in dark mode.
  Color background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? foreground.withValues(alpha: 0.18) : lightBackground;
  }

  /// Text/icon colour; slightly brighter on dark backgrounds.
  Color text(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Color.lerp(foreground, Colors.white, 0.25)! : foreground;
  }
}

/// Rounded status pill with icon, e.g. "✓ PAID".
class OrderStatusPill extends StatelessWidget {
  final String status;

  /// White pill for use on the orange/slate hero gradient.
  final bool onHero;

  const OrderStatusPill({super.key, required this.status, this.onHero = false});

  @override
  Widget build(BuildContext context) {
    final style = OrderStatusStyle.of(status);
    final fg = onHero ? style.foreground : style.text(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: onHero ? Colors.white : style.background(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: style.foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 12.sp, color: fg),
          UIHelper.horizontalSpace(4.w),
          Flexible(
            child: Text(
              status.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
