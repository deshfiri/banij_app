import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';

class CustomFieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: AppColorsTheme.textMainColor(context),
              fontSize: fontSize ?? 13.sp,
              fontWeight: FontWeight.w600,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: primaryOrange,
                        fontSize: fontSize ?? 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}
