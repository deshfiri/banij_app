import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';

/// White (dark: card) rounded card that holds an auth form and floats over
/// the hero gradient, matching the dashboard card style.
class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 22.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : primaryOrange.withValues(alpha: 0.14),
            blurRadius: 24.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// White title + subtitle shown on the hero gradient above an [AuthFormCard].
class AuthHeroTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeroTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, letterSpacing: -0.3, color: Colors.white),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }
}
