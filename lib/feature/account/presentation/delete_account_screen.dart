import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../common_widget/custom_field_label.dart';
import '../../../common_widget/custom_form_field.dart';
import '../../../common_widget/custom_password_field.dart';
import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/delete_account_provider.dart';
import '../../../providers/theme_provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<DeleteAccountProvider>().resetForm();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      context.read<DeleteAccountProvider>().resetForm();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final provider = context.watch<DeleteAccountProvider>();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE53935).withValues(alpha: 0.1),
                            border: Border.all(
                              color: const Color(0xFFE53935).withValues(alpha: 0.3),
                              width: 1.5.w,
                            ),
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 44.sp,
                            color: const Color(0xFFE53935),
                          ),
                        ),
                      ),
                      UIHelper.verticalSpace(24.h),
                      Text(
                        'Delete Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(8.h),
                      Text(
                        'Please enter your current password and reason for deleting your account. This action is permanent and cannot be undone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColorsTheme.textMutedColor(context),
                          height: 1.45,
                        ),
                      ),
                      UIHelper.verticalSpace(32.h),

                      // Current Password
                      CustomFieldLabel(label: 'Current Password', isRequired: true),
                      CustomPasswordField(
                        controller: provider.currentPasswordController,
                        hintText: 'Enter your password',
                        isObscure: provider.obscurePassword,
                        onToggleObscure: provider.toggleObscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      UIHelper.verticalSpace(20.h),

                      // Reason
                      CustomFieldLabel(label: 'Reason for leaving', isRequired: true),
                      CustomFormField(
                        controller: provider.reasonController,
                        maxline: 4,
                        hintText: 'Please tell us why you are leaving...',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a reason for account deletion';
                          }
                          return null;
                        },
                      ),
                      UIHelper.verticalSpace(32.h),

                      // Delete Button
                      CustomButton(
                        onTap: () async {
                          await provider.deleteAccount(context, _formKey);
                        },
                        btnName: 'Delete Account',
                        isLoading: provider.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
