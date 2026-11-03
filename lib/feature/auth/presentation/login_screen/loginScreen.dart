import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSupplierMode = false; // false = New Account, true = Active Supplier
  bool _isSupplierRegister = false; // false = Create account, true = Become a supplier
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API response delay
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final modeText = _isSupplierMode ? 'Active Supplier' : 'New Account';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processing Sign In as $modeText...'),
          backgroundColor: primaryOrange,
          duration: const Duration(milliseconds: 800),
        ),
      );
      Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
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

                  // Supplier vs New Account Switcher


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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 5. Password Input Field & Forgot Password with Validation
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
                  CustomFormField(
                    controller: _passwordController,
                    isPass: true,
                    isObsecure: _obscurePassword,
                    hintText: 'enter_password'.tr,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColorsTheme.textMutedColor(context),
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(14.h),

                  // 6. Remember Me Checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: primaryOrange,
                          side: BorderSide(color: AppColorsTheme.borderColor(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Text(
                        'remember_me'.tr,
                        style: TextStyle(
                          color: AppColorsTheme.textMainColor(context),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 7. Sign In Button
                  CustomButton(
                    onTap: _handleSignIn,
                    btnName: 'sign_in'.tr,
                    isLoading: _isLoading,
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 8. Dynamic Sign Up & Supplier Switcher Link at Bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSupplierRegister
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
                          Navigator.pushNamed(context, Routes.signupScreen);
                        },
                        child: Text(
                          _isSupplierRegister
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
                        'Supplier Registration Mode',
                        style: TextStyle(
                          color: AppColorsTheme.textMainColor(context),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Switch.adaptive(
                        value: _isSupplierRegister,
                        activeThumbColor: primaryOrange,
                        onChanged: (val) {
                          setState(() {
                            _isSupplierRegister = val;
                          });
                        },
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
