import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

/// Full-width primary button with the brand orange gradient and glow.
/// While [isLoading] it shows a spinner and ignores taps.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? trailingIcon;
  final double? height;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28.r);

    return Container(
      width: double.infinity,
      height: height ?? 54.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: primaryOrange.withValues(alpha: 0.35), blurRadius: 16.r, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isLoading
                  ? [
                      SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ]
                  : [
                      // Long labels (e.g. "Create Supplier account", Bangla text)
                      // in narrow buttons shrink to fit instead of overflowing.
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        UIHelper.horizontalSpace(8.w),
                        Icon(trailingIcon, color: Colors.white, size: 18.sp),
                      ],
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
