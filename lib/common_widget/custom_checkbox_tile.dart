import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

class CustomCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final TextStyle? labelStyle;

  const CustomCheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20.w,
          height: 20.h,
          child: Checkbox(
            value: value,
            activeColor: primaryOrange,
            side: BorderSide(color: AppColorsTheme.borderColor(context)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            onChanged: onChanged,
          ),
        ),
        UIHelper.horizontalSpace(8.w),
        Expanded(
          child: Text(
            label,
            style: labelStyle ??
                TextStyle(
                  color: AppColorsTheme.textMainColor(context),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
