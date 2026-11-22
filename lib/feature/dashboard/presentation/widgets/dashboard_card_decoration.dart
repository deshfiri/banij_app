import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';

/// Shared light/dark surface for dashboard cards (charts, quick access, banners).
class DashboardCardDecoration {
  DashboardCardDecoration._();

  static BoxDecoration of(BuildContext context, {double radius = 20}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: AppColorsTheme.cardBg(context),
      borderRadius: BorderRadius.circular(radius.r),
      border: Border.all(
        color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.18),
        width: 1.w,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.25) : primaryOrange.withValues(alpha: 0.06),
          blurRadius: 10.r,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
