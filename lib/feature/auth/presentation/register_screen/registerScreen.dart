import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_checkbox_tile.dart';
import '../../../../common_widget/custom_dropdown_field.dart';
import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/custom_password_field.dart';
import '../../../../constants/app_constants.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/di.dart';
import '../../../../helpers/navigation_service.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/sign_up_provider.dart';
import '../../../../providers/theme_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<SignUpProvider>().resetSignUpForm();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      context.read<SignUpProvider>().resetSignUpForm();
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

  Future<void> _selectDateOfBirth(BuildContext context, SignUpProvider provider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              onSurface: isDark ? Colors.white : textMain,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDateOfBirth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final provider = context.watch<SignUpProvider>();

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
                UIHelper.verticalSpace(5.h),
                Text(
                  'enter_details_account'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
                UIHelper.verticalSpace(10.h),

                // Main Immersive Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Name
                          CustomFieldLabel(label: 'name'.tr),
                          CustomFormField(
                            controller: provider.nameController,
                            hintText: 'full_name'.tr,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'err_enter_name'.tr;
                              }
                              return null;
                            },
                          ),
                          UIHelper.verticalSpace(16.h),

                          // 2. Email address
                          CustomFieldLabel(label: 'email_address'.tr),
                          CustomFormField(
                            controller: provider.emailController,
                            inputType: TextInputType.emailAddress,
                            hintText: 'email@example.com',
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

                          // 3. Mobile number
                          CustomFieldLabel(label: 'mobile_number'.tr),
                          CustomFormField(
                            controller: provider.phoneController,
                            inputType: TextInputType.phone,
                            hintText: '+8801XXXXXXXXX',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'err_enter_phone'.tr;
                              }
                              return null;
                            },
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            'verification_code_sent_hint'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColorsTheme.textMutedColor(context),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),

                          // 4. Password
                          CustomFieldLabel(label: 'password'.tr),
                          CustomPasswordField(
                            controller: provider.passwordController,
                            hintText: 'password'.tr,
                            isObscure: provider.obscurePassword,
                            onToggleObscure: provider.toggleObscurePassword,
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
                          UIHelper.verticalSpace(16.h),

                          // 5. Confirm password
                          CustomFieldLabel(label: 'confirm_password'.tr),
                          CustomPasswordField(
                            controller: provider.confirmPasswordController,
                            hintText: 'confirm_password'.tr,
                            isObscure: provider.obscureConfirmPassword,
                            onToggleObscure: provider.toggleObscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'err_confirm_password'.tr;
                              }
                              if (value != provider.passwordController.text) {
                                return 'err_passwords_match'.tr;
                              }
                              return null;
                            },
                          ),
                          UIHelper.verticalSpace(24.h),

                          // Section Header: Optional Fields
                          Text(
                            'optional_later'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColorsTheme.textMutedColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),

                          // 6. Date of birth
                          CustomFieldLabel(label: 'date_of_birth'.tr),
                          CustomFormField(
                            controller: provider.dobController,
                            isRead: true,
                            hintText: 'mm/dd/yyyy',
                            onTap: () => _selectDateOfBirth(context, provider),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                color: AppColorsTheme.textMutedColor(context),
                                size: 18.sp,
                              ),
                              onPressed: () => _selectDateOfBirth(context, provider),
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),

                          // 7. Gender Dropdown
                          CustomFieldLabel(label: 'gender'.tr),
                          CustomDropdownField<String>(
                            value: provider.selectedGender,
                            items: provider.genderOptions,
                            itemLabelBuilder: (gender) => gender,
                            onChanged: provider.setSelectedGender,
                          ),
                          UIHelper.verticalSpace(16.h),

                          // 8. Country Dropdown
                          CustomFieldLabel(label: 'country'.tr),
                          CustomDropdownField<String>(
                            value: provider.selectedCountry,
                            items: provider.countryOptions,
                            itemLabelBuilder: (country) => country,
                            onChanged: provider.setSelectedCountry,
                          ),
                          UIHelper.verticalSpace(16.h),

                          // 9. Nationality
                          CustomFieldLabel(label: 'nationality'.tr),
                          CustomFormField(
                            controller: provider.nationalityController,
                            hintText: 'Bangladeshi',
                          ),
                          UIHelper.verticalSpace(16.h),

                          // 10. Partner code
                          CustomFieldLabel(label: 'partner_code'.tr),
                          CustomFormField(
                            controller: provider.partnerCodeController,
                            hintText: 'optional_later'.tr,
                          ),
                          UIHelper.verticalSpace(20.h),

                          // Checkbox 1: Terms
                          CustomCheckboxTile(
                            value: provider.acceptTerms,
                            onChanged: provider.setAcceptTerms,
                            label: 'accept_terms'.tr,
                          ),
                          UIHelper.verticalSpace(12.h),

                          // Checkbox 2: Privacy Policy
                          CustomCheckboxTile(
                            value: provider.acceptPrivacy,
                            onChanged: provider.setAcceptPrivacy,
                            label: 'accept_privacy'.tr,
                          ),
                          UIHelper.verticalSpace(28.h),

                          // Create Account Button
                          CustomButton(
                            onTap: () async {
                              final success = await provider.handleCreateAccount(context, _formKey);
                              if (success && context.mounted) {
                                appData.write(kKeyIsLoggedIn, true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('creating_account_success'.tr),
                                    backgroundColor: primaryOrange,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                                NavigationService.navigateToReplacementUntil(Routes.dashboardScreen);
                              }
                            },
                            btnName: 'create_account'.tr,
                            isLoading: provider.isLoading,
                          ),
                          UIHelper.verticalSpace(24.h),

                          // Already have an account link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'new_platform'.tr,
                                style: TextStyle(
                                  color: AppColorsTheme.textMutedColor(context),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'sign_in'.tr,
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpace(16.h),
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
