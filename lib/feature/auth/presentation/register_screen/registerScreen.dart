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
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/sign_up_provider.dart';

class RegisterScreen extends StatelessWidget {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  const RegisterScreen({super.key});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SignUpProvider>();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
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
                  UIHelper.verticalSpace(24.h),

                  // 1. Name
                  CustomFieldLabel(label: 'name'.tr),
                  CustomFormField(
                    controller: provider.nameController,
                    hintText: 'full_name'.tr,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
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
                        return 'Please enter your email address';
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

                  // 3. Mobile number
                  CustomFieldLabel(label: 'mobile_number'.tr),
                  CustomFormField(
                    controller: provider.phoneController,
                    inputType: TextInputType.phone,
                    hintText: '+8801XXXXXXXXX',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your mobile number';
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
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
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
                        return 'Please confirm your password';
                      }
                      if (value != provider.passwordController.text) {
                        return 'Passwords do not match';
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
                    hintText: 'Optional',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Creating account successfully...'),
                            backgroundColor: primaryOrange,
                          ),
                        );
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
      ),
    );
  }
}
