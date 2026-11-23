import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';

/// Field building blocks for the payout method form and bank search.

/// Bold label above a form field (with its own bottom gap).
class PayoutFieldLabel extends StatelessWidget {
  final String text;

  const PayoutFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.bold,
          color: AppColorsTheme.textMainColor(context),
        ),
      ),
    );
  }
}

/// Shared outlined, filled input decoration (orange when focused).
InputDecoration payoutInputDecoration(
  BuildContext context, {
  required String hintText,
  Widget? prefixIcon,
  bool includeEnabledBorder = true,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
  );
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
    prefixIcon: prefixIcon,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    filled: true,
    fillColor: AppColorsTheme.background(context),
    border: border,
    enabledBorder: includeEnabledBorder ? border : null,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: primaryOrange, width: 1.5.w),
    ),
  );
}

/// Text input used by the payout form.
class PayoutTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  const PayoutTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
      decoration: payoutInputDecoration(context, hintText: hintText),
    );
  }
}

/// Box decoration shared by the dropdown and the bank selector.
BoxDecoration payoutBoxDecoration(BuildContext context) => BoxDecoration(
      color: AppColorsTheme.background(context),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColorsTheme.borderColor(context)),
    );

/// Bordered dropdown with a "Select..." hint.
class PayoutDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;

  const PayoutDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText = 'Select...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: payoutBoxDecoration(context),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hintText, style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context))),
          dropdownColor: AppColorsTheme.cardBg(context),
          style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Tappable field that opens a picker (used for the bank list).
class PayoutSelectField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;

  const PayoutSelectField({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: payoutBoxDecoration(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? 'Select...',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: value != null ? AppColorsTheme.textMainColor(context) : AppColorsTheme.textMutedColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: AppColorsTheme.textMutedColor(context)),
          ],
        ),
      ),
    );
  }
}
