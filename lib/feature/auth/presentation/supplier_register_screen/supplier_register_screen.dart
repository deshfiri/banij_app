import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';

class SupplierRegisterScreen extends StatefulWidget {
  const SupplierRegisterScreen({super.key});

  @override
  State<SupplierRegisterScreen> createState() => _SupplierRegisterScreenState();
}

class _SupplierRegisterScreenState extends State<SupplierRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _currentStep = 1; // 1: Business, 2: Contact, 3: Security

  // Step 1 Controllers (Business)
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();

  // Step 2 Controllers (Contact & documents)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tradeLicenceController = TextEditingController();
  final TextEditingController _tinController = TextEditingController();

  // Step 3 Controllers (Account security)
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _businessAddressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _tradeLicenceController.dispose();
    _tinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitRegistration();
      }
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Supplier registration submitted successfully!'),
        backgroundColor: primaryOrange,
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildStepIndicator() {
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
        final isCompleted = stepNum < _currentStep;
        final isActive = stepNum == _currentStep;
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
                          : (stepNum <= _currentStep
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
                          : (stepNum < _currentStep
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

  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: AppColorsTheme.textMainColor(context),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: primaryOrange),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        UIHelper.verticalSpace(8.h),
      ],
    );
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Logo Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                  _buildStepIndicator(),
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
                            _currentStep == 1
                                ? Icons.business
                                : (_currentStep == 2
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
                                _currentStep == 1
                                    ? 'business_information'.tr
                                    : (_currentStep == 2
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
                                _currentStep == 1
                                    ? 'business_info_subtitle'.tr
                                    : (_currentStep == 2
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
                  if (_currentStep == 1) ...[
                    _buildFieldLabel('business_name'.tr),
                    CustomFormField(
                      controller: _businessNameController,
                      hintText: 'enter_business_name'.tr,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter business name'
                          : null,
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildFieldLabel('contact_person'.tr),
                    CustomFormField(
                      controller: _contactPersonController,
                      hintText: 'enter_contact_person'.tr,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter contact person name'
                          : null,
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildFieldLabel('business_address'.tr),
                    CustomFormField(
                      controller: _businessAddressController,
                      maxline: 4,
                      hintText: 'enter_business_address'.tr,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter business address'
                          : null,
                    ),
                  ],

                  // Step 2 Fields (Contact & documents)
                  if (_currentStep == 2) ...[
                    _buildFieldLabel('email_address'.tr),
                    CustomFormField(
                      controller: _emailController,
                      inputType: TextInputType.emailAddress,
                      hintText: 'email@example.com',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter email address';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(val.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildFieldLabel('phone_number'.tr),
                    CustomFormField(
                      controller: _phoneController,
                      inputType: TextInputType.phone,
                      hintText: '+8801XXXXXXXXX',
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter mobile number'
                          : null,
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildFieldLabel('trade_licence_optional'.tr, isRequired: false),
                    CustomFormField(
                      controller: _tradeLicenceController,
                      hintText: 'Trade licence number',
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildFieldLabel('tin_optional'.tr, isRequired: false),
                    CustomFormField(
                      controller: _tinController,
                      hintText: 'Tax identification number',
                    ),
                  ],

                  // Step 3 Fields (Account security)
                  if (_currentStep == 3) ...[
                    _buildFieldLabel('password'.tr),
                    CustomFormField(
                      controller: _passwordController,
                      isPass: true,
                      isObsecure: _obscurePassword,
                      hintText: 'create_password'.tr,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColorsTheme.textMutedColor(context),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please create password';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    UIHelper.verticalSpace(16.h),
                    _buildFieldLabel('Confirm password'),
                    CustomFormField(
                      controller: _confirmPasswordController,
                      isPass: true,
                      isObsecure: _obscureConfirmPassword,
                      hintText: 'Confirm password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColorsTheme.textMutedColor(context),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm password';
                        }
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
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
                          onPressed: _handleBack,
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
                      // Continue / Create Account Button
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          onTap: _handleContinue,
                          btnName: _currentStep == 3 ? 'create_supplier_account'.tr : 'continue'.tr,
                          isLoading: _isLoading,
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
