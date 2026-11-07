import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/di.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/forgot_password_provider.dart';
import '../../../../providers/theme_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<ForgotPasswordProvider>().resetForm();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      context.read<ForgotPasswordProvider>().resetForm();
    } catch (_) {}
    super.dispose();
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
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final provider = context.watch<ForgotPasswordProvider>();

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
                // Top Header Bar: Back Button, Centered Logo & Theme/Language Controls
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 100% Perfectly Centered Brand Logo (Fixed Position)
                      Center(
                        child: Image.asset(
                          isDark ? whiteLogo : logo,
                          width: 120.w,
                          height: 38.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Back Button on Left
                      Positioned(
                        left: 0,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColorsTheme.textMainColor(context),
                            size: 22.sp,
                          ),
                        ),
                      ),
                      // Theme & Language Controls on Right
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

                // Main Immersive Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Icon Illustration
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryOrange.withValues(alpha: isDark ? 0.15 : 0.1),
                                border: Border.all(
                                  color: primaryOrange.withValues(alpha: 0.3),
                                  width: 1.5.w,
                                ),
                              ),
                              child: Icon(
                                Icons.lock_reset_rounded,
                                size: 44.sp,
                                color: primaryOrange,
                              ),
                            ),
                          ),
                          UIHelper.verticalSpace(24.h),

                          // Title & Subtitle
                          Text(
                            'forgot_password_title'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.sp,
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
                              height: 1.45,
                            ),
                          ),
                          UIHelper.verticalSpace(32.h),

                          // Email Input Field
                          CustomFieldLabel(label: 'email_address'.tr),
                          CustomFormField(
                            controller: provider.emailController,
                            inputType: TextInputType.emailAddress,
                            hintText: 'enter_email'.tr,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'please_enter_email'.tr;
                              }
                              final emailRegex = RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'valid_email_address'.tr;
                              }
                              return null;
                            },
                          ),
                          UIHelper.verticalSpace(28.h),

                          // Send Reset Instructions Button
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

                          // Back to Sign In Link
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
