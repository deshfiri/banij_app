import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textMain,
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

  void _handleCreateAccount() {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating account successfully...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              color: textMain,
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
    return Scaffold(
      backgroundColor: lightBackground,
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
                      logo,
                      width: 140.w,
                      height: 70.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  UIHelper.verticalSpace(5.h),
                  Text(
                    'Enter your details below to create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 1. Name
                  _buildFieldLabel('Name'),
                  CustomFormField(
                    controller: _nameController,
                    hintText: 'Full name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 2. Email address
                  _buildFieldLabel('Email address'),
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
                  _buildFieldLabel('Mobile number'),
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
                    'We send a verification code to this number.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 4. Password
                  _buildFieldLabel('Password'),
                  CustomFormField(
                    controller: _passwordController,
                    isPass: true,
                    isObsecure: _obscurePassword,
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: textMuted,
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
                  _buildFieldLabel('Confirm password'),
                  CustomFormField(
                    controller: _confirmPasswordController,
                    isPass: true,
                    isObsecure: _obscureConfirmPassword,
                    hintText: 'Confirm password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: textMuted,
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
                    'Optional — you can add these later',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 6. Date of birth
                  _buildFieldLabel('Date of birth'),
                  CustomFormField(
                    controller: _dobController,
                    isRead: true,
                    hintText: 'mm/dd/yyyy',
                    onTap: _selectDateOfBirth,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: textMuted,
                        size: 18.sp,
                      ),
                      onPressed: _selectDateOfBirth,
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 7. Gender Dropdown
                  _buildFieldLabel('Gender'),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: textMuted,
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
                                    color: textMain,
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
                  _buildFieldLabel('Country'),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountry,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: textMuted,
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
                                    color: textMain,
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
                  _buildFieldLabel('Nationality'),
                  CustomFormField(
                    controller: _nationalityController,
                    hintText: 'Bangladeshi',
                  ),
                  UIHelper.verticalSpace(16.h),

                  // 10. Partner code
                  _buildFieldLabel('Partner code'),
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
                          side: const BorderSide(color: cardBorderColor),
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
                          'I accept the terms and conditions',
                          style: TextStyle(
                            color: textMain,
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
                          side: const BorderSide(color: cardBorderColor),
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
                          'I accept the privacy policy',
                          style: TextStyle(
                            color: textMain,
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
                    btnName: 'Create account',
                  ),
                  UIHelper.verticalSpace(24.h),

                  // Already have an account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sign in',
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
