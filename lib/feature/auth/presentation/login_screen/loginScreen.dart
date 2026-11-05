import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_checkbox_tile.dart';
import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/custom_password_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
                      logo,
                      width: 140.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  UIHelper.verticalSpace(0.h),
                  Text(
                    'welcome_back'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'sign_in_workspace'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColorsTheme.textMutedColor(context),
                      height: 1.4,
                    ),
                  ),
                  UIHelper.verticalSpace(28.h),

                  // 2. Passkey Button
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.key, color: primaryOrange, size: 18.sp),
                    label: Text(
                      'sign_in_passkey'.tr,
                      style: TextStyle(
                        color: AppColorsTheme.textMainColor(context),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColorsTheme.cardBg(context),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: AppColorsTheme.borderColor(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 3. Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColorsTheme.borderColor(context), thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'or_email'.tr,
                          style: TextStyle(
                            color: AppColorsTheme.textMutedColor(context),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColorsTheme.borderColor(context), thickness: 1),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 4. Email Input Field with Validation
                  CustomFieldLabel(label: 'email_address'.tr),
                  CustomFormField(
                    controller: authProvider.emailController,
                    inputType: TextInputType.emailAddress,
                    hintText: 'enter_email'.tr,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'err_enter_email'.tr;
                      }
                      final emailRegex = RegExp(
                        r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'err_valid_email'.tr;
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 5. Password Input Field & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'password'.tr,
                        style: TextStyle(
                          color: AppColorsTheme.textMainColor(context),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.forgotPasswordScreen);
                        },
                        child: Text(
                          'forgot_password'.tr,
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(8.h),
                  CustomPasswordField(
                    controller: authProvider.passwordController,
                    hintText: 'enter_password'.tr,
                    isObscure: authProvider.obscurePassword,
                    onToggleObscure: authProvider.toggleObscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'err_enter_password'.tr;
                      }
                      if (value.length < 6) {
                        return 'err_password_length'.tr;
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(14.h),

                  // 6. Remember Me Checkbox
                  CustomCheckboxTile(
                    value: authProvider.rememberMe,
                    onChanged: authProvider.toggleRememberMe,
                    label: 'remember_me'.tr,
                    labelStyle: TextStyle(
                      color: AppColorsTheme.textMainColor(context),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 7. Sign In Button
                  CustomButton(
                    onTap: () => authProvider.handleSignIn(context, _formKey),
                    btnName: 'sign_in'.tr,
                    isLoading: authProvider.isLoading,
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 8. Dynamic Sign Up & Supplier Switcher Link at Bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authProvider.isSupplierRegister
                            ? 'become_supplier_prompt'.tr
                            : 'new_platform'.tr,
                        style: TextStyle(
                          color: AppColorsTheme.textMutedColor(context),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (authProvider.isSupplierRegister) {
                            Navigator.pushNamed(context, Routes.supplierRegisterScreen);
                          } else {
                            Navigator.pushNamed(context, Routes.signupScreen);
                          }
                        },
                        child: Text(
                          authProvider.isSupplierRegister
                              ? 'become_supplier'.tr
                              : 'create_account'.tr,
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'supplier_registration_mode'.tr,
                        style: TextStyle(
                          color: AppColorsTheme.textMainColor(context),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Switch.adaptive(
                        value: authProvider.isSupplierRegister,
                        activeThumbColor: primaryOrange,
                        onChanged: authProvider.toggleSupplierRegister,
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
