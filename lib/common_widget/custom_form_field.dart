import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';

final class CustomFormField extends StatelessWidget {
  final String? hintText;
  final double? hintFontSize;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final double? fieldHeight;
  final int? maxline;
  final String? Function(String?)? validator;
  final bool? validation;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isObsecure;
  final bool isPass;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? labelStyle;
  final TextStyle? style;
  final bool? isEnabled;
  final double? cursorHeight;
  final Color? disableColor;
  final bool isRead;
  final double? contentPadding;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? enableBorderColor;
  final Color? focusBorderColor;
  final Color? fillColor;
  final TextStyle? hintsTextStyle;

  const CustomFormField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.inputType,
    this.fieldHeight,
    this.maxline,
    this.validator,
    this.validation = false,
    this.suffixIcon,
    this.prefixIcon,
    this.isObsecure = false,
    this.isPass = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.labelStyle,
    this.isEnabled,
    this.style,
    this.cursorHeight,
    this.disableColor,
    this.isRead = false,
    this.borderRadius,
    this.padding,
    this.hintFontSize,
    this.enableBorderColor,
    this.focusBorderColor,
    this.fillColor,
    this.hintsTextStyle,
    this.contentPadding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      child: TextFormField(
        readOnly: isRead,
        cursorHeight: cursorHeight ?? 20.h,
        cursorColor: primaryOrange,
        focusNode: focusNode,
        obscureText: isPass ? isObsecure : false,
        textInputAction: textInputAction,
        autovalidateMode:
            validation == true
                ? AutovalidateMode.always
                : AutovalidateMode.onUserInteraction,
        validator: validator,
        maxLines: maxline ?? 1,
        controller: controller,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        onTap: onTap,
        inputFormatters: inputFormatters,
        enabled: isEnabled,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: contentPadding ?? 14.h,
            horizontal: 16.w,
          ),
          filled: true,
          fillColor: fillColor ?? AppColorsTheme.cardBg(context),
          isDense: true,
          suffixIcon: suffixIcon,
          prefixIcon:
              prefixIcon != null
                  ? Padding(padding: EdgeInsets.all(12.sp), child: prefixIcon)
                  : null,
          hintText: hintText,
          hintStyle:
              hintsTextStyle ??
              TextStyle(
                color: AppColorsTheme.textMutedColor(context),
                fontSize: hintFontSize ?? 14.sp,
              ),
          labelText: labelText,
          labelStyle: labelStyle,
          errorStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.redAccent,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            borderSide: BorderSide(
              color: focusBorderColor ?? primaryOrange,
              width: 1.5.w,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            borderSide: BorderSide(
              color: disableColor ?? AppColorsTheme.borderColor(context),
              width: 1.w,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.w),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            borderSide: BorderSide(
              color: enableBorderColor ?? AppColorsTheme.borderColor(context),
              width: 1.w,
            ),
          ),
        ),
        style:
            style ??
            TextStyle(
              color: AppColorsTheme.textMainColor(context),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
        keyboardType: inputType,
      ),
    );
  }
}
