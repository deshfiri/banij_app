import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String btnName;
  final Color? borderColor;
  final double? padding;
  final Color? color;
  final Color? gradientTopColor;
  final Color? gradientBottomColor;
  final bool gradient;
  final double? horizontalSpace;
  final Widget? icons;
  final Widget? suffixIcons;
  final TextStyle? textStyle;
  final double? isBorderRadius;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.btnName,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.isBorderRadius,
    this.color,
    this.icons,
    this.gradient = false,
    this.gradientTopColor,
    this.gradientBottomColor,
    this.suffixIcons,
    this.horizontalSpace,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(isBorderRadius?.r ?? 10.r),
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(minHeight: 48.h),
        padding: EdgeInsets.symmetric(vertical: padding ?? 14.h, horizontal: 16.w),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: gradient ? null : (color ?? primaryOrange),
          borderRadius: BorderRadius.circular(isBorderRadius?.r ?? 10.r),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          gradient: gradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    gradientTopColor ?? const Color(0xff3732D6),
                    gradientBottomColor ?? const Color(0xffDB58F4),
                  ],
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (isLoading)
              SizedBox(
                width: 22.w,
                height: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else ...[
              if (icons != null) ...[
                icons!,
                UIHelper.horizontalSpace(horizontalSpace ?? 12.w),
              ],
              Expanded(
                child: Text(
                  btnName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle ??
                      TextStyle(
                        color: Colors.white,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (suffixIcons != null) ...[
                UIHelper.horizontalSpace(horizontalSpace ?? 12.w),
                suffixIcons!,
              ],
            ],
          ],
        ),
      ),
    );
  }
}
