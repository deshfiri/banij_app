import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../common_widget/custom_field_label.dart';
import '../../../common_widget/custom_password_field.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/change_pass_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangePassProvider>();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Back Icon
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColorsTheme.textMainColor(context),
                      size: 22.sp,
                    ),
                  ),
                  UIHelper.horizontalSpace(8.w),
                  Text(
                    'change_password'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Form Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'change_password_sub'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(24.h),

                      // Current Password Field
                      CustomFieldLabel(label: 'current_password'.tr, isRequired: true),
                      CustomPasswordField(
                        controller: provider.currentPasswordController,
                        hintText: 'enter_password'.tr,
                        isObscure: provider.isCurrentPassVisible,
                        onToggleObscure: provider.toggleCurrentPassword,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'err_enter_current_password'.tr;
                          }
                          return null;
                        },
                      ),
                      UIHelper.verticalSpace(16.h),

                      // New Password Field
                      CustomFieldLabel(label: 'new_password'.tr, isRequired: true),
                      CustomPasswordField(
                        controller: provider.newPasswordController,
                        hintText: 'create_password'.tr,
                        isObscure: provider.isNewPassVisible,
                        onToggleObscure: provider.toggleNewPassword,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'err_enter_new_password'.tr;
                          }
                          if (val.length < 6) {
                            return 'err_password_length'.tr;
                          }
                          return null;
                        },
                      ),
                      UIHelper.verticalSpace(16.h),

                      // Confirm New Password Field
                      CustomFieldLabel(label: 'confirm_new_password'.tr, isRequired: true),
                      CustomPasswordField(
                        controller: provider.confirmPasswordController,
                        hintText: 'confirm_password'.tr,
                        isObscure: provider.isConfirmPassVisible,
                        onToggleObscure: provider.toggleConfirmPassword,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'err_confirm_new_password'.tr;
                          }
                          if (val != provider.newPasswordController.text) {
                            return 'err_passwords_match'.tr;
                          }
                          return null;
                        },
                      ),
                      UIHelper.verticalSpace(32.h),

                      // Update Password Button
                      CustomButton(
                        onTap: () => provider.updatePassword(context, _formKey),
                        btnName: 'update_password'.tr,
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
