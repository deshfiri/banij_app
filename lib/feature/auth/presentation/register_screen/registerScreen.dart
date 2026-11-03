import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _partnerCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _isLoading = false;

  String _selectedGender = 'Not specified';
  final List<String> _genderOptions = [
    'Not specified',
    'Male',
    'Female',
    'Other',
  ];

  String _selectedCountry = 'Bangladesh';
  final List<String> _countryOptions = [
    'Bangladesh',
    'India',
    'United States',
    'United Kingdom',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _partnerCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
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
      setState(() {
        _dobController.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _handleCreateAccount() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms || !_acceptPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept both Terms & Conditions and Privacy Policy to proceed.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
      const SnackBar(
        content: Text('Creating account successfully...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              color: AppColorsTheme.textMainColor(context),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
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
                  // Logo
                  Center(
                    child: Image.asset(
                      isDark ? whiteLogo : logo,
                      width: 140.w,
                      height: 70.h,
                      fit: BoxFit.contain,
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
                  UIHelper.verticalSpace(24.h),

                  // 1. Name
                  _buildFieldLabel(context, 'name'.tr),
                  CustomFormField(
                    controller: _nameController,
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
                  _buildFieldLabel(context, 'email_address'.tr),
                  CustomFormField(
                    controller: _emailController,
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
                  _buildFieldLabel(context, 'mobile_number'.tr),
                  CustomFormField(
                    controller: _phoneController,
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
                  _buildFieldLabel(context, 'password'.tr),
                  CustomFormField(
                    controller: _passwordController,
                    isPass: true,
                    isObsecure: _obscurePassword,
                    hintText: 'password'.tr,
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
                  _buildFieldLabel(context, 'confirm_password'.tr),
                  CustomFormField(
                    controller: _confirmPasswordController,
                    isPass: true,
                    isObsecure: _obscureConfirmPassword,
                    hintText: 'confirm_password'.tr,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColorsTheme.textMutedColor(context),
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
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
                  _buildFieldLabel(context, 'date_of_birth'.tr),
                  CustomFormField(
                    controller: _dobController,
                    isRead: true,
                    hintText: 'mm/dd/yyyy',
                    onTap: _selectDateOfBirth,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: AppColorsTheme.textMutedColor(context),
                        size: 18.sp,
                      ),
                      onPressed: _selectDateOfBirth,
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 7. Gender Dropdown
                  _buildFieldLabel(context, 'gender'.tr),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        dropdownColor: AppColorsTheme.cardBg(context),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColorsTheme.textMutedColor(context),
                          size: 20.sp,
                        ),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          }
                        },
                        items:
                            _genderOptions.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColorsTheme.textMainColor(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 8. Country Dropdown
                  _buildFieldLabel(context, 'country'.tr),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountry,
                        isExpanded: true,
                        dropdownColor: AppColorsTheme.cardBg(context),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColorsTheme.textMutedColor(context),
                          size: 20.sp,
                        ),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCountry = newValue;
                            });
                          }
                        },
                        items:
                            _countryOptions.map((country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(
                                  country,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColorsTheme.textMainColor(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 9. Nationality
                  _buildFieldLabel(context, 'nationality'.tr),
                  CustomFormField(
                    controller: _nationalityController,
                    hintText: 'Bangladeshi',
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 10. Partner code
                  _buildFieldLabel(context, 'partner_code'.tr),
                  CustomFormField(
                    controller: _partnerCodeController,
                    hintText: 'Optional',
                  ),
                  UIHelper.verticalSpace(20.h),

                  // Checkbox 1: Terms
                  Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: Checkbox(
                          value: _acceptTerms,
                          activeColor: primaryOrange,
                          side: BorderSide(color: AppColorsTheme.borderColor(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Expanded(
                        child: Text(
                          'accept_terms'.tr,
                          style: TextStyle(
                            color: AppColorsTheme.textMainColor(context),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(12.h),

                  // Checkbox 2: Privacy Policy
                  Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: Checkbox(
                          value: _acceptPrivacy,
                          activeColor: primaryOrange,
                          side: BorderSide(color: AppColorsTheme.borderColor(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _acceptPrivacy = value ?? false;
                            });
                          },
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Expanded(
                        child: Text(
                          'accept_privacy'.tr,
                          style: TextStyle(
                            color: AppColorsTheme.textMainColor(context),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(28.h),

                  // Create Account Button
                  CustomButton(
                    onTap: _handleCreateAccount,
                    btnName: 'create_account'.tr,
                    isLoading: _isLoading,
                  ),
                  UIHelper.verticalSpace(24.h),

                  // Already have an account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'new_platform'.tr, // or 'Already have an account? '
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
