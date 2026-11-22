import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Outlined "Sign in with a passkey" button with an orange key badge.
class PasskeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PasskeyButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(16.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
            borderRadius: radius,
            border: Border.all(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.key_rounded, color: primaryOrange, size: 16.sp),
              ),
              UIHelper.horizontalSpace(10.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
