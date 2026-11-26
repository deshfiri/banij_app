import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/gradient_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import 'auth_components.dart';

/// Persistent two-button bottom navigation bar for auth and onboarding screens.
class AuthBottomNavigationBar extends StatelessWidget {
  final String? backLabel;
  final String continueLabel;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final bool isLoading;

  const AuthBottomNavigationBar({
    super.key,
    this.backLabel,
    required this.continueLabel,
    required this.onBack,
    required this.onContinue,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 10.r,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AuthOutlinedButton(
                label: (backLabel ?? 'back'.tr),
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              flex: 2,
              child: GradientButton(
                label: continueLabel,
                trailingIcon: Icons.arrow_forward_rounded,
                isLoading: isLoading,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
