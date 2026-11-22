import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';

/// Capsule indicator: the active page stretches into an orange gradient pill.
class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const OnboardingPageIndicator({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: isActive ? 26.w : 8.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            gradient: isActive ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
            color: isActive ? null : (isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.2)),
          ),
        );
      }),
    );
  }
}
