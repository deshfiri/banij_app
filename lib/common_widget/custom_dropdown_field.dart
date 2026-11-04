import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.hintText,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColorsTheme.cardBg(context),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColorsTheme.textMutedColor(context),
            size: 20.sp,
          ),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColorsTheme.textMainColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
