import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common_widget/custom_button.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../dashboard/presentation/dashboard_screen.dart';
import '../register_screen/registerScreen.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing Sign In...'),
          backgroundColor: primaryOrange,
          duration: Duration(milliseconds: 800),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    }
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
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'Sign in to access your workspace and continue managing\nyour business.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                      height: 1.4,
                    ),
                  ),
                  UIHelper.verticalSpace(32.h),

                  // 2. Passkey Button
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.key, color: primaryOrange, size: 18.sp),
                    label: Text(
                      'Sign in with a passkey',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: cardBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 3. Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: cardBorderColor, thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'OR CONTINUE WITH EMAIL',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: cardBorderColor, thickness: 1),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 4. Email Input Field with Validation
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email address',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  CustomFormField(
                    controller: _emailController,
                    inputType: TextInputType.emailAddress,
                    hintText: 'Enter your email',
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
                        'Password',
                        style: TextStyle(
                          color: textMain,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forgot password?',
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
                    hintText: 'Enter your password',
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
                          side: const BorderSide(color: cardBorderColor),
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
                        'Remember me',
                        style: TextStyle(
                          color: textMain,
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
                    btnName: 'Sign in',
                  ),
                  UIHelper.verticalSpace(24.h),

                  // 8. Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to the platform? ',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Create an account',
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),
                  const Divider(color: cardBorderColor, thickness: 1),
                  UIHelper.verticalSpace(16.h),

                  // 9. Supplier Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Want to become a supplier? ',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Become a Supplier',
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(24.h),

                  // Language Switcher Icon
                  Center(
                    child: Icon(Icons.g_translate, color: textMuted, size: 20.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
