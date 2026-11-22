import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';

/// Horizontal rule with a centered label, e.g. "OR CONTINUE WITH EMAIL".
class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Divider(color: AppColorsTheme.borderColor(context), thickness: 1));

    return Row(
      children: [
        line,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
        ),
        line,
      ],
    );
  }
}
