import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import 'custom_form_field.dart';

class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isObscure;
  final VoidCallback onToggleObscure;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isObscure,
    required this.onToggleObscure,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      controller: controller,
      isPass: true,
      isObsecure: isObscure,
      hintText: hintText,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onChanged: onChanged,
      autofillHints: autofillHints,
      suffixIcon: IconButton(
        icon: Icon(
          isObscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColorsTheme.textMutedColor(context),
          size: 20.sp,
        ),
        onPressed: onToggleObscure,
      ),
      validator: validator,
    );
  }
}
