import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../model/security_model.dart';
import 'account_ui.dart';

/// 2FA status (from the security API) and the change-password action.
class AccountSecuritySection extends StatelessWidget {
  final bool isLoading;
  final SecurityModel? securityModel;

  const AccountSecuritySection({super.key, required this.isLoading, required this.securityModel});

  @override
  Widget build(BuildContext context) {
    final data = securityModel?.data;

    return AccountSectionCard(
      title: 'security_heading'.tr,
      subtitle: 'security_desc'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const CircularProgressIndicator(color: primaryOrange),
              ),
            )
          else if (data != null) ...[
            _TwoFactorStatus(enabled: data.twoFactorEnabled ?? false, passwordRules: data.passwordRules),
            UIHelper.verticalSpace(12.h),
          ],
          AccountSettingTile(
            icon: Icons.lock_outline_rounded,
            title: 'change_password'.tr,
            subtitle: 'change_password_sub'.tr,
            onTap: () => Navigator.pushNamed(context, Routes.changePasswordScreen),
          ),
        ],
      ),
    );
  }
}

class _TwoFactorStatus extends StatelessWidget {
  final bool enabled;
  final String? passwordRules;

  const _TwoFactorStatus({required this.enabled, this.passwordRules});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = enabled ? successGreen : warningYellow;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(enabled ? Icons.verified_user_rounded : Icons.shield_outlined, size: 19.sp, color: color),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Text(
                  'Two-Factor Authentication (2FA)'.tr,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
              UIHelper.horizontalSpace(8.w),
              AccountStatusChip(label: (enabled ? 'Enabled' : 'Disabled').tr, color: color),
            ],
          ),
          if (passwordRules != null && passwordRules!.isNotEmpty) ...[
            UIHelper.verticalSpace(10.h),
            Text(
              '${'Password Rules'.tr}: $passwordRules',
              style: TextStyle(fontSize: 11.5.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
            ),
          ],
        ],
      ),
    );
  }
}
