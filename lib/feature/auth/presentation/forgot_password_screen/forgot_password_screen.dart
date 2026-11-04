import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/forgot_password_provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Back Icon & Logo Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColorsTheme.textMainColor(context),
                          size: 22.sp,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            isDark ? whiteLogo : logo,
                            width: 140.w,
                            height: 60.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: 40.w),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),
                  Text(
                    'forgot_password_title'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'forgot_password_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColorsTheme.textMutedColor(context),
                      height: 1.4,
                    ),
                  ),
                  UIHelper.verticalSpace(32.h),

                  // 2. Email Input Field with Validation
                  CustomFieldLabel(label: 'email_address'.tr),
                  CustomFormField(
                    inputType: TextInputType.emailAddress,
                    hintText: 'enter_email'.tr,
                    onChanged: (val) {
                      context.read<ForgotPasswordProvider>().updateEmail(val);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'please_enter_email'.tr;
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'valid_email_address'.tr;
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(28.h),

                  // 3. Send Reset Instructions Button
                  CustomButton(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('reset_email_sent'.tr),
                            backgroundColor: primaryOrange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    btnName: 'send_reset_instructions'.tr,
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 4. Back to Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 14.sp,
                              color: primaryOrange,
                            ),
                            UIHelper.horizontalSpace(4.w),
                            Text(
                              'back_to_sign_in'.tr,
                              style: TextStyle(
                                color: primaryOrange,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
