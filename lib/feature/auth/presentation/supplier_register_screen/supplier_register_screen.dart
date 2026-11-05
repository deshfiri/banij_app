import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/custom_password_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/supplier_register_provider.dart';

class SupplierRegisterScreen extends StatefulWidget {
  const SupplierRegisterScreen({super.key});

  @override
  State<SupplierRegisterScreen> createState() => _SupplierRegisterScreenState();
}

class _SupplierRegisterScreenState extends State<SupplierRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildStepIndicator(BuildContext context, int currentStep) {
    final steps = [
      {'num': 1, 'title': 'step_business'.tr},
      {'num': 2, 'title': 'step_contact'.tr},
      {'num': 3, 'title': 'step_security'.tr},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final stepNum = step['num'] as int;
        final stepTitle = step['title'] as String;
        final isCompleted = stepNum < currentStep;
        final isActive = stepNum == currentStep;
        final isLast = index == steps.length - 1;

        const successGreen = Color(0xFF10B981);

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: index == 0
                          ? Colors.transparent
                          : (stepNum <= currentStep
                              ? successGreen
                              : AppColorsTheme.borderColor(context)),
                    ),
                  ),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? successGreen
                          : (isActive ? primaryOrange : AppColorsTheme.cardBg(context)),
                      border: Border.all(
                        color: isCompleted
                            ? successGreen
                            : (isActive
                                ? primaryOrange
                                : AppColorsTheme.borderColor(context)),
                        width: 1.5.w,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : Text(
                            '$stepNum',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : AppColorsTheme.textMutedColor(context),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: isLast
                          ? Colors.transparent
                          : (stepNum < currentStep
                              ? successGreen
                              : AppColorsTheme.borderColor(context)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                stepTitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
                  color: isActive || isCompleted
                      ? AppColorsTheme.textMainColor(context)
                      : AppColorsTheme.textMutedColor(context),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SupplierRegisterProvider>();

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
                  // Top Logo Header with Back Icon
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => provider.handleBack(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColorsTheme.textMainColor(context),
                          size: 22.sp,
                        ),
                      ),
                      UIHelper.horizontalSpace(4.w),
                      Image.asset(
                        isDark ? whiteLogo : logo,
                        width: 100.w,
                        height: 40.h,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Supplier Registration Tag
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryOrange,
                        ),
                      ),
                      UIHelper.horizontalSpace(6.w),
                      Text(
                        'supplier_registration'.tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMutedColor(context),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(8.h),

                  // Title & Subtitle
                  Text(
                    'become_a_supplier'.tr,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(6.h),
                  Text(
                    'supplier_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 3-Step Indicator
                  _buildStepIndicator(context, provider.currentStep),
                  UIHelper.verticalSpace(28.h),

                  // Section Header Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECE0),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            provider.currentStep == 1
                                ? Icons.business
                                : (provider.currentStep == 2
                                    ? Icons.email_outlined
                                    : Icons.lock_outline),
                            color: primaryOrange,
                            size: 22.sp,
                          ),
                        ),
                        UIHelper.horizontalSpace(14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.currentStep == 1
                                    ? 'business_information'.tr
                                    : (provider.currentStep == 2
                                        ? 'contact_and_documents'.tr
                                        : 'account_security'.tr),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                              ),
                              UIHelper.verticalSpace(2.h),
                              Text(
                                provider.currentStep == 1
                                    ? 'business_info_subtitle'.tr
                                    : (provider.currentStep == 2
                                        ? 'contact_and_documents_subtitle'.tr
                                        : 'account_security_subtitle'.tr),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  // Step 1 Fields (Business)
                  if (provider.currentStep == 1) ...[
                    CustomFieldLabel(label: 'business_name'.tr, isRequired: true),
                    CustomFormField(
                      controller: provider.businessNameController,
                      hintText: 'enter_business_name'.tr,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'err_enter_business_name'.tr
                          : null,
                    ),
                    UIHelper.verticalSpace(16.h),
                    CustomFieldLabel(label: 'contact_person'.tr, isRequired: true),
                    CustomFormField(
                      controller: provider.contactPersonController,
                      hintText: 'enter_contact_person'.tr,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'err_enter_contact_person'.tr
                          : null,
                    ),
                    UIHelper.verticalSpace(16.h),
                    CustomFieldLabel(label: 'business_address'.tr, isRequired: true),
                    CustomFormField(
                      controller: provider.businessAddressController,
                      maxline: 4,
                      hintText: 'enter_business_address'.tr,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'err_enter_business_address'.tr
                          : null,
                    ),
                  ],

                  // Step 2 Fields (Contact & documents)
                  if (provider.currentStep == 2) ...[
                    CustomFieldLabel(label: 'email_address'.tr, isRequired: true),
                    CustomFormField(
                      controller: provider.emailController,
                      inputType: TextInputType.emailAddress,
                      hintText: 'email@example.com',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'err_enter_email'.tr;
                        }
                        final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(val.trim())) {
                          return 'err_valid_email'.tr;
                        }
                        return null;
                      },
                    ),
                    UIHelper.verticalSpace(16.h),
                    CustomFieldLabel(label: 'phone_number'.tr, isRequired: true),
                    CustomFormField(
                      controller: provider.phoneController,
                      inputType: TextInputType.phone,
                      hintText: '+8801XXXXXXXXX',
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'err_enter_phone'.tr
                          : null,
                    ),
                    UIHelper.verticalSpace(16.h),
                    CustomFieldLabel(label: 'trade_licence_optional'.tr, isRequired: false),
                    CustomFormField(
                      controller: provider.tradeLicenceController,
                      hintText: 'trade_licence_optional'.tr,
                    ),
                    UIHelper.verticalSpace(16.h),
                    CustomFieldLabel(label: 'tin_optional'.tr, isRequired: false),
                    CustomFormField(
                      controller: provider.tinController,
                      hintText: 'tin_optional'.tr,
                    ),
                  ],

                  // Step 3 Fields (Account security)
                  if (provider.currentStep == 3) ...[
                    CustomFieldLabel(label: 'password'.tr, isRequired: true),
                    CustomPasswordField(
                      controller: provider.passwordController,
                      hintText: 'create_password'.tr,
                      isObscure: provider.obscurePassword,
                      onToggleObscure: provider.toggleObscurePassword,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'err_enter_password'.tr;
                        }
                        if (val.length < 6) {
                          return 'err_password_length'.tr;
                        }
                        return null;
                      },
                    ),
                    UIHelper.verticalSpace(16.h),
                    CustomFieldLabel(label: 'confirm_password'.tr, isRequired: true),
                    CustomPasswordField(
                      controller: provider.confirmPasswordController,
                      hintText: 'confirm_password'.tr,
                      isObscure: provider.obscureConfirmPassword,
                      onToggleObscure: provider.toggleObscureConfirmPassword,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'err_confirm_password'.tr;
                        }
                        if (val != provider.passwordController.text) {
                          return 'err_passwords_match'.tr;
                        }
                        return null;
                      },
                    ),
                  ],

                  UIHelper.verticalSpace(28.h),

                  // Bottom Buttons: Side-by-side Back and Continue / Create Supplier account
                  Row(
                    children: [
                      // Back Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.handleBack(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColorsTheme.cardBg(context),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            side: BorderSide(color: AppColorsTheme.borderColor(context)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, color: AppColorsTheme.textMainColor(context), size: 16.sp),
                              UIHelper.horizontalSpace(6.w),
                              Text(
                                'back'.tr,
                                style: TextStyle(
                                  color: AppColorsTheme.textMainColor(context),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      UIHelper.horizontalSpace(16.w),

                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          onTap: () => provider.handleContinue(context, _formKey),
                          btnName: provider.currentStep == 3 ? 'create_supplier_account'.tr : 'continue'.tr,
                          isLoading: provider.isLoading,
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),

                  // Footer Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'already_supplier'.tr,
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
