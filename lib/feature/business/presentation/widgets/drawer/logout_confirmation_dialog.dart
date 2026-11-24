import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../providers/account_provider.dart';

/// "Are you sure you want to logout?" dialog; logs out on Yes.
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog._();

  static Future<void> show(BuildContext context) {
    // Read the provider before the dialog opens.
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
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 360;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.r),
    );
    final buttonPadding = EdgeInsets.symmetric(vertical: 14.h);
    final buttonText = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700);

    final cancelButton = OutlinedButton(
      onPressed: () => Navigator.pop(context, false),
      style: OutlinedButton.styleFrom(
        padding: buttonPadding,
        shape: buttonShape,
        side: BorderSide(color: AppColorsTheme.borderColor(context)),
        foregroundColor: AppColorsTheme.textMainColor(context),
      ),
      child: Text('No'.tr, style: buttonText),
    );
    final confirmButton = ElevatedButton.icon(
      onPressed: () => Navigator.pop(context, true),
      icon: Icon(Icons.logout_rounded, size: 17.sp),
      label: Text('Yes'.tr, style: buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: errorRed,
        foregroundColor: Colors.white,
        padding: buttonPadding,
        shape: buttonShape,
        elevation: 0,
      ),
    );

    return Dialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16.w : 24.w,
        vertical: 24.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(color: AppColorsTheme.borderColor(context)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: screenSize.height * 0.86,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    tooltip: 'No'.tr,
                    onPressed: () => Navigator.pop(context, false),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ],
              ),
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  color: errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: errorRed.withValues(alpha: 0.18)),
                ),
                child: Icon(Icons.logout_rounded, color: errorRed, size: 32.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                'Are you sure you want to logout?'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: errorRed.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: errorRed.withValues(alpha: 0.12)),
                ),
                child: Text(
                  'You will need to sign in again to access your account and workspace.'
                      .tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              if (isCompact) ...[
                SizedBox(width: double.infinity, child: cancelButton),
                SizedBox(height: 10.h),
                SizedBox(width: double.infinity, child: confirmButton),
              ] else
                Row(
                  children: [
                    Expanded(child: cancelButton),
                    SizedBox(width: 12.w),
                    Expanded(child: confirmButton),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
