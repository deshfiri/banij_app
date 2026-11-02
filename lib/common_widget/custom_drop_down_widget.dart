

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';

class CustomDropDownWidget extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;
  final Color? backgroundColor;
  final bool isBorder;
  final Color? dropDownColor;
  final double? width;

  const CustomDropDownWidget({
    super.key,
    required this.hintText,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.backgroundColor,
    required this.isBorder,
    this.dropDownColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        border: isBorder ? Border.all(color: AppColors.c000000) : null,
        borderRadius: BorderRadius.circular(20.r),
        color: backgroundColor ?? AppColors.cFFFFFF.withAlpha(25),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isDense: true,
          dropdownColor: dropDownColor,
          
          borderRadius: BorderRadius.circular(10.r),
          isExpanded: true,
          hint: Text(
            hintText,
            style: TextFontStyle.headline16w400CACACACpoppins,
          ),
          value: selectedValue,
          icon: SvgPicture.asset(
           ""
          ),
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Text(
                    value,
                    style: TextFontStyle.headline16w400CEFEFEFpoppins,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
