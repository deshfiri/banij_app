

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/text_font_style.dart';
import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';

class CustomDropDownWidgetTwo extends StatelessWidget {
  final String hintText;
  final TextStyle? hintsTextStyle;
  final List<DropdownItemModel> items;
  final DropdownItemModel? selectedValue;
  final Function(DropdownItemModel?) onChanged;
  final Color? backgroundColor;
  final bool isBorder;
  final Color? dropDownColor;
  final double? width;
  final String icon;
  final String? prefixIconAsset;

  const CustomDropDownWidgetTwo({
    super.key,
    required this.hintText,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.backgroundColor,
    required this.isBorder,
    this.dropDownColor,
    this.width,
    this.prefixIconAsset,
    required this.icon, this.hintsTextStyle,
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
        child: DropdownButton<DropdownItemModel>(
          isDense: true,
          isExpanded: true,
          value: selectedValue,
          icon: SvgPicture.asset(Assets.icons.arrowDown),
          dropdownColor: dropDownColor ?? AppColors.cFFFFFF,
          borderRadius: BorderRadius.circular(10.r),
          onChanged: onChanged,
          hint: Row(
            children: [
              if (prefixIconAsset != null) ...[
                SvgPicture.asset(prefixIconAsset!, height: 18.h, width: 18.w),
                SizedBox(width: 8.w),
              ],
              Text(hintText, style: hintsTextStyle ?? TextFontStyle.headline16w400CACACACpoppins),
            ],
          ),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Row(
                children: [
                  if (item.iconAssetPath != null) ...[
                    SvgPicture.asset(
                      item.iconAssetPath!,
                      height: 16.h,
                      width: 16.w,
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Text(
                    item.label,
                    style: TextFontStyle.headline16w400CFFFFFFpoppins,
                  ),
                ],
              );
            }).toList();
          },
          items:
              items.map((item) {
                return DropdownMenuItem<DropdownItemModel>(
                  value: item,
                  child: Row(
                    children: [
                      if (item.iconAssetPath != null)
                        SvgPicture.asset(
                          item.iconAssetPath!,
                          height: 16.h,
                          width: 16.w,
                        ),
                      if (item.iconAssetPath != null) SizedBox(width: 6.w),
                      Text(
                        item.label,
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

class DropdownItemModel {
  final String label;
  final String? iconAssetPath;

  DropdownItemModel({required this.label, this.iconAssetPath});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItemModel &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
}