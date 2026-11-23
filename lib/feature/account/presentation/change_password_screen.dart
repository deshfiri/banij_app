import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../common_widget/custom_field_label.dart';
import '../../../common_widget/custom_password_field.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../../../providers/change_pass_provider.dart';
import '../../business/presentation/widgets/common/sub_screen_top_bar.dart';
import '../model/security_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SecurityModel? _securityModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<ChangePassProvider>().resetForm();
      } catch (_) {}
      _fetchSecurityRules();
    });
  }

  Future<void> _fetchSecurityRules() async {
    try {
      final res = await securityRxObj.fetchSecurityRules();
      if (mounted) {
        setState(() {
          _securityModel = res;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChangePassProvider>();
    final passwordRules = _securityModel?.data?.passwordRules;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            SubScreenTopBar(title: 'change_password'.tr),

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
                      UIHelper.verticalSpace(16.h),

                      // Password Rules Notice Card (from GET /security)
                      if (passwordRules != null && passwordRules.isNotEmpty) ...[
                        _PasswordRulesNotice(rules: passwordRules),
                        UIHelper.verticalSpace(20.h),
                      ],

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

/// Orange info banner showing the server's password rules.
class _PasswordRulesNotice extends StatelessWidget {
  final String rules;

  const _PasswordRulesNotice({required this.rules});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: primaryOrange, size: 20.sp),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Text(
              rules,
              style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMainColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
