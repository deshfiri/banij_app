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
import '../../../../helpers/di.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
  }

  Future<void> _toggleLanguage() async {
    bool newIsBengali = !_isBengali;
    await appData.write('isBengali', newIsBengali);
    if (!mounted) return;
    setState(() {
      _isBengali = newIsBengali;
    });
    Get.updateLocale(
      newIsBengali ? const Locale('bn', 'BD') : const Locale('en', 'US'),
    );
  }

  @override
  void dispose() {
    try {
      context.read<AuthProvider>().resetLoginForm();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: Stack(
        children: [
          // Top Background Orange Decorative Accent Shapes & Circles (Onboarding Pattern)
          Positioned(
            top: -40.h,
            right: -40.w,
            child: Container(
              width: 160.w,
              height: 160.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryOrange.withValues(alpha: isDark ? 0.12 : 0.15),
              ),
            ),
          ),
          Positioned(
            top: 60.h,
            left: -30.w,
            child: Container(
              width: 120.w,
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60.r),
                color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.15),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Bar: Logo & Theme/Language Controls
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          isDark ? whiteLogo : logo,
                          width: 120.w,
                          height: 38.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Theme Switcher Button
                            GestureDetector(
                              onTap: () {
                                final newMode = !isDark;
                                context.read<ThemeProvider>().toggleDarkMode(newMode);
                              },
                              child: Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF221A15)
                                      : Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColorsTheme.borderColor(context),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_outlined,
                                  color: isDark ? const Color(0xFFFFB74D) : primaryOrange,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                            UIHelper.horizontalSpace(6.w),
                            // Language Switcher Pill Button
                            GestureDetector(
                              onTap: _toggleLanguage,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF221A15)
                                      : Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColorsTheme.borderColor(context),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6.r,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.g_translate,
                                      color: primaryOrange,
                                      size: 14.sp,
                                    ),
                                    UIHelper.horizontalSpace(4.w),
                                    Text(
                                      _isBengali ? 'বাংলা' : 'EN',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsTheme.textMainColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Immersive Full-Width Scrollable Form Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'welcome_back'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            UIHelper.verticalSpace(6.h),
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
                            UIHelper.verticalSpace(24.h),

                            // Passkey Button
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
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                            UIHelper.verticalSpace(20.h),

                            // Divider
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
                            UIHelper.verticalSpace(20.h),

                            // Email Input Field
                            CustomFieldLabel(label: 'email_address'.tr),
                            CustomFormField(
                              controller: authProvider.emailController,
                              inputType: TextInputType.emailAddress,
                              hintText: 'enter_email'.tr,
                              autofillHints: const [AutofillHints.email],
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

                            // Password & Forgot Password
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
                                    authProvider.resetLoginForm();
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
                              autofillHints: const [AutofillHints.password],
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

                            // Remember Me Checkbox
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

                            // Sign In Button
                            CustomButton(
                              onTap: () => authProvider.handleSignIn(context, _formKey),
                              btnName: 'sign_in'.tr,
                              isLoading: authProvider.isLoading,
                            ),
                            UIHelper.verticalSpace(24.h),

                            // Dynamic Sign Up & Supplier Switcher Link at Bottom
                            Consumer<AuthProvider>(
                              builder: (context, provider, child) {
                                return Column(
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          provider.isSupplierRegister
                                              ? 'become_supplier_prompt'.tr
                                              : 'new_platform'.tr,
                                          style: TextStyle(
                                            color: AppColorsTheme.textMutedColor(context),
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        UIHelper.horizontalSpace(4.w),
                                        GestureDetector(
                                          onTap: () {
                                            final isSupplier = provider.isSupplierRegister;
                                            provider.resetLoginForm();
                                            if (isSupplier) {
                                              Navigator.pushNamed(context, Routes.supplierRegisterScreen);
                                            } else {
                                              Navigator.pushNamed(context, Routes.signupScreen);
                                            }
                                          },
                                          child: Text(
                                            provider.isSupplierRegister
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
                                          value: provider.isSupplierRegister,
                                          activeThumbColor: primaryOrange,
                                          onChanged: (val) {
                                            provider.toggleSupplierRegister(val);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            UIHelper.verticalSpace(24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
