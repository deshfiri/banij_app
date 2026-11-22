import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/account_provider.dart';

/// "Are you sure you want to logout?" dialog; logs out on Yes.
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog._();

  static Future<void> show(BuildContext context) {
    // Read the provider from the caller's context before the dialog opens.
    final accountProvider = context.read<AccountProvider>();
    return showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmationDialog._(),
    ).then((confirmed) {
      // logout() navigates via NavigationService, so it is safe even if the
      // drawer that opened this dialog has already been closed/unmounted.
      // ignore: use_build_context_synchronously
      if (confirmed == true) accountProvider.logout(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r));
    final buttonPadding = EdgeInsets.symmetric(vertical: 12.h);
    final buttonText = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold);

    return AlertDialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      icon: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: errorRed.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.logout_rounded, color: errorRed, size: 26.sp),
      ),
      title: Text(
        'Are you sure you want to logout?'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w900,
          color: AppColorsTheme.textMainColor(context),
        ),
      ),
      content: Text(
        'You will need to sign in again to access your account and workspace.'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
      ),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  padding: buttonPadding,
                  shape: buttonShape,
                  side: BorderSide(color: AppColorsTheme.borderColor(context)),
                  foregroundColor: AppColorsTheme.textMainColor(context),
                ),
                child: Text('No'.tr, style: buttonText),
              ),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: buttonPadding,
                  shape: buttonShape,
                  elevation: 0,
                ),
                child: Text('Yes'.tr, style: buttonText),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
