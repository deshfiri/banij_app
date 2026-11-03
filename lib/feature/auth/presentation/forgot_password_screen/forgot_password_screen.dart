import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/forgot_password_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ForgotPasswordProvider>();
      if (provider.email.isNotEmpty) {
        _emailController.text = provider.email;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<ForgotPasswordProvider>().updateEmail(_emailController.text.trim());

      setState(() {
        _isLoading = true;
      });

      // Simulate API response delay
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('reset_email_sent'.tr),
          backgroundColor: primaryOrange,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

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
                  // 1. Logo (Header)
                  Center(
                    child: Image.asset(
                      isDark ? whiteLogo : logo,
                      width: 140.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'email_address'.tr,
                      style: TextStyle(
                        color: AppColorsTheme.textMainColor(context),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  CustomFormField(
                    controller: _emailController,
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
                    onTap: _handleResetPassword,
                    btnName: 'send_reset_instructions'.tr,
                    isLoading: _isLoading,
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
