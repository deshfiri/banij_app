


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';
import 'custom_button.dart';

class CustomContinueButton extends StatelessWidget {
    final bool isFormValid;
  final VoidCallback onTap;
  final String buttonText;
  const CustomContinueButton({
    super.key,
  required this.isFormValid, required this.onTap, required this.buttonText,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 80.w),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: CustomButton(
          onTap: isFormValid ? onTap : () {},
          btnName: buttonText,
          textStyle: TextFontStyle.headline16w600CFFFFFFpoppins.copyWith(
            color: isFormValid
                ? AppColors.cFFFFFF
                : AppColors.cFFFFFF.withValues(alpha: 0.5),
          ),
          color: isFormValid
              ? AppColors.allPrimaryColor
              : AppColors.allPrimaryColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
